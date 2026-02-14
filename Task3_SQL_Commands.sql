-- Task-3 Order Management SQL Commands
-- Use this to create the orders and order_items tables

USE workflow_commerce;

-- 1. CREATE TABLE orders
CREATE TABLE IF NOT EXISTS orders (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    shipping_address VARCHAR(300) NOT NULL,
    order_status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_order_status (order_status),
    INDEX idx_created_at (created_at)
);

-- 2. CREATE TABLE order_items
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price_at_purchase DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
);

-- 3. INSERT sample order data
INSERT INTO orders (user_id, total_amount, shipping_address, order_status, status) 
VALUES 
(1, 2599.98, '123 Main St, City, State 12345', 'Pending', 1),
(2, 149.99, '456 Oak Ave, Town, State 67890', 'Shipped', 1),
(3, 49.99, '789 Pine Rd, Village, State 11111', 'Delivered', 1);

-- 4. INSERT sample order_items data
INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) 
VALUES 
(1, 3, 1, 1299.99),  -- Laptop Pro 15"
(1, 4, 1, 49.99),   -- Business Shirt
(1, 2, 1, 23333.00), -- iPhone
(2, 3, 2, 1299.99),  -- Laptop Pro 15"
(3, 4, 1, 49.99);   -- Business Shirt

-- 5. SELECT all orders (admin view)
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

-- 6. SELECT orders by status (admin filter)
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

-- 7. SELECT user orders (customer view)
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

-- 8. SELECT order details with items
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
LEFT JOIN products p ON oi.product_id = p.id
WHERE o.order_id = 1
ORDER BY oi.id;

-- 9. UPDATE order status (admin action)
UPDATE orders 
SET order_status = 'Shipped', updated_at = NOW() 
WHERE order_id = 2;

-- 10. CANCEL order (customer action)
UPDATE orders 
SET order_status = 'Cancelled', status = 0, updated_at = NOW() 
WHERE order_id = 1 AND order_status = 'Pending';

-- 11. CANCEL order (admin action)
UPDATE orders 
SET order_status = 'Cancelled', status = 0, updated_at = NOW() 
WHERE order_id = 1 AND order_status != 'Shipped' AND order_status != 'Delivered';

-- 12. Order statistics by status
SELECT 
    order_status,
    COUNT(*) as order_count,
    SUM(total_amount) as total_revenue
FROM orders 
WHERE status = 1
GROUP BY order_status
ORDER BY order_status;
