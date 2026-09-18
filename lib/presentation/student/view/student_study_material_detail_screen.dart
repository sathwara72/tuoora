import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/student/controllers/student_study_material_detail_controller.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';
import 'package:tuoora/presentation/student/widgets/student_attachment_tile.dart';
import 'package:tuoora/data/models/student_resource_model.dart';

class StudentStudyMaterialDetailScreen
    extends GetView<StudentStudyMaterialDetailController> {
  const StudentStudyMaterialDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final material = controller.material;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            StudentAppBar(title: material.title, showDefaultActions: false),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: AppSpacing.x16,
                children: [
                  _buildHeaderCard(material),
                  const SizedBox(height: 16),
                  if (controller.isYoutube)
                    _buildYoutubeCard(controller)
                  else ...[
                    Text(
                      AppStrings.files,
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...controller.attachments.map((attachment) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: StudentAttachmentTile(
                          attachment: attachment,
                          onTap: () => controller.openAttachment(attachment),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYoutubeCard(StudentStudyMaterialDetailController controller) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: controller.openYoutube,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Ink(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.s40,
                height: AppSpacing.s40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(AppSpacing.s12),
                ),
                child: const Icon(
                  Icons.smart_display_rounded,
                  color: Color(0xFFCC0000),
                  size: 20,
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Text(
                  'Watch on YouTube',
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.open_in_new_rounded, color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(StudentResourceModel item) {
    final hash = item.subject.hashCode;
    final isDark = hash % 2 == 0;
    final bgColor = isDark ? AppColors.primaryBrandLight : AppColors.successBg;
    final textColor = isDark ? AppColors.error : AppColors.errorRed;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Text(
                  item.subject,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.batchName} • ${item.date}',
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            style: AppTextStyles.outfit(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
