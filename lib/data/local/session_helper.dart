import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionHelper {
  SessionHelper._();
  static final SessionHelper instance = SessionHelper._();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveSession({required int userId, required String email}) async {
    await _storage.write(key: 'user_id', value: userId.toString());
    await _storage.write(key: 'email', value: email);
  }

  Future<int?> getUserId() async {
    final value = await _storage.read(key: 'user_id');
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<String?> getEmail() async {
    return _storage.read(key: 'email');
  }

  Future<bool> hasSession() async {
    final id = await getUserId();
    return id != null;
  }

  Future<void> saveBiometricEmail(String email) async {
    await _storage.write(key: 'biometric_email', value: email);
  }

  Future<String?> getBiometricEmail() async {
    return _storage.read(key: 'biometric_email');
  }

  Future<void> clear() async {
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'email');
  }
}
