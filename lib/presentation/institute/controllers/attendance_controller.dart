import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/attendance_record_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/presentation/institute/controllers/batch_details_controller.dart';
import 'package:tuoora/presentation/institute/controllers/institute_controller.dart';
import 'package:tuoora/core/widgets/app_pickers.dart';

class AttendanceStudent {
  final int id;
  final String name;
  final String? enrollmentId;
  final String? profileImageUrl;
  String status; // 'present' or 'absent'

  AttendanceStudent({
    required this.id,
    required this.name,
    this.enrollmentId,
    this.profileImageUrl,
    this.status = 'present',
  });

  bool get isPresent => status == 'present';

  Map<String, dynamic> toMap() {
    return {'student_id': id, 'status': status};
  }
}

class AttendanceController extends GetxController {
  final InstituteRepositoryImpl _repository;

  final selectedDate = DateTime.now().obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  late BatchModel batch;

  final allStudents = <AttendanceStudent>[].obs;
  final filteredStudents = <AttendanceStudent>[].obs;

  AttendanceController(this._repository);

  bool get isToday {
    final now = DateTime.now();
    return selectedDate.value.year == now.year &&
        selectedDate.value.month == now.month &&
        selectedDate.value.day == now.day;
  }

  bool get isPastDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );
    return selected.isBefore(today);
  }

  // Attendance is only editable for today. Past dates are read-only.
  bool get isEditable => isToday;

  @override
  void onInit() {
    super.onInit();
    batch = Get.arguments;

    fetchAttendance();

    // Setup search listener
    debounce(
      searchQuery,
      (_) => filterStudents(),
      time: const Duration(milliseconds: 300),
    );
  }

  String get formattedDate =>
      DateFormat('MMMM dd, yyyy • EEEE').format(selectedDate.value);
  String get apiDate => DateFormat('yyyy-MM-dd').format(selectedDate.value);

  Future<void> fetchAttendance() async {
    try {
      isLoading.value = true;
      final List<AttendanceRecordModel> response = await _repository
          .getAttendance(apiDate, int.parse(batch.id));

      if (response.isNotEmpty) {
        final students = response.map((record) {
          String? resolvedEnrollment = record.enrollmentId;
          if (resolvedEnrollment == null || resolvedEnrollment.trim().isEmpty) {
            // Check batch details controller or institute controller
            try {
              if (Get.isRegistered<BatchDetailsController>(tag: batch.id)) {
                final bdc = Get.find<BatchDetailsController>(tag: batch.id);
                final match = bdc.assignedStudents.firstWhereOrNull(
                  (bs) =>
                      bs.student.id == record.studentId ||
                      bs.student.name.trim().toLowerCase() ==
                          record.studentName.trim().toLowerCase(),
                );
                if (match != null) {
                  final enId = match.student.enrollmentID?.toString().trim() ?? '';
                  if (enId.isNotEmpty) {
                    resolvedEnrollment = enId;
                  } else if (match.student.idHash.trim().isNotEmpty) {
                    resolvedEnrollment = match.student.idHash.trim();
                  }
                }
              }
            } catch (_) {}

            if (resolvedEnrollment == null || resolvedEnrollment.trim().isEmpty) {
              try {
                if (Get.isRegistered<InstituteController>()) {
                  final inst = Get.find<InstituteController>();
                  final match = inst.students.firstWhereOrNull(
                    (s) =>
                        s.id == record.studentId ||
                        s.name.trim().toLowerCase() ==
                            record.studentName.trim().toLowerCase(),
                  );
                  if (match != null) {
                    final enId = match.enrollmentID?.toString().trim() ?? '';
                    if (enId.isNotEmpty) {
                      resolvedEnrollment = enId;
                    } else if (match.idHash.trim().isNotEmpty) {
                      resolvedEnrollment = match.idHash.trim();
                    }
                  }
                }
              } catch (_) {}
            }
          }

          return AttendanceStudent(
            id: record.studentId,
            name: record.studentName,
            enrollmentId: resolvedEnrollment ?? record.studentId.toString(),
            profileImageUrl: null, // API doesn't provide it in this endpoint
            status:
                record.status ?? 'present', // Default to present if not marked
          );
        }).toList();
        allStudents.assignAll(students);
      } else {
        allStudents.clear();
      }

      filterStudents();
    } catch (e) {
      AppSnackBar.error(AppStrings.errFailedLoadAttendance);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitAttendance() async {
    try {
      CommonLoading.show();
      final data = {
        'batch_id': int.parse(batch.id),
        'date': apiDate,
        'attendance': allStudents.map((s) => s.toMap()).toList(),
      };

      await _repository.markAttendance(data);

      CommonLoading.dismiss();
      Get.back();
      AppSnackBar.success(AppStrings.attendanceSubmitted);
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToSubmitAttendance);
    } finally {
      CommonLoading.dismiss();
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final now = DateTime.now();
    // Floor of the range = the day the batch was created. Falls back to a
    // safe sentinel when the API didn't return a parseable timestamp.
    // Stripped to midnight so the picker treats the creation day itself as
    // selectable (DatePicker compares year/month/day, not the time part).
    final creation = batch.createdAt;
    final firstDate = creation != null
        ? DateTime(creation.year, creation.month, creation.day)
        : DateTime(2020);
    // Clamp initialDate into [firstDate, today] — required by showDatePicker;
    // otherwise it asserts when the user re-opens a stale selection that's
    // older than the batch creation day (shouldn't normally happen, but
    // guards against the assert).
    final today = DateTime(now.year, now.month, now.day);
    DateTime initial = selectedDate.value;
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(today)) initial = today;

    final DateTime? picked = await AppPickers.date(
      context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: today,
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      fetchAttendance();
    }
  }

  void filterStudents() {
    if (searchQuery.value.isEmpty) {
      filteredStudents.assignAll(allStudents);
    } else {
      filteredStudents.assignAll(
        allStudents
            .where(
              (s) =>
                  s.name.toLowerCase().contains(
                    searchQuery.value.toLowerCase(),
                  ) ||
                  s.id.toString().contains(searchQuery.value) ||
                  (s.enrollmentId != null &&
                      s.enrollmentId!.toLowerCase().contains(
                            searchQuery.value.toLowerCase(),
                          )),
            )
            .toList(),
      );
    }
  }

  void toggleStatus(AttendanceStudent student, bool isPresent) {
    if (!isEditable) return;
    student.status = isPresent ? 'present' : 'absent';
    allStudents.refresh();
    filterStudents();
  }

  void markAllPresent() {
    if (!isEditable) return;
    for (var s in allStudents) {
      s.status = 'present';
    }
    allStudents.refresh();
    filterStudents();
  }

  void markAllAbsent() {
    if (!isEditable) return;
    for (var s in allStudents) {
      s.status = 'absent';
    }
    allStudents.refresh();
    filterStudents();
  }
}
