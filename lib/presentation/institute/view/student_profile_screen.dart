import 'package:intl/intl.dart';
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
                          if (student != null &&
                              (student.fees.isNotEmpty ||
                                  ((student.totalFee ?? num.tryParse(student.monthlyFee ?? '0') ?? 0) > 0) ||
                                  student.allInstallments.isNotEmpty)) ...[
                            const SizedBox(height: AppSpacing.s24),
                            _buildFeesSection(context, student),
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

  Widget _buildFeesSection(BuildContext context, Student student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (student.allBatches.length > 1) ...[
          _buildBatchFilterRow(context, student),
          const SizedBox(height: AppSpacing.s12),
        ],
        _buildFeeSummaryCard(student),
        if (student.allInstallments.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s16),
          _buildInstallmentScheduleCard(context, student),
        ],
        if (student.fees.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s16),
          _buildPaymentRecordsCard(student),
        ],
      ],
    );
  }

  Widget _buildBatchFilterRow(BuildContext context, Student student) {
    final activeSelection = controller.selectedProfileBatchId.value?.toString() ??
        student.selectedBatchId?.toString() ??
        student.batchId?.toString() ??
        'all';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.swap_horiz_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'FILTER BY BATCH',
                style: AppTextStyles.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildBatchChip(
                  label: 'All Batches',
                  isSelected: activeSelection == 'all',
                  onTap: () => controller.switchProfileBatch('all'),
                ),
                const SizedBox(width: 8),
                for (final b in student.allBatches) ...[
                  if (b is Map) ...[
                    Builder(
                      builder: (ctx) {
                        final bId = b['id']?.toString() ?? '';
                        final bName = b['name']?.toString() ?? 'Batch';
                        final isCurrent = (student.batchId != null && student.batchId.toString() == bId);
                        final label = isCurrent ? '$bName (Active)' : bName;
                        final isSel = (activeSelection == bId);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildBatchChip(
                            label: label,
                            isSelected: isSel,
                            isCurrentActive: isCurrent,
                            onTap: () => controller.switchProfileBatch(bId),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchChip({
    required String label,
    required bool isSelected,
    bool isCurrentActive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBrand
              : (isCurrentActive ? const Color(0xFFF0FDF4) : AppColors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBrand
                : (isCurrentActive ? const Color(0xFF86EFAC) : AppColors.fieldBorder),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBrand.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check_rounded,
                size: 13,
                color: Colors.white,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isCurrentActive ? const Color(0xFF15803D) : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeSummaryCard(Student student) {
    final totalFeeVal = student.totalFee != null
        ? student.totalFee!.toStringAsFixed(0)
        : (student.monthlyFee != null && student.monthlyFee!.isNotEmpty
            ? student.monthlyFee!
            : '0');

    String feeSubtitle = 'Overview of tuition, installments, and receipts';
    if (student.selectedBatch != null && student.selectedBatch is Map) {
      final bName = student.selectedBatch['name']?.toString() ?? '';
      if (bName.isNotEmpty) {
        feeSubtitle = 'Batch: $bName';
      }
    } else if (controller.selectedProfileBatchId.value == 'all' || student.selectedBatchId == 'all') {
      feeSubtitle = 'All Batches Combined';
    }

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fee Summary & Records',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      feeSubtitle,
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TOTAL FEE',
                        style: AppTextStyles.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹$totalFeeVal',
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TOTAL PAID',
                        style: AppTextStyles.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF047857),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${student.totalPaid.toStringAsFixed(0)}',
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF047857),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'BALANCE DUE',
                        style: AppTextStyles.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFBE123C),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${student.totalDue.toStringAsFixed(0)}',
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE11D48),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildInstallmentScheduleCard(BuildContext context, Student student) {
    final installments = student.allInstallments;
    if (installments.isEmpty) return const SizedBox.shrink();

    final clearedCount = installments.where((i) => i.isPaid).length;
    final totalCount = installments.length;
    final allCleared = clearedCount == totalCount;

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFFEA580C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Installment Schedule',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Batch payment milestones & due dates',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: allCleared ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: allCleared ? const Color(0xFFA7F3D0) : const Color(0xFFFFEDD5),
                  ),
                ),
                child: Text(
                  '$clearedCount of $totalCount Cleared',
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: allCleared ? const Color(0xFF047857) : const Color(0xFFC2410C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              for (var i = 0; i < installments.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _buildMilestoneCard(context, installments[i]),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(BuildContext context, FeeInstallmentModel inst) {
    Color cardBg;
    Color cardBorder;
    Color badgeBg;
    Color badgeText;
    Color badgeBorder;
    String badgeLabel;

    if (inst.isPaid) {
      cardBg = const Color(0xFFF0FDF4);
      cardBorder = const Color(0xFFA7F3D0);
      badgeBg = const Color(0xFFDCFCE7);
      badgeText = const Color(0xFF15803D);
      badgeBorder = const Color(0xFF86EFAC);
      badgeLabel = 'PAID';
    } else if (inst.isPartial) {
      cardBg = const Color(0xFFFFFBEB);
      cardBorder = const Color(0xFFFDE68A);
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = const Color(0xFFB45309);
      badgeBorder = const Color(0xFFFCD34D);
      badgeLabel = 'PARTIAL';
    } else {
      cardBg = const Color(0xFFF8FAFC);
      cardBorder = const Color(0xFFE2E8F0);
      badgeBg = const Color(0xFFFFE4E6);
      badgeText = const Color(0xFFBE123C);
      badgeBorder = const Color(0xFFFECDD3);
      badgeLabel = 'PENDING';
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                inst.title,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeBorder),
                ),
                child: Text(
                  badgeLabel,
                  style: AppTextStyles.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: badgeText,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 5),
              Text(
                'Due Date: ${_formatInstallmentDate(inst.dueDate)}',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total: ₹${inst.amount.toStringAsFixed(0)}',
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (inst.isPartial)
                    Text(
                      'Paid: ₹${inst.paidAmount.toStringAsFixed(0)}',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF059669),
                      ),
                    ),
                ],
              ),
              if (inst.isPaid)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, size: 14, color: Color(0xFF047857)),
                      const SizedBox(width: 4),
                      Text(
                        'Cleared',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Due: ₹${inst.dueAmount.toStringAsFixed(0)}',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: AppColors.primaryBrand,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _showPayInstallmentModal(context, inst),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Pay',
                                style: AppTextStyles.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPayInstallmentModal(BuildContext context, FeeInstallmentModel inst) {
    final amountController = TextEditingController(
      text: inst.dueAmount.toStringAsFixed(inst.dueAmount.truncateToDouble() == inst.dueAmount ? 0 : 2),
    );
    final selectedMethod = 'Cash'.obs;
    final amountError = RxnString();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrandLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      color: AppColors.primaryBrand,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay Installment',
                          style: AppTextStyles.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Record payment for ${inst.title}',
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Outstanding Balance',
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9F1239),
                      ),
                    ),
                    Text(
                      '₹${inst.dueAmount.toStringAsFixed(0)}',
                      style: AppTextStyles.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'AMOUNT TO PAY (₹)',
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBrand,
                  ),
                  hintText: 'Enter amount',
                  errorText: amountError.value,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.fieldBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.fieldBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primaryBrand, width: 1.5),
                  ),
                ),
              )),
              const SizedBox(height: 16),
              Text(
                'PAYMENT METHOD',
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => selectedMethod.value = 'Cash',
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedMethod.value == 'Cash'
                              ? AppColors.primaryBrandLight
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedMethod.value == 'Cash'
                                ? AppColors.primaryBrand
                                : AppColors.fieldBorder,
                            width: selectedMethod.value == 'Cash' ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.money_rounded,
                              size: 18,
                              color: selectedMethod.value == 'Cash'
                                  ? AppColors.primaryBrand
                                  : AppColors.textTertiary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Cash',
                              style: AppTextStyles.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selectedMethod.value == 'Cash'
                                    ? AppColors.primaryBrand
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => selectedMethod.value = 'Online',
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedMethod.value == 'Online'
                              ? AppColors.primaryBrandLight
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedMethod.value == 'Online'
                                ? AppColors.primaryBrand
                                : AppColors.fieldBorder,
                            width: selectedMethod.value == 'Online' ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 18,
                              color: selectedMethod.value == 'Online'
                                  ? AppColors.primaryBrand
                                  : AppColors.textTertiary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Online / UPI',
                              style: AppTextStyles.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selectedMethod.value == 'Online'
                                    ? AppColors.primaryBrand
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(color: AppColors.fieldBorder),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Obx(() {
                      final isPaying = controller.isPayingInstallment.value;
                      return ElevatedButton(
                        onPressed: isPaying
                            ? null
                            : () async {
                                final enteredAmt = double.tryParse(amountController.text.trim());
                                if (enteredAmt == null || enteredAmt <= 0) {
                                  amountError.value = 'Please enter a valid amount';
                                  return;
                                }
                                if (enteredAmt > inst.dueAmount) {
                                  amountError.value = 'Cannot exceed due ₹${inst.dueAmount.toStringAsFixed(0)}';
                                  return;
                                }
                                amountError.value = null;

                                final success = await controller.payInstallment(
                                  inst.id,
                                  amount: enteredAmt,
                                  paymentMethod: selectedMethod.value,
                                );
                                if (success) {
                                  Get.back();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBrand,
                          disabledBackgroundColor: AppColors.primaryBrand.withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isPaying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Confirm Payment',
                                    style: AppTextStyles.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPaymentRecordsCard(Student student) {
    if (student.fees.isEmpty) return const SizedBox.shrink();

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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment & Invoice Records',
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'History of billing statements',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.fieldBorder),
          for (var i = 0; i < student.fees.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.fieldBorder),
            _buildPaymentRecordRow(student.fees[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentRecordRow(StudentFee fee) {
    final isPaid = fee.status.toLowerCase() == 'paid';
    final isPartial = fee.status.toLowerCase() == 'partial';

    Color badgeBg;
    Color badgeText;
    if (isPaid) {
      badgeBg = const Color(0xFFECFDF5);
      badgeText = const Color(0xFF047857);
    } else if (isPartial) {
      badgeBg = const Color(0xFFFFFBEB);
      badgeText = const Color(0xFFB45309);
    } else {
      badgeBg = const Color(0xFFFFF1F2);
      badgeText = const Color(0xFFE11D48);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${fee.totalAmount}',
                  style: AppTextStyles.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fee.date.isNotEmpty ? _formatInstallmentDate(fee.date) : 'Recent Invoice',
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              fee.status.toUpperCase(),
              style: AppTextStyles.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: badgeText,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatInstallmentDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(rawDate);
      return DateFormat('dd MMM, yyyy').format(dt);
    } catch (_) {
      return rawDate;
    }
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
