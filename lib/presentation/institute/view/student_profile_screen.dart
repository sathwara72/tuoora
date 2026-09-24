import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/data/models/student_model.dart';
import 'package:tuoora/presentation/institute/controllers/institute_profile_controller.dart';
import 'package:tuoora/presentation/institute/controllers/student_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/services/branding_service.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';

class StudentProfileScreen extends GetView<InstituteStudentController> {
  final bool showBottomNav;
  const StudentProfileScreen({super.key, this.showBottomNav = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            Obx(() {
              final student = controller.currentStudent.value;
              final name = student?.name ?? "";
              final id = student?.enrollmentID.toString() ?? "";
              final imageUrl = student?.imageUrl ?? "";
              final grade = student?.grade ?? '-';
              return Column(
                children: [
                  InstituteAppBar(
                    title: AppStrings.instStudentProfileTitle,
                    actions: [
                      IconButton(
                        tooltip: 'Academic Report',
                        onPressed: () {
                          if (student != null) {
                            Get.toNamed(
                              AppRoutes.instituteStudentWiseReport,
                              arguments: {
                                'studentId': student.id,
                                'studentName': student.name,
                                'batchId': student.batchId,
                              },
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.insights_rounded,
                          color: AppColors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.toNamed(
                          AppRoutes.instituteAddEditStudent,
                          arguments: {
                            'studentId': id,
                            'student': student?.toJson(),
                          },
                        ),
                        icon: const AppActionIcon(asset: AppImages.icEdit),
                      ),
                      IconButton(
                        onPressed: () => _showDeleteConfirmation(context, name),
                        icon: const AppActionIcon(asset: AppImages.icDelete),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: AppSpacing.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildIdCard(
                            name: name,
                            id: id,
                            imageUrl: imageUrl,
                            grade: grade,
                            student: student,
                          ),
                          const SizedBox(height: AppSpacing.s24),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  label: 'Forgot Password',
                                  onPressed: () {
                                    if (student != null) {
                                      controller.sendPassword();
                                    }
                                  },
                                  icon: Icons.email_outlined,
                                  backgroundColor: AppColors.white,
                                  foregroundColor: AppColors
                                      .warningAmber, // It looks a bit more amber/yellow in the image
                                  borderColor: AppColors.warningAmber,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.s14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s16),
                              Expanded(
                                child: AppButton(
                                  label: 'Reset Password',
                                  onPressed: () {
                                    if (student != null) {
                                      _showResetPasswordDialog(
                                        context,
                                        student,
                                      );
                                    }
                                  },
                                  icon: Icons.lock_outline,
                                  backgroundColor: AppColors.white,
                                  foregroundColor:
                                      AppColors.studentProgressBlue,
                                  borderColor: AppColors.studentProgressBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.s14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          _buildAcademicReportCard(student),
                          if (student != null && student.fees.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.s24),
                            _buildFeesSection(student.fees),
                          ],
                          const SizedBox(height: AppSpacing.s24),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
            Obx(
              () => controller.isLoading.value
                  ? Container(
                      color: Colors.black26,
                      child: const CommonLoading(color: AppColors.white),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdCard({
    required String name,
    required String id,
    required String imageUrl,
    required String grade,
    required Student? student,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIdHeader(),
            const SizedBox(height: AppSpacing.s16),
            _buildCircleAvatar(imageUrl: imageUrl, name: name, size: 96),
            const SizedBox(height: AppSpacing.s12),
            _buildNameBlock(name: name, grade: grade),
            const SizedBox(height: AppSpacing.s16),
            _buildInfoTable(id: id, student: student),
            if ((student?.totalDue ?? 0) > 0) ...[
              const SizedBox(height: AppSpacing.s4),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20,
                  0,
                  AppSpacing.s20,
                  AppSpacing.s16,
                ),
                child: _buildFeeReminderButton(student!.totalDue),
              ),
            ] else
              const SizedBox(height: AppSpacing.s16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeReminderButton(num totalDue) {
    return Obx(() {
      final sending = controller.isSendingFeeReminder.value;
      return Material(
        color: sending
            ? AppColors.primaryBrand.withValues(alpha: 0.6)
            : AppColors.primaryBrand,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: InkWell(
          onTap: sending ? null : controller.sendFeeReminder,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s14,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (sending)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.notifications_active_rounded,
                    size: 18,
                    color: AppColors.white,
                  ),
                AppSpacing.h12,
                Text(
                  sending
                      ? 'Sending Reminder...'
                      : 'Send Fee Reminder  •  ₹${totalDue.toStringAsFixed(0)}',
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFeesSection(List<StudentFee> fees) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.cardPadding,
            child: Text(
              AppStrings.feesHistory,
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.fieldLabel,
                letterSpacing: 1.2,
              ),
            ),
          ),
          for (var i = 0; i < fees.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.fieldBorder),
            _buildFeeRow(fees[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildFeeRow(StudentFee fee) {
    final isPaid = fee.status.toLowerCase() == 'paid';
    final badgeColor = isPaid ? AppColors.successGreen : AppColors.bohoRed;
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${fee.totalAmount}',
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fee.date,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s10,
              vertical: AppSpacing.s4,
            ),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Text(
              fee.status.toUpperCase(),
              style: AppTextStyles.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdHeader() {
    String resolvedName = (Get.isRegistered<BrandingService>() ? Get.find<BrandingService>().appName : 'Tuoora') + ' Institute';
    if (Get.isRegistered<InstituteProfileController>()) {
      final v = Get.find<InstituteProfileController>().instituteName.value
          .trim();
      if (v.isNotEmpty) resolvedName = v;
    }
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
          Text(
            resolvedName.toUpperCase(),
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

  Widget _buildNameBlock({required String name, required String grade}) {
    return Column(
      children: [
        Text(
          name.isEmpty ? '—' : name,
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
            'Standard ${grade.isEmpty ? '—' : grade}',
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

  Widget _buildInfoTable({required String id, required Student? student}) {
    final rows = <(String, String)>[
      ('ID No', id.isEmpty ? '—' : id),
      ('DOB', student?.dob ?? 'Not Specified'),
      ('Phone', student?.phone ?? 'Not Available'),
      ('Email', student?.email ?? 'Not Available'),
      ('Parent', student?.guardianName ?? 'Not Specified'),
    ];
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) Divider(height: 1, color: AppColors.fieldBorder),
          _buildIdInfoRow(rows[i].$1, rows[i].$2),
        ],
      ],
    );
  }

  Widget _buildIdInfoRow(String label, String value) {
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.fieldLabel,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Circular avatar with a primary-brand ring. Shows the student's photo
  // when available, otherwise initials on a soft brand background.
  Widget _buildCircleAvatar({
    required String imageUrl,
    required String name,
    required double size,
  }) {
    final bool hasPhoto =
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.contains('ui-avatars.com');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryBrandLight,
        border: Border.all(color: AppColors.primaryBrand, width: 3),
        image: hasPhoto
            ? DecorationImage(
                image: CachedNetworkImageProvider(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasPhoto
          ? null
          : Center(
              child: Text(
                _initialsFor(name),
                style: AppTextStyles.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBrand,
                ),
              ),
            ),
    );
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  void _showResetPasswordDialog(BuildContext context, Student student) {
    final obscurePassword = true.obs;
    final passwordController = TextEditingController();

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s24,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Container(
            padding: AppSpacing.all24,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF), // Very light indigo
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF4F46E5), // Indigo
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reset Student Password',
                            style: AppTextStyles.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'DIRECT PASSWORD UPDATE',
                            style: AppTextStyles.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textTertiary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Description
                Text(
                  'Update the password for ${student.name}. The new password must satisfy the platform password policy.',
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Input Field Label
                Text(
                  'NEW PASSWORD',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                // Input Field
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.fieldBorder),
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: obscurePassword.value,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter secure password',
                        hintStyle: AppTextStyles.outfit(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () => obscurePassword.toggle(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Requirements
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.fieldBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PASSWORD REQUIREMENTS:',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDarkGrey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildRequirementBullet('8 to 15 characters'),
                      _buildRequirementBullet('At least 1 uppercase letter'),
                      _buildRequirementBullet('At least 1 digit (number)'),
                      _buildRequirementBullet(
                        'At least 1 special character (@#\$% etc.)',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceBg,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final password = passwordController.text;
                          if (password.isEmpty) {
                            AppSnackBar.error('Please enter a new password');
                            return;
                          }
                          controller.resetPassword(password);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.studentUpdateIconColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save Password',
                          style: AppTextStyles.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
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
      ),
    );
  }

  Widget _buildRequirementBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String studentName) {
    CommonDialog.showDeleteConfirmation(
      title: AppStrings.deleteStudent,
      description: 'Are you sure you want to delete\n$studentName?',
      onConfirm: () => controller.deleteStudent(),
    );
  }

  Widget _buildAcademicReportCard(Student? student) {
    if (student == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          onTap: () {
            Get.toNamed(
              AppRoutes.instituteStudentWiseReport,
              arguments: {
                'studentId': student.id,
                'studentName': student.name,
                'batchId': student.batchId,
              },
            );
          },
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrandLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: AppColors.primaryBrand,
                    size: 24,
                  ),
                ),
                AppSpacing.h16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Academic Report',
                        style: AppTextStyles.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Attendance, exams, homework & batch history',
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
