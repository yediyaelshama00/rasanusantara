import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      final supported = await auth.isDeviceSupported();
      final canCheck = await auth.canCheckBiometrics;
      final biometrics = await auth.getAvailableBiometrics();

      return supported && canCheck && biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<String> getStatusMessage() async {
    try {
      final supported = await auth.isDeviceSupported();

      if (!supported) {
        return 'Perangkat ini belum mendukung autentikasi biometrik.';
      }

      final canCheck = await auth.canCheckBiometrics;

      if (!canCheck) {
        return 'Biometrik belum tersedia di perangkat ini.';
      }

      final biometrics = await auth.getAvailableBiometrics();

      if (biometrics.isEmpty) {
        return 'Belum ada fingerprint atau face unlock yang terdaftar di HP.';
      }

      return 'Biometrik tersedia.';
    } catch (e) {
      return 'Biometrik tidak bisa diakses: $e';
    }
  }

  Future<bool> authenticate() async {
    try {
      final available = await isAvailable();

      if (!available) {
        return false;
      }

      return auth.authenticate(
        localizedReason: 'Gunakan biometrik untuk masuk ke RasaNusantara',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
