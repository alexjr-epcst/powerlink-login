-- Add meter readings table to track current and previous readings
CREATE TABLE IF NOT EXISTS meter_readings (
  id SERIAL PRIMARY KEY,
  consumer_id INTEGER NOT NULL REFERENCES consumers(id) ON DELETE CASCADE,
  reading_date DATE NOT NULL,
  meter_reading DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(consumer_id, reading_date)
);

-- Add bill receipt tracking table
CREATE TABLE IF NOT EXISTS bill_receipts (
  id SERIAL PRIMARY KEY,
  bill_id INTEGER NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
  consumer_id INTEGER NOT NULL REFERENCES consumers(id) ON DELETE CASCADE,
  current_reading DECIMAL(10, 2) NOT NULL,
  previous_reading DECIMAL(10, 2) NOT NULL,
  kwh_used DECIMAL(10, 2) GENERATED ALWAYS AS (current_reading - previous_reading) STORED,
  rate_per_kwh DECIMAL(10, 4) DEFAULT 12.50,
  total_amount_due DECIMAL(10, 2) GENERATED ALWAYS AS ((current_reading - previous_reading) * 12.50) STORED,
  due_date DATE NOT NULL,
  last_payment_date DATE,
  balance DECIMAL(10, 2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed sample meter readings (last 2 months for current consumer C001)
INSERT INTO meter_readings (consumer_id, reading_date, meter_reading) VALUES
(1, '2025-04-20', 2800),  -- Previous month reading
(1, '2025-05-24', 3045)   -- Current month reading
ON CONFLICT (consumer_id, reading_date) DO NOTHING;
