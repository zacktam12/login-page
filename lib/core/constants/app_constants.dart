class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://btkhidkmotestbzesbfw.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ0a2hpZGttb3Rlc3RiemVzYmZ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI4NjM2NjIsImV4cCI6MjA2ODQzOTY2Mn0.KaH6rFELM-exS2iJcEdcoS74phXDhAHwlLAUpTJq0m0';

  // App Configuration
  static const String appName = 'Facebook Lite';
  static const Duration splashDuration = Duration(seconds: 3);

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String rememberMeKey = 'remember_me';

  // Database Tables
  static const String usersTable = 'users';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
}
