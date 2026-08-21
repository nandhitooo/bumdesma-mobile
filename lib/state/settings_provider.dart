import 'package:flutter/material.dart';

import '../models/work_schedule.dart';
import '../services/settings_service.dart';

/// Cache ringan untuk WorkSchedule (jam kerja, toleransi, radius geofencing)
/// dari backend, dipakai bersama oleh Dashboard, AttendanceSummaryCard, dan
/// ScanSelectScreen supaya tidak ada lagi teks jam/radius yang di-hardcode
/// di UI — semua mengikuti data yang diatur Admin dari Website.
class SettingsProvider extends ChangeNotifier {
  WorkSchedule? _schedule;
  bool _loading = false;

  WorkSchedule? get schedule => _schedule;
  bool get loading => _loading;

  /// Memuat schedule sekali saja per sesi aplikasi (dipanggil dari
  /// Dashboard). Layar lain yang butuh data terbaru bisa memanggil
  /// [refresh] secara eksplisit.
  Future<void> loadIfNeeded() async {
    if (_schedule != null || _loading) return;
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    try {
      _schedule = await SettingsService.instance.getWorkSchedule();
    } catch (_) {
      // Biarkan _schedule lama (atau null) — UI pemanggil wajib punya
      // fallback yang aman kalau schedule belum berhasil dimuat.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
