-- ============================================================================
-- FlowForge - Complete SQL Database Schema & Commands
-- ============================================================================
-- A comprehensive SQL script containing all database commands for the
-- FlowForge Workflow Orchestration Engine
-- 
-- This file consolidates all task-specific SQL files into a single reference.
-- Execute sections in order for fresh database setup.
-- ============================================================================

-- ############################################################################
-- SECTION 1: DATABASE CREATION & CATEGORY MANAGEMENT
-- ############################################################################

DROP DATABASE IF EXISTS workflow_commerce;
CREATE DATABASE workflow_commerce;
USE workflow_commerce;

-- ----------------------------------------------------------------------------
-- 1.1 Create categories table
-- ----------------------------------------------------------------------------
CREATE TABLE categories (
    category_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(300),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status BOOLEAN DEFAULT TRUE
);

-- 1.2 Insert sample category data
INSERT INTO categories (category_name, description, status) 
VALUES 
('Electronics', 'High-end computing and consumer gadgets', 1),
('Apparel', 'Traditional and modern professional wear', 1),
('Logistics', 'Internal supply chain equipment', 0);

-- 1.3 Update category example
UPDATE categories 
SET category_name = 'Computing Hardware', updated_at = NOW() 
WHERE category_id = 1;

-- 1.4 Soft delete category (status = false)
UPDATE categories 
SET status = 0, updated_at = NOW() 
WHERE category_id = 2;

-- 1.5 Select active categories
SELECT * FROM categories WHERE status = 1 ORDER BY category_name ASC;

-- 1.6 Select all categories (admin view)
SELECT category_id, category_name, description, status, created_at FROM categories;


-- ############################################################################
-- SECTION 2: USER & ROLE MANAGEMENT
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 2.1 Create roles table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL UNIQUE
);

-- 2.2 Insert default roles
INSERT INTO roles (name) VALUES ('ROLE_USER'), ('ROLE_ADMIN');

-- ----------------------------------------------------------------------------
-- 2.3 Create users table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(120) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone_number VARCHAR(20),
    status TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 2.4 Create user_roles junction table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- 2.5 Create admin user (password: admin123)
INSERT INTO users (username, email, password, first_name, last_name, phone_number, status, created_at) 
VALUES ('admin', 'admin@test.com', '$2a$10$WbspULzqno53UEVNJDSy4ur3usqP8Owh1JQKQyy2uAACW5U3aYH/u', 
        'Admin', 'User', '9876543210', 1, NOW());

-- 2.6 Assign admin role
INSERT INTO user_roles (user_id, role_id)
VALUES ((SELECT id FROM users WHERE username = 'admin'), 
        (SELECT id FROM roles WHERE name = 'ROLE_ADMIN'));

-- 2.7 Create regular user (password: user123)
INSERT INTO users (username, email, password, first_name, last_name, phone_number, status, created_at) 
VALUES ('user', 'user@test.com', '$2a$10$N9qo8uLOogjWLX.x0sX.h.Z3Q5Uj6x5BVBz6W8qQ8hOJPq9hXyCzW', 
        'Test', 'User', '9123456789', 1, NOW());

INSERT INTO user_roles (user_id, role_id)
VALUES ((SELECT id FROM users WHERE username = 'user'), 
        (SELECT id FROM roles WHERE name = 'ROLE_USER'));

-- 2.8 Verify users
SELECT id, username, email, first_name, last_name, phone_number, status, created_at, updated_at 
FROM users;

