# Facebook Lite Clone

A modern, lightweight Facebook clone built with Flutter and Supabase, featuring user authentication, profile management, and a clean, responsive UI.

## 🚀 Features

- **User Authentication**: Secure login and signup with email/password
- **Profile Management**: User profiles with name, email, and phone
- **Modern UI**: Clean, responsive design inspired by Facebook Lite
- **Cross-Platform**: Works on Android, iOS, Web, and Desktop
- **Real-time Database**: Powered by Supabase for scalable backend
- **Security**: Row Level Security (RLS) and proper authentication
- **Analytics**: Login and signup attempt tracking

## 📱 Screenshots

- **Splash Screen**: App loading with Facebook branding
- **Login Page**: Email/password authentication
- **Signup Page**: New user registration
- **Find Account**: Password recovery
- **Join Facebook**: User onboarding


## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase
- **Database**: PostgreSQL
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage
- **State Management**: Flutter built-in
- **UI Framework**: Material Design

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)
- A Supabase account (free tier available)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd facebook-lite-clone
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Set Up Supabase

#### Step 1: Create a Supabase Project

1. Go to [Supabase](https://supabase.com/) and sign up/login
2. Click "New Project"
3. Choose your organization
4. Enter project details:
   - **Name**: `facebook-lite-clone` (or your preferred name)
   - **Database Password**: Create a strong password
   - **Region**: Choose closest to your users
5. Click "Create new project"

#### Step 2: Get Your Supabase Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://your-project.supabase.co`)
   - **Anon/Public Key** (starts with `eyJ...`)

#### Step 3: Update App Configuration

1. Open `lib/core/constants/app_constants.dart`
2. Replace the existing values with your Supabase credentials:

```dart
class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // ... rest of the constants
}
```

#### Step 4: Run Database Scripts

1. In your Supabase dashboard, go to **SQL Editor**
2. Run the signup script first (recommended):

```sql
-- Copy and paste the contents of scripts/signup_script.sql
-- This creates the users table and signup logging
```

3. Optionally, run the login script for detailed analytics:

```sql
-- Copy and paste the contents of scripts/login_script.sql
-- This creates login tracking functionality
```

### 4. Run the Application

#### For Development

```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d chrome    # Web
flutter run -d windows   # Windows
flutter run -d macos     # macOS
flutter run -d linux     # Linux
```

#### For Production Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Web
flutter build web --release

# iOS
flutter build ios --release
```

## 📊 Database Schema

### Users Table
```sql
users (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)
```

### Signups Table (Analytics)
```sql
signups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    identifier VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    phone VARCHAR(20),
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    success BOOLEAN DEFAULT false,
    user_id UUID REFERENCES auth.users(id),
    error_message TEXT
)
```

### Logins Table (Analytics)
```sql
logins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    identifier VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    success BOOLEAN DEFAULT false,
    user_id UUID REFERENCES auth.users(id),
    error_message TEXT
)
```

## 🔐 Security Features

- **Row Level Security (RLS)**: Users can only access their own data
- **Authentication**: Secure email/password authentication via Supabase
- **Password Validation**: Minimum 6 characters required
- **Input Validation**: Email format and phone number validation
- **Error Handling**: Comprehensive error messages for users

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants and configuration
│   ├── theme/             # App theming and styling
│   └── utils/             # Utility functions and helpers
├── data/
│   ├── models/            # Data models (UserModel)
│   └── services/          # API services (AuthService, StorageService)
├── presentation/
│   ├── pages/             # App screens
│   │   ├── auth/          # Authentication pages
│   │   ├── home/          # Home page
│   │   └── splash/        # Splash screen
│   └── widgets/           # Reusable UI components
└── main.dart              # App entry point
```

## 🎨 Customization

### Colors and Theme
Edit `lib/core/constants/app_colors.dart` to customize the app's color scheme.

### App Constants
Modify `lib/core/constants/app_constants.dart` to change:
- App name
- Splash screen duration
- Validation rules
- Table names

### UI Components
Customize widgets in `lib/presentation/widgets/` to match your design requirements.

## 📈 Analytics and Monitoring

The app includes built-in analytics for:
- **Login Attempts**: Track successful and failed logins
- **Signup Attempts**: Monitor new user registrations
- **User Activity**: Last login timestamps
- **Error Tracking**: Failed authentication attempts

View analytics in your Supabase dashboard under **Table Editor**.

## 🚨 Troubleshooting

### Common Issues

1. **"Invalid API key" error**
   - Verify your Supabase URL and anon key in `app_constants.dart`
   - Ensure the key is the anon/public key, not the service role key

2. **"Table does not exist" error**
   - Run the database scripts in Supabase SQL Editor
   - Check that table names match in `app_constants.dart`

3. **Build errors**
   - Run `flutter clean` then `flutter pub get`
   - Ensure Flutter SDK is up to date

4. **Authentication issues**
   - Verify Supabase Auth is enabled in your project
   - Check email confirmation settings in Supabase dashboard

### Getting Help

- Check the [Flutter documentation](https://flutter.dev/docs)
- Visit [Supabase documentation](https://supabase.com/docs)
- Review the code comments for implementation details

## 📄 License

This project is for educational purposes. Facebook is a registered trademark of Meta Platforms, Inc.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For support or questions:
- Create an issue in the repository
- Check the troubleshooting section above
- Review the Supabase and Flutter documentation

---

**Note**: This is a demonstration project. For production use, ensure proper security measures, data encryption, and compliance with relevant regulations.
