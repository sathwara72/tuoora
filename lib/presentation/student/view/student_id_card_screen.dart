import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_network_image.dart';
import 'package:tuoora/presentation/student/controllers/student_id_card_controller.dart';
import 'package:tuoora/presentation/student/models/student_id_card_model.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';

class StudentIdCardScreen extends GetView<StudentIdCardController> {
  const StudentIdCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const StudentAppBar(
              title: AppStrings.labelIdCard,
              showDefaultActions: false,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryBrand),
                  );
                }

                final card = controller.idCard.value;
                if (card == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                        AppSpacing.v16,
                        const Text('Failed to load ID card'),
                        AppSpacing.v16,
                        ElevatedButton(
                          onPressed: controller.loadIdCard,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: AppSpacing.all24,
                  child: Column(
                    children: [
                      RepaintBoundary(
                        key: controller.cardBoundaryKey,
                        child: _IdCardVisual(card: card),
                      ),
                      AppSpacing.v32,
                      _buildActions(),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Obx(() {
      final busy = controller.isCapturing.value;
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: busy ? null : controller.shareIdCard,
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBrand,
                side: const BorderSide(color: AppColors.primaryBrand),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
              ),
            ),
          ),
          AppSpacing.h12,
          Expanded(
            child: ElevatedButton.icon(
              onPressed: busy ? null : controller.downloadIdCard,
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.white),
                      ),
                    )
                  : const Icon(Icons.download_rounded, size: 18),
              label: Text(busy ? 'Preparing...' : 'Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrand,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _IdCardVisual extends StatelessWidget {
  final StudentIdCard card;

  const _IdCardVisual({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            AppSpacing.v16,
            _buildAvatar(),
            AppSpacing.v12,
            _buildNameBlock(),
            AppSpacing.v16,
            _buildInfoTable(),
            AppSpacing.v16,
            _buildQrBlock(),
            AppSpacing.v16,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBrand,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (card.instituteLogoUrl != null && card.instituteLogoUrl!.isNotEmpty) ...[
            ClipOval(
              child: SizedBox(
                width: 40,
                height: 40,
                child: AppNetworkImage(url: card.instituteLogoUrl!, fit: BoxFit.cover),
              ),
            ),
            AppSpacing.v8,
          ],
          Text(
            card.instituteName.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.white,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.studentIdentityCard,
            textAlign: TextAlign.center,
            style: AppTextStyles.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.white.withValues(alpha: 0.9),
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final url = card.studentProfileImageUrl;
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryBrandLight, width: 3),
      ),
      child: ClipOval(
        child: (url != null && url.isNotEmpty)
            ? AppNetworkImage(url: url, fit: BoxFit.cover)
            : Container(
                color: AppColors.primaryBrandLight,
                child: Center(
                  child: Text(
                    card.studentName.isNotEmpty ? card.studentName[0].toUpperCase() : '?',
                    style: AppTextStyles.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildNameBlock() {
    return Column(
      children: [
        Text(
          card.studentName.isEmpty ? '—' : card.studentName,
          textAlign: TextAlign.center,
          style: AppTextStyles.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryBrandLight,
            borderRadius: BorderRadius.circular(AppSpacing.s12),
          ),
          child: Text(
            card.batchName,
            style: AppTextStyles.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBrand,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTable() {
    final rows = <(String, String)>[
      ('Standard', card.studentStandard ?? 'Not Specified'),
      ('DOB', card.studentDob ?? 'Not Specified'),
      ('Phone', card.studentPhone ?? 'Not Available'),
    ];
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) Divider(height: 1, color: AppColors.fieldBorder),
          Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    rows[i].$1,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.fieldLabel,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    rows[i].$2,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQrBlock() {
    return Column(
      children: [
        Container(
          padding: AppSpacing.all12,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.s12),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: QrImageView(
            data: card.qrPayload,
            size: 140,
            backgroundColor: AppColors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.textPrimary,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Scan to verify',
          style: AppTextStyles.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}
