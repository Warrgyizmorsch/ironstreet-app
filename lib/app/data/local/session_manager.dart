import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyToken = 'auth_token';
  static const String _keyEmail = 'auth_email';
  static const String _keyName = 'auth_name';

  Future<void> saveSession({
    required String token,
    required String email,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyName, name);
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken) ?? '';
  }

  Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? '';
  }

  Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName) ?? '';
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token.isNotEmpty;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyName);
  }
}
