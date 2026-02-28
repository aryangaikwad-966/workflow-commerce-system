package com.example.workflowcommerce.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.workflowcommerce.model.Order;
import com.example.workflowcommerce.model.Payment;
import com.example.workflowcommerce.repository.OrderRepository;
import com.example.workflowcommerce.repository.PaymentRepository;

@Service
public class PaymentService {

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private OrderRepository orderRepository;

    private final Random random = new Random();

    @Transactional
    public Payment processPayment(Order order, String paymentMethod) {
        // Simulate payment processing: 90% success, 10% failure
        boolean paymentSuccess = random.nextDouble() < 0.9;

        Payment payment = new Payment();
        payment.setOrder(order);
        payment.setAmount(order.getTotalAmount());
        payment.setPaymentMethod(paymentMethod);

        if (paymentSuccess) {
            payment.setPaymentStatus("Paid");
            // Update order status to Paid
            order.setOrderStatus("Paid");
            orderRepository.save(order);
        } else {
            payment.setPaymentStatus("Failed");
        }

        return paymentRepository.save(payment);
    }

    @Transactional
    public Payment refundPayment(Long paymentId) {
        Optional<Payment> paymentOpt = paymentRepository.findById(paymentId);
        
        if (paymentOpt.isEmpty()) {
            throw new RuntimeException("Payment not found");
        }

        Payment payment = paymentOpt.get();

        if (!"Paid".equals(payment.getPaymentStatus())) {
            throw new RuntimeException("Only paid payments can be refunded");
        }

        // Update payment status to Refunded
        payment.setPaymentStatus("Refunded");
        
        // Update order status to Cancelled
        Order order = payment.getOrder();
        order.setOrderStatus("Cancelled");
        orderRepository.save(order);

        return paymentRepository.save(payment);
    }

    public List<Payment> getAllPayments() {
        return paymentRepository.findAll();
    }

    public List<Payment> getPaymentsByStatus(String status) {
        return paymentRepository.findByPaymentStatus(status);
    }

    public Optional<Payment> getPaymentById(Long paymentId) {
        return paymentRepository.findById(paymentId);
    }

    public Optional<Payment> getPaymentByOrder(Order order) {
        return paymentRepository.findByOrder(order);
    }

    public List<Payment> getUserPayments(Long userId) {
        return paymentRepository.findByOrder_User_Id(userId);
    }

    public boolean hasPaymentForOrder(Order order) {
        return paymentRepository.existsByOrder(order);
    }
}
