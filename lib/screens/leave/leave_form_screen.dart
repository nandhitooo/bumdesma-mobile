import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/leave_request.dart';
import '../../services/leave_service.dart';
import '../../state/auth_provider.dart';

/// Mirrors "Ajukan Izin & Cuti" (Gambar 3.25): tanggal, jenis (Izin/Cuti),
/// alasan, dan lampiran file .pdf/.docx (mis. surat dokter).
class LeaveFormScreen extends StatefulWidget {
  const LeaveFormScreen({super.key});

  @override
  State<LeaveFormScreen> createState() => _LeaveFormScreenState();
}

class _LeaveFormScreenState extends State<LeaveFormScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  LeaveType _type = LeaveType.izin;
  final _reasonController = TextEditingController();
  PlatformFile? _attachment;
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _attachment = result.files.first);
    }
  }

  Future<void> _submit() async {
    if (_startDate == null || _endDate == null) {
      _showError('Silakan pilih tanggal izin/cuti.');
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      _showError('Alasan wajib diisi.');
      return;
    }

    setState(() => _submitting = true);
    final nip = context.read<AuthProvider>().user?.nip ?? '';

    try {
      await LeaveService.instance.submit(
        nip: nip,
        type: _type,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text.trim(),
        attachmentFileName: _attachment?.name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pengajuan berhasil dikirim, menunggu persetujuan.')),
      );
      setState(() {
        _startDate = null;
        _endDate = null;
        _attachment = null;
        _reasonController.clear();
      });
    } catch (_) {
      _showError('Gagal mengirim pengajuan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _dateLabel() {
    if (_startDate == null || _endDate == null) return 'Input Tanggal';
    final fmt = DateFormat('dd-MM-yyyy');
    if (_startDate == _endDate) return fmt.format(_startDate!);
    return '${fmt.format(_startDate!)}  —  ${fmt.format(_endDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ajukan Izin & Cuti')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Input Tanggal',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDateRange,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today_rounded,
                      color: AppColors.primary, size: 20),
                ),
                child: Text(_dateLabel()),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Izin',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<LeaveType>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(
                    value: LeaveType.izin, child: Text('Sakit / Izin')),
                DropdownMenuItem(value: LeaveType.cuti, child: Text('Cuti')),
              ],
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 18),
            const Text('Alasan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Input Alasan'),
            ),
            const SizedBox(height: 18),
            const Text('Attach File',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickAttachment,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.attach_file_rounded,
                      color: AppColors.primary, size: 20),
                ),
                child: Text(_attachment?.name ?? '(.pdf or .docx)'),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : const Text('Ajukan'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Riwayat Pengajuan',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 12),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    final nip = context.watch<AuthProvider>().user?.nip ?? '';
    return FutureBuilder<List<LeaveRequest>>(
      future: LeaveService.instance.getMyLeaveRequests(nip),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          );
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Text('Belum ada pengajuan.',
              style: TextStyle(color: AppColors.textSecondary));
        }
        return Column(
          children: items.map((r) => _LeaveTile(request: r)).toList(),
        );
      },
    );
  }
}

class _LeaveTile extends StatelessWidget {
  final LeaveRequest request;
  const _LeaveTile({required this.request});

  Color get _statusColor {
    switch (request.status) {
      case LeaveStatus.disetujui:
        return AppColors.success;
      case LeaveStatus.ditolak:
        return AppColors.danger;
      case LeaveStatus.menunggu:
        return AppColors.warning;
    }
  }

  String get _statusLabel {
    switch (request.status) {
      case LeaveStatus.disetujui:
        return 'Disetujui';
      case LeaveStatus.ditolak:
        return 'Ditolak';
      case LeaveStatus.menunggu:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'id_ID');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.type == LeaveType.cuti ? 'Cuti' : 'Sakit / Izin',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${fmt.format(request.startDate)} — ${fmt.format(request.endDate)}',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                    color: _statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
