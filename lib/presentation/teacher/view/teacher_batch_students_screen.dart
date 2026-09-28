import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_students_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherBatchStudentsScreen
    extends GetView<TeacherBatchStudentsController> {
  const TeacherBatchStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(title: '${controller.batch.name} Students'),
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
                            color: AppColors.textTertiary.withValues(
                              alpha: 0.5,
                            ),
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
                    separatorBuilder: (_, _) => AppSpacing.v12,
                    itemBuilder: (context, index) {
                      final student = list[index];
                      return _StudentCard(
                        student: student,
                        onView: () =>
                            _showStudentDetailsSheet(context, student),
                      );
                    },
                  ),
                );
              }),
            ),
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
              style: AppTextStyles.outfit(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name, enrollment ID, or phone...',
                hintStyle: AppTextStyles.outfit(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => controller.searchQuery.value = '',
                  );
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
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
                Icon(
                  Icons.school_outlined,
                  size: 16,
                  color: AppColors.primaryBrand,
                ),
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

  void _showStudentDetailsSheet(
    BuildContext context,
    TeacherBatchStudent student,
  ) {
    final enrollmentId =
        student.enrollmentId != null && student.enrollmentId!.isNotEmpty
        ? student.enrollmentId!
        : student.id.toString();

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
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
                  style: AppTextStyles.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
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
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                    radius: 36,
                                    backgroundImage: imageProvider,
                                  ),
                              placeholder: (context, url) =>
                                  _buildSheetInitials(student.name),
                              errorWidget: (context, url, error) =>
                                  _buildSheetInitials(student.name),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
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
                          final uri = Uri(
                            scheme: 'mailto',
                            path: student.email,
                          );
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
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
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
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
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
        ? name
              .trim()
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase()
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

  const _StudentCard({required this.student, required this.onView});

  @override
  Widget build(BuildContext context) {
    final enrollmentId =
        student.enrollmentId != null && student.enrollmentId!.isNotEmpty
        ? student.enrollmentId!
        : student.id.toString();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
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
                          if (student.email != null &&
                              student.email!.isNotEmpty) ...[
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
                          if (student.phone != null &&
                              student.phone!.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            GestureDetector(
                              onTap: () {
                                final uri = Uri(
                                  scheme: 'tel',
                                  path: student.phone,
                                );
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
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFFBFDFF),
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: onView,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 2,
                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final bool hasPhoto =
        student.profileImageUrl != null &&
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
        errorWidget: (context, url, error) =>
            _buildAvatarInitials(student.name),
      );
    }
    return _buildAvatarInitials(student.name);
  }

  Widget _buildAvatarInitials(String name) {
    final initials = name.isNotEmpty
        ? name
              .trim()
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase()
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
