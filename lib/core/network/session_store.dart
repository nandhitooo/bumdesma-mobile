import 'package:shared_preferences/shared_preferences.dart';

/// Persists the JWT pair issued by POST /api/auth/login so the app stays
/// logged in across restarts and [ApiClient] can attach the access token
/// to every authenticated request.
class SessionStore {
  SessionStore._();

  static const _kAccessToken = 'auth.accessToken';
  static const _kRefreshToken = 'auth.refreshToken';
  static const _kNip = 'auth.nip';

  static Future<void> save({
    required String accessToken,
    required String refreshToken,
    required String nip,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessToken, accessToken);
    await prefs.setString(_kRefreshToken, refreshToken);
    await prefs.setString(_kNip, nip);
  }

  static Future<void> saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessToken, accessToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRefreshToken);
  }

  static Future<String?> getNip() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kNip);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessToken);
    await prefs.remove(_kRefreshToken);
    await prefs.remove(_kNip);
  }
}
