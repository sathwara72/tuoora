import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_students_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherBatchStudentsScreen extends GetView<TeacherBatchStudentsController> {
  const TeacherBatchStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(
              title: '${controller.batch.name} Students',
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
                  tooltip: 'Refresh',
                  onPressed: controller.fetchStudents,
                ),
              ],
            ),
            _buildSearchAndSummary(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.students.isEmpty) {
                  return const Center(child: CommonLoading());
                }

                final list = controller.filteredStudents;
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: AppSpacing.x24,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 64,
                            color: AppColors.textTertiary.withOpacity(0.5),
                          ),
                          AppSpacing.v12,
                          Text(
                            controller.searchQuery.value.isEmpty
                                ? 'No students assigned to this batch yet.'
                                : 'No students matching "${controller.searchQuery.value}"',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.outfit(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          AppSpacing.v20,
                          if (controller.searchQuery.value.isEmpty)
                            AppButton(
                              label: 'Assign Students',
                              onPressed: () => _navigateToAssignStudents(context),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchStudents,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => AppSpacing.v12,
                    itemBuilder: (context, index) {
                      final student = list[index];
                      return _StudentCard(
                        student: student,
                        onEdit: () => _showEditStudentDialog(context, student),
                        onRemove: () => _confirmRemoveStudent(context, student),
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
                hintText: 'Search by name, enrollment ID, or phone...',
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
            final total = controller.students.length;
            final countText = controller.searchQuery.value.isEmpty
                ? '$total Total Student${total == 1 ? '' : 's'}'
                : '${controller.filteredStudents.length} of $total Student${total == 1 ? '' : 's'}';
            return Row(
              children: [
                Icon(Icons.school_outlined, size: 16, color: AppColors.primaryBrand),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _navigateToAssignStudents(context),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: Text(
                'Assign Existing',
                style: AppTextStyles.outfit(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBrand,
                side: const BorderSide(color: AppColors.primaryBrand),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showRegisterStudentDialog(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'Register New',
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrand,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAssignStudents(BuildContext context) async {
    final result = await Get.toNamed(
      AppRoutes.teacherAssignStudents,
      arguments: controller.batch,
    );
    if (result == true) {
      controller.fetchStudents();
    }
  }

  void _confirmRemoveStudent(BuildContext context, TeacherBatchStudent student) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            const SizedBox(width: 8),
            Text(
              'Remove Student',
              style: AppTextStyles.outfit(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove ${student.name} from batch "${controller.batch.name}"? This will unassign the student from this batch.',
          style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.removeStudent(student);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Remove',
              style: AppTextStyles.outfit(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, TeacherBatchStudent student) {
    final nameCtrl = TextEditingController(text: student.name);
    final phoneCtrl = TextEditingController(text: student.phone ?? '');
    final emailCtrl = TextEditingController(text: student.email ?? '');
    final enrollmentCtrl = TextEditingController(text: student.enrollmentId ?? '');
    final standardCtrl = TextEditingController(text: student.standard ?? '');
    final guardianCtrl = TextEditingController(text: student.guardianName ?? '');

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
                Text(
                  'Edit Student Info',
                  style: AppTextStyles.outfit(fontSize: 18, fontWeight: FontWeight.w700),
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
                  children: [
                    _inputField(label: 'Full Name *', controller: nameCtrl, icon: Icons.person_outline),
                    _inputField(label: 'Phone Number', controller: phoneCtrl, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                    _inputField(label: 'Email Address', controller: emailCtrl, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    _inputField(label: 'Enrollment ID', controller: enrollmentCtrl, icon: Icons.badge_outlined),
                    _inputField(label: 'Standard / Grade', controller: standardCtrl, icon: Icons.school_outlined),
                    _inputField(label: 'Parent / Guardian Name', controller: guardianCtrl, icon: Icons.family_restroom_outlined),
                  ],
                ),
              ),
            ),
            AppSpacing.v12,
            AppButton(
              label: 'Save Changes',
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) {
                  AppSnackBar.error('Student name is required');
                  return;
                }
                final data = <String, dynamic>{
                  'name': nameCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'enrollment_id': enrollmentCtrl.text.trim(),
                  'standard': standardCtrl.text.trim(),
                  'guardian_name': guardianCtrl.text.trim(),
                };
                final ok = await controller.updateStudentInfo(student.id, data);
                if (ok) Get.back();
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showRegisterStudentDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final enrollmentCtrl = TextEditingController();
    final standardCtrl = TextEditingController();
    final guardianCtrl = TextEditingController();

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
                      'Register Student',
                      style: AppTextStyles.outfit(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Add directly into ${controller.batch.name}',
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
                  children: [
                    _inputField(label: 'Full Name *', controller: nameCtrl, icon: Icons.person_outline),
                    _inputField(label: 'Phone Number', controller: phoneCtrl, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                    _inputField(label: 'Email Address', controller: emailCtrl, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    _inputField(label: 'Enrollment ID', controller: enrollmentCtrl, icon: Icons.badge_outlined),
                    _inputField(label: 'Standard / Grade', controller: standardCtrl, icon: Icons.school_outlined),
                    _inputField(label: 'Parent / Guardian Name', controller: guardianCtrl, icon: Icons.family_restroom_outlined),
                  ],
                ),
              ),
            ),
            AppSpacing.v12,
            AppButton(
              label: 'Register & Add to Batch',
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) {
                  AppSnackBar.error('Student name is required');
                  return;
                }
                final data = <String, dynamic>{
                  'name': nameCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'enrollment_id': enrollmentCtrl.text.trim(),
                  'standard': standardCtrl.text.trim(),
                  'guardian_name': guardianCtrl.text.trim(),
                };
                final ok = await controller.registerNewStudent(data);
                if (ok) Get.back();
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.outfit(fontSize: 13, color: AppColors.textSecondary),
          prefixIcon: Icon(icon, size: 20, color: AppColors.textTertiary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primaryBrand, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final TeacherBatchStudent student;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _StudentCard({
    required this.student,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: AppTextStyles.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (student.enrollmentId != null && student.enrollmentId!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.badge_outlined, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            student.enrollmentId!,
                            style: AppTextStyles.outfit(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (student.phone != null && student.phone!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () {
                          final uri = Uri(scheme: 'tel', path: student.phone);
                          launchUrl(uri);
                        },
                        child: Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: AppColors.primaryBrand),
                            const SizedBox(width: 4),
                            Text(
                              student.phone!,
                              style: AppTextStyles.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryBrand,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'remove') onRemove();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text('Edit Info', style: AppTextStyles.outfit(fontSize: 13)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        const Icon(Icons.person_remove_outlined, size: 18, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Remove from Batch',
                          style: AppTextStyles.outfit(fontSize: 13, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.borderGrey),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFeeBadge(student.feeStatus),
              if (student.totalDue > 0)
                Text(
                  'Due: ₹${student.totalDue}',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                )
              else if (student.totalPaid > 0)
                Text(
                  'Paid: ₹${student.totalPaid}',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF059669),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final hasImg = student.profileImageUrl != null && student.profileImageUrl!.isNotEmpty;
    if (hasImg) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(student.profileImageUrl!),
        backgroundColor: AppColors.primaryBrand.withOpacity(0.1),
      );
    }
    final initials = student.name.isNotEmpty
        ? student.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFFEFF6FF),
      child: Text(
        initials,
        style: AppTextStyles.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2563EB),
        ),
      ),
    );
  }

  Widget _buildFeeBadge(String? status) {
    final s = (status ?? 'pending').toLowerCase();
    Color bg;
    Color text;
    String label;

    if (s.contains('paid') && !s.contains('un')) {
      bg = const Color(0xFFECFDF5);
      text = const Color(0xFF059669);
      label = 'Fee Paid';
    } else if (s.contains('partial')) {
      bg = const Color(0xFFFFFBEB);
      text = const Color(0xFFD97706);
      label = 'Partial Fee';
    } else if (s.contains('overdue')) {
      bg = const Color(0xFFFEF2F2);
      text = const Color(0xFFDC2626);
      label = 'Overdue';
    } else {
      bg = const Color(0xFFFFF1F2);
      text = const Color(0xFFE11D48);
      label = status != null && status.isNotEmpty ? status.capitalizeFirst! : 'Fee Due';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}
