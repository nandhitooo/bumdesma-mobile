import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/attendance.dart';

class StatusBadge extends StatelessWidget {
  final AttendanceStatus status;
  const StatusBadge({super.key, required this.status});

  ({Color color, String label, IconData icon}) get _spec {
    switch (status) {
      case AttendanceStatus.tepatWaktu:
        return (
          color: AppColors.success,
          label: 'Tepat Waktu',
          icon: Icons.check_circle_rounded
        );
      case AttendanceStatus.terlambat:
        return (
          color: AppColors.warning,
          label: 'Terlambat',
          icon: Icons.schedule_rounded
        );
      case AttendanceStatus.diterima:
        return (
          color: AppColors.success,
          label: 'Diterima',
          icon: Icons.check_circle_rounded
        );
      case AttendanceStatus.lembur:
        return (
          color: AppColors.warning,
          label: 'Lembur',
          icon: Icons.schedule_rounded
        );
      case AttendanceStatus.ditolakGeofence:
      case AttendanceStatus.ditolakToken:
      case AttendanceStatus.ditolakDataTidakLengkap:
      case AttendanceStatus.ditolakSudahLengkap:
        return (
          color: AppColors.danger,
          label: 'Ditolak',
          icon: Icons.cancel_rounded
        );
      case AttendanceStatus.izinCuti:
        return (
          color: AppColors.info,
          label: 'Izin/Cuti',
          icon: Icons.event_busy_rounded
        );
      case AttendanceStatus.alpa:
        return (
          color: AppColors.textSecondary,
          label: 'Alpa',
          icon: Icons.remove_circle_rounded
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _spec;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: s.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 14, color: s.color),
          const SizedBox(width: 4),
          Text(
            s.label,
            style: TextStyle(
              color: s.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
