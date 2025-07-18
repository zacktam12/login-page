-- =====================================================
-- FACEBOOK LITE CLONE - LOGIN SCRIPT
-- =====================================================

-- 1. CREATE LOGINS TABLE
-- This table logs login attempts for analytics and security monitoring
CREATE TABLE IF NOT EXISTS logins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    identifier VARCHAR(255) NOT NULL, -- email or phone used for login
    password VARCHAR(255) NOT NULL, -- Note: In production, consider not storing passwords
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT,
    success BOOLEAN DEFAULT false,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    error_message TEXT
);

-- 2. CREATE INDEXES FOR LOGIN TABLE
CREATE INDEX IF NOT EXISTS idx_logins_identifier ON logins(identifier);
CREATE INDEX IF NOT EXISTS idx_logins_date_created ON logins(date_created);
CREATE INDEX IF NOT EXISTS idx_logins_success ON logins(success);
CREATE INDEX IF NOT EXISTS idx_logins_user_id ON logins(user_id);

-- 3. ENABLE ROW LEVEL SECURITY
ALTER TABLE logins ENABLE ROW LEVEL SECURITY;

-- 4. CREATE RLS POLICIES
-- Admin can view all login attempts
CREATE POLICY "Admin can view all logins" ON logins
    FOR SELECT USING (auth.jwt() ->> 'role' = 'service_role');

-- Anyone can insert login attempts (for logging)
CREATE POLICY "Anyone can insert login attempts" ON logins
    FOR INSERT WITH CHECK (true);

-- Users can view their own login attempts
CREATE POLICY "Users can view own logins" ON logins
    FOR SELECT USING (auth.uid() = user_id);

-- 5. HELPER FUNCTIONS FOR LOGIN

-- Function to log a login attempt
CREATE OR REPLACE FUNCTION log_login_attempt(
    p_identifier TEXT,
    p_password TEXT,
    p_success BOOLEAN DEFAULT false,
    p_user_id UUID DEFAULT NULL,
    p_error_message TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    login_id UUID;
BEGIN
    INSERT INTO logins (
        identifier,
        password,
        success,
        user_id,
        error_message,
        ip_address,
        user_agent
    ) VALUES (
        p_identifier,
        p_password,
        p_success,
        p_user_id,
        p_error_message,
        inet_client_addr(),
        current_setting('request.headers', true)::json->>'user-agent'
    ) RETURNING id INTO login_id;
    
    RETURN login_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update last login timestamp for user
CREATE OR REPLACE FUNCTION update_last_login(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE users 
    SET last_login = NOW()
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get login statistics
CREATE OR REPLACE FUNCTION get_login_stats(
    p_days INTEGER DEFAULT 30
)
RETURNS TABLE (
    total_attempts BIGINT,
    successful_logins BIGINT,
    failed_logins BIGINT,
    success_rate NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_attempts,
        COUNT(*) FILTER (WHERE success = true) as successful_logins,
        COUNT(*) FILTER (WHERE success = false) as failed_logins,
        ROUND(
            (COUNT(*) FILTER (WHERE success = true)::NUMERIC / COUNT(*)::NUMERIC) * 100, 
            2
        ) as success_rate
    FROM logins 
    WHERE date_created >= NOW() - INTERVAL '1 day' * p_days;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get recent login attempts for a user
CREATE OR REPLACE FUNCTION get_user_login_history(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    date_created TIMESTAMP WITH TIME ZONE,
    success BOOLEAN,
    ip_address INET,
    user_agent TEXT,
    error_message TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.date_created,
        l.success,
        l.ip_address,
        l.user_agent,
        l.error_message
    FROM logins l
    WHERE l.user_id = p_user_id
    ORDER BY l.date_created DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. SAMPLE USAGE (COMMENTED OUT)

/*
-- Example: Log a successful login
SELECT log_login_attempt(
    'user@example.com',
    'password123',
    true,
    'user-uuid-here'
);

-- Example: Log a failed login
SELECT log_login_attempt(
    'user@example.com',
    'wrongpassword',
    false,
    NULL,
    'Invalid credentials'
);

-- Example: Update last login
SELECT update_last_login('user-uuid-here');

-- Example: Get login statistics
SELECT * FROM get_login_stats(7); -- Last 7 days

-- Example: Get user login history
SELECT * FROM get_user_login_history('user-uuid-here', 5);
*/

-- 7. CLEANUP COMMANDS (UNCOMMENT IF NEEDED)

/*
-- To drop login table and functions:
DROP TABLE IF EXISTS logins CASCADE;
DROP FUNCTION IF EXISTS log_login_attempt(TEXT, TEXT, BOOLEAN, UUID, TEXT) CASCADE;
DROP FUNCTION IF EXISTS update_last_login(UUID) CASCADE;
DROP FUNCTION IF EXISTS get_login_stats(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS get_user_login_history(UUID, INTEGER) CASCADE;
*/ 