-- new SQL file creating helpful views for the registration system

-- View for pending applications
CREATE OR REPLACE VIEW v_pending_applications AS
SELECT 
    id,
    application_id,
    account_number,
    full_name,
    email,
    address,
    contact_number,
    service_type,
    status,
    date_submitted,
    COALESCE(date_processed, CURRENT_TIMESTAMP) as days_pending
FROM applications
WHERE status = 'pending'
ORDER BY date_submitted DESC;

-- View for approved applications ready for account creation
CREATE OR REPLACE VIEW v_approved_applications AS
SELECT 
    id,
    application_id,
    account_number,
    full_name,
    email,
    address,
    contact_number,
    service_type,
    status,
    date_submitted,
    date_processed
FROM applications
WHERE status = 'approved' AND account_number IS NOT NULL
ORDER BY date_processed DESC;

-- View for application statistics
CREATE OR REPLACE VIEW v_application_stats AS
SELECT 
    COUNT(*) as total_applications,
    COALESCE(SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END), 0) as pending_count,
    COALESCE(SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END), 0) as approved_count,
    COALESCE(SUM(CASE WHEN status = 'declined' THEN 1 ELSE 0 END), 0) as declined_count,
    COUNT(CASE WHEN account_number IS NOT NULL THEN 1 END) as registered_consumers
FROM applications;
