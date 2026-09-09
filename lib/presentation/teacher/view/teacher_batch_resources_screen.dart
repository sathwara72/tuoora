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
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
                  tooltip: 'Refresh',
                  onPressed: controller.fetchResources,
                ),
              ],
            ),
            _buildSearchAndSummary(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.resources.isEmpty) {
                  return const Center(child: CommonLoading());
                }

                final list = controller.filteredResources;
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
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
                          AppSpacing.v16,
                          if (controller.searchQuery.value.isEmpty)
                            AppButton(
                              label: 'Upload First Material',
                              onPressed: () => _showUploadBottomSheet(context),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchResources,
                  child: ListView.separated(
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
                  ),
                );
              }),
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
        label: 'Upload Study Material',
        icon: Icons.upload_file_rounded,
        onPressed: () => _showUploadBottomSheet(context),
      ),
    );
  }

  void _showUploadBottomSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController(text: controller.batch.subject ?? '');
    final descCtrl = TextEditingController();
    final pickedFilePath = RxnString();
    final pickedFileName = RxnString();

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Material',
                      style: AppTextStyles.outfit(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Share files with ${controller.batch.name}',
                      style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputField(
                      label: 'Title *',
                      hint: 'e.g. Chapter 4 Notes, Practice Quiz',
                      controller: titleCtrl,
                      icon: Icons.title_rounded,
                    ),
                    _inputField(
                      label: 'Subject',
                      hint: 'e.g. Mathematics, Physics',
                      controller: subjectCtrl,
                      icon: Icons.subject_rounded,
                    ),
                    _inputField(
                      label: 'Description (Optional)',
                      hint: 'Brief summary of contents...',
                      controller: descCtrl,
                      icon: Icons.description_outlined,
                      maxLines: 2,
                    ),
                    AppSpacing.v8,
                    Text(
                      'Select File (PDF, Docs, Images, etc.) *',
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.v8,
                    Obx(() {
                      final hasFile = pickedFilePath.value != null;
                      return GestureDetector(
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
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: hasFile ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasFile ? const Color(0xFF059669) : AppColors.borderGrey,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hasFile ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                                color: hasFile ? const Color(0xFF059669) : AppColors.primaryBrand,
                                size: 28,
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
                                        color: hasFile ? const Color(0xFF059669) : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      hasFile ? 'File attached' : 'Supports PDF, Word, PPT, JPG, PNG',
                                      style: AppTextStyles.outfit(
                                        fontSize: 11,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (hasFile)
                                IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    pickedFilePath.value = null;
                                    pickedFileName.value = null;
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            AppSpacing.v12,
            Obx(
              () => AppButton(
                label: 'Upload File',
                isLoading: controller.isUploading.value,
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) {
                    AppSnackBar.error('Please enter a title for the study material.');
                    return;
                  }
                  if (pickedFilePath.value == null) {
                    AppSnackBar.error('Please select a file to upload.');
                    return;
                  }
                  final ok = await controller.uploadNewResource(
                    title: titleCtrl.text.trim(),
                    subject: subjectCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    filePath: pickedFilePath.value!,
                  );
                  if (ok) Get.back();
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: AppTextStyles.outfit(fontSize: 13, color: AppColors.textSecondary),
          hintStyle: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
          prefixIcon: Icon(icon, size: 20, color: AppColors.textTertiary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderGrey),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
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
