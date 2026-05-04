import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
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
  bool obscurePassword = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  String _errorMessage(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }

    if (text.contains('PlatformException')) {
      return 'Aksi gagal diproses oleh perangkat';
    }

    return text.replaceAll('Exception: ', '');
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    final confirm = confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _message('Semua data wajib diisi');
      return;
    }

    if (name.length < 3) {
      _message('Nama minimal 3 karakter');
      return;
    }

    if (!_isValidEmail(email)) {
      _message('Format email tidak valid');
      return;
    }

    if (password.length < 6) {
      _message('Password minimal 6 karakter');
      return;
    }

    if (password != confirm) {
      _message('Konfirmasi password tidak sama');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await repository.register(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
        (_) => false,
      );
    } catch (e) {
      _message(_errorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _back() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
          child: Column(
            children: [
              Row(
                children: [
                  _SmallRoundButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: loading ? null : _back,
                  ),
                  const Expanded(
                    child: _TopTitle(),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 24),
              _GamePanel(
                label: 'Daftar Akun',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 38, 18, 20),
                  child: Column(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.spiceBrown,
                            width: 2.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: AppColors.spiceBrown,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Buat Akun Baru',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Daftar untuk mulai menyimpan profil dan menjelajahi resep Nusantara.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w800,
                          height: 1.45,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _GameTextField(
                        controller: nameController,
                        hint: 'Nama lengkap',
                        icon: Icons.person_outline_rounded,
                        enabled: !loading,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      _GameTextField(
                        controller: emailController,
                        hint: 'Email',
                        icon: Icons.mail_outline_rounded,
                        enabled: !loading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      _GameTextField(
                        controller: passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        enabled: !loading,
                        obscureText: obscurePassword,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          onPressed: loading
                              ? null
                              : () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.spiceBrown,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _GameTextField(
                        controller: confirmController,
                        hint: 'Konfirmasi password',
                        icon: Icons.verified_user_outlined,
                        enabled: !loading,
                        obscureText: obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => loading ? null : _register(),
                        suffixIcon: IconButton(
                          onPressed: loading
                              ? null
                              : () {
                                  setState(() {
                                    obscureConfirm = !obscureConfirm;
                                  });
                                },
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.spiceBrown,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: loading ? null : _register,
                          icon: loading
                              ? const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.3,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward_rounded),
                          label: Text(
                            loading ? 'Mendaftarkan...' : 'Daftar Sekarang',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenEnd,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.greenEnd.withOpacity(0.45),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: const BorderSide(
                                color: AppColors.greenShadow,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _LoginPanel(
                onTap: loading ? null : _goToLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopTitle extends StatelessWidget {
  const _TopTitle();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'RasaNusantara',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.darkBrown,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.9,
        ),
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  final VoidCallback? onTap;

  const _LoginPanel({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      label: 'Sudah Terdaftar',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 32, 18, 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.spiceBrown,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.login_rounded,
                color: AppColors.spiceBrown,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sudah punya akun?',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Masuk untuk lanjut ke aplikasi.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _SmallRoundButton(
              icon: Icons.arrow_forward_rounded,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _GamePanel extends StatelessWidget {
  final String label;
  final Widget child;

  const _GamePanel({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.spiceBrown,
          width: 2.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            top: -15,
            left: 14,
            right: 14,
            child: _Ribbon(label: label),
          ),
        ],
      ),
    );
  }
}

class _Ribbon extends StatelessWidget {
  final String label;

  const _Ribbon({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(minWidth: 112),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.ribbonGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.ribbonShadow,
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _GameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  const _GameTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.enabled,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(
          icon,
          color: AppColors.spiceBrown,
        ),
        suffixIcon: suffixIcon,
        hintStyle: TextStyle(
          color: AppColors.muted.withOpacity(0.70),
          fontWeight: FontWeight.w700,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.spiceBrown,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.spiceBrown.withOpacity(0.38),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.spiceBrown,
            width: 1.9,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.spiceBrown.withOpacity(0.16),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

class _SmallRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SmallRoundButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.greenEnd,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.greenShadow,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}