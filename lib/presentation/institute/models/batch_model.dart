import 'package:tuoora/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BatchModel {
  final String id;
  final String title;
  final String time;
  final String subject;
  final String studentCount;
  final String location;
  final String statusLabel;
  final Color statusBg;
  final Color leftBorderColor;
  final double baseFee;
  final String? feesLastDate;
  final String description;
  final Color statusTextColor;
  final dynamic totalExpected;
  final dynamic totalPaid;
  final List<String> days;
  final List<dynamic>? students;
  final String? classroom;
  final int? staffId;
  final String? staffName;
  final DateTime? createdAt;

  BatchModel({
    required this.id,
    required this.title,
    required this.time,
    required this.subject,
    required this.studentCount,
    required this.location,
    required this.statusLabel,
    required this.statusBg,
    required this.leftBorderColor,
    this.baseFee = 0.0,
    this.feesLastDate,
    this.description = '',
    this.statusTextColor = AppColors.white,
    this.totalExpected,
    this.totalPaid,
    this.days = const ['Mon', 'Wed', 'Fri'],
    this.students,
    this.classroom,
    this.staffId,
    this.staffName,
    this.createdAt,
  });
}
