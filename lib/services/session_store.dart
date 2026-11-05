import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Only the device session is stored locally; accounts live in MySQL.
class SessionStore {
  static const _storage = FlutterSecureStorage();
  static const _key = 'studybuddy_session_v1';

  static Future<Map<String, dynamic>?> _read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      final value = jsonDecode(raw);
      if (value is Map<String, dynamic> &&
          value['email'] is String &&
          value['token'] is String &&
          RegExp(r'^[a-f0-9]{64}$').hasMatch(value['token'] as String)) {
        return value;
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  static Future<void> save(String email, String token) async {
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(token)) {
      throw const FormatException('Invalid session token');
    }
    await _storage.write(
      key: _key,
      value: jsonEncode({'email': email, 'token': token}),
    );
  }

  static Future<String?> token() async => (await _read())?['token'] as String?;
  static Future<String?> email() async => (await _read())?['email'] as String?;
  static Future<void> clear() => _storage.delete(key: _key);
}
