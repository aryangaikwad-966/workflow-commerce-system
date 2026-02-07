package com.example.workflowcommerce.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "categories", uniqueConstraints = {
    @UniqueConstraint(columnNames = "category_name")
})
@Data
@NoArgsConstructor
public class Category {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long category_id;

    @NotBlank
    @Size(max = 100)
    @Column(name = "category_name", nullable = false)
    private String category_name;

    @Size(max = 300)
    private String description;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime created_at;

    @UpdateTimestamp
    private LocalDateTime updated_at;

    private boolean status = true; // true = active, false = inactive (soft delete)

    public Category(String category_name, String description) {
        this.category_name = category_name;
        this.description = description;
        this.status = true;
    }
}
