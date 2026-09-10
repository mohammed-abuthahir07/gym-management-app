import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._api, this._storage);

  final ApiService _api;
  final StorageService _storage;

  String? token;
  String? role;
  Map<String, dynamic>? user;
  bool ready = false;

  bool get isLoggedIn => token != null && token!.isNotEmpty && role != null;

  Future<void> load() async {
    token = await _storage.getToken();
    role = await _storage.getRole();
    user = await _storage.getUser();
    ready = true;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
    required String selectedRole,
  }) async {
    late String path;
    late String userKey;
    switch (selectedRole) {
      case 'ADMIN':
        path = '/api/admin/auth/login';
        userKey = 'admin';
      case 'TRAINER':
        path = '/api/trainer/auth/login';
        userKey = 'trainer';
      default:
        path = '/api/member/auth/login';
        userKey = 'user';
    }

    final data = await _api.post(
      path,
      body: {'email': email, 'password': password},
      auth: false,
    ) as Map<String, dynamic>;

    final nextToken = data['token'] as String?;
    if (nextToken == null || nextToken.isEmpty) {
      throw ApiException(401, 'Login failed');
    }

    final nextUser = data[userKey] is Map
        ? Map<String, dynamic>.from(data[userKey] as Map)
        : <String, dynamic>{};
    final nextRole = (nextUser['role'] as String?) ?? selectedRole;

    await _storage.saveSession(token: nextToken, role: nextRole, user: nextUser);
    token = nextToken;
    role = nextRole;
    user = nextUser;
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? fitnessGoal,
  }) async {
    await _api.post(
      '/api/member/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (fitnessGoal != null && fitnessGoal.isNotEmpty) 'fitness_goal': fitnessGoal,
      },
      auth: false,
    );
  }

  Future<void> logout() async {
    await _storage.clear();
    token = null;
    role = null;
    user = null;
    notifyListeners();
  }

  String homeRouteForRole() {
    return switch (role) {
      'ADMIN' => '/admin',
      'TRAINER' => '/trainer',
      'MEMBER' => '/member',
      _ => '/',
    };
  }
}
