-- Task 6: Cart Management SQL Commands
-- Run these commands to set up the database for Task 6

-- ============================================
-- 1. Create carts table
-- ============================================
CREATE TABLE IF NOT EXISTS carts (
    cart_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id)
);

-- ============================================
-- 2. Create cart_items table
-- ============================================
CREATE TABLE IF NOT EXISTS cart_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cart_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================
-- 3. Verify table creation
-- ============================================
SHOW COLUMNS FROM carts;
SHOW COLUMNS FROM cart_items;

-- ============================================
-- 4. Check existing products with inventory
-- ============================================
SELECT product_id, product_name, inventory_count, price, status
FROM products 
WHERE status = 1 AND inventory_count > 0;

-- ============================================
-- 5. Sample queries for testing
-- ============================================

-- Get all carts with customer info
SELECT 
    c.cart_id,
    u.username as customer_name,
    c.created_at,
    c.updated_at
FROM carts c
JOIN users u ON c.customer_id = u.id;

-- Get cart items with product details
SELECT 
    ci.id,
    c.cart_id,
    p.product_name,
    ci.quantity,
    ci.total_price
FROM cart_items ci
JOIN carts c ON ci.cart_id = c.cart_id
JOIN products p ON ci.product_id = p.product_id;

-- Get cart statistics
SELECT 
    c.cart_id,
    u.username as customer_name,
    COUNT(ci.id) as item_count,
    COALESCE(SUM(ci.total_price), 0) as total_value
FROM carts c
JOIN users u ON c.customer_id = u.id
LEFT JOIN cart_items ci ON c.cart_id = ci.cart_id
GROUP BY c.cart_id, u.username;

-- ============================================
-- 6. Clear cart for testing (DANGER - deletes data)
-- ============================================
-- TRUNCATE TABLE cart_items;
-- TRUNCATE TABLE carts;
