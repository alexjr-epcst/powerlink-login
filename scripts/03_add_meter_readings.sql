-- Add meter readings table to track consumption history
CREATE TABLE IF NOT EXISTS meter_readings (
    id SERIAL PRIMARY KEY,
    consumer_id INTEGER REFERENCES consumers(id),
    reading_date DATE NOT NULL,
    reading_value DECIMAL(10,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_meter_readings_consumer_id ON meter_readings(consumer_id);
CREATE INDEX IF NOT EXISTS idx_meter_readings_reading_date ON meter_readings(reading_date);
