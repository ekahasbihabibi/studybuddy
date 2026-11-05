import 'package:flutter/material.dart';
import 'package:studybuddy/services/auth_service.dart';
import '../services/account_api.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.accountApi});

  final AccountApi? accountApi;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  late AnimationController _imageAnimController;
  late Animation<Offset> _imageSlideAnimation;

  late AnimationController _formAnimController;
  late Animation<double> _formScaleAnimation;

  @override
  void initState() {
    super.initState();

    _imageAnimController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _imageSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _imageAnimController,
            curve: Curves.easeOutExpo,
          ),
        );

    _formAnimController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _formScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _formAnimController, curve: Curves.elasticOut),
    );

    _imageAnimController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _formAnimController.forward();
    });
  }

  @override
  void dispose() {
    _imageAnimController.dispose();
    _formAnimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isSubmitting) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Email dan password wajib diisi');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final data = await (widget.accountApi ?? AccountApi()).submit(
        'login.php',
        {'email': email, 'password': password},
      );
      if (!mounted) return;
      if (data['success'] == true) {
        await AuthService.saveSession(email, data);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(
          () => _errorMessage = data['message'] is String
              ? data['message'] as String
              : 'Email atau password tidak sesuai.',
        );
      }
    } on AccountApiException catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Login belum berhasil. Coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C6EF5), Color(0xFF5C7CFA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _imageSlideAnimation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/login_illustration.png',
                      height: 170,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to StudyBuddy',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Belajar Lebih Mudah dan Terarah',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 30),
                ScaleTransition(
                  scale: _formScaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          enabled: !_isSubmitting,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          enabled: !_isSubmitting,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RegisterScreen(
                                        accountApi: widget.accountApi,
                                        onRegister: (email, password) {
                                          _emailController.text = email;
                                          _passwordController.text = password;
                                        },
                                      ),
                                    ),
                                  );
                                },
                          child: const Text(
                            'Belum punya akun? Daftar',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
