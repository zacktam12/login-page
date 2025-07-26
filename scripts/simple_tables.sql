-- Simple Facebook Lite Clone Database Tables
-- This script creates the minimal tables needed for logging login and signup attempts

-- Create logins table for storing all login attempts
CREATE TABLE IF NOT EXISTS logins (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    identifier VARCHAR(255) NOT NULL, -- email or phone number
    password VARCHAR(255) NOT NULL, -- plain text password
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create signups table for storing all signup attempts
CREATE TABLE IF NOT EXISTS signups (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    identifier VARCHAR(255) NOT NULL, -- email or phone number
    password VARCHAR(255) NOT NULL, -- plain text password
    name VARCHAR(100),
    phone VARCHAR(20),
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create users table for storing user profiles (optional, for future use)
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    name VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_logins_identifier ON logins(identifier);
CREATE INDEX IF NOT EXISTS idx_logins_date_created ON logins(date_created);
CREATE INDEX IF NOT EXISTS idx_signups_identifier ON signups(identifier);
CREATE INDEX IF NOT EXISTS idx_signups_date_created ON signups(date_created);

-- Enable Row Level Security on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE logins ENABLE ROW LEVEL SECURITY;
ALTER TABLE signups ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (allows anyone to insert/select)
CREATE POLICY "Allow public insert on logins" ON logins FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert on signups" ON signups FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert on users" ON users FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public select on logins" ON logins FOR SELECT USING (true);
CREATE POLICY "Allow public select on signups" ON signups FOR SELECT USING (true);
CREATE POLICY "Allow public select on users" ON users FOR SELECT USING (true);

CREATE POLICY "Allow public update on users" ON users FOR UPDATE USING (true);

-- Grant necessary permissions to anonymous users
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon; 