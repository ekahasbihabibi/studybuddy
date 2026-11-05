import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'session_store.dart';

class AccountApiException implements Exception {
  const AccountApiException(this.message);

  final String message;
}

/// Requests account endpoints without leaving the form waiting indefinitely.
class AccountApi {
  AccountApi({
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 12),
  }) : _client = client;

  final http.Client? _client;
  final Duration requestTimeout;

  Future<Map<String, dynamic>> submit(
    String endpoint,
    Map<String, String> fields, {
    bool authenticated = false,
  }) async {
    return request(endpoint, fields: fields, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> request(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, String>? query,
    bool authenticated = true,
    String? imagePath,
  }) async {
    final client = _client ?? http.Client();
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/$endpoint',
    ).replace(queryParameters: query);
    try {
      final headers = <String, String>{};
      if (authenticated) {
        final token = await SessionStore.token();
        if (token == null) {
          throw const AccountApiException('Silakan login terlebih dahulu.');
        }
        headers['Authorization'] = 'Bearer $token';
      }
      late http.Response response;
      if (imagePath != null) {
        final request = http.MultipartRequest('POST', url)
          ..headers.addAll(headers);
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
        response = await (() async {
          return http.Response.fromStream(await client.send(request));
        })().timeout(const Duration(seconds: 30));
      } else if (fields != null) {
        headers['Content-Type'] = 'application/json';
        response = await client
            .post(url, headers: headers, body: jsonEncode(fields))
            .timeout(requestTimeout);
      } else {
        response = await client
            .get(url, headers: headers)
            .timeout(requestTimeout);
      }

      if (response.statusCode >= 500) {
        throw const AccountApiException(
          'Layanan akun sedang bermasalah. Coba lagi nanti.',
        );
      }
      if (response.statusCode == 404) {
        throw const AccountApiException(
          'Layanan akun belum tersedia. Hubungi pengelola aplikasi.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['success'] is! bool) {
        throw const FormatException('Invalid account response');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (response.statusCode == 401 && authenticated) {
          await SessionStore.clear();
        }
        final message = decoded['message'];
        throw AccountApiException(
          message is String && message.isNotEmpty
              ? message
              : 'Permintaan akun tidak berhasil. Coba lagi.',
        );
      }
      return decoded;
    } on TimeoutException {
      debugPrint('Account API timeout: $url');
      throw const AccountApiException(
        'Waktu tunggu habis. Server akun belum merespons. Coba lagi nanti.',
      );
    } on SocketException {
      debugPrint('Account API connection failed: $url');
      throw const AccountApiException(
        'Tidak dapat terhubung ke server akun. Periksa koneksi dan coba lagi.',
      );
    } on http.ClientException {
      debugPrint('Account API connection failed: $url');
      throw const AccountApiException(
        'Tidak dapat terhubung ke server akun. Periksa koneksi dan coba lagi.',
      );
    } on FormatException {
      debugPrint('Account API returned an invalid response: $url');
      throw const AccountApiException(
        'Layanan akun belum dapat digunakan. Hubungi pengelola aplikasi.',
      );
    } finally {
      if (_client == null) client.close();
    }
  }
}
