import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

/// Layar "Lupa Password", diakses dari LoginScreen sebelum ada sesi login
/// sama sekali. Alurnya dua langkah:
///
/// 1. Karyawan memasukkan NIP -> backend mengirim kode OTP 6 digit ke
///    email pemulihan yang tercatat pada akun tersebut (lihat
///    AddEmailScreen / ChangePasswordScreen untuk bagaimana email itu
///    dikumpulkan).
/// 2. Karyawan memasukkan kode OTP dari email + password baru -> backend
///    memverifikasi OTP dan mengganti password.
///
/// Pesan setelah langkah 1 sengaja generik ("jika NIP terdaftar...") -
/// backend tidak membocorkan apakah NIP tertentu terdaftar atau tidak.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _nipController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();

  int _step = 1; // 1 = masukkan NIP, 2 = masukkan OTP + password baru
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nipController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final nip = _nipController.text.trim();
    if (nip.isEmpty) {
      _showError('NIP wajib diisi.');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.instance.forgotPassword(nip);
      if (!mounted) return;
      setState(() {
        _step = 2;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jika NIP terdaftar dan memiliki email pemulihan, kode OTP telah dikirim.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(_friendlyError(e));
    }
  }

  Future<void> _resetPassword() async {
    if (_otpController.text.trim().isEmpty) {
      _showError('Kode OTP wajib diisi.');
      return;
    }
    if (_newPasswordController.text.length < 8) {
      _showError('Password baru minimal 8 karakter.');
      return;
    }
    if (_newPasswordController.text != _confirmController.text) {
      _showError('Konfirmasi password tidak cocok.');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.instance.resetPassword(
        nip: _nipController.text.trim(),
        otp: _otpController.text.trim(),
        newPassword: _newPasswordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password berhasil direset. Silakan login dengan password baru Anda.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(_friendlyError(e));
    }
  }

  String _friendlyError(Object e) {
    if (e is AuthException) return e.message;
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _step == 1 ? Icons.mail_lock_outlined : Icons.pin_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              _step == 1 ? 'Masukkan NIP Anda' : 'Masukkan Kode OTP',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              _step == 1
                  ? 'Kode OTP akan dikirim ke email pemulihan yang terdaftar pada akun Anda.'
                  : 'Masukkan kode OTP yang dikirim ke email Anda, beserta password baru.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            if (_step == 1) ..._buildStepOne() else ..._buildStepTwo(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStepOne() {
    return [
      TextField(
        controller: _nipController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'NIP',
          prefixIcon: Icon(Icons.badge_outlined),
        ),
        onSubmitted: (_) => _requestOtp(),
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: _loading ? null : _requestOtp,
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : const Text('Kirim Kode OTP'),
      ),
    ];
  }

  List<Widget> _buildStepTwo() {
    return [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const Icon(Icons.badge_outlined,
                size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'NIP: ${_nipController.text.trim()}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: const InputDecoration(
          labelText: 'Kode OTP',
          prefixIcon: Icon(Icons.pin_outlined),
          counterText: '',
        ),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _newPasswordController,
        obscureText: _obscure,
        decoration: InputDecoration(
          labelText: 'Password Baru',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _confirmController,
        obscureText: _obscure,
        decoration: const InputDecoration(
          labelText: 'Konfirmasi Password Baru',
          prefixIcon: Icon(Icons.lock_outline),
        ),
        onSubmitted: (_) => _resetPassword(),
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: _loading ? null : _resetPassword,
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : const Text('Reset Password'),
      ),
      const SizedBox(height: 12),
      Center(
        child: TextButton(
          onPressed: _loading ? null : () => setState(() => _step = 1),
          child: const Text('Ubah NIP / Kirim Ulang Kode'),
        ),
      ),
    ];
  }
}
