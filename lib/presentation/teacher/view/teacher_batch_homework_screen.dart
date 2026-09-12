import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_homework_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_homework_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherBatchHomeworkScreen extends GetView<TeacherBatchHomeworkController> {
  const TeacherBatchHomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(
              title: 'Homework · ${controller.batch.name}',
              actions: [
                GestureDetector(
                  onTap: controller.addHomework,
                  child: Container(
                    width: AppSpacing.s40,
                    height: AppSpacing.s40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrand,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded, color: AppColors.white),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }
                if (controller.homeworks.isEmpty) {
                  return Center(
                    child: Text(
                      'No homework assigned yet.',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchHomeworks,
                  child: ListView.separated(
                    padding: AppSpacing.x16,
                    itemCount: controller.homeworks.length,
                    separatorBuilder: (_, __) => AppSpacing.v12,
                    itemBuilder: (context, index) {
                      final hw = controller.homeworks[index];
                      return _HomeworkCard(
                        homework: hw,
                        onEdit: () => controller.editHomework(hw),
                        onDelete: () => controller.deleteHomework(hw),
                        onGrade: () => controller.openGrading(hw),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  final TeacherHomework homework;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onGrade;

  const _HomeworkCard({
    required this.homework,
    required this.onEdit,
    required this.onDelete,
    required this.onGrade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  homework.title,
                  style: AppTextStyles.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textTertiary),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          AppSpacing.v4,
          Text(
            homework.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.outfit(fontSize: 13, color: AppColors.textSecondary),
          ),
          AppSpacing.v8,
          Row(
            children: [
              Text(
                'Due ${homework.dueDate}',
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  color: homework.isOverdue ? AppColors.bohoRed : AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.h12,
              Text(
                '${homework.submissionsCount ?? 0} submissions',
                style: AppTextStyles.outfit(fontSize: 11, color: AppColors.textTertiary),
              ),
              if (homework.daysLeftText.isNotEmpty) ...[
                AppSpacing.h12,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: homework.isOverdue
                        ? AppColors.bohoRed.withOpacity(0.1)
                        : (homework.daysLeft == 0
                            ? Colors.amber.withOpacity(0.15)
                            : AppColors.primaryBrand.withOpacity(0.08)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    homework.daysLeftText,
                    style: AppTextStyles.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: homework.isOverdue
                          ? AppColors.bohoRed
                          : (homework.daysLeft == 0
                              ? Colors.amber.shade900
                              : AppColors.primaryBrand),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: onGrade,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrand.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Grade',
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
