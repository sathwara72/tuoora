import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/data/models/student_model.dart';
import 'package:tuoora/presentation/institute/controllers/institute_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/presentation/institute/controllers/batch_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One fee milestone (installment) being set up while assigning a student.
class MilestoneDraft {
  String title;
  double amount;
  DateTime dueDate;

  /// Bumped when the amount is changed for the user, so its text field resets.
  int stamp = 0;

  MilestoneDraft({
    required this.title,
    required this.amount,
    required this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    'due_date':
        '${dueDate.year.toString().padLeft(4, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
  };
}

class BatchStudent {
  final Student student;
  double assignedFee;
  final List<MilestoneDraft> milestones;

  /// Bumped whenever milestones are rebuilt so their text fields reset.
  int version = 0;

  BatchStudent({
    required this.student,
    required this.assignedFee,
    List<MilestoneDraft>? milestones,
  }) : milestones = milestones ?? [];
}

class BatchDetailsController extends GetxController {
  final InstituteController instituteController =
      Get.find<InstituteController>();
  final InstituteRepositoryImpl _repository =
      Get.find<InstituteRepositoryImpl>();
  late final Rx<BatchModel> _batch;
  BatchModel get batch => _batch.value;

  final assignedStudents = <BatchStudent>[].obs;
  final isLoading = false.obs;
  final studentCount = 0.obs;
  final totalExpected = ''.obs;
  final totalPaid = ''.obs;
  final isStatusClosed = false.obs;

  final assignedSearchController = TextEditingController();
  final assignedSearchQuery = ''.obs;

  List<BatchStudent> get filteredAssignedStudents {
    if (assignedSearchQuery.isEmpty) return assignedStudents;
    return assignedStudents
        .where(
          (bs) => bs.student.name.toLowerCase().contains(
            assignedSearchQuery.value.toLowerCase(),
          ),
        )
        .toList();
  }

  BatchDetailsController(BatchModel initialBatch) {
    _batch = initialBatch.obs;
  }

  void updateBatch(BatchModel newBatch) {
    _batch.value = newBatch;
    studentCount.value = int.tryParse(newBatch.studentCount.split(' ')[0]) ?? 0;
    totalExpected.value = newBatch.totalExpected?.toString() ?? '0';
    totalPaid.value = newBatch.totalPaid?.toString() ?? '0';
    isStatusClosed.value = newBatch.statusLabel.toLowerCase() == 'closed';
    if (newBatch.students != null) {
      _loadAssignedStudents(newBatch.students);
    }
  }

  @override
  void onInit() {
    super.onInit();
    studentCount.value = int.tryParse(batch.studentCount.split(' ')[0]) ?? 0;
    totalExpected.value = batch.totalExpected?.toString() ?? '0';
    totalPaid.value = batch.totalPaid?.toString() ?? '0';
    isStatusClosed.value = batch.statusLabel.toLowerCase() == 'closed';
    _loadAssignedStudents(batch.students);

    if (instituteController.students.isEmpty) {
      instituteController.fetchStudents();
    }

    // Keep each enrolled student's details in sync with the global list, but
    // never rebuild who is enrolled from the (possibly stale) batch snapshot.
    ever(instituteController.students, (_) => _refreshStudentDetails());
  }

  void _refreshStudentDetails() {
    var changed = false;
    for (final bs in assignedStudents) {
      final fresh = instituteController.students.firstWhereOrNull(
        (st) => st.id == bs.student.id,
      );
      if (fresh != null && !identical(fresh, bs.student)) {
        assignedStudents[assignedStudents.indexOf(bs)] = BatchStudent(
          student: fresh,
          assignedFee: bs.assignedFee,
          milestones: bs.milestones,
        );
        changed = true;
      }
    }
    if (changed) assignedStudents.refresh();
  }

