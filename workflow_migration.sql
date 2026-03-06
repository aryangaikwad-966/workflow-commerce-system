-- ============================================
-- Workflow Engine Migration Script
-- Creates workflow tables for the 
-- Workflow-Driven Commerce Operations System
-- ============================================

USE workflow_commerce;

-- ============================================
-- 1. Create workflow_definitions table
-- ============================================
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

-- ============================================
-- 2. Create workflow_states table
-- ============================================
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

-- ============================================
-- 3. Create workflow_transitions table
-- ============================================
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

-- ============================================
-- 4. Create workflow_instances table
-- ============================================
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

-- ============================================
-- 5. Create workflow_logs table (Audit Trail)
-- ============================================
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

-- ============================================
-- 6. Add workflow_instance_id to orders table
-- ============================================
ALTER TABLE orders 
ADD COLUMN workflow_instance_id BIGINT AFTER order_status,
ADD INDEX idx_order_workflow (workflow_instance_id);

-- ============================================
-- 7. Insert Order Lifecycle Workflow
-- ============================================
INSERT INTO workflow_definitions (name, description, entity_type, active)
VALUES ('OrderLifecycleWorkflow', 
        'Manages the complete lifecycle of customer orders from creation to delivery or cancellation', 
        'ORDER', 
        TRUE);

SET @order_workflow_id = LAST_INSERT_ID();

-- Insert states
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

-- Get state IDs
SET @state_created = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'CREATED');
SET @state_payment_pending = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'PAYMENT_PENDING');
SET @state_paid = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'PAID');
SET @state_processing = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'PROCESSING');
SET @state_shipped = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'SHIPPED');
SET @state_delivered = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'DELIVERED');
SET @state_cancelled = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'CANCELLED');
SET @state_refunded = (SELECT id FROM workflow_states WHERE workflow_id = @order_workflow_id AND state_name = 'REFUNDED');

-- Insert transitions
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

-- ============================================
-- 8. Insert Payment Workflow
-- ============================================
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

-- ============================================
-- 9. Insert Shipment Workflow
-- ============================================
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

-- ============================================
-- 10. Verify installation
-- ============================================
SELECT 'Workflow tables created successfully!' AS status;

SELECT 
    wd.name AS workflow_name,
    COUNT(DISTINCT ws.id) AS state_count,
    COUNT(DISTINCT wt.id) AS transition_count
FROM workflow_definitions wd
LEFT JOIN workflow_states ws ON wd.id = ws.workflow_id
LEFT JOIN workflow_transitions wt ON wd.id = wt.workflow_id
GROUP BY wd.id, wd.name;
