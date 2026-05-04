import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
  final picker = ImagePicker();

  AppUser? user;
  bool loading = true;
  bool biometricLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _errorMessage(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }

    if (text.contains('PlatformException')) {
      return 'Aksi gagal diproses oleh perangkat';
    }

    if (text.contains('PathNotFoundException')) {
      return 'File gambar tidak ditemukan';
    }

    if (text.contains('FileSystemException')) {
      return 'Gagal menyimpan file gambar';
    }

    return 'Terjadi kesalahan. Coba lagi';
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  Future<void> _load() async {
    try {
      final data = await repository.getCurrentUser();

      if (!mounted) return;

      setState(() {
        user = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showSnack('Gagal memuat profil: ${_errorMessage(e)}');
    }
  }

  Future<String> _saveImageToAppFolder(XFile image) async {
    try {
      final originalFile = File(image.path);

      if (!await originalFile.exists()) {
        throw Exception('File gambar tidak ditemukan');
      }

      final directory = await getApplicationDocumentsDirectory();

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await originalFile.copy('${directory.path}/$fileName');

      if (!await savedImage.exists()) {
        throw Exception('Gagal menyimpan gambar profil');
      }

      return savedImage.path;
    } catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Widget _buildProfileImage({
    double size = 78,
    bool light = true,
  }) {
    final photoPath = user?.photoPath;
    final hasPhoto = photoPath != null &&
        photoPath.isNotEmpty &&
        File(photoPath).existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: light ? AppColors.paper : AppColors.cream,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.spiceBrown,
          width: 2.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.file(
                File(photoPath),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Icon(
                    Icons.person_rounded,
                    color: AppColors.spiceBrown,
                    size: size * 0.48,
                  );
                },
              )
            : Icon(
                Icons.person_rounded,
                color: AppColors.spiceBrown,
                size: size * 0.48,
              ),
      ),
    );
  }

  Widget _buildFormError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.terracotta.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.terracotta.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.terracotta,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.terracotta,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProfile() async {
    if (user == null) {
      _showSnack('Data user tidak ditemukan. Silakan login ulang.');
      return;
    }

    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    String? selectedPhotoPath = user?.photoPath;
    String? formError;

    bool saving = false;
    bool verifiedByBiometric = false;
    bool obscureOldPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return WillPopScope(
          onWillPop: () async => !saving,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final hasPhoto = selectedPhotoPath != null &&
                  selectedPhotoPath!.isNotEmpty &&
                  File(selectedPhotoPath!).existsSync();

              void showFormError(String message) {
                setSheetState(() {
                  formError = message;
                  saving = false;
                });
              }

              void clearFormError() {
                setSheetState(() {
                  formError = null;
                });
              }

              Future<void> verifyWithBiometric() async {
                if (saving) return;

                clearFormError();

                try {
                  if (!(user?.biometricEnabled ?? false)) {
                    showFormError('Biometrik belum diaktifkan untuk akun ini.');
                    return;
                  }

                  final available = await BiometricService().isAvailable();

                  if (!available) {
                    showFormError(
                      'Biometrik belum tersedia. Pastikan fingerprint/face unlock sudah aktif di HP.',
                    );
                    return;
                  }

                  final ok = await BiometricService().authenticate();

                  if (!ok) {
                    showFormError('Verifikasi biometrik gagal atau dibatalkan.');
                    return;
                  }

                  setSheetState(() {
                    verifiedByBiometric = true;
                    currentPasswordController.clear();
                    formError = null;
                  });
                } catch (e) {
                  showFormError('Biometrik gagal diproses: ${_errorMessage(e)}');
                }
              }

              Future<void> pickProfileImage() async {
                if (saving) return;

                clearFormError();

                try {
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 75,
                    maxWidth: 800,
                  );

                  if (image == null) {
                    showFormError('Pemilihan gambar dibatalkan.');
                    return;
                  }

                  final savedPath = await _saveImageToAppFolder(image);

                  setSheetState(() {
                    selectedPhotoPath = savedPath;
                    formError = null;
                  });
                } catch (e) {
                  showFormError(_errorMessage(e));
                }
              }

              Future<void> saveAccount() async {
                if (saving) return;

                clearFormError();

                final name = nameController.text.trim();
                final email = emailController.text.trim().toLowerCase();
                final currentPassword = currentPasswordController.text;
                final newPassword = newPasswordController.text.trim();
                final confirmPassword = confirmPasswordController.text.trim();

                if (name.isEmpty) {
                  showFormError('Nama tidak boleh kosong.');
                  return;
                }

                if (name.length < 3) {
                  showFormError('Nama minimal 3 karakter.');
                  return;
                }

                if (name.length > 40) {
                  showFormError('Nama maksimal 40 karakter.');
                  return;
                }

                if (email.isEmpty) {
                  showFormError('Email tidak boleh kosong.');
                  return;
                }

                if (!_isValidEmail(email)) {
                  showFormError('Format email tidak valid.');
                  return;
                }

                if (!verifiedByBiometric && currentPassword.trim().isEmpty) {
                  showFormError(
                    'Masukkan password lama atau verifikasi pakai biometrik.',
                  );
                  return;
                }

                if (newPassword.isEmpty && confirmPassword.isNotEmpty) {
                  showFormError('Isi password baru terlebih dahulu.');
                  return;
                }

                if (newPassword.isNotEmpty && newPassword.length < 6) {
                  showFormError('Password baru minimal 6 karakter.');
                  return;
                }

                if (newPassword.isNotEmpty &&
                    !verifiedByBiometric &&
                    newPassword == currentPassword) {
                  showFormError(
                    'Password baru tidak boleh sama dengan password lama.',
                  );
                  return;
                }

                if (newPassword.isNotEmpty && confirmPassword.isEmpty) {
                  showFormError('Konfirmasi password baru wajib diisi.');
                  return;
                }

                if (newPassword.isNotEmpty && newPassword != confirmPassword) {
                  showFormError('Konfirmasi password baru tidak sama.');
                  return;
                }

                setSheetState(() {
                  saving = true;
                  formError = null;
                });

                try {
                  await repository.updateAccount(
                    name: name,
                    email: email,
                    photoPath: selectedPhotoPath,
                    currentPassword: currentPassword,
                    verifiedByBiometric: verifiedByBiometric,
                    newPassword: newPassword.isEmpty ? null : newPassword,
                  );

                  if (!mounted) return;

                  Navigator.of(sheetContext).pop(true);
                } catch (e) {
                  if (!mounted) return;

                  showFormError(_errorMessage(e));
                }
              }

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.92,
                  ),
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(
                      color: AppColors.spiceBrown,
                      width: 2.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: _RibbonTitle(text: 'Edit Akun'),
                            ),
                            const SizedBox(width: 10),
                            _SmallRoundButton(
                              icon: Icons.close_rounded,
                              onTap: saving
                                  ? null
                                  : () {
                                      Navigator.of(sheetContext).pop(false);
                                    },
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: saving ? null : pickProfileImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 108,
                                height: 108,
                                decoration: BoxDecoration(
                                  color: AppColors.cream,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.spiceBrown,
                                    width: 2.6,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x26000000),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: hasPhoto
                                      ? Image.file(
                                          File(selectedPhotoPath!),
                                          width: 108,
                                          height: 108,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) {
                                            return const Center(
                                              child: Icon(
                                                Icons.person_rounded,
                                                size: 46,
                                                color: AppColors.spiceBrown,
                                              ),
                                            );
                                          },
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.person_rounded,
                                            size: 46,
                                            color: AppColors.spiceBrown,
                                          ),
                                        ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: AppColors.greenEnd,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x26000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _GameTextField(
                          controller: nameController,
                          label: 'Username / Nama',
                          hint: 'Masukkan username baru',
                          icon: Icons.person_outline_rounded,
                          enabled: !saving,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _GameTextField(
                          controller: emailController,
                          label: 'Email',
                          hint: 'Masukkan email baru',
                          icon: Icons.email_outlined,
                          enabled: !saving,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        _EditSection(
                          title: 'Verifikasi Keamanan',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                verifiedByBiometric
                                    ? 'Sudah diverifikasi dengan biometrik.'
                                    : 'Masukkan password lama. Jika login biometrik aktif, kamu juga bisa verifikasi pakai biometrik.',
                                style: const TextStyle(
                                  color: AppColors.softChocolate,
                                  fontWeight: FontWeight.w700,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (!verifiedByBiometric)
                                _GameTextField(
                                  controller: currentPasswordController,
                                  label: 'Password Lama',
                                  hint: 'Wajib untuk menyimpan perubahan',
                                  icon: Icons.lock_outline_rounded,
                                  enabled: !saving,
                                  obscureText: obscureOldPassword,
                                  textInputAction: TextInputAction.next,
                                  suffixIcon: IconButton(
                                    onPressed: saving
                                        ? null
                                        : () {
                                            setSheetState(() {
                                              obscureOldPassword =
                                                  !obscureOldPassword;
                                            });
                                          },
                                    icon: Icon(
                                      obscureOldPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.spiceBrown,
                                    ),
                                  ),
                                ),
                              if (user?.biometricEnabled ?? false) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    onPressed: verifiedByBiometric || saving
                                        ? null
                                        : verifyWithBiometric,
                                    icon: Icon(
                                      verifiedByBiometric
                                          ? Icons.verified_rounded
                                          : Icons.fingerprint_rounded,
                                    ),
                                    label: Text(
                                      verifiedByBiometric
                                          ? 'Biometrik Terverifikasi'
                                          : 'Verifikasi Pakai Biometrik',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.spiceBrown,
                                      side: const BorderSide(
                                        color: AppColors.spiceBrown,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _GameTextField(
                          controller: newPasswordController,
                          label: 'Password Baru',
                          hint: 'Kosongkan jika tidak ingin mengganti',
                          icon: Icons.lock_reset_rounded,
                          enabled: !saving,
                          obscureText: obscureNewPassword,
                          textInputAction: TextInputAction.next,
                          suffixIcon: IconButton(
                            onPressed: saving
                                ? null
                                : () {
                                    setSheetState(() {
                                      obscureNewPassword = !obscureNewPassword;
                                    });
                                  },
                            icon: Icon(
                              obscureNewPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.spiceBrown,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _GameTextField(
                          controller: confirmPasswordController,
                          label: 'Konfirmasi Password Baru',
                          hint: 'Ulangi password baru',
                          icon: Icons.lock_person_rounded,
                          enabled: !saving,
                          obscureText: obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          suffixIcon: IconButton(
                            onPressed: saving
                                ? null
                                : () {
                                    setSheetState(() {
                                      obscureConfirmPassword =
                                          !obscureConfirmPassword;
                                    });
                                  },
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.spiceBrown,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (formError != null) ...[
                          _buildFormError(formError!),
                          const SizedBox(height: 14),
                        ],
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.greenEnd,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  AppColors.greenEnd.withOpacity(0.45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: const BorderSide(
                                  color: AppColors.greenShadow,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onPressed: saving ? null : saveAccount,
                            child: saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    if (updated == true && mounted) {
      await _load();
      _showSnack('Akun berhasil diperbarui.');
    }
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
          _showSnack(
            'Biometrik belum tersedia. Pastikan fingerprint/face unlock sudah aktif di HP.',
          );
          return;
        }

        final ok = await BiometricService().authenticate();

        if (!ok) {
          _showSnack('Autentikasi biometrik dibatalkan atau gagal.');
          return;
        }
      }

      await repository.setBiometric(value);
      await _load();

      if (!mounted) return;

      _showSnack(
        value
            ? 'Login biometrik berhasil diaktifkan.'
            : 'Login biometrik berhasil dinonaktifkan.',
      );
    } catch (e) {
      _showSnack('Biometrik gagal diproses: ${_errorMessage(e)}');
    } finally {
      if (mounted) {
        setState(() {
          biometricLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await repository.logout();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (_) => false,
      );
    } catch (e) {
      _showSnack('Logout gagal: ${_errorMessage(e)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.ivory,
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                children: [
                  const _TopTitle(),
                  const SizedBox(height: 22),
                  _GamePanel(
                    label: 'Akun Saya',
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 36, 18, 18),
                      child: Row(
                        children: [
                          _buildProfileImage(size: 76),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Pengguna',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  user?.email ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          _SmallRoundButton(
                            icon: Icons.edit_rounded,
                            onTap: _showEditProfile,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _GamePanel(
                    label: 'Keamanan',
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 26, 10, 8),
                      child: SwitchListTile(
                        value: user?.biometricEnabled ?? false,
                        onChanged: biometricLoading ? null : _toggleBiometric,
                        secondary: _IconBubble(
                          icon: Icons.fingerprint_rounded,
                        ),
                        title: const Text(
                          'Login Biometrik',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        subtitle: const Text(
                          'Gunakan fingerprint atau face unlock',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        activeThumbColor: AppColors.greenEnd,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _GamePanel(
                    label: 'Menu',
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
                      child: Column(
                        children: [
                          _MenuTile(
                            icon: Icons.rate_review_outlined,
                            title: 'Saran dan Kesan TPM',
                            subtitle: 'Mata kuliah terbaik',
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.feedback,
                            ),
                          ),
                          const _GameDivider(),
                          _MenuTile(
                            icon: Icons.info_outline_rounded,
                            title: 'Tentang Aplikasi',
                            subtitle: 'RasaNusantara 1.0.0',
                            onTap: () => _showAbout(context),
                          ),
                          const _GameDivider(),
                          _MenuTile(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            subtitle: 'Keluar dari sesi perangkat ini',
                            danger: true,
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
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
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.spiceBrown,
            width: 2.6,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RibbonTitle(text: 'RasaNusantara'),
            SizedBox(height: 18),
            Text(
              'Aplikasi mobile resep tradisional Indonesia dengan SQLite, session, biometric login, LBS, sensor, AI rekomendasi, mini game, konversi mata uang, konversi waktu, dan notifikasi.',
              style: TextStyle(
                color: AppColors.softChocolate,
                height: 1.55,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
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
        'Profil',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.darkBrown,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
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

class _RibbonTitle extends StatelessWidget {
  final String text;

  const _RibbonTitle({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.ribbonGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.ribbonShadow,
          width: 1.2,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: -0.2,
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
          width: 46,
          height: 46,
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
            size: 23,
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;

  const _IconBubble({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.cream,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.spiceBrown,
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        color: AppColors.spiceBrown,
        size: 24,
      ),
    );
  }
}

class _EditSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _EditSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.spiceBrown,
          width: 1.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _GameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;

  const _GameTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.enabled,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(
          icon,
          color: AppColors.spiceBrown,
        ),
        suffixIcon: suffixIcon,
        labelStyle: const TextStyle(
          color: AppColors.softChocolate,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: TextStyle(
          color: AppColors.muted.withOpacity(0.65),
          fontWeight: FontWeight.w600,
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
            color: AppColors.spiceBrown.withOpacity(0.35),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.spiceBrown,
            width: 1.8,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.spiceBrown.withOpacity(0.18),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.terracotta : AppColors.spiceBrown;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.cream,
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
            width: 1.8,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.muted,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: color,
      ),
    );
  }
}

class _GameDivider extends StatelessWidget {
  const _GameDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1.4,
      color: AppColors.spiceBrown.withOpacity(0.20),
      indent: 76,
      endIndent: 12,
    );
  }
}