-- 2.9 Check order counts per user (for dashboard)
SELECT 
    u.id,
    u.username,
    u.email,
    COUNT(o.order_id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username, u.email;

-- 2.10 Deactivate/Reactivate user examples
-- UPDATE users SET status = 0, updated_at = NOW() WHERE id = 2;  -- Deactivate
-- UPDATE users SET status = 1, updated_at = NOW() WHERE id = 2;  -- Reactivate


-- ############################################################################
-- SECTION 3: PRODUCT MANAGEMENT
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 3.1 Create products table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS products (
    product_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    description VARCHAR(500),
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    sku VARCHAR(50) NOT NULL UNIQUE,
    category_id BIGINT NOT NULL,
    inventory_count INT NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    INDEX idx_sku (sku),
    INDEX idx_category (category_id),
    INDEX idx_status (status)
);

-- 3.2 Insert sample product data
INSERT INTO products (product_name, description, price, sku, category_id, inventory_count, status) 
VALUES 
('Laptop Pro 15"', 'High-performance laptop with 16GB RAM and 512GB SSD', 1299.99, 'LP-15-001', 1, 50, 1),
('Wireless Mouse', 'Ergonomic wireless mouse with USB-C charging', 29.99, 'WM-001', 1, 200, 1),
('Business Shirt', 'Premium cotton business shirt', 49.99, 'BS-001', 2, 100, 1),
('Forklift', 'Industrial forklift for warehouse operations', 15000.00, 'FL-001', 3, 5, 0);

-- 3.3 Select all products with category (admin view)
SELECT 
    p.product_id,
    p.product_name,
    p.description,
    p.price,
    p.sku,
    p.category_id,
    c.category_name,
    p.inventory_count,
    p.status,
    p.created_at,
    p.updated_at
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
ORDER BY p.product_name;

-- 3.4 Select active products only
SELECT 
    p.product_id,
    p.product_name,
    p.description,
    p.price,
    p.sku,
    c.category_name,
    p.inventory_count
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
WHERE p.status = 1
ORDER BY p.product_name;

-- 3.5 Update product
UPDATE products 
SET price = 1199.99, inventory_count = 45, updated_at = NOW() 
WHERE product_id = 1;

-- 3.6 Soft delete product
UPDATE products 
SET status = 0, updated_at = NOW() 
WHERE product_id = 1;

-- 3.7 Count products by category
SELECT 
    c.category_name,
    COUNT(p.product_id) as product_count
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id AND p.status = 1
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;


-- ############################################################################
-- SECTION 4: ORDER MANAGEMENT
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 4.1 Create orders table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    shipping_address VARCHAR(300) NOT NULL,
    order_status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    workflow_instance_id BIGINT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_order_status (order_status),
    INDEX idx_created_at (created_at),
    INDEX idx_order_workflow (workflow_instance_id)
);

-- ----------------------------------------------------------------------------
-- 4.2 Create order_items table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price_at_purchase DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
);

-- 4.3 Insert sample order data
INSERT INTO orders (user_id, total_amount, shipping_address, order_status, status) 
VALUES 
(1, 2599.98, '123 Main St, City, State 12345', 'Pending', 1),
(2, 149.99, '456 Oak Ave, Town, State 67890', 'Shipped', 1),
(1, 49.99, '789 Pine Rd, Village, State 11111', 'Delivered', 1);

-- 4.4 Insert sample order_items data
INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) 
VALUES 
(1, 1, 1, 1299.99),
(1, 3, 1, 49.99),
(2, 1, 2, 1299.99),
(3, 3, 1, 49.99);

-- 4.5 Select all orders (admin view)
SELECT 
    o.order_id,
    u.username,
    o.total_amount,
    o.shipping_address,
    o.order_status,
    o.created_at,
    o.updated_at,
    o.status
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
ORDER BY o.created_at DESC;

-- 4.6 Select orders by status (admin filter)
SELECT 
    o.order_id,
    u.username,
    o.total_amount,
    o.shipping_address,
    o.order_status,
    o.created_at
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
WHERE o.order_status = 'Pending' AND o.status = 1
ORDER BY o.created_at DESC;

-- 4.7 Select user orders (customer view)
SELECT 
    o.order_id,
    o.total_amount,
    o.shipping_address,
    o.order_status,
    o.created_at,
    COUNT(oi.id) as item_count
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.user_id = 1 AND o.status = 1
GROUP BY o.order_id
ORDER BY o.created_at DESC;

-- 4.8 Select order details with items
SELECT 
    o.order_id,
    o.total_amount,
    o.shipping_address,
    o.order_status,
    o.created_at,
    p.product_name,
    p.sku,
    oi.quantity,
    oi.price_at_purchase,
    (oi.quantity * oi.price_at_purchase) as item_total
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE o.order_id = 1
ORDER BY oi.id;

-- 4.9 Update order status (admin action)
UPDATE orders 
SET order_status = 'Shipped', updated_at = NOW() 
WHERE order_id = 2;

-- 4.10 Cancel order (customer action)
UPDATE orders 
SET order_status = 'Cancelled', status = 0, updated_at = NOW() 
WHERE order_id = 1 AND order_status = 'Pending';

-- 4.11 Order statistics by status
SELECT 
    order_status,
    COUNT(*) as order_count,
    SUM(total_amount) as total_revenue
