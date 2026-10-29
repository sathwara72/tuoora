import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/utils/currency_utils.dart';
import 'package:tuoora/presentation/student/controllers/fees_controller.dart';
import 'package:tuoora/presentation/student/models/fee_model.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';

class StudentPayFeesScreen extends GetView<FeesController> {
  const StudentPayFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final summary = controller.summary.value;
          final profile = controller.billingProfile.value;
          final hasUpi = profile.hasUpiPayment;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StudentAppBar(
                title: AppStrings.studentPayFeesTitle,
                showDefaultActions: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _OutstandingCard(summary: summary),
                      const SizedBox(height: AppSpacing.s12),
                      if (hasUpi)
                        _UpiCard(
                          profile: profile,
                          onCopy: controller.copyUpiHandle,
                        )
                      else
                        const _UpiUnavailableCard(),
                      const SizedBox(height: AppSpacing.s16),
                      _HowItWorksCard(profile: profile, summary: summary),
                      const SizedBox(height: AppSpacing.s8),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _OutstandingCard extends StatelessWidget {
  final FeeSummary summary;

  const _OutstandingCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.primaryBrand,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.studentPayFeesOutstanding,
            style: AppTextStyles.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.white.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${_formatThousands(summary.pendingInRupees)}',
            style: AppTextStyles.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary.pendingMonthsLabel,
            style: AppTextStyles.outfit(
              fontSize: 12,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpiCard extends StatelessWidget {
  final StudentBillingProfile profile;
  final VoidCallback onCopy;

  const _UpiCard({required this.profile, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final qrUrl = profile.instituteUpiQrCodeUrl;
    final upiId = profile.instituteUpiHandle;
    return Container(
      padding: AppSpacing.cardPadding,
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
      child: Column(
        children: [
          _QrBlock(qrUrl: qrUrl, fallbackInitial: profile.instituteName),
          const SizedBox(height: AppSpacing.s16),
          if (upiId.isNotEmpty)
            GestureDetector(
              onTap: onCopy,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      upiId,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}

class _QrBlock extends StatelessWidget {
  final String? qrUrl;
  final String fallbackInitial;

  const _QrBlock({required this.qrUrl, required this.fallbackInitial});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderGrey, width: 1.5),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: SizedBox(
        width: 200,
        height: 200,
        child: (qrUrl != null && qrUrl!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: qrUrl!,
                fit: BoxFit.contain,
                placeholder: (_, _) => const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, _, _) =>
                    _QrPlaceholder(initial: fallbackInitial),
              )
            : _QrPlaceholder(initial: fallbackInitial),
      ),
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  final String initial;

  const _QrPlaceholder({required this.initial});

  @override
  Widget build(BuildContext context) {
    final letter = initial.isNotEmpty ? initial.characters.first : 'T';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBrandLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                letter.toUpperCase(),
                style: AppTextStyles.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBrand,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'QR not uploaded — use the UPI ID below',
                textAlign: TextAlign.center,
                style: AppTextStyles.outfit(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpiUnavailableCard extends StatelessWidget {
  const _UpiUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryBrandLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 32,
                color: AppColors.primaryBrand,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              AppStrings.studentPayFeesUpiUnavailableTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.studentPayFeesUpiUnavailableBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.outfit(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  final StudentBillingProfile profile;
  final FeeSummary summary;

  const _HowItWorksCard({required this.profile, required this.summary});

  @override
  Widget build(BuildContext context) {
    final instituteLabel = profile.instituteName.isNotEmpty
        ? profile.instituteName
        : 'your institute';
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.studentPayFeesHowItWorks,
            style: AppTextStyles.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          _Step(index: 1, text: AppStrings.studentPayFeesStep1),
          const SizedBox(height: AppSpacing.s10),
          _Step(
            index: 2,
            text:
                '${AppStrings.studentPayFeesStep2Prefix} '
                '₹${_formatThousands(summary.pendingInRupees)} '
                '${AppStrings.studentPayFeesStep2Suffix} '
                '$instituteLabel.',
          ),
          const SizedBox(height: AppSpacing.s10),
          _Step(index: 3, text: AppStrings.studentPayFeesStep3),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int index;
  final String text;

  const _Step({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.primaryBrandLight,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: AppTextStyles.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBrand,
            ),
          ),
        ),
        AppSpacing.h12,
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.outfit(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatThousands(int value) => formatRupees(value, includeSymbol: false);