  void _loadAssignedStudents(List<dynamic>? studentsList) {
    assignedStudents.clear();

    if (studentsList != null && studentsList.isNotEmpty) {
      final List<BatchStudent> loadedStudents = [];
      for (var s in studentsList) {
        final targetId = s.id;
        Student? matchedStudent;
        try {
          if (Get.isRegistered<InstituteController>()) {
            final instController = Get.find<InstituteController>();
            matchedStudent = instController.students.firstWhereOrNull(
              (st) => st.id == targetId,
            );
            matchedStudent ??= instController.students.firstWhereOrNull(
              (st) =>
                  st.name.toLowerCase().trim() ==
                  s.name.toString().toLowerCase().trim(),
            );
          }
        } catch (_) {}

        final String? realEnrollment = (matchedStudent?.enrollmentID != null &&
                matchedStudent!.enrollmentID!.isNotEmpty)
            ? matchedStudent.enrollmentID
            : (matchedStudent?.idHash.isNotEmpty == true
                ? matchedStudent!.idHash
                : (s.enrollmentId != null && s.enrollmentId!.isNotEmpty)
                    ? s.enrollmentId
                    : null);

        final studentModel = matchedStudent ??
            Student(
              id: targetId,
              name: s.name,
              email: matchedStudent?.email ?? '',
              phone: matchedStudent?.phone ?? '',
              instituteId: matchedStudent?.instituteId ?? 0,
              enrollmentID: realEnrollment,
              standard: matchedStudent?.standard ?? '',
              dob: matchedStudent?.dob ?? '',
              status: 'Active',
              idHash: realEnrollment ?? '',
              createdAt: '',
              updatedAt: '',
              profileImageUrl: s.profileImageUrl ?? '',
            );

        loadedStudents.add(
          BatchStudent(student: studentModel, assignedFee: batch.baseFee),
        );
      }
      assignedStudents.assignAll(loadedStudents);
      studentCount.value = assignedStudents.length;
    }
    assignedStudents.refresh();
  }

  Future<void> removeStudentFromBatch(int studentId) async {
    try {
      isLoading.value = true;

      await _repository.removeStudentFromBatch(int.parse(batch.id), studentId);

      // Update local list and count straight away so the screen reflects it.
      final student = assignedStudents
          .firstWhereOrNull((s) => s.student.id == studentId)
          ?.student;
      assignedStudents.removeWhere((s) => s.student.id == studentId);
      studentCount.value = assignedStudents.length;
      assignedStudents.refresh();

      // The student is unassigned again, so clear their batch in the global
      // list (copyWith(batchId: null) would keep the old batch).
      if (student != null) {
        instituteController.updateStudent(student.copyWith(clearBatch: true));
      }

      AppSnackBar.success(AppStrings.studentRemoved);

      // Reconcile with the server in the background.
      refreshStudents();
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToRemoveStudent);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStudents() async {
    if (Get.isRegistered<BatchController>()) {
      final bc = Get.find<BatchController>();
      await bc.loadBatches(isRefresh: true, force: true);

      final updatedBatch = bc.batchesList.firstWhereOrNull(
        (b) => b.id == batch.id,
      );
      if (updatedBatch != null) {
        studentCount.value =
            int.tryParse(updatedBatch.studentCount.split(' ')[0]) ?? 0;
        totalExpected.value = updatedBatch.totalExpected?.toString() ?? '0';
        totalPaid.value = updatedBatch.totalPaid?.toString() ?? '0';
        _loadAssignedStudents(updatedBatch.students);
        isStatusClosed.value =
            updatedBatch.statusLabel.toLowerCase() == 'closed';
      }
    }
  }

  Future<void> closeBatch() async {
    try {
      isLoading.value = true;
      CommonLoading.show();
      await _repository.closeBatch(int.parse(batch.id));

      if (Get.isRegistered<BatchController>()) {
        final bc = Get.find<BatchController>();
        await bc.loadBatches(isRefresh: true);
      }

      CommonLoading.dismiss();
      AppSnackBar.success('Batch Closed');
      isStatusClosed.value = true;
    } catch (e) {
      CommonLoading.dismiss();
      AppSnackBar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    assignedSearchController.dispose();
    super.onClose();
  }
}
