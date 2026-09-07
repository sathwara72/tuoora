import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_fees_controller.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherFeesScreen extends GetView<TeacherFeesController> {
  const TeacherFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(title: 'Fees · ${controller.batch.name}'),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }
                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Padding(
                      padding: AppSpacing.x24,
                      child: Text(
                        controller.errorMessage.value!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }
                if (controller.fees.isEmpty) {
                  return Center(
                    child: Text(
                      'No fee records yet.',
                      style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchFees,
                  child: ListView.separated(
                    padding: AppSpacing.x16,
                    itemCount: controller.fees.length,
                    separatorBuilder: (_, __) => AppSpacing.v12,
                    itemBuilder: (context, index) {
                      final fee = controller.fees[index];
                      final total = double.tryParse(fee.totalAmount) ?? 0;
                      final paid = double.tryParse(fee.paidAmount) ?? 0;
                      return Container(
                        padding: AppSpacing.cardPadding,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                          border: Border.all(color: AppColors.borderGrey),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fee.studentName ?? 'Student',
                                    style: AppTextStyles.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '₹${paid.toStringAsFixed(0)} / ₹${total.toStringAsFixed(0)}',
                                    style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBrand.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                fee.status,
                                style: AppTextStyles.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBrand,
                                ),
                              ),
                            ),
                          ],
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
