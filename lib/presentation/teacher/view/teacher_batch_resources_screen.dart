import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_resources_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_resource_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherBatchResourcesScreen extends GetView<TeacherBatchResourcesController> {
  const TeacherBatchResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(
              title: '${controller.batch.name} Materials',
            ),
            _buildSearchAndSummary(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: controller.fetchResources,
                child: Obx(() {
                  if (controller.isLoading.value && controller.resources.isEmpty) {
                    return const Center(child: CommonLoading());
                  }

                  final list = controller.filteredResources;
                  if (list.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open_rounded,
                                size: 64,
                                color: AppColors.textTertiary.withValues(alpha: 0.5),
                              ),
                              AppSpacing.v12,
                              Text(
                                controller.searchQuery.value.isEmpty
                                    ? 'No study materials uploaded for this batch yet.'
                                    : 'No materials matching "${controller.searchQuery.value}"',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.outfit(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => AppSpacing.v12,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _ResourceCard(
                        resource: item,
                        isDownloading: controller.downloadingId.value == item.id,
                        onDownload: () => controller.downloadOrView(item),
                        onDelete: () => _confirmDelete(context, item),
                      );
                    },
                  );
                }),
              ),
            ),
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndSummary() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search study materials by title or subject...',
                hintStyle: AppTextStyles.outfit(fontSize: 13, color: AppColors.textTertiary),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => controller.searchQuery.value = '',
                  );
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          AppSpacing.v8,
          Obx(() {
            final total = controller.resources.length;
            final countText = controller.searchQuery.value.isEmpty
                ? '$total File${total == 1 ? '' : 's'} Uploaded'
                : '${controller.filteredResources.length} of $total File${total == 1 ? '' : 's'}';
            return Row(
              children: [
                Icon(Icons.attachment_rounded, size: 16, color: AppColors.primaryBrand),
                const SizedBox(width: 6),
                Text(
                  countText,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: AppButton(
        label: 'Upload Material',
        icon: Icons.upload_file_rounded,
        onPressed: () => _showUploadDialog(context),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final pickedFilePath = RxnString();
    final pickedFileName = RxnString();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header banner
              Container(
                color: const Color(0xFFFF6B00),
                padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload New Content',
                            style: AppTextStyles.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Distribute learning materials to this batch',
                            style: AppTextStyles.outfit(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),

              // Form fields
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE Field
                      Text(
                        'TITLE',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                        ),
                        child: TextField(
                          controller: titleCtrl,
                          style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'e.g. Week 4 - Study Material',
                            hintStyle: AppTextStyles.outfit(fontSize: 13, color: const Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // DESCRIPTION Field
                      Text(
                        'DESCRIPTION',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                        ),
                        child: TextField(
                          controller: descCtrl,
                          minLines: 3,
                          maxLines: 4,
                          style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Brief notes or instructions...',
                            hintStyle: AppTextStyles.outfit(fontSize: 13, color: const Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // FILE ATTACHMENT Field
                      Text(
                        'FILE ATTACHMENT',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final hasFile = pickedFilePath.value != null;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasFile ? const Color(0xFFFF6B00) : const Color(0xFFCBD5E1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEDE1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Color(0xFFFF6B00),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasFile ? pickedFileName.value! : 'Tap to choose file',
                                      style: AppTextStyles.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1E293B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      hasFile ? 'File attached' : 'Supports PDF, Word, PPT, JPG, PNG',
                                      style: AppTextStyles.outfit(
                                        fontSize: 11,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () async {
                                  final result = await FilePicker.pickFiles(
                                    type: FileType.any,
                                    allowMultiple: false,
                                  );
                                  if (result != null && result.files.single.path != null) {
                                    pickedFilePath.value = result.files.single.path;
                                    pickedFileName.value = result.files.single.name;
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFCBD5E1)),
                                  ),
                                  child: Text(
                                    hasFile ? 'Change' : 'Browse',
                                    style: AppTextStyles.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      // Format category indicator dots
                      Row(
                        children: [
                          _buildFormatDot(const Color(0xFFFF6B00), 'Images'),
                          const SizedBox(width: 14),
                          _buildFormatDot(const Color(0xFF2563EB), 'Videos'),
                          const SizedBox(width: 14),
                          _buildFormatDot(const Color(0xFFE11D48), 'Documents'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Actions: Cancel & Upload
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Obx(
                            () => ElevatedButton(
                              onPressed: controller.isUploading.value
                                  ? null
                                  : () async {
                                      if (titleCtrl.text.trim().isEmpty) {
                                        AppSnackBar.error('Please enter a title for the material.');
                                        return;
                                      }
                                      if (pickedFilePath.value == null) {
                                        AppSnackBar.error('Please select a file to upload.');
                                        return;
                                      }
                                      final ok = await controller.uploadNewResource(
                                        title: titleCtrl.text.trim(),
                                        subject: controller.batch.subject,
                                        description: descCtrl.text.trim(),
                                        filePath: pickedFilePath.value!,
                                      );
                                      if (ok) Get.back();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B00),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: controller.isUploading.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Upload',
                                      style: AppTextStyles.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildFormatDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, TeacherResource resource) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Resource?',
          style: AppTextStyles.outfit(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${resource.title}"? Students in ${controller.batch.name} will no longer be able to access this material.',
          style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: AppTextStyles.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.deleteResource(resource);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete', style: AppTextStyles.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final TeacherResource resource;
  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _ResourceCard({
    required this.resource,
    required this.isDownloading,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.insert_drive_file_rounded;
    Color iconColor = const Color(0xFF2563EB);
    Color iconBg = const Color(0xFFEFF6FF);

    if (resource.isPdf) {
      icon = Icons.picture_as_pdf_rounded;
      iconColor = const Color(0xFFDC2626);
      iconBg = const Color(0xFFFEF2F2);
    } else if (resource.isImage) {
      icon = Icons.image_rounded;
      iconColor = const Color(0xFF059669);
      iconBg = const Color(0xFFECFDF5);
    } else if (resource.isVideo) {
      icon = Icons.video_collection_rounded;
      iconColor = const Color(0xFF7C3AED);
      iconBg = const Color(0xFFF5F3FF);
    }

    String formattedDate = '';
    if (resource.createdAt != null) {
      try {
        final parsed = DateTime.parse(resource.createdAt!);
        formattedDate = DateFormat('dd MMM yyyy').format(parsed);
      } catch (_) {
        formattedDate = resource.createdAt!;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      padding: const EdgeInsets.all(14),
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
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: AppTextStyles.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (resource.subject != null && resource.subject!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          resource.subject!,
                          style: AppTextStyles.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                    if (resource.description != null && resource.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        resource.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                onSelected: (val) {
                  if (val == 'download') onDownload();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        const Icon(Icons.download_rounded, size: 18, color: AppColors.primaryBrand),
                        const SizedBox(width: 8),
                        Text('Download / Open', style: AppTextStyles.outfit(fontSize: 13)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text('Delete Resource', style: AppTextStyles.outfit(fontSize: 13, color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.borderGrey),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (formattedDate.isNotEmpty) ...[
                    Icon(Icons.access_time_rounded, size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: AppTextStyles.outfit(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                  if (resource.fileSize != null) ...[
                    const SizedBox(width: 8),
                    Text('· ${resource.fileSize}', style: AppTextStyles.outfit(fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ],
              ),
              GestureDetector(
                onTap: isDownloading ? null : onDownload,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      if (isDownloading)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBrand),
                        )
                      else
                        const Icon(Icons.download_rounded, size: 14, color: AppColors.primaryBrand),
                      const SizedBox(width: 4),
                      Text(
                        isDownloading ? 'Opening...' : 'View / Download',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBrand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
