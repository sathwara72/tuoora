import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/presentation/institute/controllers/batch_details_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/fee_record.dart';
import 'package:tuoora/presentation/institute/controllers/batch_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/institute_info_row.dart';
import 'package:tuoora/presentation/institute/widgets/institute_metric_card.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:tuoora/core/widgets/status_badge.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/utils/currency_utils.dart';
import 'package:tuoora/core/utils/date_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/services/auth_service.dart';

class BatchDetailsScreen extends StatefulWidget {
  const BatchDetailsScreen({super.key});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  late BatchDetailsController controller;
  final BatchController batchController = Get.find<BatchController>();
  final AuthService _auth = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    final BatchModel batch = Get.arguments;
    controller = Get.put(BatchDetailsController(batch), tag: batch.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.instBatchDetailsTitle,
              actions: [
                if (_auth.can('batches.edit'))
                IconButton(
                  onPressed: () {
                    batchController.initEditMode(controller.batch);
                    Get.toNamed(AppRoutes.instituteEditBatch);
                  },
                  icon: const AppActionIcon(asset: AppImages.icEdit),
                ),
                if (_auth.can('batches.delete'))
                IconButton(
                  onPressed: () => batchController.deleteBatchWithConfirmation(
                    controller.batch.id,
                  ),
                  icon: const AppActionIcon(asset: AppImages.icDelete),
                ),
                AppSpacing.h8,
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.refreshStudents();
                },
                color: AppColors.primaryBrand,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppSpacing.x16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBatchHeader(),
                      AppSpacing.v24,
                      _buildCourseManagementSection(),
                      AppSpacing.v24,
                      _buildBatchReportsSection(),
                      AppSpacing.v24,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchHeader() {
    return Obx(() {
      final batch = controller.batch;
      return Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge.fromLabel(
                  controller.isStatusClosed.value
                      ? 'Closed'
                      : batch.statusLabel,
                ),
                const Spacer(),
                if (!controller.isStatusClosed.value &&
                    _auth.can('batches.edit'))
                  GestureDetector(
                    onTap: () {
                      CommonDialog.show(
                        title: 'Close Batch',
                        description:
                            'Are you sure you want to close this batch? This action cannot be undone.',
                        confirmText: 'Close',
                        icon: Icons.highlight_remove_rounded,
                        iconColor: AppColors.primaryBrand,
                        iconBgColor: AppColors.primaryBrandLight,
                        confirmButtonColor: AppColors.primaryBrand,
                        onConfirm: () {
                          controller.closeBatch();
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.cardRadius,
                        ),
                      ),
                      child: Text(
                        'Close Batch',
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bohoRed,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.v16,
            Text(
              batch.title,
              style: AppTextStyles.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.v8,
            Text(
              batch.description,
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            AppSpacing.v24,
            Row(
              children: [
                // Fee amounts need "Display Total / Pending Fees".
                if (_auth.can('fees.totals')) ...[
                Expanded(
                  child: InstituteMetricCard(
                    label: AppStrings.instTotalCollectionLabel,
                    value: formatRupees(controller.totalExpected.value),
                  ),
                ),
                AppSpacing.h8,
                Expanded(
                  child: InstituteMetricCard(
                    label: AppStrings.instFeesPaidLabel,
                    value: formatRupees(controller.totalPaid.value),
                  ),
                ),
                AppSpacing.h8,
                ],
                Expanded(
                  child: InstituteMetricCard(
                    label: AppStrings.instNavStudents,
                    value: '${controller.studentCount.value}',
                  ),
                ),
              ],
            ),
            AppSpacing.v24,
            if (_hasSchedule(batch.time)) ...[
              InstituteInfoRow(
                icon: Icons.access_time_filled_rounded,
                text: batch.time,
              ),
              AppSpacing.v12,
            ],
            InstituteInfoRow(
              icon: Icons.calendar_month_rounded,
              text: DateFormatUtils.formatDays(batch.days),
            ),
          if (batch.feesLastDate != null &&
              batch.feesLastDate!.trim().isNotEmpty) ...[
            AppSpacing.v12,
            InstituteInfoRow(
              icon: Icons.event_busy_rounded,
              text: 'Fees due by ${batch.feesLastDate}',
            ),
          ],
          if (batch.staffName != null &&
              batch.staffName!.trim().isNotEmpty) ...[
            AppSpacing.v12,
            InstituteInfoRow(
              icon: Icons.person_rounded,
              text: batch.staffName!,
            ),
          ],
          // Owners always have fees.edit.
          if (_auth.can('fees.edit')) ...[
            AppSpacing.v16,
            _buildBatchFeeRow(batch),
          ],
        ],
      ),
    );
  });
}

  /// Batch fee with "Apply to All", which sets every student's fee to it.
  Widget _buildBatchFeeRow(BatchModel batch) {
    final busy = controller.isApplyingBatchFee.value;
    return Container(
      padding: AppSpacing.all12,
      decoration: BoxDecoration(
        color: AppColors.primaryBrandLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.currency_rupee_rounded,
            size: 18,
            color: AppColors.primaryBrand,
          ),
          AppSpacing.h8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Batch Fee',
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  formatRupees(batch.baseFee),
                  style: AppTextStyles.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: busy ? null : () => _confirmApplyBatchFee(batch),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryBrand,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      'Apply to All',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmApplyBatchFee(BatchModel batch) {
    CommonDialog.show(
      title: 'Apply Batch Fee to All?',
      description:
          "Every student's fee in this batch will be set to ${formatRupees(batch.baseFee)}. Students who already paid more than this are skipped.",
      icon: Icons.currency_rupee_rounded,
      iconColor: AppColors.primaryBrand,
      iconBgColor: AppColors.primaryBrandLight,
      confirmText: 'Apply',
      confirmButtonColor: AppColors.primaryBrand,
      onConfirm: () async {
        final result = await controller.applyBatchFeeToAll();
        if (result != null) _showApplyResult(result);
      },
    );
  }

  void _showApplyResult(BatchFeeApplyResult result) {
    CommonDialog.show(
      title: result.skipped.isEmpty ? 'Batch Fee Applied' : 'Applied with Skips',
      description: result.message,
      icon: result.skipped.isEmpty
          ? Icons.check_circle_outline_rounded
          : Icons.info_outline_rounded,
      iconColor: result.skipped.isEmpty
          ? AppColors.greenText
          : AppColors.warningAmber,
      iconBgColor: result.skipped.isEmpty
          ? AppColors.successBg
          : AppColors.warningBg,
      confirmText: 'OK',
      confirmButtonColor: AppColors.primaryBrand,
      showButtons: true,
      body: result.skipped.isEmpty
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Skipped (already paid more than the batch fee):',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                AppSpacing.v8,
                ...result.skipped.map(
                  (s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.name,
                            style: AppTextStyles.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          'Paid ${formatRupees(s.paid)}',
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            color: AppColors.warningAmber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      onConfirm: () {
        if (result.skipped.isNotEmpty) Get.back();
      },
    );
  }

  String _formatAmount(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  // Batches created after the time-slot field was removed have empty
  // start/end times, which [Batch.time] renders as a bare " - ". Hide the
  // row entirely rather than show that.
  bool _hasSchedule(String time) {
    final cleaned = time.replaceAll('-', '').trim();
    return cleaned.isNotEmpty;
  }

  Widget _buildBatchReportsSection() {
    // Report downloads need "View Financial Reports"; the Fee report also
    // shows collection totals, so it needs "Display Total / Pending Fees".
    if (!_auth.can('reports.view')) return const SizedBox.shrink();
    final reports = <(String, String, IconData, Color)>[
      if (_auth.can('fees.totals'))
        ('Fee', 'Fee Report', Icons.payments_rounded, const Color(0xFF10B981)),
      (
        'Attendance',
        'Attendance Report',
        Icons.fact_check_rounded,
        const Color(0xFFB45309),
      ),
      (
        'Performance',
        'Performance Report',
        Icons.trending_up_rounded,
        const Color(0xFF4F46E5),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Batch Reports',
          style: AppTextStyles.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.v12,
        for (final r in reports) ...[
          GestureDetector(
            onTap: () => controller.exportBatchReport(r.$1),
            child: Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                children: [
                  Icon(r.$3, color: r.$4),
                  AppSpacing.h12,
                  Expanded(
                    child: Text(
                      r.$2,
                      style: AppTextStyles.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.file_download_outlined,
                    color: AppColors.primaryBrand,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.v8,
        ],
      ],
    );
  }

  Widget _buildCourseManagementSection() {
    final tiles = <_ManagementTileData>[
      if (_auth.can('academics.timetable'))
      _ManagementTileData(
        svgAsset: AppImages.icBatchTimetable,
        title: AppStrings.timetable,
        accent: const Color(0xFF2563EB), // Blue
        onTap: () => Get.toNamed(
          AppRoutes.instituteBatchTimetable,
          arguments: controller.batch,
        ),
      ),
      if (_auth.canModule('students'))
      _ManagementTileData(
        svgAsset: AppImages.icBatchStudents,
        title: AppStrings.instNavStudents,
        accent: AppColors.primaryBrand,
        onTap: () => Get.toNamed(
          AppRoutes.instituteBatchStudents,
          arguments: controller.batch,
        ),
      ),
      if (_auth.canModule('batches'))
      _ManagementTileData(
        icon: Icons.school_rounded,
        title: 'Subjects',
        accent: const Color(0xFF8B5CF6), // Purple
        onTap: () => Get.toNamed(
          AppRoutes.instituteBatchClasses,
          arguments: controller.batch,
        ),
      ),
      if (_auth.can('academics.exams'))
      _ManagementTileData(
        svgAsset: AppImages.icBatchExam, // Clipboard with checkmark
        title: AppStrings.exams,
        accent: const Color(0xFF4F46E5), // Matched color
        onTap: () => Get.toNamed(
          AppRoutes.instituteBatchExams,
          arguments: controller.batch,
        ),
      ),
      if (_auth.can('academics.homework'))
      _ManagementTileData(
        icon: Icons.menu_book_rounded,
        title: AppStrings.homework,
        accent: AppColors.bohoRed,
        onTap: () => Get.toNamed(
          AppRoutes.instituteBatchHomework,
          arguments: controller.batch,
        ),
      ),
      if (_auth.canModule('attendance'))
      _ManagementTileData(
        svgAsset: AppImages.icBatchAttendance,
        title: AppStrings.instAttendanceTitle,
        accent: const Color(0xFFB45309), // Matched color
        onTap: () => Get.toNamed(
          AppRoutes.instituteMarkAttendance,
          arguments: controller.batch,
        ),
      ),
      if (_auth.canModule('batches'))
      _ManagementTileData(
        svgAsset: AppImages.icBatchResource,
        title: 'Materials',
        accent: const Color(0xFF10B981), // Matched color
        onTap: () => Get.toNamed(
          AppRoutes.instituteBatchResources,
          arguments: controller.batch,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.instCourseManagementHeader,
          style: AppTextStyles.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.v20,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final tile = tiles[index];
            return _buildManagementTile(
              svgAsset: tile.svgAsset,
              icon: tile.icon,
              title: tile.title,
              onTap: tile.onTap,
              accent: tile.accent,
            );
          },
        ),
      ],
    );
  }

  Widget _buildManagementTile({
    String? svgAsset,
    IconData? icon,
    required String title,
    required VoidCallback onTap,
    required Color accent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null
                ? Icon(icon, size: 48, color: accent)
                : SvgPicture.asset(
                    svgAsset!,
                    width: 48,
                    height: 48,
                    theme: SvgTheme(currentColor: accent),
                    colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                  ),
            AppSpacing.v12,
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                textAlign: TextAlign.center,
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementTileData {
  final String? svgAsset;
  final IconData? icon;
  final String title;
  final VoidCallback onTap;
  final Color accent;

  const _ManagementTileData({
    this.svgAsset,
    this.icon,
    required this.title,
    required this.onTap,
    required this.accent,
  });
}
