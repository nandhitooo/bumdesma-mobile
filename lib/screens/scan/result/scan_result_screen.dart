import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/attendance.dart';
import '../../../shell/main_shell.dart';

/// Renders the correct card for every outcome shown in the mockups
/// (Gambar 3.28 Tepat Waktu, 3.29 Terlambat, 3.30 Ditolak-geofence,
/// 3.31 Diterima, 3.32 Lembur, 3.33 Ditolak-tidak-ada-masuk), driven by
/// the [ScanResult] returned from AttendanceService.scan().
class ScanResultScreen extends StatelessWidget {
  final ScanResult result;
  const ScanResultScreen({super.key, required this.result});

  bool get _isRejected => !result.success;

  ({Color color, IconData icon, String heading}) get _visual {
    if (_isRejected) {
      return (
        color: AppColors.danger,
        icon: Icons.close_rounded,
        heading: 'Absen Ditolak',
      );
    }
    switch (result.status) {
      case AttendanceStatus.tepatWaktu:
      case AttendanceStatus.diterima:
        return (
          color: AppColors.success,
          icon: Icons.check_rounded,
          heading: 'Absen Diterima',
        );
      case AttendanceStatus.terlambat:
      case AttendanceStatus.lembur:
        return (
          color: AppColors.warning,
          icon: Icons.check_rounded,
          heading: 'Absen Diterima',
        );
      default:
        return (
          color: AppColors.danger,
          icon: Icons.close_rounded,
          heading: 'Absen Ditolak',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _visual;
    final isMasuk = result.requestedType == ScanType.masuk;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      v.heading,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: v.color, width: 2.4),
                      ),
                      child: Icon(v.icon, color: v.color, size: 34),
                    ),
                    const SizedBox(height: 20),
                    if (!_isRejected) ...[
                      const Text('info',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 10),
                      _buildInfoBox(isMasuk),
                      const SizedBox(height: 14),
                      Text(
                        isMasuk ? '' : 'Hati-hati di jalan pulang ya...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ] else ...[
                      Text(
                        result.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainShell()),
                    (route) => false,
                  ),
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(bool isMasuk) {
    final hari = DateFormat('EEEE', 'id_ID').format(result.timestamp);
    final tanggal = DateFormat('d MMMM yyyy', 'id_ID').format(result.timestamp);
    final jam = DateFormat('HH:mm').format(result.timestamp);

    final rows = <(String, String)>[
      ('Hari', hari),
      ('Tanggal', tanggal),
      ('Jam', jam),
      if (isMasuk)
        (
          'Terlambat',
          result.terlambatMenit != null ? '${result.terlambatMenit} Menit' : '--',
        )
      else
        (
          'Lembur',
          result.lemburMenit != null ? '${result.lemburMenit} Menit' : '--',
        ),
      if (isMasuk)
        (
          'Status',
          result.status == AttendanceStatus.terlambat ? 'Terlambat' : 'Tepat Waktu',
        ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider, width: 1.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  children: [
                    TextSpan(text: '${r.$1}: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(text: r.$2),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
