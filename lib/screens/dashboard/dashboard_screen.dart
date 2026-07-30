import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../state/attendance_provider.dart';
import '../../state/auth_provider.dart';
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
      if (nip != null) context.read<AttendanceProvider>().refreshToday(nip);
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final attendance = context.watch<AttendanceProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) await attendance.refreshToday(user.nip);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(user?.nama ?? '', user?.nip ?? '')),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AttendanceSummaryCard(
                    record: attendance.today,
                    loading: attendance.loading,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aksi Cepat',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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

  Widget _buildHeader(String nama, String nip) {
    final today = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()},',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                    ),
                    Text(
                      nama.isEmpty ? '-' : nama,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => showNotificationPanel(context, nip),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            today,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
