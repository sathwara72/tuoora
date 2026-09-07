import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/enums/app_enums.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/presentation/student/models/assignment_model.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/data/repositories/student_homework_repository.dart';
import 'package:tuoora/presentation/student/controllers/attachment_preview_controller.dart';

class AssignmentsController extends GetxController {
  final RxInt activeTab = 0.obs;

  final RxList<Assignment> pending = <Assignment>[].obs;
  final RxList<Assignment> completed = <Assignment>[].obs;

  final Rxn<Assignment> selectedAssignment = Rxn<Assignment>();

  final Rxn<AssignmentAttachment> selectedAttachment =
      Rxn<AssignmentAttachment>();

  final RxBool isLoading = true.obs;
  final RxBool isDetailLoading = false.obs;
  final RxBool isAttachmentLoading = false.obs;
  final RxBool isDownloading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  late StudentHomeworkRepository _repository;

  final RxInt weeklyRemaining = 0.obs;
  final RxInt weeklyTotal = 0.obs;
  final RxInt weeklyCompleted = 0.obs;
  final RxInt weeklyOverdue = 0.obs;
  final RxString teacherName = 'Institute'.obs;

  /// Draft submission state for the currently-open assignment. Cleared and
  /// re-prefilled (from the assignment's existing submission, if any) every
  /// time a new assignment is opened, so a resubmission starts from what
  /// was last submitted rather than a blank form.
  final TextEditingController noteController = TextEditingController();
  final Rxn<String> newAttachmentLocalPath = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _repository = StudentHomeworkRepository(Get.find<ApiClient>());
    loadAssignments();
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  Future<void> loadAssignments() async {
    try {
      isLoading.value = true;
      final data = await _repository.getHomeworks();
      // Newest-created first; assignments with no createdAt fall to the
      // bottom (still stable amongst themselves).
      int byNewest(Assignment a, Assignment b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      }

      pending.assignAll(List.of(data.pending)..sort(byNewest));
      completed.assignAll(List.of(data.completed)..sort(byNewest));

      weeklyTotal.value = data.summary.total;
      weeklyRemaining.value = data.summary.pending;
      weeklyCompleted.value = data.summary.completed;
      weeklyOverdue.value = data.summary.overdue;
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToLoadAssignments);
    } finally {
      isLoading.value = false;
    }
  }

  void selectTab(int index) {
    if (index < 0 || index > 1 || activeTab.value == index) return;
    activeTab.value = index;
  }

  void _resetSubmissionDraft(Assignment? assignment) {
    noteController.text = assignment?.submissionNote ?? '';
    newAttachmentLocalPath.value = null;
  }

  Future<void> openAssignment(Assignment assignment) async {
    selectedAssignment.value = assignment;
    _resetSubmissionDraft(assignment);
    Get.toNamed(AppRoutes.studentAssignmentDetail);

    try {
      isDetailLoading.value = true;
      final int id = int.parse(assignment.id);
      final detail = await _repository.getHomeworkDetail(id);
      selectedAssignment.value = detail;
      _resetSubmissionDraft(detail);
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToLoadAssignmentDetails);
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> openAssignmentById(int id) async {
    selectedAssignment.value = null;
    _resetSubmissionDraft(null);
    Get.toNamed(AppRoutes.studentAssignmentDetail);

    try {
      isDetailLoading.value = true;
      final detail = await _repository.getHomeworkDetail(id);
      selectedAssignment.value = detail;
      _resetSubmissionDraft(detail);
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToLoadAssignmentDetails);
    } finally {
      isDetailLoading.value = false;
    }
  }

  void openAttachment(AssignmentAttachment attachment) {
    final assignment = selectedAssignment.value;
    if (assignment == null) return;

    Get.toNamed(
      AppRoutes.studentAttachmentPreview,
      arguments: AttachmentPreviewArgs(
        attachment: attachment,
        sourceType: AttachmentSourceType.assignment,
        sourceId: assignment.id,
        onLoadPreview: () async {
          final int id = int.parse(assignment.id);
          final attachmentDetail = await _repository.getHomeworkAttachment(id);

          final ctrl = Get.find<AttachmentPreviewController>();
          ctrl.selectedAttachment.value = AssignmentAttachment(
            id: attachment.id,
            name: attachment.name,
            sizeLabel: attachmentDetail.fileSize,
            kind: attachment.kind,
            url: attachmentDetail.previewUrl,
            extensionLabel: attachmentDetail.extension,
          );
        },
      ),
    );
  }

  Future<void> pickSubmissionAttachment() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        newAttachmentLocalPath.value = result.files.single.path;
      }
    } catch (e) {
      AppSnackBar.error('Failed to pick file: $e');
    }
  }

  void removeNewSubmissionAttachment() {
    newAttachmentLocalPath.value = null;
  }

  /// Submits (or resubmits) the currently-open assignment with whatever is
  /// in [noteController] / [newAttachmentLocalPath]. Allowed any number of
  /// times up until the due date — the backend is the source of truth for
  /// that gate, this just mirrors it client-side for a snappier error.
  Future<void> submitCurrentAssignment() async {
    final assignment = selectedAssignment.value;
    if (assignment == null || isSubmitting.value) return;

    final note = noteController.text.trim();
    final hasExistingAttachment =
        (assignment.submissionAttachmentUrl ?? '').isNotEmpty;
    if (note.isEmpty &&
        newAttachmentLocalPath.value == null &&
        !hasExistingAttachment) {
      AppSnackBar.error('Add a note or attach a file before submitting.');
      return;
    }

    try {
      isSubmitting.value = true;
      final id = int.tryParse(assignment.id) ?? 0;
      await _repository.submitHomework(
        id,
        note: note.isEmpty ? null : note,
        attachmentPath: newAttachmentLocalPath.value,
      );

      final detail = await _repository.getHomeworkDetail(id);
      selectedAssignment.value = detail;
      _resetSubmissionDraft(detail);

      // Refresh the pending/completed lists + summary counts in the
      // background — a resubmission doesn't move lists, but a first
      // submission does, and either way the counts may have changed.
      loadAssignments();

      AppSnackBar.success(AppStrings.assignmentSubmittedSuccessfully);
    } catch (e) {
      AppSnackBar.error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isSubmitting.value = false;
    }
  }

  List<Assignment> get activeItems =>
      activeTab.value == 0 ? pending : completed;
}
