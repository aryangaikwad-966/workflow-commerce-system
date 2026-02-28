-- Task 7: Wishlist Management SQL Commands
-- Run these commands to set up the database for Task 7

-- ============================================
-- 1. Create wishlists table
-- ============================================
CREATE TABLE IF NOT EXISTS wishlists (
    wishlist_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_wishlist_customer (customer_id),
    FOREIGN KEY (customer_id) REFERENCES users(id)
);

-- ============================================
-- 2. Create wishlist_items table
-- ============================================
CREATE TABLE IF NOT EXISTS wishlist_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    wishlist_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_wishlist_product (wishlist_id, product_id),
    FOREIGN KEY (wishlist_id) REFERENCES wishlists(wishlist_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================
-- 3. Verify table creation
-- ============================================
SHOW COLUMNS FROM wishlists;
SHOW COLUMNS FROM wishlist_items;

-- ============================================
-- 4. Check existing products with inventory
-- ============================================
SELECT product_id, product_name, inventory_count, price, status
FROM products 
WHERE status = 1 AND inventory_count > 0;

-- ============================================
-- 5. Sample queries for testing
-- ============================================

-- Get all wishlists with customer info
SELECT 
    w.wishlist_id,
    u.username as customer_name,
    w.created_at,
    w.updated_at
FROM wishlists w
JOIN users u ON w.customer_id = u.id;

-- Get wishlist items with product details
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

-- Get wishlist statistics
SELECT 
    w.wishlist_id,
    u.username as customer_name,
    COUNT(wi.id) as item_count
FROM wishlists w
JOIN users u ON w.customer_id = u.id
LEFT JOIN wishlist_items wi ON w.wishlist_id = wi.wishlist_id
GROUP BY w.wishlist_id, u.username;

-- ============================================
-- 6. Clear wishlist for testing (DANGER - deletes data)
-- ============================================
-- TRUNCATE TABLE wishlist_items;
-- TRUNCATE TABLE wishlists;
