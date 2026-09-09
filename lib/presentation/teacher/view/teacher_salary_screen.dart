import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_salary_controller.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherSalaryScreen extends GetView<TeacherSalaryController> {
  const TeacherSalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const TeacherAppBar(title: 'Salary Slips'),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }
                if (controller.salaries.isEmpty) {
                  return Center(
                    child: Text(
                      'No salary slips yet.',
                      style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchSalaries,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: controller.salaries.length,
                    separatorBuilder: (_, _) => AppSpacing.v12,
                    itemBuilder: (context, index) {
                      final salary = controller.salaries[index];
                      final isDownloading = controller.downloadingId.value == salary.id;
                      return GestureDetector(
                        onTap: isDownloading ? null : () => controller.viewSlip(salary),
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
                                width: AppSpacing.s44,
                                height: AppSpacing.s44,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBrand.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(Icons.receipt_long_rounded, color: AppColors.primaryBrand),
                                ),
                              ),
                              AppSpacing.h16,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '₹${salary.netSalary ?? '-'}',
                                      style: AppTextStyles.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${salary.paymentDate ?? ''} · ${salary.status}',
                                      style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
                                    ),
                                  ],
                                ),
                              ),
                              isDownloading
                                  ? const CommonLoading(size: 18)
                                  : const Icon(Icons.download_rounded, color: AppColors.primaryBrand),
                            ],
                          ),
                        ),
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
