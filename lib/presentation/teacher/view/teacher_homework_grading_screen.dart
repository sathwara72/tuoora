import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_homework_grading_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_homework_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherHomeworkGradingScreen extends GetView<TeacherHomeworkGradingController> {
  const TeacherHomeworkGradingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(title: 'Grade · ${controller.homework.title}'),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }
                final list = controller.submissions;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'No submissions yet.',
                      style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.separated(
                  padding: AppSpacing.x16,
                  itemCount: list.length,
                  separatorBuilder: (_, __) => AppSpacing.v12,
                  itemBuilder: (context, index) =>
                      _SubmissionRow(submission: list[index], controller: controller),
                );
              }),
            ),
            Padding(
              padding: AppSpacing.x16.add(const EdgeInsets.only(bottom: AppSpacing.s16)),
              child: Obx(
                () => AppButton(
                  label: 'Save Grades',
                  onPressed: controller.submitGrades,
                  isLoading: controller.isSaving.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmissionRow extends StatelessWidget {
  final TeacherHomeworkSubmission submission;
  final TeacherHomeworkGradingController controller;

  const _SubmissionRow({required this.submission, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isPending = submission.status.toLowerCase() == 'pending';

    return Container(
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  submission.studentName,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Pending Submission',
                    style: AppTextStyles.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
            ],
          ),
          if (submission.note != null && submission.note!.isNotEmpty) ...[
            AppSpacing.v4,
            Text(
              submission.note!,
              style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          AppSpacing.v12,
          Row(
            children: [
              SizedBox(
                width: 90,
                child: TextFormField(
                  key: ValueKey('${submission.studentId}_${submission.status}'),
                  initialValue: isPending ? '' : (submission.score?.toString() ?? ''),
                  enabled: !isPending,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    color: isPending ? AppColors.textTertiary : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: isPending ? 'N/A' : 'Score',
                    hintStyle: AppTextStyles.outfit(
                      fontSize: 12,
                      color: isPending ? AppColors.textTertiary : AppColors.fieldLabel,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    filled: true,
                    fillColor: isPending ? AppColors.borderGrey.withOpacity(0.25) : AppColors.fieldBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.fieldBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.fieldBorder),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.borderGrey.withOpacity(0.5)),
                    ),
                  ),
                  onChanged: (value) => controller.updateScore(submission, value),
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: SizedBox(
                  height: AppSpacing.s36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: TeacherHomeworkGradingController.statuses.map((status) {
                      final isSelected = submission.status.toLowerCase() == status.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.s8),
                        child: GestureDetector(
                          onTap: () => controller.updateStatus(submission, status),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryBrand : AppColors.fieldBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryBrand : AppColors.fieldBorder,
                              ),
                            ),
                            child: Text(
                              status,
                              style: AppTextStyles.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 6),
            Text(
              'Grades cannot be given to pending homework',
              style: AppTextStyles.outfit(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
