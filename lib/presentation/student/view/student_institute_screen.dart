import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:tuoora/core/utils/pull_refresh.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';
import 'package:tuoora/presentation/student/controllers/student_institute_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentInstituteScreen extends GetView<StudentInstituteController> {
  const StudentInstituteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const StudentAppBar(
              title: AppStrings.studentReceiptInstitute,
              showDefaultActions: false,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && !PullRefresh.active.value) {
                  return const CommonLoading(color: AppColors.primaryBrand);
                }

                final institute = controller.instituteData.value;
                if (institute == null) {
                  return const AppEmptyView(
                    icon: Icons.school_outlined,
                    title: AppStrings.instituteDetailsUnavailable,
                    message:
                        'We couldn\'t load your institute info. Please try again later.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => PullRefresh.run(controller.fetchInstitute),
                  color: AppColors.primaryBrand,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroCard(institute),
                        const SizedBox(height: 16),
                        _buildContactCard(institute),
                        const SizedBox(height: 16),
                        _buildChatButton(),
                        const SizedBox(height: 32),
                        Text(
                          AppStrings.location,
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildMapCard(institute),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(dynamic institute) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.textDarkGrey,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: institute.logoUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: institute.logoUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CommonLoading(color: AppColors.primaryBrand),
                      errorWidget: (context, url, error) => Text(
                        institute.initials,
                        style: AppTextStyles.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  )
                : Text(
                    institute.initials,
                    style: AppTextStyles.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            institute.name,
            style: AppTextStyles.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(dynamic institute) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _buildInfoRow('Contact person', institute.contactPerson),
          Divider(
            height: 1,
            color: AppColors.borderGrey.withValues(alpha: 0.5),
          ),
          _buildInfoRow('Phone', institute.phone),
          if (institute.email != null) ...[
            Divider(
              height: 1,
              color: AppColors.borderGrey.withValues(alpha: 0.5),
            ),
            _buildInfoRow('Email', institute.email!),
          ],
          if (institute.website != null) ...[
            Divider(
              height: 1,
              color: AppColors.borderGrey.withValues(alpha: 0.5),
            ),
            _buildInfoRow('Website', institute.website!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton() {
    return AppButton(
      label: AppStrings.chatWithInstitute,
      icon: Icons.chat_bubble_outline_rounded,
      backgroundColor: AppColors.primaryBrand,
      borderRadius: AppSpacing.cardRadius,
      onPressed: () => Get.toNamed(AppRoutes.studentChat),
    );
  }

  Widget _buildMapCard(dynamic institute) {
    final location = institute.location;
    final addressLine1 = location.address ?? '';
    final addressLine2 =
        '${location.city ?? ''}, ${location.state ?? ''} ${location.pincode ?? ''}'
            .trim();

    final displayAddr1 = addressLine1.isNotEmpty
        ? addressLine1
        : (location.fullAddress ?? 'Address not available');
    final displayAddr2 = addressLine1.isNotEmpty ? addressLine2 : '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        children: [
          Container(
            height: 160,
            decoration: const BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.cardRadius),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: MapBackgroundPainter()),
                ),
                Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 40,
                    color: AppColors.primaryBrand,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrand,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: const Icon(
                    Icons.domain_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayAddr1,
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (displayAddr2.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          displayAddr2,
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    if (location.fullAddress != null) {
                      final url =
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location.fullAddress!)}';
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    side: BorderSide(
                      color: AppColors.borderGrey.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.cardRadius,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.primaryBrand,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.directions,
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final blockPaint = Paint()
      ..color = AppColors.successBg
      ..style = PaintingStyle.fill;

    // Draw horizontal road
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.45),
      roadPaint,
    );

    // Draw vertical roads
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.25, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, 0),
      Offset(size.width * 0.8, size.height),
      roadPaint,
    );

    // Draw some green blocks
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.6, 60, 40),
        const Radius.circular(4),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.45, size.height * 0.6, 80, 40),
        const Radius.circular(4),
      ),
      blockPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
