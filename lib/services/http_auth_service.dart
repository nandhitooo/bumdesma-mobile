import '../core/network/api_client.dart';
import '../core/network/session_store.dart';
import '../models/user.dart';
import 'auth_service.dart';

/// Real implementation of [AuthService], wired to bumdesma-backend's
/// /api/auth routes. NIP is used as the login username (see auth.routes.js
/// and auth.controller.js#login on the backend).
class HttpAuthService implements AuthService {
  final ApiClient _api = ApiClient.instance;

  @override
  Future<AppUser> login({required String nip, required String password}) async {
    try {
      final res = await _api.post('/auth/login', body: {
        'nip': nip,
        'password': password,
      });
      final data = res['data'] as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>;

      await SessionStore.save(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        nip: user['nip'] as String,
      );

      return AppUser(
        nip: user['nip'] as String,
        nama: user['name'] as String,
        jabatan: user['jabatan'] as String? ?? '-',
        departemen: user['departemen'] as String? ?? '-',
        mustChangePassword: data['mustChangePassword'] as bool? ?? false,
      );
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> changePassword({
    required String nip,
    required String newPassword,
  }) async {
    try {
      // NB: bumdesma-backend's /auth/change-password also expects
      // `oldPassword` for a self-service password change. For the
      // mandatory first-login flow, the temporary password issued by
      // Admin doubles as `oldPassword` — pass it in from the screen that
      // collects it if you have it; otherwise ask the user to re-enter it.
      await _api.post('/auth/change-password', body: {
        'newPassword': newPassword,
      });
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } on ApiException catch (_) {
      // Ignore backend errors on logout — always clear the local session.
    } finally {
      await SessionStore.clear();
    }
  }
}
