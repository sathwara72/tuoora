import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/student/controllers/fees_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_profile_controller.dart';
import 'package:tuoora/presentation/student/models/fee_model.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';

class StudentReceiptScreen extends GetView<FeesController> {
  const StudentReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StudentAppBar(
              title: AppStrings.studentReceiptTitle,
              showDefaultActions: false,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isReceiptLoading.value &&
                    controller.currentReceipt.value == null) {
                  return const CommonLoading(color: AppColors.primaryBrand);
                }
                final receipt = controller.currentReceipt.value;
                if (receipt == null) {
                  return const Center(child: Text(AppStrings.noReceiptSelected));
                }
                return _Body(
                  receipt: receipt,
                  statement: controller.selectedStatement.value,
                  isDownloading: controller.isDownloading.value,
                  onDownload: controller.downloadCurrentReceipt,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final StudentReceipt receipt;
  final FeeStatement? statement;
  final bool isDownloading;
  final Future<void> Function() onDownload;

  const _Body({
    required this.receipt,
    required this.statement,
    required this.isDownloading,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReceiptCard(receipt: receipt, statement: statement),
          const SizedBox(height: AppSpacing.s12),
          _ActionRow(isDownloading: isDownloading, onDownload: onDownload),
          const SizedBox(height: AppSpacing.s16),
          Center(
            child: Text(
              AppStrings.thisIsASystemGeneratedReceipt,
              style: AppTextStyles.outfit(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final StudentReceipt receipt;
  final FeeStatement? statement;

  const _ReceiptCard({required this.receipt, required this.statement});

  @override
  Widget build(BuildContext context) {
    final monthHeader =
        statement?.monthHeader ??
        (receipt.date.isNotEmpty ? receipt.date.toUpperCase() : 'RECEIPT');
    final isPaid = statement?.isPaid ?? true;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              monthHeader,
              style: AppTextStyles.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '₹${receipt.amount}',
                    style: AppTextStyles.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                ),
                _StatusPill(isPaid: isPaid),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            _DashedDivider(color: AppColors.borderGrey.withValues(alpha: 0.8)),
            _DetailRow(
              label: AppStrings.studentReceiptStudent,
              value: receipt.studentName,
            ),
            _DetailRow(
              label: AppStrings.studentReceiptEnrollmentId,
              value: _resolveEnrollment(),
            ),
            _DetailRow(
              label: AppStrings.studentReceiptInstitute,
              value: receipt.instituteName,
            ),
            _DetailRow(
              label: AppStrings.studentReceiptInvoiceNo,
              value: receipt.receiptNumber,
            ),
            _DetailRow(label: AppStrings.paymentMethod, value: receipt.paymentMethod),
            _DetailRow(label: AppStrings.labelDate, value: receipt.date, isLast: true),
          ],
        ),
      ),
    );
  }

  String _resolveEnrollment() {
    if (receipt.enrollmentId.trim().isNotEmpty) {
      return receipt.enrollmentId.trim();
    }
    if (Get.isRegistered<StudentProfileController>()) {
      final enrollment = Get.find<StudentProfileController>()
          .profileData
          .value
          ?.header
          .enrollment
          .trim();
      if (enrollment != null && enrollment.isNotEmpty) {
        return enrollment;
      }
    }
    if (receipt.rollNo.trim().isNotEmpty) {
      return receipt.rollNo.trim();
    }
    return '-';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              AppSpacing.h8,
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: AppColors.borderGrey.withValues(alpha: 0.4),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  final Color color;
  const _DashedDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isPaid;

  const _StatusPill({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final bg = isPaid ? AppColors.successGreen : AppColors.bohoRed;
    final label = isPaid
        ? AppStrings.instStatusPaid
        : AppStrings.studentAssignmentsTabPending;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Text(
        label,
        style: AppTextStyles.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final bool isDownloading;
  final Future<void> Function() onDownload;

  const _ActionRow({required this.isDownloading, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: isDownloading
                ? AppStrings.studentAttachmentDownloadStarted
                : AppStrings.studentAttachmentDownload,
            icon: Icons.download_rounded,
            isPrimary: false,
            isLoading: isDownloading,
            onTap: isDownloading ? null : onDownload,
          ),
        ),
        AppSpacing.h12,
        Expanded(
          child: _ActionButton(
            label: AppStrings.studentReceiptContact,
            icon: Icons.call_rounded,
            isPrimary: true,
            isLoading: false,
            onTap: () => Get.toNamed(AppRoutes.studentInstitute),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary ? AppColors.textPrimary : AppColors.white;
    final fg = isPrimary ? AppColors.white : AppColors.textPrimary;
    final border = Border.all(
      color: isPrimary ? AppColors.textPrimary : AppColors.borderGrey,
    );
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: border,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s14,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(fg),
                  ),
                )
              else
                Icon(icon, size: 18, color: fg),
              AppSpacing.h8,
              Text(
                label,
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
