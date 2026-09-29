import 'package:tuoora/core/enums/app_enums.dart';
import 'package:tuoora/data/models/student_model.dart';

class DailyUpdate {
  final int? id;
  final int? batchId;
  final int? instituteId;
  final int? studentId;
  final UpdateCategory category;
  final UpdateTargetType targetType;
  final String description;
  final String? attachment;
  final DateTime? date;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DailyUpdateBatch? batch;
  final Student? student;

  // Field for creation
  final String? topic;

  const DailyUpdate({
    this.id,
    this.batchId,
    this.instituteId,
    this.studentId,
    required this.category,
    required this.targetType,
    required this.description,
    this.attachment,
    this.date,
    this.createdAt,
    this.updatedAt,
    this.batch,
    this.student,
    this.topic,
  });

  factory DailyUpdate.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return DailyUpdate(
      id: json['id'],
      batchId: json['batch_id'],
      instituteId: json['institute_id'],
      studentId: json['student_id'],
      topic: json['topic'],
      category: UpdateCategory.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (json['category']?.toString().toLowerCase() ?? 'other'),
        orElse: () => UpdateCategory.Other,
      ),
      targetType: UpdateTargetType.values.firstWhere(
        (e) => e.name == json['target_type'],
        orElse: () => UpdateTargetType.all,
      ),
      description: json['description']?.toString() ?? '',
      attachment: json['attachment']?.toString(),
      date: parseDate(json['date']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      batch: json['batch'] != null
          ? DailyUpdateBatch.fromJson(json['batch'])
          : null,
      student: json['student'] != null
          ? Student.fromJson(json['student'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'topic': topic,
      'description': description,
      'category': category.name,
      'target_type': targetType.name,
    };

    if (date != null) {
      data['date'] = "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}";
    }

    if (targetType == UpdateTargetType.all) {
      if (studentId != null) data['student_id'] = studentId;
    } else if (targetType == UpdateTargetType.batch) {
      if (batchId != null) data['batch_id'] = batchId;
    }

    return data;
  }

  // UI Helpers
  String get timeAgo {
    if (createdAt == null) return 'Recently';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String get audience {
    if (targetType == UpdateTargetType.batch) {
      return batch?.name ?? 'Batch';
    }
    return 'All Students';
  }
}

class DailyUpdateBatch {
  final int id;
  final String name;
  final String? subject;

  DailyUpdateBatch({required this.id, required this.name, this.subject});

  factory DailyUpdateBatch.fromJson(Map<String, dynamic> json) {
    return DailyUpdateBatch(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      subject: json['subject']?.toString(),
    );
  }
}
