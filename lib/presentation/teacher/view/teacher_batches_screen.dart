import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batches_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherBatchesScreen extends GetView<TeacherBatchesController> {
  const TeacherBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const TeacherAppBar(title: 'My Batches'),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }
                if (controller.batches.isEmpty) {
                  return Center(
                    child: Text(
                      'No batches assigned to you yet.',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchBatches,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: controller.batches.length,
                    separatorBuilder: (_, _) => AppSpacing.v12,
                    itemBuilder: (context, index) =>
                        _BatchCard(batch: controller.batches[index], onTap: () => controller.openBatch(controller.batches[index])),
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

class _BatchCard extends StatelessWidget {
  final TeacherBatch batch;
  final VoidCallback onTap;

  const _BatchCard({required this.batch, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.s48,
              height: AppSpacing.s48,
              decoration: BoxDecoration(
                color: AppColors.primaryBrand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.groups_rounded, color: AppColors.primaryBrand),
              ),
            ),
            AppSpacing.h16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batch.name,
                    style: AppTextStyles.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (batch.subject != null && batch.subject!.isNotEmpty)
                    Text(
                      batch.subject!,
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  AppSpacing.v4,
                  Text(
                    '${batch.studentsCount ?? 0} students'
                    '${batch.startTime != null ? ' · ${batch.startTime} - ${batch.endTime ?? ''}' : ''}',
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
