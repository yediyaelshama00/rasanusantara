import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/biometric_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final repository = AuthRepository();
  AppUser? user;
  bool loading = true;
  bool biometricLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await repository.getCurrentUser();
    if (!mounted) return;
    setState(() {
      user = data;
      loading = false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (biometricLoading) return;

    setState(() {
      biometricLoading = true;
    });

    try {
      if (value) {
        final available = await BiometricService().isAvailable();

        if (!available) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Biometrik belum tersedia. Pastikan fingerprint/face unlock sudah aktif di HP.',
              ),
            ),
          );

          return;
        }

        final ok = await BiometricService().authenticate();

        if (!ok) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Autentikasi biometrik dibatalkan atau gagal.'),
            ),
          );

          return;
        }
      }

      await repository.setBiometric(value);
      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Login biometrik berhasil diaktifkan.'
                : 'Login biometrik berhasil dinonaktifkan.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Biometrik gagal diproses: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          biometricLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await repository.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                children: [
                  const Text('Profil', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: AppColors.ink, letterSpacing: -0.5)),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.spiceBrown, AppColors.terracotta], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(34),
                      boxShadow: [BoxShadow(color: AppColors.spiceBrown.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 12))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.32))),
                          child: const Center(child: Text('👨‍🍳', style: TextStyle(fontSize: 34))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(user?.name ?? 'Pengguna', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 5),
                            Text(user?.email ?? '', style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _MenuCard(
                    children: [
                      SwitchListTile(
                        value: user?.biometricEnabled ?? false,
                        onChanged: biometricLoading ? null : _toggleBiometric,
                        secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.spiceBrown),
                        title: const Text('Login Biometrik', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink)),
                        subtitle: const Text('Gunakan fingerprint atau face unlock', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
                        activeThumbColor: AppColors.spiceBrown,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _MenuCard(
                    children: [
                      _MenuTile(icon: Icons.rate_review_outlined, title: 'Saran dan Kesan TPM', subtitle: 'Simpan kesan mata kuliah', onTap: () => Navigator.pushNamed(context, AppRoutes.feedback)),
                      _Divider(),
                      _MenuTile(icon: Icons.info_outline_rounded, title: 'Tentang Aplikasi', subtitle: 'RasaNusantara versi tugas akhir', onTap: () => _showAbout(context)),
                      _Divider(),
                      _MenuTile(icon: Icons.logout_rounded, title: 'Logout', subtitle: 'Keluar dari sesi perangkat ini', danger: true, onTap: _logout),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
        decoration: const BoxDecoration(color: AppColors.ivory, borderRadius: BorderRadius.vertical(top: Radius.circular(34))),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RasaNusantara', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink)),
            SizedBox(height: 10),
            Text('Aplikasi mobile resep tradisional Indonesia dengan SQLite, session, biometric login, LBS, sensor, AI rekomendasi, mini game, konversi mata uang, konversi waktu, dan notifikasi.', style: TextStyle(color: AppColors.muted, height: 1.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;

  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: AppColors.line)),
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _MenuTile({required this.icon, required this.title, required this.subtitle, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.terracotta : AppColors.spiceBrown;
    return ListTile(
      onTap: onTap,
      leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.chevron_right_rounded, color: color),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.line, indent: 72);
  }
}
