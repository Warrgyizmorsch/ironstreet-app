import 'dart:developer';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager extends GetxService {
  static const String _keyToken = 'auth_token';
  static const String _keyEmail = 'auth_email';
  static const String _keyName = 'auth_name';
  static const String _keyCartToken = 'cart_token';
  static const String _keyNonce = 'cart_nonce';
  static const String _keyAddresses = 'saved_addresses';

  late final SharedPreferences _prefs;

  Future<SessionManager> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveCartToken(String token) async {
    await _prefs.setString(_keyCartToken, token);
  }

  String getCartToken() {
    return _prefs.getString(_keyCartToken) ?? '';
  }

  Future<void> saveNonce(String nonce) async {
    await _prefs.setString(_keyNonce, nonce);
  }

  String getNonce() {
    return _prefs.getString(_keyNonce) ?? '';
  }

  Future<void> saveSession({
    required String token,
    required String email,
    required String name,
  }) async {
    await _prefs.setString(_keyToken, token);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setString(_keyName, name);
  }

  String getToken() {
    return _prefs.getString(_keyToken) ?? '';
  }

  String getEmail() {
    return _prefs.getString(_keyEmail) ?? '';
  }

  String getName() {
    return _prefs.getString(_keyName) ?? '';
  }

  bool isLoggedIn() {
    return getToken().isNotEmpty;
  }

  Future<void> saveAddresses(String addressesJson) async {
    await _prefs.setString(_keyAddresses, addressesJson);
  }

  String getAddresses() {
    return _prefs.getString(_keyAddresses) ?? '';
  }

  Future<void> clearNonce() async {
    await _prefs.remove(_keyNonce);
  }

  static const String _keyThemeMode = 'theme_mode';

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyName);
    await _prefs.remove(_keyAddresses);
    await _prefs.remove(_keyCartToken);
    await _prefs.remove(_keyNonce);
    log('session clearing');
  }
}
