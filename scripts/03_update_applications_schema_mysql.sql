-- Added additional database schema updates for enhanced application tracking (MySQL Compatible)

-- Add columns with proper MySQL syntax
ALTER TABLE applications 
ADD COLUMN processed_at TIMESTAMP NULL,
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Add indexes for better query performance
CREATE INDEX idx_applications_status ON applications(status);
CREATE INDEX idx_applications_account_number ON applications(account_number);
CREATE INDEX idx_applications_created_at ON applications(created_at);
