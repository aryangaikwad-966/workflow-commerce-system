-- Task 5: Payment Management SQL Commands
-- Run these commands to set up the database for Task 5

-- ============================================
-- 1. Create payments table
-- ============================================
CREATE TABLE IF NOT EXISTS payments (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(50) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ============================================
-- 2. Verify table creation
-- ============================================
SHOW COLUMNS FROM payments;

-- ============================================
-- 3. Check existing orders that can be paid
-- ============================================
SELECT order_id, user_id, total_amount, order_status, created_at
FROM orders 
WHERE order_status = 'Pending';

-- ============================================
-- 4. Sample queries for testing
-- ============================================

-- Get all payments with customer info
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

-- Get payments by status
SELECT * FROM payments WHERE payment_status = 'Paid';
SELECT * FROM payments WHERE payment_status = 'Failed';
SELECT * FROM payments WHERE payment_status = 'Refunded';

-- Count payments by status
SELECT 
    payment_status,
    COUNT(*) as count,
    SUM(amount) as total_amount
FROM payments
GROUP BY payment_status;

-- ============================================
-- 5. Manual refund (if needed via SQL)
-- ============================================
-- UPDATE payments 
-- SET payment_status = 'Refunded', updated_at = NOW() 
-- WHERE payment_id = 1;

-- UPDATE orders 
-- SET order_status = 'Cancelled', updated_at = NOW() 
-- WHERE order_id = (SELECT order_id FROM payments WHERE payment_id = 1);

-- ============================================
-- 6. Reset payment for testing (DANGER - deletes payment data)
-- ============================================
-- TRUNCATE TABLE payments;
