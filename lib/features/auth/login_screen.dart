import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/biometric_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repository = AuthRepository();
  bool loading = false;
  bool obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _message('Email dan password wajib diisi');
      return;
    }
    setState(() => loading = true);
    try {
      await repository.login(
          email: emailController.text, password: passwordController.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } catch (e) {
      _message(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _biometricLogin() async {
    final ok = await BiometricService().authenticate();

    if (!ok) {
      _message('Autentikasi biometrik dibatalkan');
      return;
    }

    try {
      await repository.loginWithBiometric();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } catch (e) {
      _message(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: const LinearGradient(
                    colors: [AppColors.spiceBrown, AppColors.terracotta],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.spiceBrown.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 12))
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                        right: -24, top: -30, child: _Ornament(size: 120)),
                    Positioned(
                        left: -18, bottom: -18, child: _Ornament(size: 96)),
                    const Padding(
                      padding: EdgeInsets.all(26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('RasaNusantara',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 31,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1)),
                          SizedBox(height: 8),
                          Text(
                              'Masuk dan lanjutkan jelajah resep tradisional Indonesia.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text('Selamat datang kembali',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink)),
              const SizedBox(height: 8),
              const Text('Gunakan akun yang sudah kamu buat di perangkat ini.',
                  style: TextStyle(
                      color: AppColors.muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 22),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                    hintText: 'Email'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: passwordController,
                obscureText: obscure,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                  text: loading ? 'Memproses...' : 'Masuk',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: loading ? null : _login),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _biometricLogin,
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text('Masuk dengan Biometrik'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  foregroundColor: AppColors.spiceBrown,
                  side: const BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun?',
                      style: TextStyle(
                          color: AppColors.muted, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                    child: const Text('Daftar',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.terracotta)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ornament extends StatelessWidget {
  final double size;

  const _Ornament({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.12),
      ),
    );
  }
}
