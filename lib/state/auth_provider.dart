import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/fcm_push_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get mustChangePassword => _user?.mustChangePassword ?? false;
  bool get mustAddEmail => _user?.mustAddEmail ?? false;

  Future<bool> login(String nip, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.instance.login(nip: nip, password: password);
      // Aktifkan push FCM untuk sesi ini: minta izin notifikasi (Android
      // 13+/iOS), lalu daftarkan token perangkat ke backend atas NIP ini
      // supaya keputusan izin/cuti & jadwal piket muncul di notif bar HP.
      // Fire-and-forget: login tidak boleh nunggu jaringan push.
      unawaited(FcmPushService.instance.start(nip: nip));
      return true;
    } catch (e) {
      _error = e is AuthException ? e.message : 'Terjadi kesalahan. Coba lagi.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    String? email,
  }) async {
    if (_user == null) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await AuthService.instance.changePassword(
        nip: _user!.nip,
        oldPassword: oldPassword,
        newPassword: newPassword,
        email: email,
      );
      final resolvedEmail = (email != null && email.isNotEmpty) ? email : _user!.email;
      _user = _user!.copyWith(
        mustChangePassword: false,
        email: resolvedEmail,
        mustAddEmail: resolvedEmail == null || resolvedEmail.isEmpty,
      );
      return true;
    } catch (e) {
      _error = e is AuthException ? e.message : 'Gagal mengubah password. Coba lagi.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEmail(String email) async {
    if (_user == null) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await AuthService.instance.updateEmail(nip: _user!.nip, email: email);
      _user = _user!.copyWith(email: email, mustAddEmail: false);
      return true;
    } catch (e) {
      _error = e is AuthException ? e.message : 'Gagal menyimpan email. Coba lagi.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    // Lepas ikatan token push dengan NIP ini di backend SEBELUM sesi
    // dihapus: endpoint /api/push/unregister butuh Authorization Bearer,
    // yang sudah tidak ada kalau SessionStore sudah dibersihkan dulu.
    await FcmPushService.instance.stop();
    await AuthService.instance.logout();
    _user = null;
    notifyListeners();
  }
}
