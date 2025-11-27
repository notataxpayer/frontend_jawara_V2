import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const String _keyToken = 'auth_token';
  static const String _keyUserData = 'user_data';

  /// Save user data and token after login
  static Future<void> saveUserData({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserData, jsonEncode(userData));
  }

  /// Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Get saved user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_keyUserData);
    if (userDataString != null) {
      final decoded = jsonDecode(userDataString);
      return Map<String, dynamic>.from(decoded as Map);
    }
    return null;
  }

  /// Get user name
  static Future<String> getUserName() async {
    final userData = await getUserData();
    return userData?['nama'] ?? userData?['name'] ?? 'User';
  }

  /// Get user email
  static Future<String> getUserEmail() async {
    final userData = await getUserData();
    return userData?['email'] ?? '';
  }

  /// Get user role
  static Future<String> getUserRole() async {
    final userData = await getUserData();
    return userData?['role'] ?? 'warga';
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all user data (logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserData);
  }

  /// Get user initial for avatar
  static Future<String> getUserInitial() async {
    final name = await getUserName();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
