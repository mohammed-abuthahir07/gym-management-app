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

class ApiService {
  ApiService(this._storage);

  final StorageService _storage;

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

  Future<dynamic> get(String path, {bool auth = true}) async {
    final response = await http.get(_uri(path), headers: await _headers(auth: auth));
    return _decode(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final response = await http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body ?? {}),
    );
    return _decode(response);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final response = await http.put(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body ?? {}),
    );
    return _decode(response);
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    final response = await http.delete(_uri(path), headers: await _headers(auth: auth));
    return _decode(response);
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
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
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
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
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
      409 => 'This action conflicts with existing data.',
      500 => 'Something went wrong. Please try again.',
      _ => 'Request failed. Please try again.',
    };
  }
}
