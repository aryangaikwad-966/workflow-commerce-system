-- 1. CREATE TABLE categories
drop database workflow_commerce;
create database workflow_commerce;
use workflow_commerce;
CREATE TABLE categories (
    category_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(300),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status BOOLEAN DEFAULT TRUE
);

-- 2. INSERT sample category data
INSERT INTO categories (category_name, description, status) 
VALUES 
('Electronics', 'High-end computing and consumer gadgets', 1),
('Apparel', 'Traditional and modern professional wear', 1),
('Logistics', 'Internal supply chain equipment', 0);

-- 3. UPDATE category
UPDATE categories 
SET category_name = 'Computing Hardware', updated_at = NOW() 
WHERE category_id = 1;

-- 4. SOFT DELETE category (status = false)
UPDATE categories 
SET status = 0, updated_at = NOW() 
WHERE category_id = 2;

UPDATE users 
SET password = '$2a$10$WbspULzqno53UEVNJDSy4ur3usqP8Owh1JQKQyy2uAACW5U3aYH/u' 
WHERE username = 'admin';

-- 5. SELECT active categories
SELECT * FROM categories WHERE status = 1 ORDER BY category_name ASC;
select * from users;

-- 6. SELECT all categories (admin view)
SELECT category_id, category_name, description, status, created_at FROM categories;

USE workflow_commerce;

-- 1. Remove the broken admin
DELETE FROM user_roles WHERE user_id IN (SELECT id FROM users WHERE username = 'admin');
DELETE FROM users WHERE username = 'admin';

-- 2. Re-Insert Admin with known hash for 'admin123'
INSERT INTO users (username, email, password, created_at)
VALUES ('admin', 'admin@test.com', '$2a$10$WbspULzqno53UEVNJDSy4ur3usqP8Owh1JQKQyy2uAACW5U3aYH/u', NOW());

-- 3. Assign Role (Crucial Step: Role ID 2 is ADMIN)
INSERT INTO user_roles (user_id, role_id)
VALUES ((SELECT id FROM users WHERE username = 'admin'), 2);