import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://192.168.100.109/studybuddy"; // Ganti sesuai IP lokal kamu

  // 🔐 Register
  static Future<String> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register.php"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('REGISTER status: ${response.statusCode}');
      print('REGISTER body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['message'] ?? "Registrasi berhasil";
      } else {
        return "Terjadi kesalahan server";
      }
    } catch (e) {
      return "Gagal terhubung ke server";
    }
  }

  // 🔐 Login
  static Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      print('LOGIN status: ${response.statusCode}');
      print('LOGIN body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        if (result['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', email);
          return "Login sukses";
        } else {
          return result['message'] ?? "Email atau password salah";
        }
      } else {
        return "Login gagal: server error";
      }
    } catch (e) {
      return "Login gagal: tidak bisa terhubung ke server";
    }
  }

  // 💾 Simpan email user
  static Future<void> saveCurrentUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  // 🔓 Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data yang disimpan
  }

  // ✅ Cek apakah user login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_email');
  }

  // ✅ Ambil email user saat ini
  static Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  // ✅ Ambil nama user dari server berdasarkan email
  static Future<String?> getUserNameFromServer(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/get_profile.php"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          return result['name'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ✅ Digunakan di HomeScreen: Ambil nama user saat ini
  static Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');

    if (email != null) {
      final name = await getUserNameFromServer(email);
      return name ?? email; // fallback ke email jika nama tidak tersedia
    }
    return null;
  }

  // 📝 Update nama user
  static Future<bool> updateUserName(String email, String newName) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/update_profile.php"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'name': newName,
        }),
      );

      final result = json.decode(response.body);
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // 📦 Ambil nama dan foto user (untuk HomeScreen atau Profile)
  static Future<Map<String, String?>> getUserProfile(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/get_profile.php"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          return {
            'name': result['name'],
            'profile_picture': result['profile_picture']
          };
        }
      }
      return {};
    } catch (e) {
      return {};

    }
  }
  // 🔴 Hapus Foto Profil
  static Future<bool> deleteProfilePicture(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/delete_profile_picture.php"),
        body: {'email': email},
      );
      final result = json.decode(response.body);
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
