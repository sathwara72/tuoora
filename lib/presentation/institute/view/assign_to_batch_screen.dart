import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/batch_details_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/data/models/student_model.dart';
import 'package:tuoora/presentation/institute/controllers/institute_controller.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/student_repository_impl.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AssignToBatchController extends GetxController {
  final BatchModel batch;
  final InstituteController instituteController =
      Get.find<InstituteController>();
  final BatchDetailsController batchDetailsController;
  final InstituteRepositoryImpl _repository =
      Get.find<InstituteRepositoryImpl>();
  final StudentRepositoryImpl _studentRepository =
      Get.find<StudentRepositoryImpl>();

  final searchController = TextEditingController();
  final searchResults = <Student>[].obs;
  final selectedStudents = <BatchStudent>[].obs;
  final isLoading = false.obs;
  final isFetching = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  int _page = 1;
  Timer? _debounce;

  AssignToBatchController(this.batch, this.batchDetailsController);

  Set<int> get _excludedIds => {
    ...batchDetailsController.assignedStudents.map((s) => s.student.id),
    ...selectedStudents.map((s) => s.student.id),
  };

  /// Loads students that are not in any batch, straight from the server so a
  /// student who was just removed from a batch shows up immediately.
  Future<void> loadUnassignedStudents({bool loadMore = false}) async {
    // Nothing is listed until the user searches.
    if (searchController.text.trim().isEmpty) {
      searchResults.clear();
      hasMore.value = false;
      return;
    }
    if (loadMore) {
      if (isLoadingMore.value || isFetching.value || !hasMore.value) return;
      isLoadingMore.value = true;
    } else {
      _page = 1;
      hasMore.value = true;
      isFetching.value = true;
    }

    try {
      final query = searchController.text.trim();
      final result = await _studentRepository.listStudents(
        search: query,
        page: _page,
        unassigned: true,
      );
      // The box was cleared or changed while this was loading: drop it.
      if (searchController.text.trim() != query) return;
      final excluded = _excludedIds;
      final fresh = result.where((s) => !excluded.contains(s.id)).toList();
      if (loadMore) {
        searchResults.addAll(fresh);
      } else {
        searchResults.assignAll(fresh);
      }
      if (result.length < 10) {
        hasMore.value = false;
      } else {
        _page++;
      }
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToLoadStudents);
    } finally {
      isFetching.value = false;
      isLoadingMore.value = false;
    }
  }

  void searchStudents(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      searchResults.clear();
      hasMore.value = false;
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => loadUnassignedStudents(),
    );
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadUnassignedStudents(),
      instituteController.fetchStudents(reset: true),
    ]);
  }

  void _clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    searchResults.clear();
    hasMore.value = false;
  }

  void addStudentToSelection(Student student) {
    final today = DateTime.now();
    selectedStudents.add(
      BatchStudent(
        student: student,
        assignedFee: batch.baseFee,
        milestones: [
          MilestoneDraft(
            title: 'Installment 1',
            amount: batch.baseFee,
            dueDate: DateTime(today.year, today.month, today.day),
          ),
        ],
      ),
    );
    // Back to an empty picker for the next search.
    _clearSearch();
  }

  void removeStudentFromSelection(int studentId) {
    selectedStudents.removeWhere((s) => s.student.id == studentId);
  }

  BatchStudent? _find(int studentId) =>
      selectedStudents.firstWhereOrNull((s) => s.student.id == studentId);

  /// Milestones always add up to the fee. Everything except [fixedIndex] (the
  /// one the user is typing in) shares what is left, in whole rupees, with any
  /// odd rupee going to the first of them.
  void _redistribute(BatchStudent bs, {int? fixedIndex}) {
    final n = bs.milestones.length;
    if (n == 0) return;
    final total = bs.assignedFee.floorToDouble();

    if (n == 1) {
      bs.milestones.first
        ..amount = total
        ..stamp += 1;
      return;
    }

    var fixedAmount = 0.0;
    if (fixedIndex != null) {
      final m = bs.milestones[fixedIndex];
      final clamped = m.amount.clamp(0, total).toDouble();
      if (clamped != m.amount) {
        m.amount = clamped;
        m.stamp++;
      }
      fixedAmount = clamped;
    }

    final others = [
      for (int i = 0; i < n; i++)
        if (i != fixedIndex) i,
    ];
    final remaining = total - fixedAmount;
    final base = (remaining / others.length).floorToDouble();
    final extra = remaining - base * others.length;
    for (int k = 0; k < others.length; k++) {
      bs.milestones[others[k]]
        ..amount = k == 0 ? base + extra : base
        ..stamp += 1;
    }
  }

  void _retitle(BatchStudent bs) {
    for (int i = 0; i < bs.milestones.length; i++) {
      bs.milestones[i].title = 'Installment ${i + 1}';
    }
  }

  DateTime _dateForNext(BatchStudent bs) {
    final last = bs.milestones.isNotEmpty
        ? bs.milestones.last.dueDate
        : DateTime.now();
    return DateTime(last.year, last.month + 1, last.day);
  }

  /// Changing the fee re-splits it evenly across the milestones.
  void updateStudentFee(int studentId, String feeStr) {
    final bs = _find(studentId);
    if (bs == null) return;
    bs.assignedFee = double.tryParse(feeStr) ?? 0;
    _redistribute(bs);
    selectedStudents.refresh();
  }

  void splitMilestones(int studentId, int count) {
    final bs = _find(studentId);
    if (bs == null || count < 1) return;
    final now = DateTime.now();
    bs.milestones
      ..clear()
      ..addAll(
        List.generate(
          count,
          (i) => MilestoneDraft(
            title: 'Installment ${i + 1}',
            amount: 0,
            dueDate: DateTime(now.year, now.month + i, now.day),
          ),
        ),
      );
    _redistribute(bs);
    selectedStudents.refresh();
  }

  void addMilestone(int studentId) {
    final bs = _find(studentId);
    if (bs == null) return;
    bs.milestones.add(
      MilestoneDraft(title: '', amount: 0, dueDate: _dateForNext(bs)),
    );
    _retitle(bs);
    _redistribute(bs);
    selectedStudents.refresh();
  }

  /// Removing a milestone never lowers the fee: what it held is shared out
  /// across the ones that remain.
  void removeMilestone(int studentId, int index) {
    final bs = _find(studentId);
    if (bs == null || index < 0 || index >= bs.milestones.length) return;
    if (bs.milestones.length == 1) return; // a fee needs at least one milestone
    bs.milestones.removeAt(index);
    _retitle(bs);
    _redistribute(bs);
    selectedStudents.refresh();
  }

  void updateMilestoneAmount(int studentId, int index, String value) {
    final bs = _find(studentId);
    if (bs == null || index >= bs.milestones.length) return;
    bs.milestones[index].amount = double.tryParse(value) ?? 0;
    _redistribute(bs, fixedIndex: index);
    selectedStudents.refresh();
  }

  void updateMilestoneDate(int studentId, int index, DateTime date) {
    final bs = _find(studentId);
    if (bs == null || index >= bs.milestones.length) return;
    bs.milestones[index].dueDate = date;
    selectedStudents.refresh();
  }

  Future<void> confirmAssignment() async {
    if (selectedStudents.isEmpty) return;

    try {
      isLoading.value = true;

      final List<Map<String, dynamic>> studentsData = selectedStudents
          .map(
            (bs) => {
              'id': bs.student.id,
              'fee': bs.assignedFee.toInt(),
              'installments': bs.milestones
                  .where((m) => m.amount > 0)
                  .map((m) => m.toJson())
                  .toList(),
            },
          )
          .toList();

      await _repository.assignStudentsToBatch(
        int.parse(batch.id),
        studentsData,
      );

      final assigned = List<BatchStudent>.from(selectedStudents);
      batchDetailsController.assignedStudents.addAll(assigned);

      // Update global students list to reflect new batch assignment
      for (var bs in assigned) {
        instituteController.updateStudent(
          bs.student.copyWith(batchId: int.parse(batch.id)),
        );
      }

      batchDetailsController.studentCount.value =
          batchDetailsController.assignedStudents.length;
      batchDetailsController.assignedStudents.refresh();
      Get.back();
      AppSnackBar.success(AppStrings.studentsAssigned);

      // Pull the authoritative batch (and fees) in the background.
      batchDetailsController.refreshStudents();
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToAssignStudents);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}

