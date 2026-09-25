import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/presentation/institute/controllers/institute_controller.dart';
import 'package:tuoora/presentation/institute/models/fee_record.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InstituteFeesScreen extends GetView<InstituteController> {
  const InstituteFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.instFeesTitle,
              onBackTap: () => Get.back(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.refreshFees(),
                color: AppColors.primaryBrand,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppSpacing.x16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSpacing.v16,
                      Obx(() => _buildSummaryCards(controller)),
                      AppSpacing.v20,
                      Obx(() => _buildRegistryHeader(context, controller)),
                      AppSpacing.v16,
                      Obx(() {
                        if (controller.selectedFeeTab.value == 'pending') {
                          return _buildPendingList(controller);
                        } else {
                          return _buildRegistryList(controller);
                        }
                      }),
                      AppSpacing.v24,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SubscriptionGuard.hideAddOnIOS
          ? null
          : FloatingActionButton(
              heroTag: 'fees_fab_unique_tag',
              onPressed: () => SubscriptionGuard.runAddAction(
                () => Get.toNamed(AppRoutes.instituteRecordFee),
              ),
              backgroundColor: SubscriptionGuard.blocksAdd
                  ? AppColors.textMuted
                  : AppColors.primaryBrand,
              child: const Icon(Icons.add, color: AppColors.white, size: 28),
            ),
    );
  }

  Widget _buildSummaryCards(InstituteController controller) {
    final isPendingTab = controller.selectedFeeTab.value == 'pending';
    final isCollectedTab = !isPendingTab;
    final pendingCount = controller.pendingStudentsCount.value;

    return Row(
      children: [
        // Collected Stat Card
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.selectedFeeTab.value = 'collected';
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                gradient: isCollectedTab
                    ? const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isCollectedTab ? null : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCollectedTab ? Colors.transparent : AppColors.borderGrey,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCollectedTab
                        ? const Color(0xFF4F46E5).withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: isCollectedTab ? 10 : 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'COLLECTED',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isCollectedTab
                              ? AppColors.white.withValues(alpha: 0.8)
                              : AppColors.textTertiary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isCollectedTab
                              ? AppColors.white.withValues(alpha: 0.2)
                              : const Color(0xFFECFDF5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: isCollectedTab ? AppColors.white : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\u20B9',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isCollectedTab ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Pending Stat Card
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.selectedFeeTab.value = 'pending';
              controller.fetchPendingFees();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                gradient: isPendingTab
                    ? const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isPendingTab ? null : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPendingTab ? Colors.transparent : const Color(0xFFFDE68A),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isPendingTab
                        ? const Color(0xFFD97706).withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: isPendingTab ? 10 : 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'PENDING',
                            style: AppTextStyles.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isPendingTab
                                  ? AppColors.white.withValues(alpha: 0.9)
                                  : const Color(0xFFB45309),
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (pendingCount > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: isPendingTab ? AppColors.white.withValues(alpha: 0.25) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '',
                                style: AppTextStyles.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: isPendingTab ? AppColors.white : const Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isPendingTab
                              ? AppColors.white.withValues(alpha: 0.2)
                              : const Color(0xFFFFFBEB),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.schedule,
                          size: 14,
                          color: isPendingTab ? AppColors.white : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\u20B9',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isPendingTab ? AppColors.white : const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistryHeader(BuildContext context, InstituteController controller) {
    final isPending = controller.selectedFeeTab.value == 'pending';

    if (isPending) {
      final count = controller.pendingStudents.length;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Pending Students',
                style: AppTextStyles.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '',
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ],
          ),
          ElevatedButton.icon(
            onPressed: (controller.isSendingReminders.value || count == 0)
                ? null
                : () => _confirmSendAllReminders(context, controller),
            icon: controller.isSendingReminders.value
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded, size: 14),
            label: Text(
              'Remind All',
              style: AppTextStyles.outfit(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.instFeeRegistry,
          style: AppTextStyles.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => controller.downloadFeeReport(),
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.primaryBrand,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: const Icon(Icons.download, color: AppColors.white, size: 24),
          ),
        ),
      ],
    );
  }

  void _confirmSendAllReminders(BuildContext context, InstituteController controller) {
    final count = controller.pendingStudents.length;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active_outlined, color: Color(0xFFD97706), size: 22),
            const SizedBox(width: 8),
            Text(
              'Send Fee Reminders?',
              style: AppTextStyles.outfit(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'This will send in-app and push notification reminders to all $count pending student(s) and their parents.',
          style: AppTextStyles.outfit(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.outfit(color: AppColors.textTertiary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.sendFeeReminderToAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Confirm & Send',
              style: AppTextStyles.outfit(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistryList(InstituteController controller) {
    if (controller.isLoadingFees.value && controller.feeRecords.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(32.0), child: CommonLoading()),
      );
    }

    if (controller.feeRecords.isEmpty) {
      return const AppEmptyView(
        icon: Icons.receipt_long_outlined,
        title: AppStrings.noFeeRecordsFound,
      );
    }

    return Column(
      children: controller.feeRecords.map((record) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s10),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                Get.toNamed(AppRoutes.instituteFeeReceipt, arguments: record),
            child: _buildFeeItem(
              record.student?.name ?? '',
              '\u20B9',
              'ID: ',
              record.date,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPendingList(InstituteController controller) {
    if (controller.isLoadingPendingFees.value && controller.pendingStudents.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(32.0), child: CommonLoading()),
      );
    }

    if (controller.pendingStudents.isEmpty) {
      return const AppEmptyView(
        icon: Icons.check_circle_outline,
        title: 'No Pending Fees',
      );
    }

    return Column(
      children: controller.pendingStudents.map((student) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPendingStudentCard(student, controller),
        );
      }).toList(),
    );
  }

  Widget _buildPendingStudentCard(
    PendingFeeStudent student,
    InstituteController controller,
  ) {
    final initials = student.name.isNotEmpty
        ? student.name.split(' ').where((s) => s.isNotEmpty).map((s) => s[0]).take(2).join('').toUpperCase()
        : '?';

    final hasBroken = student.hasBrokenPromise && student.promise != null;
    final hasPromise = student.promise != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasBroken
              ? const Color(0xFFFCA5A5)
              : (hasPromise ? const Color(0xFF93C5FD) : const Color(0xFFFDE68A)),
          width: hasBroken ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasBroken) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '⚠️ Broken Promise',
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  Text(
                    student.promise!.promiseDate,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (hasPromise) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📅 Will Pay On',
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  Text(
                    student.promise!.promiseDate,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFEF3C7),
                child: Text(
                  initials,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: AppTextStyles.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          student.enrollmentId,
                          style: AppTextStyles.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        if (student.phone.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '• ',
                            style: AppTextStyles.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  student.batchName,
                  style: AppTextStyles.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fee / Paid',
                    style: AppTextStyles.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹ / ₹',
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Pending Due',
                    style: AppTextStyles.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '₹',
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: Obx(() {
                    final isSending = controller.isSendingReminderTo(student.id);
                    return OutlinedButton.icon(
                      onPressed: isSending
                          ? null
                          : () => controller.sendFeeReminderToStudent(student.id, student.name),
                      icon: isSending
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD97706)),
                            )
                          : const Icon(Icons.notifications_active_outlined, size: 15),
                      label: Text(
                        isSending ? 'Sending...' : 'Reminder',
                        style: AppTextStyles.outfit(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB45309),
                        side: const BorderSide(color: Color(0xFFFDE68A)),
                        backgroundColor: const Color(0xFFFFFBEB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: Builder(
                  builder: (btnCtx) => OutlinedButton.icon(
                    onPressed: () => _showPromiseModal(btnCtx, student, controller),
                    icon: const Icon(Icons.event_note_outlined, size: 15),
                    label: Text(
                      'Promise',
                      style: AppTextStyles.outfit(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1D4ED8),
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      backgroundColor: const Color(0xFFEFF6FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItem(
    String name,
    String amount,
    String studentId,
    DateTime date,
  ) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryBrandLight,
            child: Text(
              name.isNotEmpty ? name[0] : '?',
              style: AppTextStyles.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBrand,
              ),
            ),
          ),
          AppSpacing.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      amount,
                      style: AppTextStyles.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                AppSpacing.v4,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      studentId,
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM, yyyy').format(date),
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPromiseModal(
    BuildContext context,
    PendingFeeStudent student,
    InstituteController controller,
  ) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));
    final amountController = TextEditingController(text: student.pendingAmount.toStringAsFixed(0));
    final notesController = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.calendar_month_outlined, color: Color(0xFF2563EB), size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Promise to Pay',
                                style: AppTextStyles.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                student.name,
                                style: AppTextStyles.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Promised Payment Date',
                    style: AppTextStyles.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.background),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd MMM, yyyy').format(selectedDate),
                            style: AppTextStyles.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const Icon(Icons.edit_calendar_outlined, size: 18, color: AppColors.primaryBrand),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Promised Amount (₹)',
                    style: AppTextStyles.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.outfit(fontSize: 13, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.scaffoldBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Notes (Optional)',
                    style: AppTextStyles.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    style: AppTextStyles.outfit(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. Guardian will transfer via UPI',
                      hintStyle: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.scaffoldBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () async {
                        final amt = double.tryParse(amountController.text) ?? student.pendingAmount;
                        final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                        Get.back();
                        await controller.saveFeePromise(
                          studentId: student.id,
                          promiseDate: dateStr,
                          amount: amt,
                          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Save Promise', style: AppTextStyles.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

}
