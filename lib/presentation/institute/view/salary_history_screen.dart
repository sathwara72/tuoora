import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/staff_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/data/models/staff_model.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SalaryHistoryScreen extends GetView<StaffController> {
  const SalaryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.salaryHistory,
              actions: [_buildAddSalaryButton()],
            ),
            Expanded(
              child: Obx(() {
                final salaries = controller.salaryList;
                return CommonStateWidget(
                  isLoading:
                      controller.isLoadingSalary.value && salaries.isEmpty,
                  isEmpty: salaries.isEmpty,
                  emptyTitle: AppStrings.noSalaryRecords,
                  emptySubtitle: AppStrings.noSalaryPaymentsFoundForThis,
                  emptyIcon: Icons.payments_outlined,
                  child: ListView.separated(
                    padding: AppSpacing.screenPaddingTop,
                    itemCount: salaries.length,
                    separatorBuilder: (_, _) => AppSpacing.v10,
                    itemBuilder: (context, index) {
                      final salary = salaries[index];
                      return _buildSalaryCard(salary);
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

  Widget _buildAddSalaryButton() {
    return GestureDetector(
      onTap: () {
        final staff = controller.selectedStaff.value;
        if (staff == null) return;
        Get.toNamed(
          AppRoutes.instituteAddSalary,
          arguments: {'staffId': staff.id},
        );
      },
      child: Container(
        width: AppSpacing.s40,
        height: AppSpacing.s40,
        decoration: BoxDecoration(
          color: AppColors.primaryBrand,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.white,
          size: AppSpacing.s22,
        ),
      ),
    );
  }

  Widget _buildSalaryCard(StaffSalary salary) {
    DateTime paymentDate;
    try {
      paymentDate = DateTime.parse(salary.paymentDate);
    } catch (e) {
      paymentDate = DateTime.now();
    }

    final monthStr = DateFormat('MMMM yyyy').format(paymentDate);
    final dateStr = 'Paid on ${DateFormat('MMM dd, yyyy').format(paymentDate)}';

    return Container(
      padding: AppSpacing.cardPadding,
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
      child: Row(
        children: [
          Container(
            padding: AppSpacing.all12,
            decoration: const BoxDecoration(
              color: AppColors.primaryBrandLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: AppColors.primaryBrand,
              size: 24,
            ),
          ),
          AppSpacing.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthStr,
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  dateStr,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${salary.netSalary}',
                style: AppTextStyles.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                salary.paymentMethod,
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  color: AppColors.successGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