class AssignToBatchScreen extends StatelessWidget {
  const AssignToBatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BatchModel batch = Get.arguments;
    final BatchDetailsController detailsController =
        Get.find<BatchDetailsController>(tag: batch.id);
    final controller = Get.put(
      AssignToBatchController(batch, detailsController),
    );

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.assignToBatch,
              onBackTap: () => Get.back(),
            ),
            Expanded(
              child: Stack(
                children: [
                  RefreshIndicator(
                    color: AppColors.primaryBrand,
                    onRefresh: controller.refreshAll,
                    child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.x16.add(AppSpacing.y16),
                    child: Column(
                      children: [
                        _buildSearchSection(controller),
                        AppSpacing.v24,
                        Obx(() => _buildSelectionList(controller)),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      top: false,
                      minimum: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        color: AppColors.scaffoldBg,
                        padding: AppSpacing.all16,
                        child: Obx(
                          () => AppButton(
                            label: AppStrings.assignStudent,
                            icon: Icons.check_circle_rounded,
                            isLoading: controller.isLoading.value,
                            isDisabled: controller.selectedStudents.isEmpty,
                            onPressed: controller.selectedStudents.isEmpty
                                ? null
                                : controller.confirmAssignment,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(AssignToBatchController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSearchField(
          hintText: AppStrings.searchAndAddStudentsToThis,
          controller: controller.searchController,
          onChanged: controller.searchStudents,
        ),
        Obx(() {
          if (controller.isFetching.value && controller.searchResults.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (controller.searchResults.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  controller.searchResults.length +
                  (controller.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= controller.searchResults.length) {
                  return Center(
                    child: controller.isLoadingMore.value
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton(
                            onPressed: () => controller.loadUnassignedStudents(
                              loadMore: true,
                            ),
                            child: const Text('Show more'),
                          ),
                  );
                }
                final student = controller.searchResults[index];
                return Container(
                  padding: AppSpacing.cardPadding,
                  margin: AppSpacing.bottom10,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPickerAvatar(
                        imageUrl: student.imageUrl,
                        name: student.name,
                      ),
                      AppSpacing.h16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: AppTextStyles.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Enrollment ID: ${student.displayEnrollmentId}',
                              style: AppTextStyles.outfit(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.addStudentToSelection(student);
                        },
                        child: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.primaryBrand,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSelectionList(AssignToBatchController controller) {
    if (controller.selectedStudents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Icon(
                Icons.person_add_rounded,
                size: 48,
                color: Colors.grey.shade200,
              ),
              AppSpacing.v16,
              Text(
                AppStrings.noStudentsSelectedYet,
                style: AppTextStyles.outfit(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.selectedStudents.length,
      itemBuilder: (context, index) {
        final bs = controller.selectedStudents[index];
        return Container(
          margin: AppSpacing.bottom10,
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildSelectedAvatar(
                    imageUrl: bs.student.imageUrl,
                    name: bs.student.name,
                  ),
                  AppSpacing.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bs.student.name,
                          style: AppTextStyles.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Enrollment ID: ${bs.student.displayEnrollmentId}',
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        controller.removeStudentFromSelection(bs.student.id),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              AppSpacing.v16,
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '₹',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBrand,
                            ),
                          ),
                          AppSpacing.h12,
                          Expanded(
                            child: TextFormField(
                              key: ValueKey(
                                'fee-${bs.student.id}-${bs.version}',
                              ),
                              initialValue: bs.assignedFee.toStringAsFixed(0),
                              onChanged: (val) => controller.updateStudentFee(
                                bs.student.id,
                                val,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [LengthLimitingTextInputFormatter(6)],
                              style: AppTextStyles.outfit(
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                hintText: AppStrings.enterFee,
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.v12,
              _buildMilestones(controller, bs),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestones(AssignToBatchController controller, BatchStudent bs) {
    final id = bs.student.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Fee milestones',
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            for (final n in const [1, 2, 3, 4])
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: ChoiceChip(
                  label: Text('$n'),
                  selected: bs.milestones.length == n,
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                  selectedColor: AppColors.primaryBrandLight,
                  onSelected: (_) => controller.splitMilestones(id, n),
                ),
              ),
          ],
        ),
        AppSpacing.v8,
        for (int i = 0; i < bs.milestones.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              key: ValueKey('ms-$id-$i-${bs.milestones[i].stamp}-${bs.version}'),
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: bs.milestones[i].amount.toStringAsFixed(0),
                    keyboardType: TextInputType.number,
                    inputFormatters: [LengthLimitingTextInputFormatter(6)],
                    onChanged: (v) =>
                        controller.updateMilestoneAmount(id, i, v),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixText: '₹ ',
                      labelText: bs.milestones[i].title,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                AppSpacing.h8,
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: Get.context!,
                        initialDate: bs.milestones[i].dueDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        controller.updateMilestoneDate(id, i, picked);
                      }
                    },
                    icon: const Icon(Icons.event_rounded, size: 16),
                    label: Text(
                      '${bs.milestones[i].dueDate.day.toString().padLeft(2, '0')}/'
                      '${bs.milestones[i].dueDate.month.toString().padLeft(2, '0')}/'
                      '${bs.milestones[i].dueDate.year}',
                      style: AppTextStyles.outfit(fontSize: 12),
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: bs.milestones.length > 1
                      ? () => controller.removeMilestone(id, i)
                      : null,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => controller.addMilestone(id),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add milestone'),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerAvatar({required String imageUrl, required String name}) {
    final bool hasPhoto =
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.contains('ui-avatars.com');
    final String initial = name.trim().isEmpty
        ? '?'
        : name.trim()[0].toUpperCase();
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryBrandLight,
        shape: BoxShape.circle,
        image: hasPhoto
            ? DecorationImage(
                image: CachedNetworkImageProvider(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasPhoto
          ? null
          : Center(
              child: Text(
                initial,
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrand,
                ),
              ),
            ),
    );
  }

  Widget _buildSelectedAvatar({
    required String imageUrl,
    required String name,
  }) {
    final bool hasPhoto =
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.contains('ui-avatars.com');
    final String initial = name.trim().isEmpty
        ? '?'
        : name.trim()[0].toUpperCase();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryBrandLight,
          image: hasPhoto
              ? DecorationImage(
                  image: CachedNetworkImageProvider(imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: hasPhoto
            ? null
            : Center(
                child: Text(
                  initial,
                  style: AppTextStyles.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBrand,
                  ),
                ),
              ),
      ),
    );
  }
}
