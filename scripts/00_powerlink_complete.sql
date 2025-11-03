-- ===================================================================
-- PowerLink BAPA - Complete Database Schema (MySQL Compatible)
-- ===================================================================
-- This is the consolidated master SQL script that includes:
-- - All table creations with relationships
-- - All schema updates and enhancements
-- - Seed data for testing
-- - Performance indexes
-- 
-- Usage: Run this single script in phpMyAdmin to set up the complete database
-- ===================================================================

-- SET CHARACTER SET AND COLLATION
SET CHARACTER SET utf8mb4;
SET COLLATION_CONNECTION = utf8mb4_unicode_ci;

-- ===================================================================
-- PART 1: CREATE CORE TABLES
-- ===================================================================

-- Admin users table
CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    full_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_admins_username (username)
);

-- Consumer accounts table
CREATE TABLE IF NOT EXISTS consumers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    contact_number VARCHAR(20),
    meter_number VARCHAR(20) UNIQUE,
    connection_date DATE,
    status VARCHAR(20) DEFAULT 'active', -- active, suspended, overdue
    service_type VARCHAR(20) DEFAULT 'residential', -- residential, commercial
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_consumers_account_number (account_number),
    INDEX idx_consumers_email (email),
    INDEX idx_consumers_status (status)
);

-- Applications for electricity connection
CREATE TABLE IF NOT EXISTS applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    application_id VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    id_document_url TEXT, -- URL to uploaded ID document
    proof_of_residency_url TEXT, -- URL to uploaded proof of residency
    service_type VARCHAR(20) DEFAULT 'residential',
    status VARCHAR(20) DEFAULT 'pending', -- pending, approved, declined, review
    account_number VARCHAR(20), -- assigned when approved
    reviewed_by INT,
    notes TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    processed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (reviewed_by) REFERENCES admins(id) ON DELETE SET NULL,
    INDEX idx_applications_status (status),
    INDEX idx_applications_account_number (account_number),
    INDEX idx_applications_created_at (created_at)
);

-- Account numbers pool for assignment
CREATE TABLE IF NOT EXISTS account_numbers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    is_assigned BOOLEAN DEFAULT FALSE,
    assigned_to INT,
    assigned_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_to) REFERENCES consumers(id) ON DELETE SET NULL,
    INDEX idx_account_numbers_is_assigned (is_assigned)
);

-- Billing information
CREATE TABLE IF NOT EXISTS bills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bill_number VARCHAR(20) UNIQUE NOT NULL,
    consumer_id INT NOT NULL,
    billing_period_start DATE NOT NULL,
    billing_period_end DATE NOT NULL,
    kwh_used DECIMAL(10,2) NOT NULL,
    rate_per_kwh DECIMAL(10,2) NOT NULL,
    amount_due DECIMAL(10,2) NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- pending, paid, overdue
    paid_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (consumer_id) REFERENCES consumers(id) ON DELETE CASCADE,
    INDEX idx_bills_consumer_id (consumer_id),
    INDEX idx_bills_status (status),
    INDEX idx_bills_due_date (due_date)
);

-- Announcements table for system notifications
CREATE TABLE IF NOT EXISTS announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'general', -- outage, promotion, payment, general
    priority VARCHAR(10) NOT NULL DEFAULT 'medium', -- low, medium, high
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- active, inactive
    scheduled_for TIMESTAMP NULL, -- optional scheduling for future announcements
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES admins(id) ON DELETE SET NULL,
    INDEX idx_announcements_status (status),
    INDEX idx_announcements_type (type),
    INDEX idx_announcements_priority (priority),
    INDEX idx_announcements_scheduled_for (scheduled_for)
);

-- Payments table for transaction tracking
CREATE TABLE IF NOT EXISTS payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT NOT NULL,
    consumer_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL, -- gcash, paymaya, credit_card, cash
    payment_reference VARCHAR(100), -- transaction reference from payment provider
    status VARCHAR(20) DEFAULT 'completed', -- pending, completed, failed
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bill_id) REFERENCES bills(id) ON DELETE CASCADE,
    FOREIGN KEY (consumer_id) REFERENCES consumers(id) ON DELETE CASCADE,
    INDEX idx_payments_bill_id (bill_id),
    INDEX idx_payments_consumer_id (consumer_id),
    INDEX idx_payments_status (status)
);

-- Meter readings table to track current and previous readings
CREATE TABLE IF NOT EXISTS meter_readings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    consumer_id INT NOT NULL REFERENCES consumers(id) ON DELETE CASCADE,
    reading_date DATE NOT NULL,
    meter_reading DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(consumer_id, reading_date),
    INDEX idx_meter_readings_consumer_id (consumer_id),
    INDEX idx_meter_readings_reading_date (reading_date)
);

-- Bill receipt tracking table
CREATE TABLE IF NOT EXISTS bill_receipts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
    consumer_id INT NOT NULL REFERENCES consumers(id) ON DELETE CASCADE,
    current_reading DECIMAL(10, 2) NOT NULL,
    previous_reading DECIMAL(10, 2) NOT NULL,
    kwh_used DECIMAL(10, 2) GENERATED ALWAYS AS (current_reading - previous_reading) STORED,
    rate_per_kwh DECIMAL(10, 4) DEFAULT 12.50,
    total_amount_due DECIMAL(10, 2) GENERATED ALWAYS AS ((current_reading - previous_reading) * 12.50) STORED,
    due_date DATE NOT NULL,
    last_payment_date DATE,
    balance DECIMAL(10, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_bill_receipts_bill_id (bill_id),
    INDEX idx_bill_receipts_consumer_id (consumer_id)
);

-- ===================================================================
-- PART 2: INSERT SEED DATA
-- ===================================================================

