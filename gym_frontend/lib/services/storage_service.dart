import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class StorageService {
  SharedPreferences? _prefs;
  String? _token;
  String? _role;
  Map<String, dynamic>? _user;
  bool _loaded = false;

  Future<SharedPreferences> _instance() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _hydrate() async {
    if (_loaded) return;
    final prefs = await _instance();
    _token = prefs.getString(AppConstants.tokenKey);
    _role = prefs.getString(AppConstants.roleKey);
    final raw = prefs.getString(AppConstants.userJsonKey);
    if (raw != null && raw.isNotEmpty) {
      _user = jsonDecode(raw) as Map<String, dynamic>;
    }
    _loaded = true;
  }

  Future<void> saveSession({
    required String token,
    required String role,
    Map<String, dynamic>? user,
  }) async {
    _token = token;
    _role = role;
    _user = user;
    _loaded = true;
    final prefs = await _instance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.roleKey, role);
    if (user != null) {
      await prefs.setString(AppConstants.userJsonKey, jsonEncode(user));
    }
  }

  Future<String?> getToken() async {
    await _hydrate();
    return _token;
  }

  Future<String?> getRole() async {
    await _hydrate();
    return _role;
  }

  Future<Map<String, dynamic>?> getUser() async {
    await _hydrate();
    return _user;
  }

  Future<void> clear() async {
    _token = null;
    _role = null;
    _user = null;
    _loaded = true;
    final prefs = await _instance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.roleKey);
    await prefs.remove(AppConstants.userJsonKey);
  }
}
