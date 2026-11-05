import 'package:shared_preferences/shared_preferences.dart';
import 'account_api.dart';
import 'session_store.dart';

class AuthService {
  static Future<void> saveSession(
    String email,
    Map<String, dynamic> response,
  ) async {
    final token = response['access_token'];
    final user = response['user'];
    if (response['success'] != true ||
        token is! String ||
        user is! Map ||
        user['email'] is! String ||
        (user['email'] as String).toLowerCase() != email.trim().toLowerCase()) {
      throw const AccountApiException(
        'Sesi dari server tidak valid. Silakan coba login kembali.',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    final previousEmail =
        await SessionStore.email() ?? prefs.getString('user_email');
    if (previousEmail != null &&
        previousEmail.toLowerCase() != email.trim().toLowerCase()) {
      if (!await prefs.clear()) {
        throw const AccountApiException(
          'Data akun sebelumnya belum dapat dibersihkan. Coba login kembali.',
        );
      }
    } else {
      await prefs.remove('user_email'); // Remove the legacy email-only session.
    }
    try {
      await SessionStore.save(user['email'] as String, token);
    } on FormatException {
      throw const AccountApiException(
        'Sesi dari server tidak valid. Silakan coba login kembali.',
      );
    }
  }

  static Future<bool> isLoggedIn() async => await SessionStore.token() != null;
  static Future<String?> getCurrentUserEmail() => SessionStore.email();

  static Future<void> logout() async {
    try {
      if (await SessionStore.token() != null) {
        await AccountApi().submit('logout.php', {}, authenticated: true);
      }
    } on AccountApiException {
      // Local logout still works when the server is unreachable. The remote
      // session then expires automatically; online logout revokes it immediately.
    } finally {
      await SessionStore.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  // Keep the existing caller signature. Identity is always taken from the
  // bearer token by the server, never from a client-supplied email address.
  static Future<Map<String, String?>> getUserProfile(String email) async {
    final data = await AccountApi().request('get_profile.php');
    return {
      'email': data['email'] as String?,
      'name': data['name'] as String?,
      'profile_picture': data['profile_picture'] as String?,
    };
  }

  static Future<String?> getUserNameFromServer(String email) async =>
      (await getUserProfile(email))['name'];

  static Future<String?> getCurrentUserName() async {
    final email = await getCurrentUserEmail();
    if (email == null) return null;
    return await getUserNameFromServer(email) ?? email;
  }

  static Future<bool> updateUserName(String email, String newName) async {
    try {
      final data = await AccountApi().submit('update_profile.php', {
        'name': newName,
      }, authenticated: true);
      return data['success'] == true;
    } on AccountApiException {
      return false;
    }
  }

  static Future<String?> uploadProfilePicture(String path) async {
    final data = await AccountApi().request(
      'upload_profile.php',
      imagePath: path,
    );
    return data['profile_picture'] as String?;
  }

  static Future<bool> deleteProfilePicture(String email) async {
    try {
      final data = await AccountApi().submit(
        'delete_profile_picture.php',
        {},
        authenticated: true,
      );
      return data['success'] == true;
    } on AccountApiException {
      return false;
    }
  }
}
