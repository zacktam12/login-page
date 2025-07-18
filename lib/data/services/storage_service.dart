import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save user data
  static Future<void> saveUserData(UserModel user) async {
    await init();
    await _prefs!.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
  }

  // Get user data
  static Future<UserModel?> getUserData() async {
    await init();
    final userData = _prefs!.getString(AppConstants.userDataKey);
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Save remember me preference
  static Future<void> saveRememberMe(bool remember) async {
    await init();
    await _prefs!.setBool(AppConstants.rememberMeKey, remember);
  }

  // Get remember me preference
  static Future<bool> getRememberMe() async {
    await init();
    return _prefs!.getBool(AppConstants.rememberMeKey) ?? false;
  }

  // Save user token
  static Future<void> saveUserToken(String token) async {
    await init();
    await _prefs!.setString(AppConstants.userTokenKey, token);
  }

  // Get user token
  static Future<String?> getUserToken() async {
    await init();
    return _prefs!.getString(AppConstants.userTokenKey);
  }

  // Clear all user data
  static Future<void> clearUserData() async {
    await init();
    await _prefs!.remove(AppConstants.userDataKey);
    await _prefs!.remove(AppConstants.userTokenKey);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }
}
