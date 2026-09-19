import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class _CacheEntry {
  _CacheEntry(this.data, this.expiresAt);
  final dynamic data;
  final DateTime expiresAt;
  bool get isFresh => DateTime.now().isBefore(expiresAt);
}

class ApiService {
  ApiService(this._storage);

  final StorageService _storage;
  final http.Client _client = http.Client();
  final Map<String, _CacheEntry> _getCache = {};
  final Map<String, Future<dynamic>> _inFlightGets = {};

  static const _timeout = Duration(seconds: 20);
  static const _publicTtl = Duration(seconds: 45);

  Future<Map<String, String>> _headers({bool auth = true, bool json = true}) async {
    final headers = <String, String>{
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  bool _isPublicCacheable(String path) {
    return path == '/api/plans' ||
        path == '/api/promotions' ||
        path == '/api/content' ||
        path == '/api/trainers';
  }

  dynamic _cachedGet(String path) {
    final hit = _getCache[path];
    if (hit != null && hit.isFresh) return hit.data;
    if (hit != null) _getCache.remove(path);
    return null;
  }

  void _storeGet(String path, dynamic data) {
    _getCache[path] = _CacheEntry(data, DateTime.now().add(_publicTtl));
  }

  void invalidateCache() {
    _getCache.clear();
  }

  Future<dynamic> get(String path, {bool auth = true}) async {
    if (_isPublicCacheable(path)) {
      final cached = _cachedGet(path);
      if (cached != null) return cached;
    }

    final existing = _inFlightGets[path];
    if (existing != null) return existing;

    final future = () async {
      try {
        final response = await _client
            .get(_uri(path), headers: await _headers(auth: auth))
            .timeout(_timeout);
        final data = _decode(response);
        if (_isPublicCacheable(path)) {
          _storeGet(path, data);
        }
        return data;
      } on TimeoutException {
        throw ApiException(408, 'The request timed out. Please try again.');
      } on SocketException {
        throw ApiException(503, 'Unable to reach the server. Check your connection.');
      } finally {
        _inFlightGets.remove(path);
      }
    }();

    _inFlightGets[path] = future;
    return future;
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final response = await _client
          .post(
            _uri(path),
            headers: await _headers(auth: auth),
            body: jsonEncode(body ?? {}),
          )
          .timeout(_timeout);
      invalidateCache();
      return _decode(response);
    } on TimeoutException {
      throw ApiException(408, 'The request timed out. Please try again.');
    } on SocketException {
      throw ApiException(503, 'Unable to reach the server. Check your connection.');
    }
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final response = await _client
          .put(
            _uri(path),
            headers: await _headers(auth: auth),
            body: jsonEncode(body ?? {}),
          )
          .timeout(_timeout);
      invalidateCache();
      return _decode(response);
    } on TimeoutException {
      throw ApiException(408, 'The request timed out. Please try again.');
    } on SocketException {
      throw ApiException(503, 'Unable to reach the server. Check your connection.');
    }
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    try {
      final response = await _client
          .delete(_uri(path), headers: await _headers(auth: auth))
          .timeout(_timeout);
      invalidateCache();
      return _decode(response);
    } on TimeoutException {
      throw ApiException(408, 'The request timed out. Please try again.');
    } on SocketException {
      throw ApiException(503, 'Unable to reach the server. Check your connection.');
    }
  }

  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> fields,
    File? file,
    String fileField = 'image',
    bool auth = true,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.headers.addAll(await _headers(auth: auth, json: false));
    request.fields.addAll(fields);
    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    }
    try {
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      invalidateCache();
      return _decode(response);
    } on TimeoutException {
      throw ApiException(408, 'The request timed out. Please try again.');
    } on SocketException {
      throw ApiException(503, 'Unable to reach the server. Check your connection.');
    }
  }

  Future<dynamic> putMultipart(
    String path, {
    required Map<String, String> fields,
    File? file,
    String fileField = 'image',
    bool auth = true,
  }) async {
    final request = http.MultipartRequest('PUT', _uri(path));
    request.headers.addAll(await _headers(auth: auth, json: false));
    request.fields.addAll(fields);
    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    }
    try {
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      invalidateCache();
      return _decode(response);
    } on TimeoutException {
      throw ApiException(408, 'The request timed out. Please try again.');
    } on SocketException {
      throw ApiException(503, 'Unable to reach the server. Check your connection.');
    }
  }

  dynamic _decode(http.Response response) {
    dynamic data;
    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {'message': response.body};
      }
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw ApiException(response.statusCode, _messageFrom(data, response.statusCode));
  }

  String _messageFrom(dynamic data, int status) {
    if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }
    return switch (status) {
      400 => 'Please check the submitted details.',
      401 => 'Please sign in again.',
      403 => 'You do not have access to this action.',
      404 => 'The requested item was not found.',
      408 => 'The request timed out. Please try again.',
      409 => 'This action conflicts with existing data.',
      500 => 'Something went wrong. Please try again.',
      _ => 'Request failed. Please try again.',
    };
  }
}
