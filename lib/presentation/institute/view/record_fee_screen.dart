import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/core/utils/currency_utils.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/record_fee_controller.dart';
import 'package:tuoora/presentation/institute/models/fee_record.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:tuoora/presentation/institute/widgets/institute_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class RecordFeeScreen extends GetView<RecordFeeController> {
  const RecordFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            Obx(
              () => Column(
                children: [
                  const InstituteAppBar(title: AppStrings.addTransaction),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: AppSpacing.x16.add(AppSpacing.y16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStudentSearchSection(),
                          AppSpacing.v16,
                          _buildFeeDetailsSection(context),
                        ],
                      ),
                    ),
                  ),
                  _buildFixedFooterButton(),
                ],
              ),
            ),
            Obx(
              () => controller.isLoading.value
                  ? Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.1),
                        child: const CommonLoading(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InstituteLabel(AppStrings.studentInformationLabel),
        if (!controller.isStudentSelected.value) ...[
          Obx(
            () => AppSearchField(
              hintText: AppStrings.instSearchStudentHint,
              onChanged: (value) => controller.searchQuery.value = value,
              borderColor: controller.studentError.value != null
                  ? Colors.redAccent
                  : Colors.transparent,
            ),
          ),
          Obx(() {
            if (controller.studentError.value != null) {
              return Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  controller.studentError.value!,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          if (controller.searchQuery.value.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.s8),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.background),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: controller.filteredStudents.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final student = controller.filteredStudents[index];
                  return ListTile(
                    onTap: () => controller.selectStudent(student),
                    leading: _buildStudentAvatar(
                      student.imageUrl,
                      student.name,
                      size: 40,
                    ),
                    title: Text(
                      student.name,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      student.id.toString(),
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
        ] else
          Container(
            padding: AppSpacing.all12,
            decoration: BoxDecoration(
              color: AppColors.primaryBrandLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildStudentAvatar(
                  controller.selectedStudent.value!.imageUrl,
                  controller.selectedStudent.value!.name,
                  size: 48,
                ),
                AppSpacing.h16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.selectedStudent.value?.name ?? "",
                        style: AppTextStyles.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Batch: ${controller.selectedStudent.value?.currentBatchName ?? ""}',
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.changeStudent(),
                  child: Text(
                    AppStrings.instChangeBtn,
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (controller.isStudentSelected.value &&
            (controller.selectedStudent.value?.totalDue ?? 0) > 0) ...[
          AppSpacing.v12,
          _buildPendingFeesBanner(
            (controller.selectedStudent.value!.totalDue).toDouble(),
          ),
        ],
        if (controller.isStudentSelected.value &&
            controller.hasPaidBefore) ...[
          AppSpacing.v8,
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _openFeeHistory,
              icon: const Icon(
                Icons.history_rounded,
                size: 18,
                color: AppColors.primaryBrand,
              ),
              label: Text(
                'View Fees History',
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrand,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _openFeeHistory() {
    controller.loadFeeHistory();
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.75),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppSpacing.v16,
            Text(
              'Fees History',
              style: AppTextStyles.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              controller.selectedStudent.value?.name ?? '',
              style: AppTextStyles.outfit(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.v12,
            Flexible(
              child: Obx(() {
                if (controller.isHistoryLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CommonLoading(),
                  );
                }
                if (controller.historyError.value != null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      controller.historyError.value!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                }
                final items = controller.feeHistory;
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No payments yet',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: AppColors.borderGrey.withValues(alpha: 0.6),
                  ),
                  itemBuilder: (_, i) => _buildHistoryRow(items[i]),
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildHistoryRow(FeePayment p) {
    final date = p.paidAt ?? p.createdAt;
    final method = p.paymentMethod.isEmpty ? AppStrings.instPaymentCash : p.paymentMethod;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: AppSpacing.all8,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              method.toLowerCase() == 'cash'
                  ? Icons.wallet
                  : Icons.account_balance,
              size: 18,
              color: AppColors.greenText,
            ),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date != null
                      ? DateFormat('dd MMM yyyy').format(date.toLocal())
                      : '—',
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  method,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatRupees(p.amount),
            style: AppTextStyles.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.greenText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingFeesBanner(double amount) {
    return Container(
      padding: AppSpacing.all12,
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.warningAmber.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: AppColors.warningAmber,
          ),
          AppSpacing.h8,
          Expanded(
            child: Text(
              AppStrings.pendingFeesLabel,
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.warningAmber,
              ),
            ),
          ),
          Text(
            formatRupees(amount),
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.warningAmber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InstituteLabel(AppStrings.instAmountLabel),
        Obx(
          () => Container(
            padding: AppSpacing.all16,
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: controller.amountError.value != null
                    ? Colors.redAccent
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => controller.amount.value = value,
                    keyboardType: TextInputType.number,
                    inputFormatters: [LengthLimitingTextInputFormatter(6)],
                    decoration: InputDecoration(
                      hintText: AppStrings.recordFeeEnterAmount,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: AppTextStyles.outfit(
                        fontSize: 15,
                        color: AppColors.fieldLabel,
                      ),
                    ),
                    style: AppTextStyles.outfit(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.payments,
                  color: AppColors.textTertiary,
                  size: AppSpacing.s24,
                ),
              ],
            ),
          ),
        ),
        Obx(() {
          if (controller.amountError.value != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                controller.amountError.value!,
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        AppSpacing.v20,
        const InstituteLabel(AppStrings.feeDateLabel),
        GestureDetector(
          onTap: () => controller.selectRecordDate(context),
          child: Container(
            padding: AppSpacing.all16,
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    DateFormat(
                      'MM/dd/yyyy',
                    ).format(controller.selectedRecordDate.value),
                    style: AppTextStyles.outfit(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.textTertiary,
                  size: AppSpacing.s22,
                ),
              ],
            ),
          ),
        ),
        AppSpacing.v20,
        InstituteLabel(AppStrings.instPaymentMethodLabel),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodBtn(
                AppStrings.instPaymentCash,
                Icons.wallet,
                controller.paymentMethod.value == AppStrings.instPaymentCash,
              ),
            ),
            AppSpacing.h12,
            Expanded(
              child: _buildPaymentMethodBtn(
                AppStrings.instPaymentOnline,
                Icons.account_balance,
                controller.paymentMethod.value == AppStrings.instPaymentOnline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodBtn(String label, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () => controller.setPaymentMethod(label),
      child: Container(
        height: 48,
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryBrandLight.withValues(alpha: 0.5)
              : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isActive ? AppColors.primaryBrand : AppColors.fieldBg,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primaryBrand : AppColors.fieldLabel,
              size: 24,
            ),
            AppSpacing.h12,
            Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? AppColors.primaryBrand
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentAvatar(String imageUrl, String name, {double size = 48}) {
    if (imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.contains('ui-avatars.com')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primaryBrandLight,
          borderRadius: BorderRadius.circular(size / 3),
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final names = name.trim().split(' ');
    String initials = '';
    if (names.isNotEmpty) {
      initials += names[0][0].toUpperCase();
      if (names.length > 1 && names.last.isNotEmpty) {
        initials += names.last[0].toUpperCase();
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primaryBrandLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.outfit(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBrand,
          ),
        ),
      ),
    );
  }

  Widget _buildFixedFooterButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: AppButton(
        label: AppStrings.instSaveFeeBtn,
        onPressed: () => controller.saveRecord(),
      ),
    );
  }
}
