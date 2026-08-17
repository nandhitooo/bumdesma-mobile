import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../models/leave_request.dart';
import '../../services/leave_service.dart';
import '../../state/auth_provider.dart';
import '../../widgets/gradient_app_header.dart';
import '../../widgets/section_card.dart';

/// Mirrors "Ajukan Izin & Cuti" (Gambar 3.25): tanggal, jenis (Izin/Cuti),
/// alasan, dan lampiran file .pdf/.docx (mis. surat dokter).
///
/// Redesigned to use [GradientAppHeader] and to group the form and
/// history list into distinct [SectionCard]s with clearer type icons
/// (Cuti vs Sakit/Izin) instead of a flat, undifferentiated list.
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
        // IMPORTANT: pass the actual local file path (PlatformFile.path),
        // not PlatformFile.name — using only the bare filename here would
        // mean HttpLeaveService tries to open a path that doesn't exist,
        // so the attachment silently never reaches the backend.
        attachmentPath: _attachment?.path,
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
    } on ApiException catch (e) {
      // Surface the backend's actual reason instead of masking every
      // failure behind the same generic message.
      _showError(e.message);
    } catch (e) {
      _showError('Gagal mengirim pengajuan: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _dateLabel() {
    if (_startDate == null || _endDate == null) return 'Pilih tanggal';
    final fmt = DateFormat('dd MMM yyyy', 'id_ID');
    if (_startDate == _endDate) return fmt.format(_startDate!);
    return '${fmt.format(_startDate!)}  —  ${fmt.format(_endDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: GradientAppHeader(
              title: 'Izin & Cuti',
              subtitle: 'Ajukan izin, sakit, atau cuti di sini',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SectionCard(
                  title: 'Formulir Pengajuan',
                  icon: Icons.edit_calendar_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tanggal',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDateRange,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.calendar_today_rounded,
                                color: AppColors.primary, size: 20),
                          ),
                          child: Text(_dateLabel()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Jenis',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<LeaveType>(
                        initialValue: _type,
                        items: const [
                          DropdownMenuItem(
                              value: LeaveType.sakit, child: Text('Sakit')),
                          DropdownMenuItem(
                              value: LeaveType.izin, child: Text('Izin')),
                          DropdownMenuItem(
                              value: LeaveType.cuti, child: Text('Cuti')),
                        ],
                        onChanged: (v) => setState(() => _type = v ?? _type),
                      ),
                      const SizedBox(height: 16),
                      const Text('Alasan',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _reasonController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                            hintText: 'Jelaskan alasan Anda'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Lampiran',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickAttachment,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.attach_file_rounded,
                                color: AppColors.primary, size: 20),
                          ),
                          child: Text(
                            _attachment?.name ?? 'Pilih file .pdf atau .docx',
                            style: TextStyle(
                              color: _attachment == null
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.4, color: Colors.white),
                              )
                            : const Text('Ajukan Sekarang'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(Icons.history_rounded,
                        size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Riwayat Pengajuan',
                        style: AppTextStyles.sectionTitle),
                  ],
                ),
                const SizedBox(height: 12),
                _buildHistoryList(),
              ]),
            ),
          ),
        ],
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
            child: LinearProgressIndicator(color: AppColors.primary),
          );
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'Belum ada pengajuan',
            message: 'Pengajuan izin/cuti Anda akan tampil di sini.',
          );
        }
        return Column(
          children: items
              .map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LeaveTile(request: r),
                  ))
              .toList(),
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

  IconData get _typeIcon {
    switch (request.type) {
      case LeaveType.cuti:
        return Icons.beach_access_rounded;
      case LeaveType.sakit:
        return Icons.sick_outlined;
      case LeaveType.izin:
        return Icons.event_note_rounded;
    }
  }

  Color get _typeColor {
    switch (request.type) {
      case LeaveType.cuti:
        return AppColors.info;
      case LeaveType.sakit:
        return AppColors.danger;
      case LeaveType.izin:
        return AppColors.accent;
    }
  }

  String get _typeLabel {
    switch (request.type) {
      case LeaveType.cuti:
        return 'Cuti';
      case LeaveType.sakit:
        return 'Sakit';
      case LeaveType.izin:
        return 'Izin';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'id_ID');

    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_typeIcon, color: _typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _typeLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '${fmt.format(request.startDate)} — ${fmt.format(request.endDate)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
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
    );
  }
}
