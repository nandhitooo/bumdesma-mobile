import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/notification_item.dart';
import '../../services/notification_service.dart';
import '../../widgets/section_card.dart';

/// Pop-up shown when the employee taps the notification bell on Dashboard
/// (Gambar 3.24): jadwal piket Sabtu yang di-assign Admin, dan status
/// pengajuan Izin/Cuti.
///
/// Redesigned so unread items are visually highlighted (subtle tinted
/// background + red dot) instead of every item looking identical, and the
/// empty state now uses the shared [EmptyState] widget.
Future<void> showNotificationPanel(BuildContext context, String nip) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _NotificationSheet(nip: nip),
  );
}

class _NotificationSheet extends StatefulWidget {
  final String nip;
  const _NotificationSheet({required this.nip});

  @override
  State<_NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<_NotificationSheet> {
  late Future<List<AppNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = NotificationService.instance.getNotifications(widget.nip);
    NotificationService.instance.markAllRead(widget.nip);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Icon(Icons.notifications_rounded, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Notifikasi', style: AppTextStyles.sectionTitle),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<AppNotification>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary));
                    }
                    final items = snapshot.data!;
                    if (items.isEmpty) {
                      return const EmptyState(
                        icon: Icons.notifications_off_outlined,
                        title: 'Belum ada notifikasi',
                        message:
                            'Info piket dan status izin/cuti akan muncul di sini.',
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: items.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _NotificationTile(item: items[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification item;
  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isPiket = item.type == NotificationType.piket;
    final color = isPiket ? AppColors.info : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.read ? AppColors.surface : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              isPiket
                  ? Icons.event_available_rounded
                  : Icons.description_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('d MMM yyyy, HH:mm', 'id_ID')
                      .format(item.createdAt),
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (!item.read)
            Container(
              margin: const EdgeInsets.only(top: 4, left: 6),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.danger, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
