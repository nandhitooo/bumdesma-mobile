import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/attendance.dart';
import '../../services/attendance_service.dart';
import '../../state/auth_provider.dart';

/// Mirrors "Riwayat" screen (Gambar 3.35): daftar absensi per hari,
/// dikelompokkan berdasarkan tanggal, dengan filter bulan.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Pilih Bulan',
    );
    if (picked != null) {
      setState(() => _month = DateTime(picked.year, picked.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    final nip = context.watch<AuthProvider>().user?.nip ?? '';
    final isCurrentMonth = _month.year == DateTime.now().year &&
        _month.month == DateTime.now().month;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Riwayat')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _pickMonth,
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: Text(
                  isCurrentMonth
                      ? 'Bulan Ini'
                      : DateFormat('MMMM yyyy', 'id_ID').format(_month),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DailyAttendance>>(
              future:
                  AttendanceService.instance.getHistory(nip, month: _month),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!.reversed.toList();
                if (items.isEmpty) {
                  return const Center(
                    child: Text('Belum ada data absensi bulan ini.',
                        style: TextStyle(color: AppColors.textSecondary)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: items.length,
                  itemBuilder: (context, i) => _DayGroup(record: items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayGroup extends StatelessWidget {
  final DailyAttendance record;
  const _DayGroup({required this.record});

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(record.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateLabel,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          _HistoryRow(
            icon: Icons.login_rounded,
            iconColor: AppColors.success,
            title: 'Masuk',
            time: record.jamMasuk,
            status: record.statusMasuk,
          ),
          const SizedBox(height: 8),
          _HistoryRow(
            icon: Icons.logout_rounded,
            iconColor: AppColors.danger,
            title: 'Pulang',
            time: record.jamPulang,
            status: record.statusPulang,
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final DateTime? time;
  final AttendanceStatus? status;

  const _HistoryRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.status,
  });

  ({Color color, String label}) get _statusSpec {
    if (time == null) return (color: AppColors.textSecondary, label: 'Tidak Masuk');
    switch (status) {
      case AttendanceStatus.terlambat:
        return (color: AppColors.warning, label: 'Terlambat');
      case AttendanceStatus.lembur:
        return (color: AppColors.warning, label: 'Lembur');
      case AttendanceStatus.tepatWaktu:
      case AttendanceStatus.diterima:
        return (color: AppColors.success, label: 'Tepat Waktu');
      default:
        return (color: AppColors.textSecondary, label: '--');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _statusSpec;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Text(
            time == null ? '--' : DateFormat('HH:mm').format(time!),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 12),
          Text(
            s.label,
            style: TextStyle(
                color: s.color, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
