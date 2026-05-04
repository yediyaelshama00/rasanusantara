import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../local/database_helper.dart';
import '../local/session_helper.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final SessionHelper _session = SessionHelper.instance;

  String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(24, (_) => random.nextInt(256));
    return base64UrlEncode(values);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt:$password:rasanusantara');
    return sha256.convert(bytes).toString();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  String _cleanDbError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('unique') && message.contains('email')) {
      return 'Email sudah digunakan akun lain';
    }

    if (message.contains('database is locked')) {
      return 'Database sedang sibuk. Coba lagi sebentar';
    }

    if (message.contains('no such column') && message.contains('photo_path')) {
      return 'Kolom photo_path belum ada di database. Uninstall aplikasi lalu run ulang, atau lakukan migration database';
    }

    if (message.contains('no such table') && message.contains('users')) {
      return 'Tabel users belum dibuat di database';
    }

    return 'Terjadi kesalahan saat menyimpan akun';
  }

  Future<AppUser?> getCurrentUser() async {
    final userId = await _session.getUserId();

    if (userId == null) return null;

    final db = await _db.database;

    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return AppUser.fromMap(rows.first);
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await _db.database;

    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return AppUser.fromMap(rows.first);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty) {
      throw Exception('Nama tidak boleh kosong');
    }

    if (cleanName.length < 3) {
      throw Exception('Nama minimal 3 karakter');
    }

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception('Format email tidak valid');
    }

    if (password.length < 6) {
      throw Exception('Password minimal 6 karakter');
    }

    final existing = await getUserByEmail(normalizedEmail);

    if (existing != null) {
      throw Exception('Email sudah terdaftar');
    }

    final salt = _generateSalt();
    final hash = _hashPassword(password, salt);

    final db = await _db.database;

    try {
      final id = await db.insert(
        'users',
        {
          'name': cleanName,
          'email': normalizedEmail,
          'password_hash': hash,
          'salt': salt,
          'photo_path': '',
          'biometric_enabled': 0,
        },
      );

      await _session.saveSession(
        userId: id,
        email: normalizedEmail,
      );

      return AppUser(
        id: id,
        name: cleanName,
        email: normalizedEmail,
        passwordHash: hash,
        salt: salt,
        photoPath: '',
        biometricEnabled: false,
      );
    } catch (e) {
      throw Exception(_cleanDbError(e));
    }
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (!_isValidEmail(normalizedEmail)) {
      throw Exception('Format email tidak valid');
    }

    if (password.isEmpty) {
      throw Exception('Password tidak boleh kosong');
    }

    final user = await getUserByEmail(normalizedEmail);

    if (user == null) {
      throw Exception('Email tidak ditemukan');
    }

    final hash = _hashPassword(password, user.salt);

    if (hash != user.passwordHash) {
      throw Exception('Password salah');
    }

    await _session.saveSession(
      userId: user.id!,
      email: user.email,
    );

    if (user.biometricEnabled) {
      await _session.saveBiometricEmail(user.email);
    }

    return user;
  }

  Future<AppUser?> loginWithBiometric() async {
    final email = await _session.getBiometricEmail();

    if (email == null) {
      throw Exception('Tidak ada user yang mengaktifkan biometric');
    }

    final user = await getUserByEmail(email);

    if (user == null) {
      throw Exception('User biometric tidak ditemukan');
    }

    if (!user.biometricEnabled) {
      throw Exception('Biometric sudah dinonaktifkan user');
    }

    await _session.saveSession(
      userId: user.id!,
      email: user.email,
    );

    return user;
  }

  Future<void> setBiometric(bool enabled) async {
    final user = await getCurrentUser();

    if (user == null) {
      throw Exception('Session habis. Silakan login ulang');
    }

    if (user.id == null) {
      throw Exception('ID user tidak valid');
    }

    final db = await _db.database;

    try {
      final updatedRows = await db.update(
        'users',
        {
          'biometric_enabled': enabled ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );

      if (updatedRows == 0) {
        throw Exception('Data biometric gagal diperbarui');
      }

      if (enabled) {
        await _session.saveBiometricEmail(user.email);
      }
    } catch (e) {
      final text = e.toString();

      if (text.startsWith('Exception: ')) {
        rethrow;
      }

      throw Exception(_cleanDbError(e));
    }
  }

  Future<void> updateAccount({
    required String name,
    required String email,
    required String? photoPath,
    required String currentPassword,
    required bool verifiedByBiometric,
    String? newPassword,
  }) async {
    try {
      final user = await getCurrentUser();

      if (user == null) {
        throw Exception('Session habis. Silakan login ulang');
      }

      if (user.id == null) {
        throw Exception('ID user tidak valid. Silakan login ulang');
      }

      final cleanName = name.trim();
      final cleanEmail = email.trim().toLowerCase();
      final cleanCurrentPassword = currentPassword;
      final cleanNewPassword = newPassword?.trim() ?? '';

      if (cleanName.isEmpty) {
        throw Exception('Nama tidak boleh kosong');
      }

      if (cleanName.length < 3) {
        throw Exception('Nama minimal 3 karakter');
      }

      if (cleanName.length > 40) {
        throw Exception('Nama maksimal 40 karakter');
      }

      if (cleanEmail.isEmpty) {
        throw Exception('Email tidak boleh kosong');
      }

      if (!_isValidEmail(cleanEmail)) {
        throw Exception('Format email tidak valid');
      }

      if (!verifiedByBiometric) {
        if (cleanCurrentPassword.trim().isEmpty) {
          throw Exception('Password lama wajib diisi');
        }

        final currentHash = _hashPassword(
          cleanCurrentPassword,
          user.salt,
        );

        if (currentHash != user.passwordHash) {
          throw Exception('Password lama salah');
        }
      } else {
        if (!user.biometricEnabled) {
          throw Exception('Biometrik belum aktif untuk akun ini');
        }
      }

      if (cleanNewPassword.isNotEmpty) {
        if (cleanNewPassword.length < 6) {
          throw Exception('Password baru minimal 6 karakter');
        }

        if (!verifiedByBiometric && cleanNewPassword == cleanCurrentPassword) {
          throw Exception('Password baru tidak boleh sama dengan password lama');
        }
      }

      final existingUser = await getUserByEmail(cleanEmail);

      if (existingUser != null && existingUser.id != user.id) {
        throw Exception('Email sudah digunakan akun lain');
      }

      final Map<String, Object?> data = {
        'name': cleanName,
        'email': cleanEmail,
        'photo_path': photoPath ?? '',
      };

      if (cleanNewPassword.isNotEmpty) {
        final newSalt = _generateSalt();
        final newHash = _hashPassword(cleanNewPassword, newSalt);

        data['password_hash'] = newHash;
        data['salt'] = newSalt;
      }

      final db = await _db.database;

      final updatedRows = await db.update(
        'users',
        data,
        where: 'id = ?',
        whereArgs: [user.id],
      );

      if (updatedRows == 0) {
        throw Exception('Data user gagal diperbarui');
      }

      await _session.saveSession(
        userId: user.id!,
        email: cleanEmail,
      );

      if (user.biometricEnabled) {
        await _session.saveBiometricEmail(cleanEmail);
      }
    } catch (e) {
      final text = e.toString();

      if (text.startsWith('Exception: ')) {
        rethrow;
      }

      throw Exception(_cleanDbError(e));
    }
  }

  Future<void> updateProfile({
    required String email,
    required String name,
    String? photoPath,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty) {
      throw Exception('Nama tidak boleh kosong');
    }

    if (!_isValidEmail(cleanEmail)) {
      throw Exception('Format email tidak valid');
    }

    final db = await _db.database;

    try {
      final updatedRows = await db.update(
        'users',
        {
          'name': cleanName,
          'photo_path': photoPath ?? '',
        },
        where: 'email = ?',
        whereArgs: [cleanEmail],
      );

      if (updatedRows == 0) {
        throw Exception('Profil gagal diperbarui');
      }
    } catch (e) {
      final text = e.toString();

      if (text.startsWith('Exception: ')) {
        rethrow;
      }

      throw Exception(_cleanDbError(e));
    }
  }

  Future<void> updateProfileName(String name) async {
    final user = await getCurrentUser();

    if (user == null) {
      throw Exception('Session habis. Silakan login ulang');
    }

    await updateProfile(
      email: user.email,
      name: name,
      photoPath: user.photoPath,
    );
  }

  Future<void> logout() async {
    await _session.clear();
  }
}