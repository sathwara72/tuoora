import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/status_badge.dart';
import 'package:tuoora/presentation/institute/controllers/homework_rating_controller.dart';
import 'package:tuoora/presentation/institute/models/homework_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/institute_bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeworkRatingScreen extends StatelessWidget {
  const HomeworkRatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeworkModel homework = Get.arguments;
    final controller = Get.put(
      HomeworkRatingController(homework),
      tag: homework.id,
    );

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.instHomeworkRatingTitle,
              onBackTap: () => Get.back(),
            ),
            Expanded(
              child: Obx(
                () => controller.isFetchingDetails.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBrand,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: AppSpacing.x16.add(AppSpacing.y16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(homework),
                            AppSpacing.v24,
                            _buildProgressSection(homework),
                            AppSpacing.v24,
                            _buildFilterSection(controller),
                            AppSpacing.v24,
                            Column(
                              children: controller.filteredSubmissions
                                  .map(
                                    (sub) => _buildStudentRatingCard(
                                        controller, sub),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (!controller.canEdit) return const SizedBox.shrink();
        if (controller.filterIndex.value == 2 || controller.filterIndex.value == 3) {
          return const SizedBox.shrink();
        }
        return InstituteBottomButton(
          label: AppStrings.submitRatings,
          icon: Icons.check_circle_rounded,
          isLoading: controller.isLoading.value,
          onTap: () => controller.submitRatings(),
        );
      }),
    );
  }

  Widget _buildHeader(HomeworkModel hw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hw.subject.toUpperCase(),
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBrandLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'BATCH ${hw.batchId}',
                style: AppTextStyles.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrand,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.v8,
        Text(
          hw.title,
          style: AppTextStyles.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.v8,
        Text(
          hw.description,
          style: AppTextStyles.outfit(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(HomeworkModel hw) {
    final submitted = hw.submittedCount;
    final total = hw.submissions.length;
    final progress = total == 0 ? 0.0 : submitted / total;

    return Container(
      padding: AppSpacing.all20,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successBg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_box_outlined,
                    color: AppColors.primaryBrand,
                    size: 20,
                  ),
                  AppSpacing.h8,
                  Text(
                    AppStrings.instGradingProgressLabel,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$submitted/$total ',
                      style: AppTextStyles.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: AppStrings.instSubmittedTag,
                      style: AppTextStyles.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.v16,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.successBg,
              color: AppColors.primaryBrand,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(HomeworkRatingController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(controller, AppStrings.instFilterAll, 0),
          AppSpacing.h12,
          _buildFilterChip(controller, AppStrings.instFilterSubmitted, 1),
          AppSpacing.h12,
          _buildFilterChip(controller, 'Pending', 2),
          AppSpacing.h12,
          _buildFilterChip(controller, 'Reviewed', 3),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    HomeworkRatingController controller,
    String label,
    int index,
  ) {
    return Obx(() {
      final isSelected = controller.filterIndex.value == index;
      return GestureDetector(
        onTap: () => controller.filterIndex.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBrand : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryBrand : AppColors.successBg,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStudentRatingCard(
    HomeworkRatingController controller,
    HomeworkSubmission sub,
  ) {
    final isSubmitted = sub.isSubmitted;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: AppSpacing.all16,
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
      child: Column(
        children: [
          Row(
            children: [
              _buildStudentAvatar(sub.profileImageUrl, sub.studentName),
              AppSpacing.h16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.studentName,
                      style: AppTextStyles.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Enrollment ID: ${controller.getEnrollmentIdForStudent(sub)}',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge.fromLabel(sub.status),
            ],
          ),
          if (isSubmitted) ...[
            AppSpacing.v16,
            Row(
              children: [
                Text(
                  AppStrings.instScoreLabel,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: (controller.canEdit && sub.status.toLowerCase() != 'reviewed')
                            ? () => controller.updateScore(
                                sub.studentId.toString(),
                                sub.score - 1,
                              )
                            : null,
                        icon: const Icon(Icons.remove, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      AppSpacing.h12,
                      Text(
                        sub.score.toStringAsFixed(0),
                        style: AppTextStyles.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      AppSpacing.h12,
                      IconButton(
                        onPressed: (controller.canEdit && sub.status.toLowerCase() != 'reviewed')
                            ? () => controller.updateScore(
                                sub.studentId.toString(),
                                sub.score + 1,
                              )
                            : null,
                        icon: const Icon(Icons.add, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                AppSpacing.h8,
                Text(
                  '/ 10',
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentAvatar(String? imageUrl, String name) {
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.contains('ui-avatars.com')) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryBrandLight,
          shape: BoxShape.circle,
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
      if (names.length > 1) {
        initials += names[names.length - 1][0].toUpperCase();
      }
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primaryBrandLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBrand,
          ),
        ),
      ),
    );
  }

}
