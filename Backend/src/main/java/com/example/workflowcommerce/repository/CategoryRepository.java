package com.example.workflowcommerce.repository;

import com.example.workflowcommerce.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {
    Optional<Category> findByCategory_name(String category_name);
    boolean existsByCategory_name(String category_name);
}
