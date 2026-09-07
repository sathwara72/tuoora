import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/enums/app_enums.dart';

class AssignmentAttachment {
  final String id;
  final String name;
  final String sizeLabel;
  final AssignmentAttachmentKind kind;
  final String? url;
  final String? durationLabel;
  final int? pageCount;
  final String? extensionLabel;

  const AssignmentAttachment({
    required this.id,
    required this.name,
    required this.sizeLabel,
    required this.kind,
    this.url,
    this.durationLabel,
    this.pageCount,
    this.extensionLabel,
  });

  String get inferredExtension {
    if (extensionLabel != null) return extensionLabel!.toUpperCase();
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toUpperCase();
  }
}

class Assignment {
  final String id;
  final String title;
  final String subjectLabel;
  final String dueLabel;
  final IconData icon;
  final Color stripe;
  final Color iconBg;
  final Color iconColor;
  final AssignmentBadge badge;
  final String? dueDateFullText;
  final String? instructions;
  final String? assignedBy;
  final List<AssignmentAttachment> attachments;
  final String? pendingNote;
  final String? completedNote;
  final String? gradeNote;
  final bool isOverdue;
  final DateTime? createdAt;
  final String? submissionNote;
  final String? submissionAttachmentUrl;

  /// True once the due date has passed, regardless of submission status —
  /// unlike [isOverdue] (display-only, forced false once completed), this
  /// is what gates whether a (re)submission is still allowed.
  final bool dueDatePassed;

  const Assignment({
    required this.id,
    required this.title,
    required this.subjectLabel,
    required this.dueLabel,
    required this.icon,
    required this.stripe,
    required this.iconBg,
    required this.iconColor,
    required this.badge,
    this.dueDateFullText,
    this.instructions,
    this.assignedBy,
    this.attachments = const [],
    this.pendingNote,
    this.completedNote,
    this.gradeNote,
    this.isOverdue = false,
    this.createdAt,
    this.submissionNote,
    this.submissionAttachmentUrl,
    this.dueDatePassed = false,
  });

  bool get isCompleted => badge == AssignmentBadge.done;

  factory Assignment.fromJson(
    Map<String, dynamic> json, {
    bool isCompleted = false,
  }) {
    final subject = json['subject']?.toString() ?? 'General';
    const palettes = <List<Color>>[
      [AppColors.primaryBrand, AppColors.primaryBrandLight],
      [AppColors.successGreen, AppColors.successBg],
      [AppColors.bohoRed, AppColors.errorBg],
      [AppColors.subjectPhysics, AppColors.subjectPhysicsSoft],
      [AppColors.orangeTag, AppColors.primaryBrandLight],
      [AppColors.successGreen, AppColors.successBg],
    ];

    final id = json['id']?.toString() ?? '';
    final palette = palettes[id.hashCode.abs() % palettes.length];

    final stripe = palette[0];
    final iconBg = palette[1];
    final iconColor = stripe;
    final icon = Icons.menu_book_rounded;

    final attachments = <AssignmentAttachment>[];
    if (json['attachment_url'] != null) {
      final url = json['attachment_url'].toString();
      final name = url.split('/').last;
      final ext = name.split('.').last.toLowerCase();
      var kind = AssignmentAttachmentKind.document;
      if (['jpg', 'jpeg', 'png'].contains(ext)) {
        kind = AssignmentAttachmentKind.image;
      }
      if (['mp4', 'mov'].contains(ext)) kind = AssignmentAttachmentKind.video;

      attachments.add(
        AssignmentAttachment(
          id: url,
          name: name,
          sizeLabel: 'Attachment',
          kind: kind,
          url: url,
        ),
      );
    }

    final rawDue = json['due_date']?.toString();
    DateTime? parsedDue;
    if (rawDue != null && rawDue.isNotEmpty) {
      try {
        parsedDue = DateTime.parse(rawDue);
      } catch (_) {}
    }

    String dueLabelText = rawDue ?? '';
    int? dueDiffDays;
    if (parsedDue != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dueDay = DateTime(parsedDue.year, parsedDue.month, parsedDue.day);
      dueDiffDays = dueDay.difference(today).inDays;
      if (dueDiffDays == 0) {
        dueLabelText = 'Today';
      } else if (dueDiffDays == 1) {
        dueLabelText = 'Tomorrow';
      } else {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        dueLabelText = '${parsedDue.day} ${months[parsedDue.month - 1]}';
      }
    }

    final bool duePassed =
        json['is_overdue'] == true || (dueDiffDays != null && dueDiffDays < 0);

    final bool overdue = !isCompleted && duePassed;

    AssignmentBadge badge = AssignmentBadge.today;
    if (isCompleted) {
      badge = AssignmentBadge.done;
    } else {
      if (json['is_overdue'] == true) {
        badge = AssignmentBadge.today;
      } else {
        badge = AssignmentBadge.tomorrow;
      }
    }

    String? completedNoteStr;
    String? gradeNoteStr;
    String? submissionNoteStr;
    String? submissionAttachmentUrlStr;
    if (json['submission'] != null) {
      final sub = json['submission'];
      completedNoteStr = 'Status: ${sub['status'] ?? 'Submitted'}';
      if (sub['score'] != null) {
        gradeNoteStr = 'Score: ${sub['score']}';
      }
      submissionNoteStr = sub['note'];
      submissionAttachmentUrlStr = sub['attachment_url'];
    }

    DateTime? createdAtDt;
    final rawCreated = json['created_at']?.toString();
    if (rawCreated != null && rawCreated.isNotEmpty) {
      try {
        createdAtDt = DateTime.parse(rawCreated);
      } catch (_) {}
    }

    return Assignment(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      subjectLabel: subject.toUpperCase(),
      dueLabel: dueLabelText,
      icon: icon,
      stripe: stripe,
      iconBg: iconBg,
      iconColor: iconColor,
      badge: badge,
      dueDateFullText: json['due_date'],
      instructions: json['description'],
      assignedBy: 'Batch: ${json['batch_name']}',
      attachments: attachments,
      pendingNote: overdue ? 'Overdue' : null,
      completedNote: completedNoteStr,
      gradeNote: gradeNoteStr,
      submissionNote: submissionNoteStr,
      submissionAttachmentUrl: submissionAttachmentUrlStr,
      dueDatePassed: duePassed,
      isOverdue: overdue,
      createdAt: createdAtDt,
    );
  }
}

class AssignmentSummary {
  final int total;
  final int pending;
  final int completed;
  final int overdue;

  const AssignmentSummary({
    required this.total,
    required this.pending,
    required this.completed,
    required this.overdue,
  });

  factory AssignmentSummary.fromJson(Map<String, dynamic> json) {
    return AssignmentSummary(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      completed: json['completed'] ?? 0,
      overdue: json['overdue'] ?? 0,
    );
  }
}
