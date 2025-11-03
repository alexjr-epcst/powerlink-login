-- PowerLink BAPA Database Schema (MySQL Compatible)
-- Energy Management System Tables

-- Admin users table
CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    full_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (reviewed_by) REFERENCES admins(id) ON DELETE SET NULL
);

-- Account numbers pool for assignment
CREATE TABLE IF NOT EXISTS account_numbers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    is_assigned BOOLEAN DEFAULT FALSE,
    assigned_to INT,
    assigned_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_to) REFERENCES consumers(id) ON DELETE SET NULL
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
    FOREIGN KEY (consumer_id) REFERENCES consumers(id) ON DELETE CASCADE
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
    FOREIGN KEY (created_by) REFERENCES admins(id) ON DELETE SET NULL
);

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT NOT NULL,
    consumer_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_reference VARCHAR(100),
    status VARCHAR(20) DEFAULT 'completed',
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bill_id) REFERENCES bills(id) ON DELETE CASCADE,
    FOREIGN KEY (consumer_id) REFERENCES consumers(id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_consumers_account_number ON consumers(account_number);
CREATE INDEX idx_consumers_email ON consumers(email);
CREATE INDEX idx_applications_status ON applications(status);
CREATE INDEX idx_bills_consumer_id ON bills(consumer_id);
CREATE INDEX idx_bills_status ON bills(status);
CREATE INDEX idx_announcements_status ON announcements(status);
CREATE INDEX idx_announcements_type ON announcements(type);
CREATE INDEX idx_announcements_priority ON announcements(priority);
CREATE INDEX idx_announcements_scheduled_for ON announcements(scheduled_for);
CREATE INDEX idx_payments_bill_id ON payments(bill_id);
CREATE INDEX idx_payments_consumer_id ON payments(consumer_id);
