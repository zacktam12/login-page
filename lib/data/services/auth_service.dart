import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Update last login
        await _updateLastLogin(response.user!.id);

        // Get user data from our custom table
        final userData = await _getUserData(response.user!.id);
        return userData;
      }

      return null;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile in our custom table
        final userModel = UserModel(
          id: response.user!.id,
          email: email,
          name: name,
          phone: phone,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _createUserProfile(userModel);
        return userModel;
      }

      return null;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _supabase.auth.currentUser != null;
  }

  // Create user profile in custom table
  Future<void> _createUserProfile(UserModel user) async {
    await _supabase.from(AppConstants.usersTable).insert(user.toJson());
  }

  // Get user data from custom table
  Future<UserModel?> _getUserData(String userId) async {
    final response = await _supabase
        .from(AppConstants.usersTable)
        .select()
        .eq('id', userId)
        .single();

    return UserModel.fromJson(response);
  }

  // Update last login timestamp
  Future<void> _updateLastLogin(String userId) async {
    await _supabase.from(AppConstants.usersTable).update(
        {'last_login': DateTime.now().toIso8601String()}).eq('id', userId);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Log login event to Supabase
  Future<void> logLoginEvent({
    required String identifier, // mobile or email
    required String password,
  }) async {
    await _supabase.from('logins').insert({
      'identifier': identifier,
      'password': password, // Not encrypted (not recommended for production)
      'date_created': DateTime.now().toIso8601String(),
    });
  }

  // Log signup event to Supabase
  Future<void> logSignupEvent({
    required String identifier, // mobile or email
    required String password,
    String? name,
    String? phone,
  }) async {
    await _supabase.from('signups').insert({
      'identifier': identifier,
      'password': password, // Not encrypted (not recommended for production)
      'name': name,
      'phone': phone,
      'date_created': DateTime.now().toIso8601String(),
    });
  }

  // Check if a signup already exists with the same email or phone
  Future<bool> signupExists({required String email, String? phone}) async {
    final query = _supabase
        .from('signups')
        .select('id')
        .or('identifier.eq.$email${phone != null && phone.isNotEmpty ? ",phone.eq.$phone" : ""}')
        .limit(1);
    final result = await query;
    return result != null && result.isNotEmpty;
  }
}
