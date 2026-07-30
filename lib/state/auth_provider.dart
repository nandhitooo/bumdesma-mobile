import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get mustChangePassword => _user?.mustChangePassword ?? false;

  Future<bool> login(String nip, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.instance.login(nip: nip, password: password);
      return true;
    } catch (e) {
      _error = e is AuthException ? e.message : 'Terjadi kesalahan. Coba lagi.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String newPassword) async {
    if (_user == null) return false;
    _loading = true;
    notifyListeners();
    try {
      await AuthService.instance
          .changePassword(nip: _user!.nip, newPassword: newPassword);
      _user = _user!.copyWith(mustChangePassword: false);
      return true;
    } catch (e) {
      _error = 'Gagal mengubah password. Coba lagi.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    _user = null;
    notifyListeners();
  }
}
