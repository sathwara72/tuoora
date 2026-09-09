import 'package:flutter/material.dart' show Color;
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/date_format_utils.dart';
import 'package:tuoora/data/models/staff_model.dart';

class Batch {
  final int id;
  final int instituteId;
  final String name;
  final String subject;
  final String description;
  final String fees;
  final String? feesLastDate;
  final String startTime;
  final String endTime;
  final List<String> days;
  final String? classroom;
  final int? maxCapacity;
  final String createdAt;
  final String updatedAt;
  final int? studentsCount;
  final dynamic totalPaid;
  final dynamic totalExpected;
  final List<BatchStudent>? students;
  final int? staffId;
  final Staff? staff;

  /// Server-side lifecycle status — `"active"`, `"closed"`, etc. Drives
  /// the status badge label / colour on the UI side via [toUIModel].
  final String status;

  /// Soft-delete timestamp passed straight through from the API. The app
  /// doesn't render deleted batches today, but keeping it on the model
  /// means future callers can filter on it without re-parsing.
  final String? deletedAt;

  Batch({
    required this.id,
    required this.instituteId,
    required this.name,
    required this.subject,
    required this.description,
    required this.fees,
    this.feesLastDate,
    required this.startTime,
    required this.endTime,
    required this.days,
    this.classroom,
    this.maxCapacity,
    required this.createdAt,
    required this.updatedAt,
    this.studentsCount,
    this.totalPaid,
    this.totalExpected,
    this.students,
    this.staffId,
    this.staff,
    this.status = 'active',
    this.deletedAt,
  });

  BatchModel toUIModel() {
    // Map server status → label + status-badge colours. Anything not
    // explicitly recognised falls back to a neutral "Active" look so a
    // future status value doesn't break the badge.
    final normalized = status.toLowerCase().trim();
    final String label;
    final Color bg;
    final Color textColor;
    switch (normalized) {
      case 'closed':
        label = 'Closed';
        bg = AppColors.errorBg;
        textColor = AppColors.bohoRed;
        break;
      case 'inactive':
        label = 'Inactive';
        bg = AppColors.errorBg;
        textColor = AppColors.bohoRed;
        break;
      case 'active':
      default:
        label = 'Active';
        bg = AppColors.successBg;
        textColor = AppColors.greenText;
        break;
    }

    return BatchModel(
      id: id.toString(),
      title: name,
      time: '${_format12Hour(startTime)} - ${_format12Hour(endTime)}',
      subject: subject,
      studentCount: '${studentsCount ?? 0} Students',
      location: classroom ?? 'Main Hall',
      statusLabel: label,
      statusBg: bg,
      leftBorderColor: AppColors.primaryBrand,
      statusTextColor: textColor,
      baseFee: double.tryParse(fees.toString()) ?? 0.0,
      feesLastDate: feesLastDate,
      description: description,
      totalExpected: totalExpected,
      totalPaid: totalPaid,
      days: DateFormatUtils.normalizeDays(days),
      students: students,
      classroom: classroom,
      staffId: staffId,
      staffName: staff?.fullName,
      createdAt: DateTime.tryParse(createdAt)?.toLocal(),
    );
  }

  factory Batch.fromJson(Map<String, dynamic> json) {
    int safeInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }

    int? safeNullableInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return Batch(
      id: safeInt(json['id']),
      instituteId: safeInt(json['institute_id']),
      name: json['name']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      fees: json['fees']?.toString() ?? '0.00',
      feesLastDate: json['fees_last_date']?.toString(),
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      days: DateFormatUtils.normalizeDays(json['days']),
      classroom: json['classroom']?.toString(),
      maxCapacity: safeNullableInt(json['max_capacity']),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      studentsCount: safeNullableInt(json['students_count']),
      totalPaid: json['total_paid'],
      totalExpected: json['total_expected'],
      students: (json['students'] as List?)
          ?.whereType<Map>()
          .map((i) => BatchStudent.fromJson(i.cast<String, dynamic>()))
          .toList(),
      staffId: safeNullableInt(json['staff_id']),
      staff: json['staff'] is Map
          ? Staff.fromJson((json['staff'] as Map).cast<String, dynamic>())
          : null,
      status: json['status']?.toString() ?? 'active',
      deletedAt: json['deleted_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institute_id': instituteId,
      'name': name,
      'subject': subject,
      'description': description,
      'fees': fees,
      'fees_last_date': feesLastDate,
      'start_time': startTime,
      'end_time': endTime,
      'days': days,
      'classroom': classroom,
      'max_capacity': maxCapacity,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'students_count': studentsCount,
      'total_paid': totalPaid,
      'total_expected': totalExpected,
      'students': students?.map((s) => s.toJson()).toList(),
      'staff_id': staffId,
      'staff': staff != null
          ? {
              'id': staff!.id,
              'full_name': staff!.fullName,
              'email': staff!.email,
              'phone': staff!.phone,
            }
          : null,
      'status': status,
      'deleted_at': deletedAt,
    };
  }

  // Converts a server-format time like "18:30" or "06:00 PM" into a 12-hour
  // display string like "6:30 PM". Falls back to the original input if it
  // cannot be parsed so we never blank out the schedule.
  static String _format12Hour(String raw) {
    if (raw.trim().isEmpty) return raw;
    final cleaned = raw.trim();
    final upper = cleaned.toUpperCase();
    if (upper.contains('AM') || upper.contains('PM')) return cleaned;
    final parts = cleaned.split(':');
    if (parts.length < 2) return cleaned;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return cleaned;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = ((h + 11) % 12) + 1;
    final mm = m.toString().padLeft(2, '0');
    return '$hour12:$mm $period';
  }
}

class BatchStudent {
  final int id;
  final int? studentId;
  final String name;
  final String? enrollmentId;
  final int? batchId;
  final String? profileImageUrl;
  final bool isBirthdayToday;

  BatchStudent({
    required this.id,
    this.studentId,
    required this.name,
    this.enrollmentId,
    this.batchId,
    this.profileImageUrl,
    this.isBirthdayToday = false,
  });

  factory BatchStudent.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    final rawEnrollment = json['enrollment_id']?.toString() ??
        json['id_hash']?.toString() ??
        json['enrollmentId']?.toString();

    return BatchStudent(
      id: toInt(json['id']) ?? 0,
      studentId: toInt(json['student_id']),
      name: json['name']?.toString() ?? '',
      enrollmentId: rawEnrollment,
      batchId: toInt(json['batch_id']),
      profileImageUrl: json['profile_image_url']?.toString(),
      isBirthdayToday: json['is_birthday_today'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'name': name,
      'enrollment_id': enrollmentId,
      'batch_id': batchId,
      'profile_image_url': profileImageUrl,
      'is_birthday_today': isBirthdayToday,
    };
  }
}

class BatchListResponse {
  final List<Batch> items;
  final int total;
  final int currentPage;
  final int lastPage;

  BatchListResponse({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory BatchListResponse.fromJson(Map<String, dynamic> json) {
    return BatchListResponse(
      items: (json['items'] as List).map((i) => Batch.fromJson(i)).toList(),
      total: json['total'],
      currentPage: json['current_page'],
      lastPage: json['last_page'],
    );
  }
}

