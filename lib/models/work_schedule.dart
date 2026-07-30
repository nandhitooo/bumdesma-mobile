import 'package:flutter/material.dart';

/// Mirrors Tabel 3.1 (Work Schedule) and the Pengaturan page: jam kerja
/// reguler, batas toleransi keterlambatan, serta konfigurasi geofencing.
class WorkSchedule {
  final TimeOfDay jamMasuk;
  final TimeOfDay jamPulang;
  final int toleransiMenit;
  final double officeLatitude;
  final double officeLongitude;
  final double radiusMeters;

  const WorkSchedule({
    required this.jamMasuk,
    required this.jamPulang,
    required this.toleransiMenit,
    required this.officeLatitude,
    required this.officeLongitude,
    required this.radiusMeters,
  });
}
