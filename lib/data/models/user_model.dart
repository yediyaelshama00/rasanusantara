class AppUser {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String salt;
  final String photoPath;
  final bool biometricEnabled;

  const AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.photoPath,
    required this.biometricEnabled,
  });

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      salt: map['salt'] as String,
      photoPath: map['photo_path'] as String? ?? '',
      biometricEnabled: (map['biometric_enabled'] as int? ?? 0) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'salt': salt,
      'photo_path': photoPath,
      'biometric_enabled': biometricEnabled ? 1 : 0,
    };
  }
}
