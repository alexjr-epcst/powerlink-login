-- Add payments table for transaction tracking
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    bill_id INTEGER REFERENCES bills(id),
    consumer_id INTEGER REFERENCES consumers(id),
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL, -- gcash, paymaya, credit_card, cash
    payment_reference VARCHAR(100), -- transaction reference from payment provider
    status VARCHAR(20) DEFAULT 'completed', -- pending, completed, failed
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_payments_bill_id ON payments(bill_id);
CREATE INDEX IF NOT EXISTS idx_payments_consumer_id ON payments(consumer_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
