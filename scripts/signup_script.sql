-- =====================================================
-- FACEBOOK LITE CLONE - SIGNUP SCRIPT
-- =====================================================

-- 1. CREATE USERS TABLE
-- This table stores user profiles and links to Supabase auth.users
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. CREATE SIGNUPS TABLE
-- This table logs signup attempts for analytics and security monitoring
CREATE TABLE IF NOT EXISTS signups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    identifier VARCHAR(255) NOT NULL, -- email or phone used for signup
    password VARCHAR(255) NOT NULL, -- Note: In production, consider not storing passwords
    name VARCHAR(100),
    phone VARCHAR(20),
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT,
    success BOOLEAN DEFAULT false,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    error_message TEXT
);

-- 3. CREATE INDEXES
-- Users table indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);

-- Signups table indexes
CREATE INDEX IF NOT EXISTS idx_signups_identifier ON signups(identifier);
CREATE INDEX IF NOT EXISTS idx_signups_date_created ON signups(date_created);
CREATE INDEX IF NOT EXISTS idx_signups_success ON signups(success);
CREATE INDEX IF NOT EXISTS idx_signups_user_id ON signups(user_id);

-- 4. ENABLE ROW LEVEL SECURITY
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE signups ENABLE ROW LEVEL SECURITY;

-- 5. CREATE RLS POLICIES

-- Users table policies
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Signups table policies
CREATE POLICY "Admin can view all signups" ON signups
    FOR SELECT USING (auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Anyone can insert signup attempts" ON signups
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can view own signup attempts" ON signups
    FOR SELECT USING (auth.uid() = user_id);

-- 6. TRIGGERS AND FUNCTIONS

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at for users table
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to handle new user creation (triggered when auth.users record is created)
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, name, phone, created_at, last_login)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', ''),
        COALESCE(NEW.raw_user_meta_data->>'phone', ''),
        NOW(),
        NOW()
    );
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically create user profile when auth.users record is created
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- 7. HELPER FUNCTIONS FOR SIGNUP

-- Function to log a signup attempt
CREATE OR REPLACE FUNCTION log_signup_attempt(
    p_identifier TEXT,
    p_password TEXT,
    p_name TEXT DEFAULT NULL,
    p_phone TEXT DEFAULT NULL,
    p_success BOOLEAN DEFAULT false,
    p_user_id UUID DEFAULT NULL,
    p_error_message TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    signup_id UUID;
BEGIN
    INSERT INTO signups (
        identifier,
        password,
        name,
        phone,
        success,
        user_id,
        error_message,
        ip_address,
        user_agent
    ) VALUES (
        p_identifier,
        p_password,
        p_name,
        p_phone,
        p_success,
        p_user_id,
        p_error_message,
        inet_client_addr(),
        current_setting('request.headers', true)::json->>'user-agent'
    ) RETURNING id INTO signup_id;
    
    RETURN signup_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if email already exists
CREATE OR REPLACE FUNCTION check_email_exists(p_email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS(
        SELECT 1 FROM users WHERE email = p_email
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if phone already exists
CREATE OR REPLACE FUNCTION check_phone_exists(p_phone TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS(
        SELECT 1 FROM users WHERE phone = p_phone
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user by email
CREATE OR REPLACE FUNCTION get_user_by_email(p_email TEXT)
RETURNS TABLE (
    id UUID,
    email VARCHAR,
    name VARCHAR,
    phone VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE,
    last_login TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.email, u.name, u.phone, u.created_at, u.last_login
    FROM users u
    WHERE u.email = p_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get signup statistics
CREATE OR REPLACE FUNCTION get_signup_stats(
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE (
    total_attempts BIGINT,
    successful_signups BIGINT,
    failed_signups BIGINT,
    success_rate NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_attempts,
        COUNT(*) FILTER (WHERE success = true) as successful_signups,
        COUNT(*) FILTER (WHERE success = false) as failed_signups,
        ROUND(
            (COUNT(*) FILTER (WHERE success = true)::NUMERIC / COUNT(*)::NUMERIC) * 100, 
            2
        ) as success_rate
    FROM signups 
    WHERE date_created >= NOW() - INTERVAL '1 day' * p_days;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get recent signups
CREATE OR REPLACE FUNCTION get_recent_signups(
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    date_created TIMESTAMP WITH TIME ZONE,
    identifier VARCHAR,
    name VARCHAR,
    phone VARCHAR,
    success BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.date_created,
        s.identifier,
        s.name,
        s.phone,
        s.success
    FROM signups s
    ORDER BY s.date_created DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. SAMPLE USAGE (COMMENTED OUT)

/*
-- Example: Log a successful signup
SELECT log_signup_attempt(
    'newuser@example.com',
    'password123',
    'John Doe',
    '+1234567890',
    true,
    'user-uuid-here'
);

-- Example: Log a failed signup
SELECT log_signup_attempt(
    'existing@example.com',
    'password123',
    'John Doe',
    '+1234567890',
    false,
    NULL,
    'Email already exists'
);

-- Example: Check if email exists
SELECT check_email_exists('user@example.com');

-- Example: Check if phone exists
SELECT check_phone_exists('+1234567890');

-- Example: Get user by email
SELECT * FROM get_user_by_email('user@example.com');

-- Example: Get signup statistics
SELECT * FROM get_signup_stats(7); -- Last 7 days

-- Example: Get recent signups
SELECT * FROM get_recent_signups(5);
*/

-- 9. SAMPLE DATA (OPTIONAL - FOR TESTING)

/*
-- Insert sample users (uncomment if needed for testing)
INSERT INTO users (id, email, name, phone, created_at, last_login) VALUES
    (gen_random_uuid(), 'john.doe@example.com', 'John Doe', '+1234567890', NOW(), NOW()),
    (gen_random_uuid(), 'jane.smith@example.com', 'Jane Smith', '+0987654321', NOW(), NOW())
ON CONFLICT (email) DO NOTHING;
*/

-- 10. CLEANUP COMMANDS (UNCOMMENT IF NEEDED)

/*
-- To drop all tables and functions:
DROP TABLE IF EXISTS signups CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS log_signup_attempt(TEXT, TEXT, TEXT, TEXT, BOOLEAN, UUID, TEXT) CASCADE;
DROP FUNCTION IF EXISTS check_email_exists(TEXT) CASCADE;
DROP FUNCTION IF EXISTS check_phone_exists(TEXT) CASCADE;
DROP FUNCTION IF EXISTS get_user_by_email(TEXT) CASCADE;
DROP FUNCTION IF EXISTS get_signup_stats(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS get_recent_signups(INTEGER) CASCADE;
*/ 