FROM orders 
WHERE status = 1
GROUP BY order_status
ORDER BY order_status;


-- ############################################################################
-- SECTION 5: PAYMENT MANAGEMENT
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 5.1 Create payments table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS payments (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(50) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    INDEX idx_payment_order (order_id),
    INDEX idx_payment_status (payment_status)
);

-- 5.2 Verify table creation
SHOW COLUMNS FROM payments;

-- 5.3 Check existing orders that can be paid
SELECT order_id, user_id, total_amount, order_status, created_at
FROM orders 
WHERE order_status = 'Pending';

-- 5.4 Get all payments with customer info
SELECT 
    p.payment_id,
    p.order_id,
    u.username as customer_name,
    p.amount,
    p.payment_method,
    p.payment_status,
    p.created_at
FROM payments p
JOIN orders o ON p.order_id = o.order_id
JOIN users u ON o.user_id = u.id;

-- 5.5 Get payments by status
SELECT * FROM payments WHERE payment_status = 'COMPLETED';
SELECT * FROM payments WHERE payment_status = 'FAILED';
SELECT * FROM payments WHERE payment_status = 'REFUNDED';

-- 5.6 Count payments by status
SELECT 
    payment_status,
    COUNT(*) as count,
    SUM(amount) as total_amount
FROM payments
GROUP BY payment_status;

-- 5.7 Manual refund (if needed via SQL)
-- UPDATE payments 
-- SET payment_status = 'REFUNDED', updated_at = NOW() 
-- WHERE payment_id = 1;

-- UPDATE orders 
-- SET order_status = 'Refunded', updated_at = NOW() 
-- WHERE order_id = (SELECT order_id FROM payments WHERE payment_id = 1);


-- ############################################################################
-- SECTION 6: CART MANAGEMENT
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 6.1 Create carts table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS carts (
    cart_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_cart_customer (customer_id)
);

-- ----------------------------------------------------------------------------
-- 6.2 Create cart_items table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cart_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cart_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY uk_cart_product (cart_id, product_id)
);

-- 6.3 Verify table creation
SHOW COLUMNS FROM carts;
SHOW COLUMNS FROM cart_items;

-- 6.4 Check existing products with inventory
SELECT product_id, product_name, inventory_count, price, status
FROM products 
WHERE status = 1 AND inventory_count > 0;

-- 6.5 Get all carts with customer info
SELECT 
    c.cart_id,
    u.username as customer_name,
    c.created_at,
    c.updated_at
FROM carts c
JOIN users u ON c.customer_id = u.id;

-- 6.6 Get cart items with product details
SELECT 
    ci.id,
    c.cart_id,
    p.product_name,
    ci.quantity,
    ci.total_price
FROM cart_items ci
JOIN carts c ON ci.cart_id = c.cart_id
JOIN products p ON ci.product_id = p.product_id;

-- 6.7 Get cart statistics
SELECT 
    c.cart_id,
    u.username as customer_name,
    COUNT(ci.id) as item_count,
    COALESCE(SUM(ci.total_price), 0) as total_value
FROM carts c
JOIN users u ON c.customer_id = u.id
LEFT JOIN cart_items ci ON c.cart_id = ci.cart_id
GROUP BY c.cart_id, u.username;


