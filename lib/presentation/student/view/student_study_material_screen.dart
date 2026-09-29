import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/presentation/student/controllers/student_study_material_controller.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';
import 'package:tuoora/data/models/student_resource_model.dart';

class StudentStudyMaterialScreen
    extends GetView<StudentStudyMaterialController> {
  const StudentStudyMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const StudentAppBar(
              title: AppStrings.labelStudyMaterial,
              showDefaultActions: false,
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: controller.fetchResources,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.x16,
                      itemCount: 4,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) => _buildShimmerCard(),
                    );
                  }

                  if (controller.resources.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        AppEmptyView(
                          icon: Icons.menu_book_outlined,
                          title: AppStrings.noStudyMaterialFound,
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s16,
                      8,
                      AppSpacing.s16,
                      24,
                    ),
                    itemCount: controller.resources.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = controller.resources[index];
                      return _buildMaterialCard(item);
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(StudentResourceModel item) {
    final typeInfo = _getResourceTypeInfo(item);
    final hasSubject = item.subject.trim().isNotEmpty;
    final hasDescription = item.description.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            Get.toNamed(AppRoutes.studentStudyMaterialDetail, arguments: item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: typeInfo.iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        typeInfo.icon,
                        color: typeInfo.iconColor,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: hasSubject
                                    ? const Color(0xFFF1F5F9)
                                    : typeInfo.iconBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                hasSubject
                                    ? item.subject.trim()
                                    : typeInfo.typeLabel,
                                style: AppTextStyles.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: hasSubject
                                      ? const Color(0xFF334155)
                                      : typeInfo.iconColor,
                                ),
                              ),
                            ),
                            if (item.date.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.date,
                                    style: AppTextStyles.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.title.isNotEmpty ? item.title : 'Study Material',
                          style: AppTextStyles.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hasDescription) ...[
                const SizedBox(height: 10),
                Text(
                  item.description.trim(),
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (item.batchName.isNotEmpty) ...[
                    const Icon(
                      Icons.groups_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.batchName,
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    typeInfo.typeLabel,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: typeInfo.iconColor,
                    ),
                  ),
                  if (item.fileSize.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.fileSize,
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.isYoutube
                            ? 'Watch'
                            : (item.isLink ? 'Open' : 'View'),
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: typeInfo.iconColor,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: typeInfo.iconColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _TypeInfo _getResourceTypeInfo(StudentResourceModel item) {
    if (item.isYoutube) {
      return const _TypeInfo(
        icon: Icons.smart_display_rounded,
        iconColor: Color(0xFFDC2626),
        iconBg: Color(0xFFFEF2F2),
        typeLabel: 'YouTube',
      );
    }
    if (item.isLink) {
      return const _TypeInfo(
        icon: Icons.link_rounded,
        iconColor: Color(0xFF2563EB),
        iconBg: Color(0xFFEFF6FF),
        typeLabel: 'Link',
      );
    }
    final fileType = item.fileType.toLowerCase();
    final url = item.fileUrl.toLowerCase();
    if (fileType == 'pdf' || url.endsWith('.pdf')) {
      return const _TypeInfo(
        icon: Icons.picture_as_pdf_rounded,
        iconColor: Color(0xFFEA580C),
        iconBg: Color(0xFFFFF7ED),
        typeLabel: 'PDF',
      );
    }
    if (fileType == 'video' ||
        url.endsWith('.mp4') ||
        item.resourceType == 'video') {
      return const _TypeInfo(
        icon: Icons.video_collection_rounded,
        iconColor: Color(0xFF7C3AED),
        iconBg: Color(0xFFF5F3FF),
        typeLabel: 'Video',
      );
    }
    if (fileType.contains('image') ||
        url.endsWith('.jpg') ||
        url.endsWith('.png') ||
        url.endsWith('.jpeg')) {
      return const _TypeInfo(
        icon: Icons.image_rounded,
        iconColor: Color(0xFF059669),
        iconBg: Color(0xFFECFDF5),
        typeLabel: 'Image',
      );
    }
    return _TypeInfo(
      icon: Icons.insert_drive_file_rounded,
      iconColor: AppColors.primaryBrand,
      iconBg: AppColors.primaryBrandLight,
      typeLabel:
          item.fileType.isNotEmpty ? item.fileType.toUpperCase() : 'Document',
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeInfo {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String typeLabel;

  const _TypeInfo({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.typeLabel,
  });
}