-- Insert default admin user
INSERT INTO admins (username, password_hash, email, full_name, role) 
VALUES (
    'admin', 
    '$2b$10$rQZ8kHqQZQZQZQZQZQZQZOeKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK',
    'admin@powerlink-bapa.com',
    'System Administrator',
    'admin'
) ON DUPLICATE KEY UPDATE username = username;

-- Insert sample account numbers for assignment
INSERT INTO account_numbers (account_number) VALUES
    ('C001'), ('C002'), ('C003'), ('C004'), ('C005'),
    ('C006'), ('C007'), ('C008'), ('C009'), ('C010'),
    ('C011'), ('C012'), ('C013'), ('C014'), ('C015'),
    ('C016'), ('C017'), ('C018'), ('C019'), ('C020')
ON DUPLICATE KEY UPDATE account_number = account_number;

-- Insert sample consumers (for testing)
INSERT INTO consumers (
    account_number, email, password_hash, full_name, address, 
    contact_number, meter_number, connection_date, status, service_type
) VALUES
    (
        'C001', 
        'juan.delacruz@email.com', 
        '$2b$10$samplehash1', 
        'Juan dela Cruz', 
        '123 Main St, Zone A, Barangay PowerLink',
        '09123456789',
        'MT-001',
        '2024-01-15',
        'active',
        'residential'
    ),
    (
        'C002', 
        'maria.santos@email.com', 
        '$2b$10$samplehash2', 
        'Maria Santos', 
        '456 Oak Ave, Zone B, Barangay PowerLink',
        '09987654321',
        'MT-002',
        '2024-02-01',
        'overdue',
        'residential'
    ),
    (
        'C003', 
        'pedro.garcia@email.com', 
        '$2b$10$samplehash3', 
        'Pedro Garcia', 
        '789 Pine Rd, Zone C, Barangay PowerLink',
        '09555123456',
        'MT-003',
        '2024-02-15',
        'active',
        'residential'
    )
ON DUPLICATE KEY UPDATE account_number = account_number;

-- Mark account numbers as assigned
UPDATE account_numbers 
SET is_assigned = TRUE, assigned_at = CURRENT_TIMESTAMP
WHERE account_number IN ('C001', 'C002', 'C003');

-- Insert sample applications
INSERT INTO applications (
    application_id, full_name, address, contact_number, email, 
    service_type, status, account_number
) VALUES
    (
        'APP001',
        'Ana Reyes',
        '321 Elm St, Zone A, Barangay PowerLink',
        '09321654987',
        'ana.reyes@email.com',
        'residential',
        'pending',
        NULL
    ),
    (
        'APP002',
        'Carlos Mendoza',
        '654 Maple Ave, Zone B, Barangay PowerLink',
        '09654321987',
        'carlos.mendoza@email.com',
        'residential',
        'approved',
        'C004'
    ),
    (
        'APP003',
        'Rosa Lopez',
        '987 Cedar Rd, Zone C, Barangay PowerLink',
        '09987123654',
        'rosa.lopez@email.com',
        'residential',
        'review',
        NULL
    )
ON DUPLICATE KEY UPDATE application_id = application_id;

-- Insert sample bills
INSERT INTO bills (
    bill_number, consumer_id, billing_period_start, billing_period_end,
    kwh_used, rate_per_kwh, amount_due, due_date, status
) VALUES
    (
        'B001',
        1,
        '2025-04-01',
        '2025-04-30',
        85,
        12.50,
        920.75,
        '2025-05-25',
        'paid'
    ),
    (
        'B002',
        2,
        '2025-04-01',
        '2025-04-30',
        112,
        12.50,
        1250.00,
        '2025-05-25',
        'overdue'
    ),
    (
        'B003',
        3,
        '2025-04-01',
        '2025-04-30',
        78,
        12.50,
        875.50,
        '2025-05-25',
        'pending'
    )
ON DUPLICATE KEY UPDATE bill_number = bill_number;

-- Insert sample announcements
INSERT INTO announcements (
    title, content, type, priority, status, scheduled_for, created_by
) VALUES
    (
        'Scheduled Power Maintenance',
        'There will be a scheduled power maintenance on January 15, 2025 from 8:00 AM to 12:00 PM. Affected areas include Zone A and Zone B.',
        'outage',
        'high',
        'active',
        '2025-01-15 08:00:00',
        1
    ),
    (
        'New Online Payment Option Available',
        'We are excited to announce that you can now pay your electricity bills online through GCash and PayMaya. Visit our website to learn more.',
        'payment',
        'medium',
        'active',
        NULL,
        1
    ),
    (
        'Holiday Discount Promotion',
        'Get 5% discount on your electricity bill when you pay before the due date this month. Promo valid until January 31, 2025.',
        'promotion',
        'medium',
        'active',
        NULL,
        1
    ),
    (
        'System Maintenance Notice',
        'Our billing system will undergo maintenance on January 20, 2025 from 2:00 AM to 4:00 AM. Online services may be temporarily unavailable.',
        'general',
        'low',
        'inactive',
        NULL,
        1
    );

-- Insert sample meter readings (last 2 months for consumer C001)
INSERT INTO meter_readings (consumer_id, reading_date, meter_reading) VALUES
    (1, '2025-04-20', 2800),
    (1, '2025-05-24', 3045)
ON DUPLICATE KEY UPDATE meter_reading = VALUES(meter_reading);

-- ===================================================================
-- PART 3: DATA INTEGRITY AND VERIFICATION
-- ===================================================================

-- Show table structure for verification
-- SELECT 'Database Setup Complete' AS Status;
-- SHOW TABLES;

-- ===================================================================
-- END OF POWERLINK BAPA COMPLETE DATABASE SCHEMA
-- ===================================================================
