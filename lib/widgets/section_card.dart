import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Consistent white rounded "section" container reused across the app.
/// Previously every screen hand-rolled its own near-identical
/// BoxDecoration (subtle border + soft shadow) for this — this widget is
/// the single source of truth for that look.
class SectionCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.trailing,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                ],
                Expanded(
                    child: Text(title!, style: AppTextStyles.sectionTitle)),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

/// Empty-state placeholder reused wherever a list can be empty (Riwayat,
/// notifications, leave history) instead of a single bare Text widget.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textMuted, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}
