class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-$$$$]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email or phone number is required';
    }

    // Check if it's an email - more permissive regex
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (emailRegex.hasMatch(value)) {
      return null;
    }

    // Check if it's a phone number
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (phoneRegex.hasMatch(value)) {
      return null;
    }

    return 'Please enter a valid email or phone number';
  }
}
