package com.example.workflowcommerce.controller;

import com.example.workflowcommerce.dto.CouponApplyRequest;
import com.example.workflowcommerce.dto.CouponApplyResponse;
import com.example.workflowcommerce.dto.CouponCreateRequest;
import com.example.workflowcommerce.model.Coupon;
import com.example.workflowcommerce.service.CouponService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/coupons")
public class CouponController {

    @Autowired
    private CouponService couponService;

    @PostMapping("/create")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createCoupon(@RequestBody CouponCreateRequest request) {
        try {
            Coupon coupon = couponService.createCoupon(request);
            return ResponseEntity.ok(coupon);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/update/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateCoupon(@PathVariable Long id, @RequestBody CouponCreateRequest request) {
        try {
            Coupon coupon = couponService.updateCoupon(id, request);
            return ResponseEntity.ok(coupon);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/deactivate/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deactivateCoupon(@PathVariable Long id) {
        try {
            Coupon coupon = couponService.deactivateCoupon(id);
            return ResponseEntity.ok(coupon);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Coupon>> getAllCoupons() {
        return ResponseEntity.ok(couponService.getAllCoupons());
    }

    @PostMapping("/apply")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<?> applyCoupon(@RequestBody CouponApplyRequest request) {
        try {
            CouponApplyResponse response = couponService.applyCoupon(request.getCouponCode(), request.getCartTotal());
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
