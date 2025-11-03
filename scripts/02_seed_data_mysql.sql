-- Seed data for PowerLink BAPA system (MySQL Compatible)

-- Insert default admin user
INSERT INTO admins (username, password_hash, email, full_name, role) 
VALUES (
    'admin', 
    '$2b$10$rQZ8kHqQZQZQZQZQZQZQZOeKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK', -- This would be hashed 'powerlink2025'
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
        1, -- Juan dela Cruz
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
        2, -- Maria Santos
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
        3, -- Pedro Garcia
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
