import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/attendance.dart';
import '../../state/attendance_provider.dart';
import '../../state/auth_provider.dart';
import 'result/scan_result_screen.dart';

/// Mirrors "Arahkan Ke QR Yaa..." (Gambar 3.27): membuka kamera, membaca
/// QR statis kantor, mengambil lokasi GPS, lalu mengirim ke
/// AttendanceService untuk divalidasi (token + geofencing + jadwal).
class ScanCameraScreen extends StatefulWidget {
  final ScanType scanType;
  const ScanCameraScreen({super.key, required this.scanType});

  @override
  State<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends State<ScanCameraScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;
  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled || _processing) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    setState(() => _processing = true);
    _handled = true;
    await _controller.stop();

    final nip = context.read<AuthProvider>().user?.nip ?? '';

    try {
      final result = await context.read<AttendanceProvider>().scan(
            nip: nip,
            type: widget.scanType,
            token: code,
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ScanResultScreen(result: result)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(e))),
      );
      setState(() {
        _processing = false;
        _handled = false;
      });
      await _controller.start();
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('LocationPermissionException')) {
      return msg.replaceFirst('LocationPermissionException: ', '');
    }
    return 'Gagal memproses absensi. Pastikan GPS aktif dan coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Arahkan Ke QR Yaa...'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(controller: _controller, onDetect: _onDetect),
                    if (_processing)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
            child: Text(
              'Aplikasi akan mengambil informasi lokasi ketika melakukan scanning',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade200, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
