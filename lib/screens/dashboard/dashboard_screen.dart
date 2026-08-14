import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../state/attendance_provider.dart';
import '../../state/auth_provider.dart';
import '../../state/notification_provider.dart';
import '../leave/leave_form_screen.dart';
import '../notification/notification_panel.dart';
import '../scan/scan_select_screen.dart';
import 'widgets/attendance_summary_card.dart';
import 'widgets/quick_action_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nip = context.read<AuthProvider>().user?.nip;
      if (nip != null) {
        context.read<AttendanceProvider>().refreshToday(nip);
        context.read<NotificationProvider>().refresh(nip);
      }
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  Future<void> _openNotifications(String nip) async {
    context.read<NotificationProvider>().clear();
    await showNotificationPanel(context, nip);
    if (!mounted) return;
    context.read<NotificationProvider>().refresh(nip);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final attendance = context.watch<AttendanceProvider>();
    final notification = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          if (user != null) {
            await attendance.refreshToday(user.nip);
            if (!mounted) return;
            await context.read<NotificationProvider>().refresh(user.nip);
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(
                user?.nama ?? '',
                user?.jabatan ?? '',
                user?.nip ?? '',
                notification.hasUnread,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AttendanceSummaryCard(
                    record: attendance.today,
                    loading: attendance.loading,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Aksi Cepat',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Scan Absensi',
                          color: AppColors.primary,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ScanSelectScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.event_note_rounded,
                          label: 'Izin/Cuti',
                          color: AppColors.info,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const LeaveFormScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String nama, String jabatan, String nip, bool hasUnread) {
    final today =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x2616423C),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      // SafeArea (top only) memastikan konten tidak ketiban status bar /
      // notch, sementara gradient di atas tetap full-bleed sampai ujung layar.
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_greeting()},',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12.5),
                        ),
                        Text(
                          nama.isEmpty ? '-' : nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (jabatan.isNotEmpty)
                          Text(
                            jabatan,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _openNotifications(nip),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_rounded,
                              color: Colors.white, size: 22),
                        ),
                        if (hasUnread)
                          Positioned(
                            top: -1,
                            right: -1,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primary, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14, color: Colors.white.withValues(alpha: 0.85)),
                    const SizedBox(width: 8),
                    Text(
                      today,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
