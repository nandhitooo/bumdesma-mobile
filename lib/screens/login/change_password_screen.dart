import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../state/auth_provider.dart';
import '../../shell/main_shell.dart';

/// Shown after first login using the temporary password given by Admin.
/// Per Flow Karyawan (Gambar 3.11): mandatory before the employee can
/// reach the Dashboard.
class ChangePasswordScreen extends StatefulWidget {
  final bool isVoluntary; // true when opened from Profile, not forced
  const ChangePasswordScreen({super.key, this.isVoluntary = false});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPass = _newPasswordController.text;
    final confirm = _confirmController.text;

    if (newPass.length < 6) {
      _showError('Password baru minimal 6 karakter.');
      return;
    }
    if (newPass != confirm) {
      _showError('Konfirmasi password tidak cocok.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.changePassword(newPass);
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
    } else {
      _showError('Gagal memperbarui password. Coba lagi.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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
                'Ini adalah login pertama Anda. Silakan ganti password sementara dengan password baru sebelum melanjutkan.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
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
                  : const Text('Simpan Password'),
            ),
          ],
        ),
      ),
    );
  }
}
