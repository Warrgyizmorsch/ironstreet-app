import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyToken = 'auth_token';
  static const String _keyEmail = 'auth_email';
  static const String _keyName = 'auth_name';
  static const String _keyCartToken = 'cart_token';
  static const String _keyNonce = 'cart_nonce';

  Future<void> saveCartToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCartToken, token);
  }

  Future<String> getCartToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCartToken) ?? '';
  }

  Future<void> saveNonce(String nonce) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNonce, nonce);
  }

  Future<String> getNonce() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNonce) ?? '';
  }

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

  static const String _keyAddresses = 'saved_addresses';

  Future<void> saveAddresses(String addressesJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAddresses, addressesJson);
  }

  Future<String> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAddresses) ?? '';
  }

  Future<void> clearNonce() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyNonce);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyName);
    await prefs.remove(_keyAddresses);
    await prefs.remove(_keyCartToken);
    await prefs.remove(_keyNonce);
    log('session clearing');
  }
}