-- ############################################################################
-- SECTION 7: WISHLIST MANAGEMENT
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 7.1 Create wishlists table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wishlists (
    wishlist_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_wishlist_customer (customer_id),
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 7.2 Create wishlist_items table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wishlist_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    wishlist_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_wishlist_product (wishlist_id, product_id),
    FOREIGN KEY (wishlist_id) REFERENCES wishlists(wishlist_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- 7.3 Verify table creation
SHOW COLUMNS FROM wishlists;
SHOW COLUMNS FROM wishlist_items;

-- 7.4 Get all wishlists with customer info
SELECT 
    w.wishlist_id,
    u.username as customer_name,
    w.created_at,
    w.updated_at
FROM wishlists w
JOIN users u ON w.customer_id = u.id;

-- 7.5 Get wishlist items with product details
SELECT 
    wi.id,
    w.wishlist_id,
    p.product_name,
    p.price,
    p.inventory_count,
    wi.created_at as added_at
FROM wishlist_items wi
JOIN wishlists w ON wi.wishlist_id = w.wishlist_id
JOIN products p ON wi.product_id = p.product_id;

-- 7.6 Get wishlist statistics
SELECT 
    w.wishlist_id,
    u.username as customer_name,
    COUNT(wi.id) as item_count
FROM wishlists w
JOIN users u ON w.customer_id = u.id
LEFT JOIN wishlist_items wi ON w.wishlist_id = wi.wishlist_id
GROUP BY w.wishlist_id, u.username;


-- ############################################################################
-- SECTION 8: SHIPPING MANAGEMENT
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 8.1 Create shipping table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS shipping (
    shipping_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    courier_service VARCHAR(100) NOT NULL,
    tracking_number VARCHAR(100) NOT NULL,
    shipping_status VARCHAR(50) NOT NULL,
    shipping_method VARCHAR(50) NOT NULL,
    shipping_cost DECIMAL(10,2) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_shipping_order (order_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    INDEX idx_shipping_status (shipping_status),
    INDEX idx_tracking (tracking_number)
);

-- 8.2 Verify table creation
SHOW COLUMNS FROM shipping;

-- 8.3 Get all shipments with order info
SELECT 
    s.shipping_id,
    s.order_id,
    u.username as customer_name,
    s.courier_service,
    s.tracking_number,
    s.shipping_status,
    s.shipping_method,
    s.shipping_cost,
    s.created_at
FROM shipping s
JOIN orders o ON s.order_id = o.order_id
JOIN users u ON o.user_id = u.id
ORDER BY s.created_at DESC;


-- ############################################################################
-- SECTION 9: REVIEW & RATING MANAGEMENT
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 9.1 Create reviews table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS reviews (
    review_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text VARCHAR(1000),
    status BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_review_product_customer (product_id, customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_review_product (product_id),
    INDEX idx_review_rating (rating),
    INDEX idx_review_status (status)
);

-- 9.2 Verify table creation
SHOW COLUMNS FROM reviews;

-- 9.3 Get product reviews with customer info
SELECT 
    r.review_id,
    p.product_name,
    u.username as reviewer,
    r.rating,
    r.review_text,
    r.status as approved,
    r.created_at
FROM reviews r
JOIN products p ON r.product_id = p.product_id
JOIN users u ON r.customer_id = u.id
ORDER BY r.created_at DESC;

-- 9.4 Get average rating per product
SELECT 
    p.product_id,
    p.product_name,
    AVG(r.rating) as avg_rating,
    COUNT(r.review_id) as review_count
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id AND r.status = 1
GROUP BY p.product_id, p.product_name
ORDER BY avg_rating DESC;


-- ############################################################################
-- SECTION 10: COUPON & DISCOUNT MANAGEMENT
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 10.1 Create coupons table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS coupons (
    coupon_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    coupon_code VARCHAR(50) NOT NULL UNIQUE,
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('Percentage', 'Fixed')),
    discount_value DECIMAL(10,2) NOT NULL CHECK (discount_value > 0),
    min_order_amount DECIMAL(10,2),
    valid_from DATETIME NOT NULL,
    valid_to DATETIME NOT NULL,
    usage_limit INT NOT NULL CHECK (usage_limit > 0),
    usage_count INT DEFAULT 0,
    status BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_discount_logic CHECK (
        (discount_type = 'Fixed') OR 
        (discount_type = 'Percentage' AND discount_value <= 100)
    ),
    CONSTRAINT chk_valid_dates CHECK (valid_to > valid_from),
    CONSTRAINT chk_usage_count CHECK (usage_count <= usage_limit),
    INDEX idx_coupon_code (coupon_code),
    INDEX idx_coupon_status (status),
    INDEX idx_coupon_validity (valid_from, valid_to)
);

-- 10.2 Verify table creation
SHOW COLUMNS FROM coupons;

-- 10.3 Insert sample coupons
INSERT INTO coupons (coupon_code, discount_type, discount_value, min_order_amount, valid_from, valid_to, usage_limit, status)
VALUES 
('WELCOME10', 'Percentage', 10.00, 50.00, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 100, 1),
('FLAT50', 'Fixed', 50.00, 200.00, NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY), 50, 1),
('SUMMER25', 'Percentage', 25.00, 100.00, NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY), 200, 1);

-- 10.4 Get active valid coupons
SELECT 
    coupon_id,
    coupon_code,
    discount_type,
    discount_value,
    min_order_amount,
    valid_from,
    valid_to,
    usage_limit,
    usage_count,
    (usage_limit - usage_count) as remaining_uses
FROM coupons
WHERE status = 1 
  AND valid_from <= NOW() 
  AND valid_to >= NOW()
  AND usage_count < usage_limit;


-- ############################################################################
-- SECTION 11: WORKFLOW ENGINE TABLES
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 11.1 Create workflow_definitions table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS workflow_definitions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    entity_type VARCHAR(50) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_workflow_name (name),
    INDEX idx_workflow_entity_type (entity_type),
    INDEX idx_workflow_active (active)
);

