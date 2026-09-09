import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_assign_students_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherAssignStudentsScreen extends GetView<TeacherAssignStudentsController> {
  const TeacherAssignStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(
              title: 'Assign to ${controller.batch.name}',
            ),
            _buildSearchAndSelectAllHeader(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.availableStudents.isEmpty) {
                  return const Center(child: CommonLoading());
                }

                if (controller.availableStudents.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: AppSpacing.x24,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search_rounded,
                            size: 64,
                            color: AppColors.textTertiary.withValues(alpha: 0.5),
                          ),
                          AppSpacing.v12,
                          Text(
                            controller.searchQuery.value.isEmpty
                                ? 'No available unassigned students found in your institute.'
                                : 'No students found matching "${controller.searchQuery.value}"',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.outfit(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: controller.availableStudents.length,
                  separatorBuilder: (_, _) => AppSpacing.v12,
                  itemBuilder: (context, index) {
                    final student = controller.availableStudents[index];
                    return Obx(() {
                      final isSelected = controller.selectedStudentIds.contains(student.id);
                      return _SelectableStudentTile(
                        student: student,
                        isSelected: isSelected,
                        onTap: () => controller.toggleSelection(student.id),
                      );
                    });
                  },
                );
              }),
            ),
            _buildBottomAssignBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndSelectAllHeader() {
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
              onChanged: controller.onSearchChanged,
              style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search available students...',
                hintStyle: AppTextStyles.outfit(fontSize: 13, color: AppColors.textTertiary),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          AppSpacing.v8,
          Obx(() {
            final total = controller.availableStudents.length;
            final selectedCount = controller.selectedStudentIds.length;
            final isAllSelected = total > 0 && selectedCount == total;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$total Available Student${total == 1 ? '' : 's'}',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (total > 0)
                  TextButton.icon(
                    onPressed: controller.selectAll,
                    icon: Icon(
                      isAllSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      size: 18,
                      color: AppColors.primaryBrand,
                    ),
                    label: Text(
                      isAllSelected ? 'Deselect All' : 'Select All',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBrand,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomAssignBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final count = controller.selectedStudentIds.length;
        return AppButton(
          label: count > 0 ? 'Assign ($count) to Batch' : 'Select Students to Assign',
          isLoading: controller.isSubmitting.value,
          onPressed: count > 0 ? controller.assignSelectedStudents : null,
        );
      }),
    );
  }
}

class _SelectableStudentTile extends StatelessWidget {
  final TeacherBatchStudent student;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableStudentTile({
    required this.student,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBrand : AppColors.borderGrey,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (student.enrollmentId != null && student.enrollmentId!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${student.enrollmentId!}',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (student.phone != null && student.phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      student.phone!,
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primaryBrand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final hasImg = student.profileImageUrl != null && student.profileImageUrl!.isNotEmpty;
    if (hasImg) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(student.profileImageUrl!),
        backgroundColor: AppColors.primaryBrand.withOpacity(0.1),
      );
    }
    final initials = student.name.isNotEmpty
        ? student.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFEFF6FF),
      child: Text(
        initials,
        style: AppTextStyles.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2563EB),
        ),
      ),
    );
  }
}
