import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/attendance.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final DailyAttendance? record;
  final bool loading;

  const AttendanceSummaryCard({
    super.key,
    required this.record,
    required this.loading,
  });

  String _fmtTime(DateTime? t) =>
      t == null ? '--' : DateFormat('HH:mm').format(t);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Hari Ini',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _AttendanceRow(
            icon: Icons.login_rounded,
            iconColor: AppColors.success,
            title: 'Masuk',
            lineOne: 'Pukul: ${_fmtTime(record?.jamMasuk)}',
            lineTwo: record?.statusMasuk == AttendanceStatus.terlambat
                ? 'Terlambat: ya'
                : 'Terlambat: --',
          ),
          const SizedBox(height: 12),
          _AttendanceRow(
            icon: Icons.logout_rounded,
            iconColor: AppColors.danger,
            title: 'Pulang',
            lineOne: 'Pukul: ${_fmtTime(record?.jamPulang)}',
            lineTwo: record?.lemburMenit != null
                ? 'Lembur: ${record!.lemburMenit} menit'
                : 'Lembur: --',
          ),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String lineOne;
  final String lineTwo;

  const _AttendanceRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.lineOne,
    required this.lineTwo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor, iconColor.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(lineOne, style: const TextStyle(fontSize: 12.5)),
              const SizedBox(height: 2),
              Text(lineTwo,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
