import 'package:tuoora/core/constants/app_permissions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/core/utils/currency_utils.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/widgets/app_whatsapp_icon.dart';
import 'package:tuoora/presentation/institute/controllers/institute_controller.dart';
import 'package:tuoora/presentation/institute/models/fee_record.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

class FeeReceiptScreen extends GetView<InstituteController> {
  const FeeReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Get.arguments as FeeRecord;
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
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.all16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildReceiptCard(r, dateFmt, timeFmt),
                    AppSpacing.v16,
                    _buildDownloadButton(r),
                    AppSpacing.v12,
                    _buildShareButtons(r),
                    if (Get.find<AuthService>().can(
                          AppPermissions.feesDelete,
                        ) &&
                        r.transactionPaymentId != null) ...[
                      AppSpacing.v12,
                      _buildDeleteButton(r),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(
    FeeRecord r,
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
          Padding(padding: AppSpacing.all16, child: _buildHeader(r, dateFmt)),
          _divider(),
          Padding(
            padding: AppSpacing.all16,
            child: _buildBilledAndPayment(r, dateFmt, timeFmt),
          ),
          _divider(),
          Padding(padding: AppSpacing.all16, child: _buildLineItems(r)),
          _divider(),
          Padding(padding: AppSpacing.all16, child: _buildTotalRow(r)),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(FeeRecord r) {
    return Obx(() {
      final busy = controller.isDownloadingReceipt(r.id);
      return AppButton(
        label: busy ? 'Downloading…' : 'Download Receipt',
        icon: Icons.download_rounded,
        isLoading: busy,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryBrand,
        borderColor: AppColors.primaryBrand,
        hasShadow: false,
        onPressed: () => controller.downloadFeeReceipt(r.id),
      );
    });
  }

  Widget _buildDeleteButton(FeeRecord r) {
    return Obx(() {
      final busy = controller.isDeletingTransaction.value;
      return AppButton(
        label: busy ? 'Deleting…' : 'Delete Transaction',
        icon: Icons.delete_outline_rounded,
        isLoading: busy,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.errorRed,
        borderColor: AppColors.errorRed,
        hasShadow: false,
        onPressed: () => _confirmDelete(r),
      );
    });
  }

  void _confirmDelete(FeeRecord r) {
    CommonDialog.showDeleteConfirmation(
      title: 'Delete Transaction',
      description:
          'Delete the ${_money(r.transactionAmount)} payment from '
          '${r.student?.name ?? 'this student'}? This cannot be undone.',
      onConfirm: () async {
        final deleted = await controller.deleteTransaction(r);
        if (deleted) Get.back();
      },
    );
  }

  /// Opens the share popup. Nothing goes out automatically when a payment
  /// is saved; only these options send the receipt.
  Widget _buildShareButtons(FeeRecord r) {
    return Obx(() {
      final busy = controller.sharingReceiptChannel.value != null;
      return AppButton(
        label: busy ? 'Sending…' : 'Share Receipt',
        icon: Icons.share_rounded,
        isLoading: busy,
        onPressed: () => _showShareSheet(r),
      );
    });
  }

  void _showShareSheet(FeeRecord r) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
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
                'Share Receipt',
                style: AppTextStyles.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.v12,
              _shareOption(
                icon: const AppWhatsAppIcon(size: 22),
                color: const Color(0xFF25D366),
                title: 'WhatsApp',
                subtitle: r.student?.name != null
                    ? 'Open a chat with ${r.student!.name} with the receipt details'
                    : 'Open WhatsApp with the receipt details',
                onTap: () => controller.openReceiptOnWhatsApp(r),
              ),
              _shareOption(
                icon: const Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 22,
                  color: AppColors.bohoRed,
                ),
                color: AppColors.bohoRed,
                title: 'Share PDF',
                subtitle: 'Send the receipt PDF on WhatsApp or any app',
                onTap: () => controller.shareReceiptPdf(r),
              ),
              _shareOption(
                icon: const Icon(
                  Icons.send_rounded,
                  size: 22,
                  color: Color(0xFF128C7E),
                ),
                color: const Color(0xFF128C7E),
                title: 'Send on WhatsApp automatically',
                subtitle: 'Tuoora sends the approved template with the PDF',
                onTap: () => controller.shareFeeReceipt(r, 'whatsapp'),
              ),
              _shareOption(
                icon: const Icon(
                  Icons.email_outlined,
                  size: 22,
                  color: AppColors.primaryBrand,
                ),
                color: AppColors.primaryBrand,
                title: 'Email',
                subtitle: 'Email the receipt to the student / parent',
                onTap: () => controller.shareFeeReceipt(r, 'email'),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _shareOption({
    required Widget icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        Get.back();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: icon,
            ),
            AppSpacing.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    color: AppColors.borderGrey.withValues(alpha: 0.6),
  );

  Widget _buildHeader(FeeRecord r, DateFormat dateFmt) {
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
              'Date: ${dateFmt.format(r.transactionPaidAt)}',
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

  Widget _buildBilledAndPayment(
    FeeRecord r,
    DateFormat dateFmt,
    DateFormat timeFmt,
  ) {
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
              _kvRow(AppStrings.receiptMethodLabel, r.transactionMethod),
              AppSpacing.v4,
              _kvRow(
                AppStrings.receiptPaidDateLabel,
                dateFmt.format(r.transactionPaidAt),
              ),
              AppSpacing.v4,
              _kvRow(
                'Transaction Date:',
                timeFmt.format(r.transactionRecordedAt.toLocal()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLineItems(FeeRecord r) {
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
              child: Text(
                'Fee Payment',
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            AppSpacing.h8,
            Text(
              _money(r.transactionAmount),
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
          _money(r.transactionAmount),
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

  String _money(double v) => formatRupees(v);
}
