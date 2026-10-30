import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/institute/controllers/batch_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

/// Batch picker behind the dashboard Attendance card, so users with
/// attendance access but no Batches access can still reach Mark Attendance.
class AttendanceBatchesScreen extends StatefulWidget {
  const AttendanceBatchesScreen({super.key});

  @override
  State<AttendanceBatchesScreen> createState() =>
      _AttendanceBatchesScreenState();
}

class _AttendanceBatchesScreenState extends State<AttendanceBatchesScreen> {
  final controller = Get.find<BatchController>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The search text is shared with the Batches screen.
      controller.onBatchSearchChanged('');
      controller.loadBatches(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadBatches(isRefresh: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.instAttendanceTitle,
              onBackTap: () => Get.back(),
            ),
            Padding(
              padding: AppSpacing.screenPadding,
              child: AppSearchField(
                hintText: AppStrings.instBatchSearchHint,
                onChanged: controller.onBatchSearchChanged,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.loadBatches(isRefresh: true),
                color: AppColors.primaryBrand,
                child: Obx(() {
                  final isSearching = controller.batchSearchQuery.value
                      .trim()
                      .isNotEmpty;
                  return CommonStateWidget(
                    isLoading: controller.isLoading.value,
                    isEmpty: controller.batchesList.isEmpty,
                    emptyTitle: 'No Batches Found',
                    emptySubtitle: isSearching
                        ? 'Try searching with a different name.'
                        : 'There are no batches to take attendance for yet.',
                    emptyIcon: isSearching
                        ? Icons.search_off_rounded
                        : Icons.school_outlined,
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.x16.add(
                        const EdgeInsets.only(bottom: 16),
                      ),
                      itemCount:
                          controller.batchesList.length +
                          (controller.isMoreLoading.value ? 1 : 0),
                      separatorBuilder: (context, index) => AppSpacing.v10,
                      itemBuilder: (context, index) {
                        if (index < controller.batchesList.length) {
                          return _buildBatchCard(controller.batchesList[index]);
                        }
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CommonLoading(size: 20, strokeWidth: 2),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchCard(BatchModel batch) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.instituteMarkAttendance, arguments: batch),
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: AppSpacing.s10,
              offset: const Offset(0, AppSpacing.s4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batch.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.v4,
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline_rounded,
                        size: AppSpacing.s16,
                        color: AppColors.fieldLabel,
                      ),
                      AppSpacing.h4,
                      Text(
                        batch.studentCount,
                        style: AppTextStyles.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
