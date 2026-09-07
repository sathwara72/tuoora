import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/presentation/institute/controllers/batch_details_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/controllers/batch_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/institute_info_row.dart';
import 'package:tuoora/presentation/institute/widgets/institute_metric_card.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:tuoora/core/widgets/status_badge.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class BatchDetailsScreen extends StatefulWidget {
  const BatchDetailsScreen({super.key});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  late BatchDetailsController controller;
  final BatchController batchController = Get.find<BatchController>();

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
                IconButton(
                  onPressed: () {
                    batchController.initEditMode(controller.batch);
                    Get.toNamed(AppRoutes.instituteEditBatch);
                  },
                  icon: const AppActionIcon(asset: AppImages.icEdit),
                ),
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
              Obx(
                () => StatusBadge.fromLabel(
                  controller.isStatusClosed.value
                      ? 'Closed'
                      : batch.statusLabel,
                ),
              ),
              AppSpacing.h12,
              Text(
                'Batch ID: ${batch.id.length > 4 ? batch.id.substring(0, 4) : batch.id}',
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              Obx(() {
                if (controller.isStatusClosed.value) {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
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
                );
              }),
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
          Obx(
            () => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InstituteMetricCard(
                        label: AppStrings.instTotalCollectionLabel,
                        value: '₹${controller.totalExpected.value}',
                      ),
                    ),
                    AppSpacing.h12,
                    Expanded(
                      child: InstituteMetricCard(
                        label: AppStrings.instFeesPaidLabel,
                        value: '₹${controller.totalPaid.value}',
                      ),
                    ),
                  ],
                ),
                AppSpacing.v12,
                SizedBox(
                  width: double.infinity,
                  child: InstituteMetricCard(
                    label: AppStrings.instNavStudents,
                    value: '${controller.studentCount.value}',
                  ),
                ),
              ],
            ),
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
            text: batch.days.join(', '),
          ),
          if (batch.feesLastDate != null &&
              batch.feesLastDate!.trim().isNotEmpty) ...[
            AppSpacing.v12,
            InstituteInfoRow(
              icon: Icons.event_busy_rounded,
              text: 'Fees due by ${batch.feesLastDate}',
            ),
          ],
          if (batch.classroom != null &&
              batch.classroom!.trim().isNotEmpty) ...[
            AppSpacing.v12,
            InstituteInfoRow(
              icon: Icons.location_on_rounded,
              text: batch.classroom!,
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
        ],
      ),
    );
  }

  // Batches created after the time-slot field was removed have empty
  // start/end times, which [Batch.time] renders as a bare " - ". Hide the
  // row entirely rather than show that.
  bool _hasSchedule(String time) {
    final cleaned = time.replaceAll('-', '').trim();
    return cleaned.isNotEmpty;
  }

  static const List<Color> _accentPalette = <Color>[
    AppColors.primaryBrand,
    AppColors.successGreen,
    AppColors.bohoRed,
    AppColors.subjectPhysics,
  ];

  Widget _buildCourseManagementSection() {
    final tiles = <_ManagementTileData>[
      _ManagementTileData(
        svgAsset: AppImages.icBatchStudents,
        title: AppStrings.instNavStudents,
        onTap: () => Get.toNamed(
          AppRoutes.instituteBatchStudents,
          arguments: controller.batch,
        ),
      ),
      _ManagementTileData(
        icon: Icons.school_rounded,
        title: 'Classes',
        onTap: () => Get.toNamed(
          AppRoutes.instituteBatchClasses,
          arguments: controller.batch,
        ),
      ),
      _ManagementTileData(
        icon: Icons.menu_book_rounded,
        title: AppStrings.homework,
        onTap: () => Get.toNamed(
          AppRoutes.instituteBatchHomework,
          arguments: controller.batch,
        ),
      ),
      _ManagementTileData(
        svgAsset: AppImages.icBatchAttendance,
        title: AppStrings.instAttendanceTitle,
        onTap: () => Get.toNamed(
          AppRoutes.instituteMarkAttendance,
          arguments: controller.batch,
        ),
      ),
      _ManagementTileData(
        svgAsset: AppImages.icBatchHomework,
        title: AppStrings.exams,
        onTap: () => Get.toNamed(
          AppRoutes.instituteBatchExams,
          arguments: controller.batch,
        ),
      ),
      _ManagementTileData(
        svgAsset: AppImages.icBatchTimetable,
        title: AppStrings.timetable,
        onTap: () => Get.toNamed(
          AppRoutes.instituteBatchTimetable,
          arguments: controller.batch,
        ),
      ),
      _ManagementTileData(
        svgAsset: AppImages.icBatchResource,
        title: AppStrings.resources,
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
            final accent = _accentPalette[index % _accentPalette.length];
            return _buildManagementTile(
              svgAsset: tile.svgAsset,
              icon: tile.icon,
              title: tile.title,
              onTap: tile.onTap,
              accent: accent,
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

  const _ManagementTileData({
    this.svgAsset,
    this.icon,
    required this.title,
    required this.onTap,
  });
}
