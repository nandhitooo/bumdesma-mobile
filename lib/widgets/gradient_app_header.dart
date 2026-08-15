import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Shared rounded-bottom gradient header used across Dashboard, Profile,
/// Riwayat, Izin/Cuti, and Absen Dulu so every top-level screen reads as
/// part of the same app instead of Dashboard being the only screen with a
/// "designed" header and everything else falling back to a flat AppBar.
class GradientAppHeader extends StatelessWidget {
  /// Pass null (or leave the default) when a screen wants a fully custom
  /// header body via [bottom] only (e.g. Dashboard's avatar+greeting
  /// row) — in that case the title/leading/actions row is skipped
  /// entirely instead of leaving a phantom empty row.
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottom;
  final EdgeInsetsGeometry padding;

  const GradientAppHeader({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.bottom,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 26),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.headerGradient,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl + 8),
          bottomRight: Radius.circular(AppRadius.xl + 8),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x2616423C),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null && title!.isNotEmpty) ...[
                Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 8)
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title!, style: AppTextStyles.screenTitle),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (actions != null) ...actions!,
                  ],
                ),
                if (bottom != null) const SizedBox(height: 16),
              ],
              if (bottom != null) bottom!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Small circular glass icon button used in header actions (bell, back
/// arrow, etc.) so every header icon looks the same across screens.
class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          if (showDot)
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Circular initial-letter avatar used in header rows (Dashboard, Profile).
class HeaderAvatar extends StatelessWidget {
  final String initial;
  final double size;

  const HeaderAvatar({super.key, required this.initial, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.4),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
