-- Task 10: Coupon & Discount Management SQL Commands

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
    CONSTRAINT chk_usage_count CHECK (usage_count <= usage_limit)
);

SHOW COLUMNS FROM coupons;
