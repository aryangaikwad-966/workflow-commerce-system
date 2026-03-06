package com.example.workflowcommerce.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.workflowcommerce.dto.ShippingCreateRequest;
import com.example.workflowcommerce.dto.ShippingResponse;
import com.example.workflowcommerce.event.OrderDeliveredEvent;
import com.example.workflowcommerce.event.ShippingCreatedEvent;
import com.example.workflowcommerce.model.Order;
import com.example.workflowcommerce.model.Shipping;
import com.example.workflowcommerce.repository.OrderRepository;
import com.example.workflowcommerce.repository.ShippingRepository;

@Service
public class ShippingService {

    @Autowired
    private ShippingRepository shippingRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private ApplicationEventPublisher eventPublisher;

    // Allowed values: Shipped, In Transit, Delivered
    public static final String STATUS_SHIPPED = "Shipped";
    public static final String STATUS_IN_TRANSIT = "In Transit";
    public static final String STATUS_DELIVERED = "Delivered";

    public BigDecimal calculateShippingCost(String shippingMethod, String destination) {
        BigDecimal cost = new BigDecimal("10.00"); // Base cost
        if ("Express".equalsIgnoreCase(shippingMethod)) {
            cost = cost.add(new BigDecimal("15.00"));
        }
        return cost;
    }

    @Transactional
    public ShippingResponse createShipping(Long orderId, ShippingCreateRequest request) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found with id: " + orderId));

        // Order must be paid (Paid) or in processing state (Processing)
        String status = order.getOrderStatus();
        if (!"Paid".equalsIgnoreCase(status) && !"Processing".equalsIgnoreCase(status)) {
            throw new RuntimeException("Cannot ship order. Order must be Paid or Processing. Current status: " + status);
        }

        if (shippingRepository.existsByOrderOrderId(orderId)) {
            throw new RuntimeException("Shipping already created for this order.");
        }

        Shipping shipping = new Shipping();
        shipping.setOrder(order);
        shipping.setCourierService(request.getCourierService());
        shipping.setTrackingNumber(request.getTrackingNumber());
        shipping.setShippingMethod(request.getShippingMethod());
        
        // Simple logic: base shipping cost plus some variation
        shipping.setShippingCost(calculateShippingCost(request.getShippingMethod(), order.getShippingAddress()));
        
        shipping.setShippingStatus(STATUS_SHIPPED);

        shippingRepository.save(shipping);

        // Update Order Status to "Shipped"
        order.setOrderStatus("Shipped");
        orderRepository.save(order);

        // Publish event - workflow transition will happen AFTER this transaction commits
        eventPublisher.publishEvent(new ShippingCreatedEvent(this, orderId, request.getTrackingNumber()));

        return new ShippingResponse(shipping);
    }

    @Transactional
    public ShippingResponse updateShippingStatus(Long shippingId, String newStatus) {
        Shipping shipping = shippingRepository.findById(shippingId)
                .orElseThrow(() -> new RuntimeException("Shipping not found with id: " + shippingId));

        String currentStatus = shipping.getShippingStatus();

        if (STATUS_DELIVERED.equals(currentStatus)) {
            throw new RuntimeException("Cannot edit shipping once Delivered");
        }

        // Strictly enforce sequential transitions: Shipped -> In Transit -> Delivered
        if (STATUS_IN_TRANSIT.equals(newStatus)) {
            // Can only go to In Transit from Shipped
            if (!STATUS_SHIPPED.equals(currentStatus)) {
                throw new RuntimeException("Cannot transition to 'In Transit'. Current status must be 'Shipped'. Current: " + currentStatus);
            }
        } else if (STATUS_DELIVERED.equals(newStatus)) {
            // Can only go to Delivered from In Transit (enforce no skipping)
            if (!STATUS_IN_TRANSIT.equals(currentStatus)) {
                throw new RuntimeException("Cannot skip 'In Transit' stage. Must go Shipped -> In Transit -> Delivered. Current: " + currentStatus);
            }
        }

        if (!STATUS_SHIPPED.equals(newStatus) && !STATUS_IN_TRANSIT.equals(newStatus) && !STATUS_DELIVERED.equals(newStatus)) {
             throw new RuntimeException("Invalid shipping status: " + newStatus);
        }

        shipping.setShippingStatus(newStatus);
        
        Order order = shipping.getOrder();
        if (STATUS_DELIVERED.equals(newStatus)) {
            order.setOrderStatus("Delivered");
            orderRepository.save(order);
            
            // Publish event - workflow transition will happen AFTER this transaction commits
            eventPublisher.publishEvent(new OrderDeliveredEvent(this, order.getOrderId()));
        }

        return new ShippingResponse(shippingRepository.save(shipping));
    }

    public List<ShippingResponse> getAllShippings() {
        return shippingRepository.findAll().stream()
                .map(ShippingResponse::new)
                .collect(Collectors.toList());
    }

    public ShippingResponse getShippingByOrderId(Long orderId, String username) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found with id: " + orderId));
        
        // Verify ownership
        if (!order.getUser().getUsername().equals(username)) {
            throw new RuntimeException("Unauthorized: Cannot view shipping of another user");
        }

        Shipping shipping = shippingRepository.findByOrderOrderId(orderId)
                .orElseThrow(() -> new RuntimeException("Shipping not found for order id: " + orderId));

        return new ShippingResponse(shipping);
    }
}
