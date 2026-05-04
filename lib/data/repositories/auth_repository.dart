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

  Future<AppUser?> getCurrentUser() async {
    final userId = await _session.getUserId();
    if (userId == null) return null;
    final db = await _db.database;
    final rows =
        await db.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await _db.database;
    final rows = await db.query('users',
        where: 'email = ?', whereArgs: [email.trim().toLowerCase()], limit: 1);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser> register(
      {required String name,
      required String email,
      required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existing = await getUserByEmail(normalizedEmail);
    if (existing != null) throw Exception('Email sudah terdaftar');
    final salt = _generateSalt();
    final hash = _hashPassword(password, salt);
    final db = await _db.database;
    final id = await db.insert('users', {
      'name': name.trim(),
      'email': normalizedEmail,
      'password_hash': hash,
      'salt': salt,
      'photo_path': '',
      'biometric_enabled': 0,
    });
    await _session.saveSession(userId: id, email: normalizedEmail);
    return AppUser(
        id: id,
        name: name.trim(),
        email: normalizedEmail,
        passwordHash: hash,
        salt: salt,
        photoPath: '',
        biometricEnabled: false);
  }

  Future<AppUser> login(
      {required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = await getUserByEmail(normalizedEmail);
    if (user == null) throw Exception('Email tidak ditemukan');
    final hash = _hashPassword(password, user.salt);
    if (hash != user.passwordHash) throw Exception('Password salah');
    await _session.saveSession(userId: user.id!, email: user.email);
    if (user.biometricEnabled) await _session.saveBiometricEmail(user.email);
    return user;
  }

  Future<AppUser?> loginWithBiometric() async {
    // mengambil email yang pernah enable biometric
    final email = await _session.getBiometricEmail();
    if (email == null) {
      throw Exception('Tidak ada user yang mengaktifkan biometric');
    }

    // cari user di database
    final user = await getUserByEmail(email);
    if (user == null) {
      throw Exception('User biometric tidak ditemukan');
    }

    // cek apakah user masih mengaktifkan biometric
    if (!user.biometricEnabled) {
      throw Exception('Biometric sudah dinonaktifkan user');
    }

    // simpan session sebagai user aktif
    await _session.saveSession(
      userId: user.id!,
      email: user.email,
    );

    return user;
  }

  Future<void> setBiometric(bool enabled) async {
    final user = await getCurrentUser();
    if (user == null) return;
    final db = await _db.database;
    await db.update('users', {'biometric_enabled': enabled ? 1 : 0},
        where: 'id = ?', whereArgs: [user.id]);
    if (enabled) await _session.saveBiometricEmail(user.email);
  }

  Future<void> updateProfileName(String name) async {
    final user = await getCurrentUser();
    if (user == null) return;
    final db = await _db.database;
    await db.update('users', {'name': name.trim()},
        where: 'id = ?', whereArgs: [user.id]);
  }

  Future<void> logout() async {
    await _session.clear();
  }
}