-- ----------------------------------------------------------------------------
-- 11.2 Create workflow_states table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS workflow_states (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    workflow_id BIGINT NOT NULL,
    state_name VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    is_initial BOOLEAN DEFAULT FALSE,
    is_terminal BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    color_code VARCHAR(7),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_workflow_state (workflow_id, state_name),
    FOREIGN KEY (workflow_id) REFERENCES workflow_definitions(id) ON DELETE CASCADE,
    INDEX idx_state_workflow (workflow_id),
    INDEX idx_state_initial (is_initial),
    INDEX idx_state_terminal (is_terminal)
);

-- ----------------------------------------------------------------------------
-- 11.3 Create workflow_transitions table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS workflow_transitions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    workflow_id BIGINT NOT NULL,
    from_state_id BIGINT NOT NULL,
    to_state_id BIGINT NOT NULL,
    allowed_roles VARCHAR(100) NOT NULL,
    action_name VARCHAR(200),
    description VARCHAR(500),
    requires_comment BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (workflow_id) REFERENCES workflow_definitions(id) ON DELETE CASCADE,
    FOREIGN KEY (from_state_id) REFERENCES workflow_states(id) ON DELETE CASCADE,
    FOREIGN KEY (to_state_id) REFERENCES workflow_states(id) ON DELETE CASCADE,
    INDEX idx_transition_workflow (workflow_id),
    INDEX idx_transition_from_state (from_state_id),
    INDEX idx_transition_to_state (to_state_id)
);

-- ----------------------------------------------------------------------------
-- 11.4 Create workflow_instances table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS workflow_instances (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    workflow_id BIGINT NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id BIGINT NOT NULL,
    current_state_id BIGINT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    created_by VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at DATETIME,
    FOREIGN KEY (workflow_id) REFERENCES workflow_definitions(id),
    FOREIGN KEY (current_state_id) REFERENCES workflow_states(id),
    INDEX idx_instance_workflow (workflow_id),
    INDEX idx_instance_entity (entity_type, entity_id),
    INDEX idx_instance_state (current_state_id),
    INDEX idx_instance_created (created_at),
    INDEX idx_instance_completed (is_completed)
);

-- ----------------------------------------------------------------------------
-- 11.5 Create workflow_logs table (Audit Trail)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS workflow_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    workflow_instance_id BIGINT NOT NULL,
    from_state_id BIGINT,
    to_state_id BIGINT NOT NULL,
    performed_by VARCHAR(50) NOT NULL,
    performed_role VARCHAR(50),
    action_name VARCHAR(100),
    comment VARCHAR(500),
    ip_address VARCHAR(50),
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (workflow_instance_id) REFERENCES workflow_instances(id) ON DELETE CASCADE,
    FOREIGN KEY (from_state_id) REFERENCES workflow_states(id),
    FOREIGN KEY (to_state_id) REFERENCES workflow_states(id),
    INDEX idx_log_instance (workflow_instance_id),
    INDEX idx_log_timestamp (timestamp),
    INDEX idx_log_actor (performed_by)
);


-- ############################################################################
-- SECTION 12: WORKFLOW DATA INITIALIZATION
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 12.1 Insert Order Lifecycle Workflow Definition
-- ----------------------------------------------------------------------------
INSERT INTO workflow_definitions (name, description, entity_type, active)
VALUES ('OrderLifecycleWorkflow', 
        'Manages the complete lifecycle of customer orders from creation to delivery or cancellation', 
        'ORDER', 
        TRUE);

SET @order_workflow_id = LAST_INSERT_ID();

