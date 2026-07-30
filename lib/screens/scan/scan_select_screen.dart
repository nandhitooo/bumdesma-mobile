import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/attendance.dart';
import '../../services/settings_service.dart';
import '../../state/auth_provider.dart';
import 'scan_camera_screen.dart';

/// Mirrors "Halaman Pilih Jenis Absen" (Gambar 3.26): karyawan memilih
/// Absen Masuk atau Absen Pulang sebelum kamera QR dibuka.
///
/// Per Sub Bab 3.2.7 point 2: jika hari ini Sabtu dan karyawan TIDAK
/// terjadwal piket, tombol absen disembunyikan sepenuhnya.
class ScanSelectScreen extends StatefulWidget {
  const ScanSelectScreen({super.key});

  @override
  State<ScanSelectScreen> createState() => _ScanSelectScreenState();
}

class _ScanSelectScreenState extends State<ScanSelectScreen> {
  bool _loading = true;
  bool _allowedToday = true;

  @override
  void initState() {
    super.initState();
    _checkEligibility();
  }

  Future<void> _checkEligibility() async {
    final nip = context.read<AuthProvider>().user?.nip ?? '';
    final now = DateTime.now();

    if (now.weekday == DateTime.saturday) {
      final assigned =
          await SettingsService.instance.isAssignedSaturdayPiket(nip);
      _allowedToday = assigned;
    } else {
      _allowedToday = true;
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
      appBar: AppBar(title: const Text('Absen Dulu')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_allowedToday
              ? _buildNotScheduled()
              : _buildOptions(),
    );
  }

  Widget _buildNotScheduled() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.weekend_rounded, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text(
            'Bukan Jadwal Piket Anda',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Hari ini Sabtu dan Anda tidak terdaftar pada jadwal piket, sehingga absensi tidak tersedia.',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Absen Dulu',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 28),
          _ScanOptionButton(
            label: 'Absen Masuk',
            icon: Icons.login_rounded,
            color: AppColors.success,
            onTap: () => _openCamera(ScanType.masuk),
          ),
          const SizedBox(height: 16),
          _ScanOptionButton(
            label: 'Absen Pulang',
            icon: Icons.logout_rounded,
            color: AppColors.danger,
            onTap: () => _openCamera(ScanType.pulang),
          ),
        ],
      ),
    );
  }
}

class _ScanOptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ScanOptionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1.4),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Text(label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
