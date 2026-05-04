import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final repository = AuthRepository();
  bool loading = false;
  bool obscure = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      _message('Semua data wajib diisi');
      return;
    }
    if (passwordController.text.length < 6) {
      _message('Password minimal 6 karakter');
      return;
    }
    if (passwordController.text != confirmController.text) {
      _message('Konfirmasi password tidak sama');
      return;
    }
    setState(() => loading = true);
    try {
      await repository.register(name: nameController.text, email: emailController.text, password: passwordController.text);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
    } catch (e) {
      _message(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Center(child: Text('👤', style: TextStyle(fontSize: 48))),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Buat akun baru', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: AppColors.ink)),
              const SizedBox(height: 8),
              const Text('Simpan resep favorit dan jadwal masakmu secara lokal di perangkat.', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600, height: 1.4)),
              const SizedBox(height: 24),
              TextField(controller: nameController, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded), hintText: 'Nama lengkap')),
              const SizedBox(height: 14),
              TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline_rounded), hintText: 'Email')),
              const SizedBox(height: 14),
              TextField(
                controller: passwordController,
                obscureText: obscure,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  hintText: 'Password',
                  suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(controller: confirmController, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.verified_user_outlined), hintText: 'Konfirmasi password')),
              const SizedBox(height: 22),
              PrimaryButton(text: loading ? 'Mendaftarkan...' : 'Daftar Sekarang', icon: Icons.arrow_forward_rounded, onPressed: loading ? null : _register),
            ],
          ),
        ),
      ),
    );
  }
}
