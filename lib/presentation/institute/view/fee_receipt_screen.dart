import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:tuoora/presentation/institute/controllers/institute_controller.dart';
import 'package:tuoora/presentation/institute/models/fee_record.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

class FeeReceiptScreen extends GetView<InstituteController> {
  const FeeReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Get.arguments as FeeRecord;
    final isPaid = r.status.toLowerCase() == 'paid';
    final dateFmt = DateFormat('dd MMM, yyyy');
    final timeFmt = DateFormat('dd MMM, yyyy hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.receiptDetailsTitle,
              isRoot: false,
              actions: [
                Obx(() {
                  final busy = controller.isDownloadingReceipt(r.id);
                  return IconButton(
                    tooltip: AppStrings.downloadReceiptTooltip,
                    onPressed: busy
                        ? null
                        : () => controller.downloadFeeReceipt(r.id),
                    icon: const AppActionIcon(asset: AppImages.icDownload),
                  );
                }),
                AppSpacing.h8,
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.all16,
                child: _buildReceiptCard(r, isPaid, dateFmt, timeFmt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(
    FeeRecord r,
    bool isPaid,
    DateFormat dateFmt,
    DateFormat timeFmt,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primaryBrand,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.cardRadius),
              ),
            ),
          ),
          Padding(
            padding: AppSpacing.all16,
            child: _buildHeader(r, isPaid, dateFmt),
          ),
          _divider(),
          Padding(
            padding: AppSpacing.all16,
            child: _buildBilledAndPayment(r, timeFmt),
          ),
          _divider(),
          Padding(padding: AppSpacing.all16, child: _buildLineItems(r)),
          _divider(),
          Padding(padding: AppSpacing.all16, child: _buildTotalRow(r)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    color: AppColors.borderGrey.withValues(alpha: 0.6),
  );

  Widget _buildHeader(FeeRecord r, bool isPaid, DateFormat dateFmt) {
    final name = r.student?.name ?? '—';
    final phone = r.student?.phone ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryBrandLight,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '',
            style: AppTextStyles.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBrand,
            ),
          ),
        ),
        AppSpacing.h12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (phone.isNotEmpty) ...[
                AppSpacing.v2,
                Text(
                  'Phone: $phone',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        AppSpacing.h8,
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPaid ? AppColors.successBg : AppColors.warningBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                r.status.toUpperCase(),
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPaid ? AppColors.greenText : AppColors.warningAmber,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            AppSpacing.v8,
            Text(
              'Receipt No: REC-${_paddedId(r.id)}',
              style: AppTextStyles.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.v2,
            Text(
              'Date: ${dateFmt.format(r.date)}',
              style: AppTextStyles.outfit(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _paddedId(int id) => id.toString().padLeft(4, '0');

  Widget _buildBilledAndPayment(FeeRecord r, DateFormat timeFmt) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(AppStrings.receiptBilledTo),
              AppSpacing.v8,
              Text(
                r.student?.name ?? '—',
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.v4,
              Text(
                'Enrollment ID: ${r.student?.displayEnrollmentId ?? 'N/A'}',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.v2,
              Text(
                r.student?.email ?? "",
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.v8,
              _sectionHeader(AppStrings.receiptPaymentInformation),
              AppSpacing.v8,
              _kvRow(AppStrings.receiptMethodLabel, _methodOf(r)),
              AppSpacing.v4,
              _kvRow(
                AppStrings.receiptPaidDateLabel,
                timeFmt.format(_paidAtOf(r)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _methodOf(FeeRecord r) {
    final p = r.latestPayment;
    if (p != null && p.paymentMethod.isNotEmpty) return p.paymentMethod;
    return AppStrings.instPaymentCash;
  }

  DateTime _paidAtOf(FeeRecord r) => r.latestPayment?.paidAt ?? r.updatedAt;

  Widget _buildLineItems(FeeRecord r) {
    final periodLabel = DateFormat('MMMM yyyy').format(r.date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _sectionHeader(AppStrings.receiptDescription)),
            Text(
              AppStrings.receiptAmountHeader,
              style: AppTextStyles.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        AppSpacing.v12,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.receiptMonthlyAcademicFees,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.v2,
                  Text(
                    'Billing Period: $periodLabel',
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.h8,
            Text(
              _money(r.totalAmount),
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalRow(FeeRecord r) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          AppStrings.receiptAmountPaid,
          style: AppTextStyles.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.h16,
        Text(
          _money(r.paidAmount),
          style: AppTextStyles.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBrand,
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String label) {
    return Text(
      label,
      style: AppTextStyles.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBrand,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _kvRow(String k, String v) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.outfit(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        children: [
          TextSpan(text: '$k '),
          TextSpan(
            text: v,
            style: AppTextStyles.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _money(double v) => '₹${NumberFormat('#,##,###.##').format(v)}';
}
