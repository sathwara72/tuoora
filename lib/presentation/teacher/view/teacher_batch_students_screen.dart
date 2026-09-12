import 'package:cached_network_image/cached_network_image.dart';
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
                        onView: () => _showStudentDetailsSheet(context, student),
                        onEdit: () => _showEditStudentDialog(context, student),
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _navigateToAssignStudents(context),
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
          label: Text(
            'Assign Student',
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBrand,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
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

  void _showStudentDetailsSheet(BuildContext context, TeacherBatchStudent student) {
    final enrollmentId = student.enrollmentId != null && student.enrollmentId!.isNotEmpty
        ? student.enrollmentId!
        : student.id.toString();

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
                  'Student Details',
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
                    AppSpacing.v12,
                    Center(
                      child: _hasValidPhoto(student.profileImageUrl)
                          ? CachedNetworkImage(
                              imageUrl: student.profileImageUrl!,
                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                radius: 36,
                                backgroundImage: imageProvider,
                              ),
                              placeholder: (context, url) => _buildSheetInitials(student.name),
                              errorWidget: (context, url, error) => _buildSheetInitials(student.name),
                            )
                          : _buildSheetInitials(student.name),
                    ),
                    AppSpacing.v12,
                    Text(
                      student.name,
                      style: AppTextStyles.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.v6,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            'ID: $enrollmentId',
                            style: AppTextStyles.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: AppTextStyles.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF10B981),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.v20,
                    _detailTile(
                      icon: Icons.school_outlined,
                      label: 'Standard',
                      value: student.standard?.isNotEmpty == true ? student.standard! : '-',
                    ),
                    _detailTile(
                      icon: Icons.family_restroom_outlined,
                      label: 'Guardian Name',
                      value: student.guardianName?.isNotEmpty == true ? student.guardianName! : '-',
                    ),
                    if (student.phone != null && student.phone!.isNotEmpty)
                      _detailTile(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: student.phone!,
                        actionIcon: Icons.call_outlined,
                        onTapAction: () {
                          final uri = Uri(scheme: 'tel', path: student.phone);
                          launchUrl(uri);
                        },
                      ),
                    if (student.email != null && student.email!.isNotEmpty)
                      _detailTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: student.email!,
                        actionIcon: Icons.mail_outline,
                        onTapAction: () {
                          final uri = Uri(scheme: 'mailto', path: student.email);
                          launchUrl(uri);
                        },
                      ),
                    if (controller.batch.teacherCanViewFees) ...[
                      _detailTile(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Fee Status',
                        value: student.feeStatus ?? 'Pending',
                      ),
                      if (student.totalDue > 0)
                        _detailTile(
                          icon: Icons.money_off_outlined,
                          label: 'Total Due',
                          value: '₹${student.totalDue}',
                          valueColor: Colors.redAccent,
                        ),
                      if (student.totalPaid > 0)
                        _detailTile(
                          icon: Icons.attach_money_outlined,
                          label: 'Total Paid',
                          value: '₹${student.totalPaid}',
                          valueColor: const Color(0xFF059669),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            AppSpacing.v12,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _confirmRemoveStudent(context, student);
                    },
                    icon: const Icon(Icons.person_remove_outlined, size: 18, color: Colors.redAccent),
                    label: Text(
                      'Remove',
                      style: AppTextStyles.outfit(color: Colors.redAccent, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _showEditStudentDialog(context, student);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                    label: Text(
                      'Edit Info',
                      style: AppTextStyles.outfit(color: Colors.white, fontWeight: FontWeight.w600),
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
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _detailTile({
    required IconData icon,
    required String label,
    required String value,
    IconData? actionIcon,
    VoidCallback? onTapAction,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGrey.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.outfit(fontSize: 11, color: AppColors.textTertiary),
                ),
                Text(
                  value,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (actionIcon != null && onTapAction != null)
            IconButton(
              icon: Icon(actionIcon, size: 20, color: AppColors.primaryBrand),
              onPressed: onTapAction,
            ),
        ],
      ),
    );
  }

  bool _hasValidPhoto(String? url) {
    return url != null &&
        url.isNotEmpty &&
        url.startsWith('http') &&
        !url.contains('ui-avatars.com');
  }

  Widget _buildSheetInitials(String name) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFEFF6FF),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6366F1),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final TeacherBatchStudent student;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const _StudentCard({
    required this.student,
    required this.onView,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final enrollmentId = student.enrollmentId != null && student.enrollmentId!.isNotEmpty
        ? student.enrollmentId!
        : student.id.toString();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        'ID: $enrollmentId',
                        style: AppTextStyles.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: AppTextStyles.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            student.name,
                            style: AppTextStyles.outfit(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (student.email != null && student.email!.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              student.email!,
                              style: AppTextStyles.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (student.phone != null && student.phone!.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            GestureDetector(
                              onTap: () {
                                final uri = Uri(scheme: 'tel', path: student.phone);
                                launchUrl(uri);
                              },
                              child: Text(
                                student.phone!,
                                style: AppTextStyles.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STANDARD',
                      style: AppTextStyles.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      student.standard?.isNotEmpty == true ? student.standard! : '-',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GUARDIAN',
                      style: AppTextStyles.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      student.guardianName?.isNotEmpty == true ? student.guardianName! : '-',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFFBFDFF),
              border: Border(
                top: BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: onView,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: Color(0xFFFF6B00),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'View',
                          style: AppTextStyles.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFF6B00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final bool hasPhoto = student.profileImageUrl != null &&
        student.profileImageUrl!.isNotEmpty &&
        student.profileImageUrl!.startsWith('http') &&
        !student.profileImageUrl!.contains('ui-avatars.com');

    if (hasPhoto) {
      return CachedNetworkImage(
        imageUrl: student.profileImageUrl!,
        imageBuilder: (context, imageProvider) => Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (context, url) => _buildAvatarInitials(student.name),
        errorWidget: (context, url, error) => _buildAvatarInitials(student.name),
      );
    }
    return _buildAvatarInitials(student.name);
  }

  Widget _buildAvatarInitials(String name) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFFEFF6FF),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6366F1),
        ),
      ),
    );
  }
}
