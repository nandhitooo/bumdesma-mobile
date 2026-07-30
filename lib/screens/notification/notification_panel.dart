import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/notification_item.dart';
import '../../services/notification_service.dart';

/// Pop-up shown when the employee taps the notification bell on Dashboard
/// (Gambar 3.24): jadwal piket Sabtu yang di-assign Admin, dan status
/// pengajuan Izin/Cuti.
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.notifications_rounded, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Notifikasi',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<AppNotification>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = snapshot.data!;
                    if (items.isEmpty) {
                      return const Center(
                        child: Text('Belum ada notifikasi.',
                            style: TextStyle(color: AppColors.textSecondary)),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.divider),
                      itemBuilder: (context, i) =>
                          _NotificationTile(item: items[i]),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor:
                (isPiket ? AppColors.info : AppColors.success).withValues(alpha: 0.12),
            child: Icon(
              isPiket ? Icons.event_available_rounded : Icons.description_rounded,
              color: isPiket ? AppColors.info : AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.description,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(item.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
