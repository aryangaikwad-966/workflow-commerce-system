package com.example.workflowcommerce.payload.request;

import java.util.List;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class OrderRequest {
    
    @NotNull
    private List<OrderItemRequest> items;
    
    @NotBlank
    @Size(max = 300)
    private String shippingAddress;

    // Getters and Setters
    public List<OrderItemRequest> getItems() { return items; }
    public void setItems(List<OrderItemRequest> items) { this.items = items; }
    
    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }
}
