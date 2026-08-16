import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/attendance.dart';
import '../../services/settings_service.dart';
import '../../state/auth_provider.dart';
import '../../widgets/gradient_app_header.dart';
import '../../widgets/section_card.dart';
import 'scan_camera_screen.dart';

/// Mirrors "Halaman Pilih Jenis Absen" (Gambar 3.26): karyawan memilih
/// Absen Masuk atau Absen Pulang sebelum kamera QR dibuka.
///
/// Per Sub Bab 3.2.7 point 2: jika hari ini Sabtu dan karyawan TIDAK
/// terjadwal piket, tombol absen disembunyikan sepenuhnya.
///
/// Redesigned to use [GradientAppHeader] instead of the plain green
/// AppBar (for consistency with the rest of the app) and richer option
/// cards with a short description under each label.
class ScanSelectScreen extends StatefulWidget {
  const ScanSelectScreen({super.key});

  @override
  State<ScanSelectScreen> createState() => _ScanSelectScreenState();
}

class _ScanSelectScreenState extends State<ScanSelectScreen> {
  bool _loading = true;
  bool _allowedToday = true;
  String _blockedReason = '';

  @override
  void initState() {
    super.initState();
    _checkEligibility();
  }

  Future<void> _checkEligibility() async {
    final nip = context.read<AuthProvider>().user?.nip ?? '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (now.weekday == DateTime.sunday) {
      _allowedToday = false;
      _blockedReason =
          'Hari ini hari Minggu, bukan hari kerja. Absensi tidak tersedia.';
    } else {
      final holidays = await SettingsService.instance.getNationalHolidays();
      final isHoliday = holidays.any(
        (h) => DateTime(h.year, h.month, h.day) == today,
      );

      if (isHoliday) {
        _allowedToday = false;
        _blockedReason =
            'Hari ini merupakan hari libur nasional/cuti bersama. Absensi tidak tersedia.';
      } else if (now.weekday == DateTime.saturday) {
        final assigned =
            await SettingsService.instance.isAssignedSaturdayPiket(nip);
        _allowedToday = assigned;
        _blockedReason =
            'Hari ini Sabtu dan Anda tidak terdaftar pada jadwal piket, sehingga absensi tidak tersedia.';
      } else {
        _allowedToday = true;
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  void _openCamera(ScanType type) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ScanCameraScreen(scanType: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GradientAppHeader(
            title: 'Absen Dulu',
            subtitle: 'Pilih jenis absensi yang ingin dilakukan',
            leading: HeaderIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : !_allowedToday
                    ? _buildNotScheduled()
                    : _buildOptions(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotScheduled() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: EmptyState(
          icon: Icons.weekend_rounded,
          title: 'Absensi Tidak Tersedia',
          message: _blockedReason,
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ScanOptionCard(
          label: 'Absen Masuk',
          description: 'Catat kehadiran Anda saat tiba di kantor',
          icon: Icons.login_rounded,
          color: AppColors.success,
          onTap: () => _openCamera(ScanType.masuk),
        ),
        const SizedBox(height: 14),
        _ScanOptionCard(
          label: 'Absen Pulang',
          description: 'Catat waktu Anda pulang dari kantor',
          icon: Icons.logout_rounded,
          color: AppColors.danger,
          onTap: () => _openCamera(ScanType.pulang),
        ),
      ],
    );
  }
}

class _ScanOptionCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ScanOptionCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: SectionCard(
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(description, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
