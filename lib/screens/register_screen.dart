import 'package:flutter/material.dart';
import '../services/account_api.dart';

class RegisterScreen extends StatefulWidget {
  final Function(String email, String password) onRegister;

  const RegisterScreen({super.key, required this.onRegister, this.accountApi});

  final AccountApi? accountApi;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController(); // <- Nama
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isSubmitting) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.length < 8) {
      setState(
        () => _errorMessage =
            'Semua data wajib diisi, dan password min 8 karakter',
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final data = await (widget.accountApi ?? AccountApi()).submit(
        'register.php',
        {'name': name, 'email': email, 'password': password},
      );
      if (!mounted) return;
      if (data['success'] == true) {
        widget.onRegister(email, password);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] is String
                  ? data['message'] as String
                  : 'Akun berhasil dibuat. Silakan masuk.',
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        setState(
          () => _errorMessage = data['message'] is String
              ? data['message'] as String
              : 'Pendaftaran belum berhasil. Coba lagi.',
        );
      }
    } on AccountApiException catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage = 'Pendaftaran belum berhasil. Coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.app_registration, size: 80, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Buat Akun Baru',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),

              TextField(
                controller: _nameController,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _emailController,
                enabled: !_isSubmitting,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                enabled: !_isSubmitting,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _register,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isSubmitting ? 'Mendaftar...' : 'Daftar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Sudah punya akun? Masuk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
