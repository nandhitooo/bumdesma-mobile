import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../state/auth_provider.dart';
import '../login/add_email_screen.dart';
import '../login/change_password_screen.dart';
import '../login/login_screen.dart';

/// Mirrors "Profile" screen (Gambar 3.36): foto, Data Pegawai, tombol
/// Edit, Reset Password, dan Log-Out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Akun?'),
        content: const Text('Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Keluar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  (user?.nama.isNotEmpty ?? false) ? user!.nama[0] : '?',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.nama ?? '-',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(user?.jabatan ?? '-',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Data Pegawai',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 14),
                  _DataRow(label: 'Nama Lengkap', value: user?.nama ?? '-'),
                  _DataRow(label: 'NIP', value: user?.nip ?? '-'),
                  _DataRow(label: 'Jabatan', value: user?.jabatan ?? '-'),
                  _DataRow(
                    label: 'Email',
                    value: (user?.email == null || user!.email!.isEmpty)
                        ? 'Belum diisi'
                        : user.email!,
                    valueColor: (user?.email == null || user!.email!.isEmpty)
                        ? AppColors.warning
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Edit profil belum tersedia pada versi ini.')),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const AddEmailScreen()),
                          ),
                          icon: const Icon(Icons.email_outlined, size: 18),
                          label: Text(
                              (user?.email == null || user!.email!.isEmpty)
                                  ? 'Isi Email'
                                  : 'Ubah Email'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ChangePasswordScreen(isVoluntary: true),
              ),
            ),
            icon: const Icon(Icons.lock_reset_rounded, size: 18),
            label: const Text('Reset Password'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Log-Out'),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DataRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(
              text: value,
              style: valueColor != null
                  ? TextStyle(color: valueColor, fontWeight: FontWeight.w600)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
