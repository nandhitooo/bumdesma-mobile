import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../state/auth_provider.dart';
import '../../shell/main_shell.dart';

/// Shown after first login using the temporary password given by Admin
/// (isVoluntary=false, wajib — per Flow Karyawan Gambar 3.11), atau saat
/// karyawan mengganti password sendiri lewat Profile (isVoluntary=true).
///
/// Email pemulihan WAJIB terisi:
/// - Selalu wajib di layar ini pada login pertama.
/// - Wajib juga pada penggantian password sukarela jika akun belum
///   memiliki email tercatat sama sekali (lihat AuthProvider.mustAddEmail).
class ChangePasswordScreen extends StatefulWidget {
  final bool isVoluntary; // true when opened from Profile, not forced
  /// Password yang baru saja dipakai untuk login (diteruskan dari
  /// LoginScreen), dipakai otomatis sebagai "password lama" pada alur
  /// wajib ganti password login pertama — karyawan tidak perlu mengetik
  /// ulang. Tidak dipakai kalau [isVoluntary] true.
  final String? temporaryPassword;

  const ChangePasswordScreen({
    super.key,
    this.isVoluntary = false,
    this.temporaryPassword,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  late final TextEditingController _emailController;
  bool _obscure = true;

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void initState() {
    super.initState();
    final currentEmail = context.read<AuthProvider>().user?.email;
    _emailController = TextEditingController(text: currentEmail ?? '');
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Login pertama: email selalu wajib. Penggantian sukarela: wajib hanya
  /// kalau akun ini memang belum punya email tercatat sama sekali.
  bool get _emailRequired {
    if (!widget.isVoluntary) return true;
    return context.read<AuthProvider>().mustAddEmail;
  }

  Future<void> _submit() async {
    final newPass = _newPasswordController.text;
    final confirm = _confirmController.text;
    final email = _emailController.text.trim();

    if (newPass.length < 8) {
      _showError('Password baru minimal 8 karakter.');
      return;
    }
    if (newPass != confirm) {
      _showError('Konfirmasi password tidak cocok.');
      return;
    }
    if (_emailRequired && email.isEmpty) {
      _showError('Email wajib diisi untuk keperluan pemulihan password.');
      return;
    }
    if (email.isNotEmpty && !_emailRegex.hasMatch(email)) {
      _showError('Format email tidak valid.');
      return;
    }

    final oldPassword = widget.isVoluntary
        ? _oldPasswordController.text
        : (widget.temporaryPassword ?? '');
    if (oldPassword.isEmpty) {
      _showError('Password saat ini wajib diisi.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.changePassword(
      oldPassword: oldPassword,
      newPassword: newPass,
      email: email.isEmpty ? null : email,
    );
    if (!mounted) return;

    if (ok) {
      if (widget.isVoluntary) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diperbarui.')),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } else if (auth.error != null) {
      _showError(auth.error!);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final emailRequired = _emailRequired;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganti Password'),
        automaticallyImplyLeading: widget.isVoluntary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isVoluntary) ...[
              const Icon(Icons.password_rounded,
                  size: 48, color: AppColors.primary),
              const SizedBox(height: 12),
              const Text(
                'Amankan Akun Anda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ini adalah login pertama Anda. Silakan ganti password sementara dengan password baru, dan lengkapi email pemulihan sebelum melanjutkan.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
            ],
            if (widget.isVoluntary) ...[
              TextField(
                controller: _oldPasswordController,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: 'Password Saat Ini',
                  prefixIcon: Icon(Icons.lock_person_outlined),
                ),
              ),
              const SizedBox(height: 14),
            ],
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
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: emailRequired ? 'Email Pemulihan *' : 'Email Pemulihan',
                hintText: 'nama@email.com',
                prefixIcon: const Icon(Icons.email_outlined),
                helperText:
                    'Dipakai untuk verifikasi jika suatu saat Anda lupa password.',
                helperMaxLines: 2,
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: auth.loading ? null : _submit,
              child: auth.loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
