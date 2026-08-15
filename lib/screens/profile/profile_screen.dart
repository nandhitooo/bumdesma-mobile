import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../state/auth_provider.dart';
import '../../widgets/gradient_app_header.dart';
import '../../widgets/section_card.dart';
import '../login/add_email_screen.dart';
import '../login/change_password_screen.dart';
import '../login/login_screen.dart';

/// Mirrors "Profile" screen (Gambar 3.36): foto, Data Pegawai, tombol
/// Edit, Reset Password, dan Log-Out.
///
/// Redesigned to reuse [GradientAppHeader] (same gradient/avatar language
/// as Dashboard) instead of a flat AppBar, and to present Data Pegawai as
/// scannable icon+label+value rows instead of one RichText paragraph.
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
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
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
    final initial =
        (user?.nama.isNotEmpty ?? false) ? user!.nama[0].toUpperCase() : '?';
    final emailFilled = user?.email != null && user!.email!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: GradientAppHeader(
              title: 'Profile',
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 46),
              bottom: Row(
                children: [
                  HeaderAvatar(initial: initial, size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nama ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (user?.jabatan.isNotEmpty ?? false)
                              ? user!.jabatan
                              : 'Jabatan belum diisi',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SectionCard(
                  title: 'Data Pegawai',
                  icon: Icons.badge_outlined,
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Nama Lengkap',
                        value: user?.nama ?? '-',
                      ),
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'NIP',
                        value: user?.nip ?? '-',
                      ),
                      _InfoRow(
                        icon: Icons.work_outline_rounded,
                        label: 'Jabatan',
                        value: (user?.jabatan.isNotEmpty ?? false)
                            ? user!.jabatan
                            : '-',
                      ),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: emailFilled ? user!.email! : 'Belum diisi',
                        valueColor: emailFilled ? null : AppColors.warning,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SectionCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ActionTile(
                        icon: Icons.edit_outlined,
                        label: 'Edit Profil',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Edit profil belum tersedia pada versi ini.'),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      _ActionTile(
                        icon: Icons.email_outlined,
                        label: emailFilled ? 'Ubah Email' : 'Lengkapi Email',
                        trailingWarning: !emailFilled,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const AddEmailScreen()),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _ActionTile(
                        icon: Icons.lock_reset_rounded,
                        label: 'Reset Password',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const ChangePasswordScreen(isVoluntary: true),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Log-Out'),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool trailingWarning;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
            ),
            if (trailingWarning)
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.warning, shape: BoxShape.circle),
              ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
