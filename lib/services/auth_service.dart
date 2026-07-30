import '../models/user.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

/// Handles login with NIP + temporary/permanent password, and the
/// mandatory password-change flow described in Flow Karyawan (Gambar 3.11):
/// "Jika karyawan baru pertama kali login, sistem akan mewajibkan
/// penggantian password sementara menjadi password baru."
///
/// Swap [AuthService.instance] for a real HTTP-backed implementation
/// (using Env.apiBaseUrl) once the Node.js backend is available.
abstract class AuthService {
  static AuthService instance = MockAuthService();

  Future<AppUser> login({required String nip, required String password});

  Future<void> changePassword({
    required String nip,
    required String newPassword,
  });

  Future<void> logout();
}

class MockAuthService implements AuthService {
  // NIP -> (password, mustChangePassword)
  final Map<String, _Credential> _db = {
    '3124510004': _Credential(password: 'temp1234', mustChange: true),
    '3124510099': _Credential(password: 'sudahaman1', mustChange: false),
  };

  final Map<String, AppUser> _profiles = {
    '3124510004': const AppUser(
      nip: '3124510004',
      nama: 'Fernandhito Dian Pratama',
      jabatan: 'Staff IT',
      departemen: 'Operasional',
    ),
    '3124510099': const AppUser(
      nip: '3124510099',
      nama: 'Siti Aminah',
      jabatan: 'Teller',
      departemen: 'Keuangan',
    ),
  };

  @override
  Future<AppUser> login({
    required String nip,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final cred = _db[nip];
    final profile = _profiles[nip];
    if (cred == null || profile == null || cred.password != password) {
      throw AuthException('NIP atau password salah.');
    }

    return profile.copyWith(mustChangePassword: cred.mustChange);
  }

  @override
  Future<void> changePassword({
    required String nip,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final cred = _db[nip];
    if (cred == null) throw AuthException('User tidak ditemukan.');
    _db[nip] = _Credential(password: newPassword, mustChange: false);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

class _Credential {
  final String password;
  final bool mustChange;
  _Credential({required this.password, required this.mustChange});
}
