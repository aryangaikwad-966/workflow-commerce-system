-- Task-2 Product Management SQL Commands
-- Use this to create the products table and test data

USE workflow_commerce;

-- 1. CREATE TABLE products
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

-- 2. INSERT sample product data
INSERT INTO products (product_name, description, price, sku, category_id, inventory_count, status) 
VALUES 
('Laptop Pro 15"', 'High-performance laptop with 16GB RAM and 512GB SSD', 1299.99, 'LP-15-001', 1, 50, 1),
('Wireless Mouse', 'Ergonomic wireless mouse with USB-C charging', 29.99, 'WM-001', 1, 200, 1),
('Business Shirt', 'Premium cotton business shirt', 49.99, 'BS-001', 2, 100, 1),
('Forklift', 'Industrial forklift for warehouse operations', 15000.00, 'FL-001', 3, 5, 0);

-- 3. SELECT all products (admin view)
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

-- 4. SELECT active products only
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

-- 5. Test SKU uniqueness constraint (should fail)
-- INSERT INTO products (product_name, description, price, sku, category_id, inventory_count, status) 
-- VALUES ('Duplicate Laptop', 'This should fail', 999.99, 'LP-15-001', 1, 10, 1);

-- 6. Test foreign key constraint (should fail)
-- INSERT INTO products (product_name, description, price, sku, category_id, inventory_count, status) 
-- VALUES ('Invalid Category', 'This should fail', 99.99, 'TEST-001', 999, 10, 1);

-- 7. SOFT DELETE product (set status = false)
UPDATE products 
SET status = 0, updated_at = NOW() 
WHERE product_id = 1;

-- 8. UPDATE product
UPDATE products 
SET price = 1199.99, inventory_count = 45, updated_at = NOW() 
WHERE product_id = 1;

-- 9. Count products by category
SELECT 
    c.category_name,
    COUNT(p.product_id) as product_count
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id AND p.status = 1
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;
