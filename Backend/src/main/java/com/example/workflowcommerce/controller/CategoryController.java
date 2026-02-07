package com.example.workflowcommerce.controller;

import com.example.workflowcommerce.model.Category;
import com.example.workflowcommerce.payload.response.MessageResponse;
import com.example.workflowcommerce.repository.CategoryRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    @Autowired
    CategoryRepository categoryRepository;

    @GetMapping
    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createCategory(@Valid @RequestBody Category category) {
        if (categoryRepository.existsByCategory_name(category.getCategory_name())) {
            return ResponseEntity.badRequest().body(new MessageResponse("Error: Category name already exists!"));
        }
        category.setStatus(true);
        categoryRepository.save(category);
        return ResponseEntity.ok(new MessageResponse("Category created successfully!"));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> updateCategory(@PathVariable Long id, @Valid @RequestBody Category categoryRequest) {
        return categoryRepository.findById(id).map(category -> {
            category.setCategory_name(categoryRequest.getCategory_name());
            category.setDescription(categoryRequest.getDescription());
            categoryRepository.save(category);
            return ResponseEntity.ok(new MessageResponse("Category updated successfully!"));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deactivateCategory(@PathVariable Long id) {
        return categoryRepository.findById(id).map(category -> {
            category.setStatus(false);
            categoryRepository.save(category);
            return ResponseEntity.ok(new MessageResponse("Category deactivated successfully!"));
        }).orElse(ResponseEntity.notFound().build());
    }
}
