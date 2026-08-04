import 'dart:io';

import 'package:intl/intl.dart';

import '../core/network/api_client.dart';
import '../models/leave_request.dart';
import 'leave_service.dart';

/// Real implementation of [LeaveService], wired to bumdesma-backend's
/// /api/leaves routes (POST is multipart/form-data because of the optional
/// .pdf/.docx lampiran — see leave.routes.js + upload.middleware.js).
class HttpLeaveService implements LeaveService {
  final ApiClient _api = ApiClient.instance;
  final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  Future<List<LeaveRequest>> getMyLeaveRequests(String nip) async {
    final res = await _api.get('/leaves/me');
    final rows = (res['data'] as List).cast<Map<String, dynamic>>();
    return rows.map(_fromJson).toList();
  }

  @override
  Future<LeaveRequest> submit({
    required String nip,
    required LeaveType type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? attachmentPath,
  }) async {
    final fields = {
      'jenis': type == LeaveType.cuti ? 'cuti' : 'izin',
      'tanggal_mulai': _dateFmt.format(startDate),
      'tanggal_selesai': _dateFmt.format(endDate),
      'alasan': reason,
    };

    // attachmentPath is the actual local filesystem path returned by
    // file_picker (PlatformFile.path) — NOT just the bare filename. Using
    // only the filename here previously meant File(...) pointed at a path
    // that didn't exist, so the file silently never made it into the
    // multipart request and file_lampiran stayed null on the backend.
    final file = attachmentPath != null ? File(attachmentPath) : null;

    final res = await _api.postMultipart('/leaves', fields: fields, file: file);
    return _fromJson(res['data'] as Map<String, dynamic>);
  }

  @override
  Future<bool> isOnApprovedLeave(String nip, DateTime date) async {
    // Purely advisory on the mobile side (e.g. to hide the scan button) —
    // POST /attendance/scan already rejects scans during an approved leave
    // authoritatively on the server regardless of this check.
    final list = await getMyLeaveRequests(nip);
    final target = DateTime(date.year, date.month, date.day);
    return list.any((r) {
      if (r.status != LeaveStatus.disetujui) return false;
      final start = DateTime(r.startDate.year, r.startDate.month, r.startDate.day);
      final end = DateTime(r.endDate.year, r.endDate.month, r.endDate.day);
      return !target.isBefore(start) && !target.isAfter(end);
    });
  }

  LeaveRequest _fromJson(Map<String, dynamic> row) {
    return LeaveRequest(
      id: row['id'] as String,
      type: (row['jenis'] as String) == 'cuti' ? LeaveType.cuti : LeaveType.izin,
      startDate: DateTime.parse(row['tanggal_mulai'] as String),
      endDate: DateTime.parse(row['tanggal_selesai'] as String),
      reason: row['alasan'] as String,
      attachmentFileName: row['file_lampiran'] as String?,
      submittedAt: DateTime.parse(row['created_at'] as String),
      status: _mapStatus(row['status'] as String?),
    );
  }

  // status ('pending' | 'diteruskan' | 'approved' | 'rejected') -> LeaveStatus
  LeaveStatus _mapStatus(String? status) {
    switch (status) {
      case 'approved':
        return LeaveStatus.disetujui;
      case 'rejected':
        return LeaveStatus.ditolak;
      case 'pending':
      case 'diteruskan':
      default:
        return LeaveStatus.menunggu;
    }
  }
}
