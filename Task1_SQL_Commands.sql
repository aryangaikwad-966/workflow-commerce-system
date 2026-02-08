-- ==========================================================
-- SQL Commands for Task 1: Foundation & Category Management
-- ==========================================================

-- 1. DATABASE SELECTION
USE workflow_commerce;

-- 2. VERIFY ROLES & USERS
-- Check if default roles (USER, ADMIN) exist
SELECT * FROM roles;

-- List all registered users
SELECT id, username, email FROM users;

-- View user roles (Admin vs User assignments)
SELECT u.username, r.name 
FROM users u 
JOIN user_roles ur ON u.id = ur.user_id 
JOIN roles r ON ur.role_id = r.id;

-- 3. CATEGORY MANAGEMENT (CORE TASK)
-- List all categories with status information
SELECT category_id, category_name, description, status FROM categories;

-- View only active categories
SELECT * FROM categories WHERE status = 1;

-- View soft-deleted (inactive) categories
SELECT * FROM categories WHERE status = 0;

-- 4. SAMPLE DATA (OPTIONAL)
-- Use these to manually seed categories if needed
INSERT INTO categories (category_name, description, status, created_at, updated_at) 
VALUES ('Electronics', 'Smartphones, Laptops, etc.', 1, NOW(), NOW());

INSERT INTO categories (category_name, description, status, created_at, updated_at) 
VALUES ('Fashion', 'Clothing and Accessories', 1, NOW(), NOW());

-- 5. PRODUCTS (To support category product count)
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category_id BIGINT,
    created_at DATETIME,
    updated_at DATETIME,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 6. TROUBLESHOOTING
-- Manually reset a user's password to 'admin123'
-- UPDATE users SET password = '$2a$10$7.P0O6i3O/iG8f.v0xM7yeA9U0S9kL0j000000000000000000000' WHERE username = 'admin';

-- Manually reactivate a category
-- UPDATE categories SET status = 1 WHERE category_id = 1;