-- 12.2 Insert Order Workflow States
INSERT INTO workflow_states (workflow_id, state_name, description, is_initial, is_terminal, display_order, color_code)
VALUES 
(@order_workflow_id, 'CREATED', 'Order has been created and is awaiting payment', TRUE, FALSE, 1, '#6c757d'),
(@order_workflow_id, 'PAYMENT_PENDING', 'Waiting for payment confirmation', FALSE, FALSE, 2, '#ffc107'),
(@order_workflow_id, 'PAID', 'Payment has been received and confirmed', FALSE, FALSE, 3, '#17a2b8'),
(@order_workflow_id, 'PROCESSING', 'Order is being processed and prepared', FALSE, FALSE, 4, '#007bff'),
(@order_workflow_id, 'SHIPPED', 'Order has been shipped to customer', FALSE, FALSE, 5, '#6610f2'),
(@order_workflow_id, 'DELIVERED', 'Order has been delivered successfully', FALSE, TRUE, 6, '#28a745'),
(@order_workflow_id, 'CANCELLED', 'Order has been cancelled', FALSE, TRUE, 7, '#dc3545'),
(@order_workflow_id, 'REFUNDED', 'Order has been refunded', FALSE, TRUE, 8, '#e83e8c');

-- 12.3 Get state IDs for transitions
SET @state_created = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'CREATED');
SET @state_payment_pending = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'PAYMENT_PENDING');
SET @state_paid = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'PAID');
SET @state_processing = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'PROCESSING');
SET @state_shipped = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'SHIPPED');
SET @state_delivered = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'DELIVERED');
SET @state_cancelled = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'CANCELLED');
SET @state_refunded = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'REFUNDED');

-- 12.4 Insert Order Workflow Transitions
INSERT INTO workflow_transitions (workflow_id, from_state_id, to_state_id, allowed_roles, action_name, description, requires_comment)
VALUES 
-- From CREATED
(@order_workflow_id, @state_created, @state_payment_pending, 'ROLE_USER,ROLE_ADMIN,SYSTEM', 'Initiate Payment', 'Move order to payment pending state', FALSE),
(@order_workflow_id, @state_created, @state_cancelled, 'ROLE_USER,ROLE_ADMIN', 'Cancel Order', 'Cancel the order before payment', FALSE),

-- From PAYMENT_PENDING
(@order_workflow_id, @state_payment_pending, @state_paid, 'SYSTEM,ROLE_ADMIN', 'Confirm Payment', 'Payment has been verified and confirmed', FALSE),
(@order_workflow_id, @state_payment_pending, @state_cancelled, 'ROLE_USER,ROLE_ADMIN', 'Cancel Order', 'Cancel order due to payment failure or customer request', TRUE),

-- From PAID
(@order_workflow_id, @state_paid, @state_processing, 'ROLE_ADMIN,SYSTEM', 'Start Processing', 'Begin order processing and preparation', FALSE),
(@order_workflow_id, @state_paid, @state_refunded, 'ROLE_ADMIN', 'Refund Order', 'Issue full refund for the order', TRUE),

-- From PROCESSING
(@order_workflow_id, @state_processing, @state_shipped, 'ROLE_ADMIN', 'Ship Order', 'Order has been shipped to carrier', FALSE),
(@order_workflow_id, @state_processing, @state_refunded, 'ROLE_ADMIN', 'Refund Order', 'Issue refund during processing', TRUE),

-- From SHIPPED
(@order_workflow_id, @state_shipped, @state_delivered, 'ROLE_ADMIN,SYSTEM', 'Mark Delivered', 'Confirm order delivery to customer', FALSE),
(@order_workflow_id, @state_shipped, @state_refunded, 'ROLE_ADMIN', 'Refund Order', 'Issue refund for shipped order', TRUE);

-- ----------------------------------------------------------------------------
-- 12.5 Insert Payment Workflow Definition
-- ----------------------------------------------------------------------------
INSERT INTO workflow_definitions (name, description, entity_type, active)
VALUES ('PaymentWorkflow', 'Tracks payment processing status', 'PAYMENT', TRUE);

SET @payment_workflow_id = LAST_INSERT_ID();

INSERT INTO workflow_states (workflow_id, state_name, description, is_initial, is_terminal, display_order, color_code)
VALUES 
(@payment_workflow_id, 'INITIATED', 'Payment has been initiated', TRUE, FALSE, 1, '#6c757d'),
(@payment_workflow_id, 'PROCESSING', 'Payment is being processed', FALSE, FALSE, 2, '#ffc107'),
(@payment_workflow_id, 'COMPLETED', 'Payment completed successfully', FALSE, TRUE, 3, '#28a745'),
(@payment_workflow_id, 'FAILED', 'Payment failed', FALSE, TRUE, 4, '#dc3545'),
(@payment_workflow_id, 'REFUNDED', 'Payment has been refunded', FALSE, TRUE, 5, '#e83e8c');

