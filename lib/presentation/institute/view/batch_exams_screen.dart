import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/status_badge.dart';
import 'package:tuoora/presentation/institute/controllers/exam_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/exam_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchExamsScreen extends StatefulWidget {
  const BatchExamsScreen({super.key});

  @override
  State<BatchExamsScreen> createState() => _BatchExamsScreenState();
}

class _BatchExamsScreenState extends State<BatchExamsScreen> {
  late final BatchModel batch;
  late final ExamController controller;

  @override
  void initState() {
    super.initState();
    batch = Get.arguments as BatchModel;
    controller = Get.put(ExamController(batch), tag: batch.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.exams,
              onBackTap: () => Get.back(),
            ),
            Padding(
              padding: AppSpacing.x16.add(AppSpacing.y16),
              child: AppSearchField(
                hintText: 'Search exams',
                onChanged: (val) => controller.searchQuery.value = val,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: () => controller.fetchExams(),
                child: Obx(() {
                  return CommonStateWidget(
                    isLoading: controller.isLoading.value,
                    isEmpty: controller.filteredExams.isEmpty,
                    emptyTitle: controller.searchQuery.value.isNotEmpty
                        ? 'No exams found'
                        : 'No exams yet',
                    emptySubtitle: controller.searchQuery.value.isNotEmpty
                        ? 'Try searching with a different title'
                        : 'Start by scheduling a new exam for this batch',
                    emptyIcon: controller.searchQuery.value.isNotEmpty
                        ? Icons.search_off_rounded
                        : Icons.fact_check_outlined,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.x16.add(AppSpacing.bottom16),
                      child: Column(
                        children: controller.filteredExams
                            .map((exam) => _buildExamItem(exam))
                            .toList(),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SubscriptionGuard.runAddAction(() {
          controller.startCreate();
          Get.toNamed(AppRoutes.instituteAddExam, arguments: batch.id);
        }),
        backgroundColor: SubscriptionGuard.blocksAdd
            ? AppColors.textMuted
            : AppColors.primaryBrand,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _statusBadge(ExamModel exam) {
    if (exam.isCompleted) return StatusBadge.reviewed('Completed');
    if (exam.isCancelled) return StatusBadge.danger('Cancelled');
    return StatusBadge.success('Scheduled');
  }

  Widget _buildExamItem(ExamModel exam) {
    return GestureDetector(
      onTap: () async {
        final result = await Get.toNamed(
          AppRoutes.instituteExamMarks,
          arguments: exam,
        );
        if (result == true) {
          controller.fetchExams();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: AppSpacing.all16,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exam.title,
                    style: AppTextStyles.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _statusBadge(exam),
              ],
            ),
            AppSpacing.v8,
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrandLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    exam.examTypeLabel,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ),
                if (exam.subject != null && exam.subject!.isNotEmpty) ...[
                  AppSpacing.h8,
                  Text(
                    exam.subject!,
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
            AppSpacing.v12,
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                AppSpacing.h8,
                Text(
                  exam.formattedDate,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                AppSpacing.h24,
                Icon(
                  Icons.assignment_outlined,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                AppSpacing.h8,
                Text(
                  'Max: ${exam.totalMarks.toStringAsFixed(0)}',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                if (exam.stats != null) ...[
                  AppSpacing.h24,
                  Icon(
                    Icons.people_outline_rounded,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  AppSpacing.h8,
                  Text(
                    '${exam.stats!.marksEnteredCount}/${exam.stats!.totalStudents}',
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
