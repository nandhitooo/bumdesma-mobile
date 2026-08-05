import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../state/auth_provider.dart';
import '../../shell/main_shell.dart';

/// Layar wajib diisi bagi karyawan yang akunnya sudah tidak lagi lewat
/// ChangePasswordScreen (is_first_login sudah false) tapi belum punya
/// email pemulihan tercatat sama sekali — misalnya akun lama dari sebelum
/// fitur email pemulihan ditambahkan. Tidak bisa dilewati (no back button)
/// sampai email tersimpan.
///
/// Juga bisa dibuka secara sukarela dari Profile ("Ubah Email") untuk
/// memperbarui email yang sudah ada.
class AddEmailScreen extends StatefulWidget {
  const AddEmailScreen({super.key});

  @override
  State<AddEmailScreen> createState() => _AddEmailScreenState();
}

class _AddEmailScreenState extends State<AddEmailScreen> {
  late final TextEditingController _emailController;
  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void initState() {
    super.initState();
    final currentEmail = context.read<AuthProvider>().user?.email;
    _emailController = TextEditingController(text: currentEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _isVoluntary => !(context.read<AuthProvider>().mustAddEmail);

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Email wajib diisi untuk keperluan pemulihan password.');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      _showError('Format email tidak valid.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final wasVoluntary = _isVoluntary;
    final ok = await auth.updateEmail(email);
    if (!mounted) return;

    if (ok) {
      if (wasVoluntary) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email berhasil disimpan.')),
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
    final voluntary = _isVoluntary;

    return Scaffold(
      appBar: AppBar(
        title: Text(voluntary ? 'Ubah Email' : 'Lengkapi Email'),
        automaticallyImplyLeading: voluntary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!voluntary) ...[
              const Icon(Icons.mark_email_read_outlined,
                  size: 48, color: AppColors.primary),
              const SizedBox(height: 12),
              const Text(
                'Lengkapi Email Pemulihan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Akun Anda belum memiliki email tercatat. Email ini dipakai untuk verifikasi jika suatu saat Anda lupa password.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
            ],
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'nama@email.com',
                prefixIcon: Icon(Icons.email_outlined),
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
