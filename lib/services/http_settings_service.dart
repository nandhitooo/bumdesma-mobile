import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/work_schedule.dart';
import 'settings_service.dart';

/// Real implementation of [SettingsService], wired to bumdesma-backend's
/// /api/settings and /api/piket/me routes.
class HttpSettingsService implements SettingsService {
  final ApiClient _api = ApiClient.instance;

  @override
  Future<WorkSchedule> getWorkSchedule() async {
    final res = await _api.get('/settings');
    final data = res['data'] as Map<String, dynamic>;
    final settings = data['settings'] as Map<String, dynamic>;
    final schedules =
        (data['workSchedules'] as List).cast<Map<String, dynamic>>();

    final reguler = schedules.firstWhere(
      (s) => s['day_type'] == 'reguler',
      orElse: () => schedules.first,
    );

    return WorkSchedule(
      jamMasuk: _parseTime(reguler['start_time'] as String),
      jamPulang: _parseTime(reguler['end_time'] as String),
      toleransiMenit: (reguler['late_tolerance_minutes'] as num).toInt(),
      officeLatitude: double.parse(settings['office_latitude'].toString()),
      officeLongitude: double.parse(settings['office_longitude'].toString()),
      radiusMeters: double.parse(
        (settings['geofence_radius_meters'] ?? 50).toString(),
      ),
    );
  }

  @override
  Future<bool> isAssignedSaturdayPiket(String nip) async {
    final res = await _api.get('/piket/me');
    final rows = (res['data'] as List).cast<Map<String, dynamic>>();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return rows.any((r) => r['tanggal'] == todayStr);
  }

  // Backend TIME column comes back as 'HH:mm:ss'.
  TimeOfDay _parseTime(String hhmmss) {
    final parts = hhmmss.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Future<List<DateTime>> getNationalHolidays() async {
    final res = await _api.get('/settings');
    final data = res['data'] as Map<String, dynamic>;
    final settings = data['settings'] as Map<String, dynamic>;
    final raw = settings['national_holidays'];
    List<dynamic> list;
    if (raw is String) {
      list = raw.isEmpty ? [] : (jsonDecode(raw) as List<dynamic>);
    } else {
      list = (raw as List<dynamic>?) ?? [];
    }
    return list.map((s) => DateTime.parse(s as String)).toList();
  }
}