-- ----------------------------------------------------------------------------
-- 12.6 Insert Shipment Workflow Definition
-- ----------------------------------------------------------------------------
INSERT INTO workflow_definitions (name, description, entity_type, active)
VALUES ('ShipmentWorkflow', 'Tracks shipment status through delivery process', 'SHIPMENT', TRUE);

SET @shipment_workflow_id = LAST_INSERT_ID();

INSERT INTO workflow_states (workflow_id, state_name, description, is_initial, is_terminal, display_order, color_code)
VALUES 
(@shipment_workflow_id, 'PENDING', 'Shipment pending pickup', TRUE, FALSE, 1, '#6c757d'),
(@shipment_workflow_id, 'PICKED_UP', 'Package picked up by carrier', FALSE, FALSE, 2, '#17a2b8'),
(@shipment_workflow_id, 'IN_TRANSIT', 'Package in transit', FALSE, FALSE, 3, '#007bff'),
(@shipment_workflow_id, 'OUT_FOR_DELIVERY', 'Package out for delivery', FALSE, FALSE, 4, '#6610f2'),
(@shipment_workflow_id, 'DELIVERED', 'Package delivered', FALSE, TRUE, 5, '#28a745'),
(@shipment_workflow_id, 'RETURNED', 'Package returned to sender', FALSE, TRUE, 6, '#dc3545');


-- ############################################################################
-- SECTION 13: VERIFICATION QUERIES
-- ############################################################################

-- 13.1 Verify workflow installation
SELECT 'Workflow tables created successfully!' AS status;

SELECT 
    wd.name AS workflow_name,
    wd.entity_type,
    COUNT(DISTINCT ws.id) AS state_count,
    COUNT(DISTINCT wt.id) AS transition_count
FROM workflow_definitions wd
LEFT JOIN workflow_states ws ON wd.id = ws.workflow_id
LEFT JOIN workflow_transitions wt ON wd.id = wt.workflow_id
GROUP BY wd.id, wd.name, wd.entity_type;

-- 13.2 List all tables
SHOW TABLES;

-- 13.3 Database summary
SELECT 
    'categories' AS table_name, COUNT(*) AS row_count FROM categories
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'shipping', COUNT(*) FROM shipping
UNION ALL SELECT 'carts', COUNT(*) FROM carts
UNION ALL SELECT 'wishlists', COUNT(*) FROM wishlists
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL SELECT 'coupons', COUNT(*) FROM coupons
UNION ALL SELECT 'workflow_definitions', COUNT(*) FROM workflow_definitions
UNION ALL SELECT 'workflow_states', COUNT(*) FROM workflow_states
UNION ALL SELECT 'workflow_transitions', COUNT(*) FROM workflow_transitions
UNION ALL SELECT 'workflow_instances', COUNT(*) FROM workflow_instances
UNION ALL SELECT 'workflow_logs', COUNT(*) FROM workflow_logs;


-- ############################################################################
-- SECTION 14: UTILITY COMMANDS
-- ############################################################################

-- 14.1 Clear all transactional data (for testing - DANGER!)
-- SET FOREIGN_KEY_CHECKS = 0;
-- TRUNCATE TABLE workflow_logs;
-- TRUNCATE TABLE workflow_instances;
-- TRUNCATE TABLE shipping;
-- TRUNCATE TABLE payments;
-- TRUNCATE TABLE order_items;
-- TRUNCATE TABLE orders;
-- TRUNCATE TABLE cart_items;
-- TRUNCATE TABLE carts;
-- TRUNCATE TABLE wishlist_items;
-- TRUNCATE TABLE wishlists;
-- TRUNCATE TABLE reviews;
-- SET FOREIGN_KEY_CHECKS = 1;

-- 14.2 Reset password for admin user (password: admin123)
-- UPDATE users 
-- SET password = '$2a$10$WbspULzqno53UEVNJDSy4ur3usqP8Owh1JQKQyy2uAACW5U3aYH/u' 
-- WHERE username = 'admin';

-- ============================================================================
-- END OF FlowForge Complete SQL Schema
-- ============================================================================
