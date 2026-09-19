import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/utils/date_format_utils.dart';
import 'package:tuoora/core/widgets/status_badge.dart';
import 'package:tuoora/presentation/institute/controllers/homework_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/homework_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchHomeworkScreen extends StatefulWidget {
  const BatchHomeworkScreen({super.key});

  @override
  State<BatchHomeworkScreen> createState() => _BatchHomeworkScreenState();
}

class _BatchHomeworkScreenState extends State<BatchHomeworkScreen> {
  late final BatchModel batch;
  late final HomeworkController controller;

  @override
  void initState() {
    super.initState();
    batch = Get.arguments as BatchModel;
    controller = Get.put(HomeworkController(batch), tag: batch.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.instBatchHomeworkTitle,
              onBackTap: () => Get.back(),
            ),
            Padding(
              padding: AppSpacing.x16.add(AppSpacing.y16),
              child: _buildSearchBar(controller),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: () => controller.fetchHomeworks(),
                child: Obx(() {
                  return CommonStateWidget(
                    isLoading: controller.isLoading.value,
                    isEmpty: controller.filteredHomeworks.isEmpty,
                    emptyTitle: controller.searchQuery.value.isNotEmpty
                        ? 'No assignments found'
                        : 'No homework yet',
                    emptySubtitle: controller.searchQuery.value.isNotEmpty
                        ? 'Try searching with a different title'
                        : 'Start by creating a new homework assignment for this batch',
                    emptyIcon: controller.searchQuery.value.isNotEmpty
                        ? Icons.search_off_rounded
                        : Icons.assignment_outlined,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.x16.add(AppSpacing.bottom16),
                      child: Column(
                        children: List.generate(
                          controller.filteredHomeworks.length,
                          (i) => _buildHomeworkItem(
                            controller.filteredHomeworks[i],
                            controller,
                            i,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SubscriptionGuard.hideAddOnIOS
          ? null
          : FloatingActionButton(
              onPressed: () => SubscriptionGuard.runAddAction(
                () => Get.toNamed(
                  AppRoutes.instituteAddHomework,
                  arguments: batch,
                ),
              ),
              backgroundColor: SubscriptionGuard.blocksAdd
                  ? AppColors.textMuted
                  : AppColors.primaryBrand,
              child: const Icon(Icons.add, color: AppColors.white),
            ),
    );
  }

  Widget _buildSearchBar(HomeworkController controller) {
    return AppSearchField(
      hintText: AppStrings.instSearchAssignmentsHint,
      onChanged: (val) => controller.searchQuery.value = val,
    );
  }

  // Same rotating accent palette as the institute dashboard, so the left
  // stripe on each homework card sits in the same visual rhythm as the
  // dashboard and batch-list cards.
  static const List<Color> _stripePalette = <Color>[
    AppColors.instBrandOrange,
    AppColors.successGreen,
    AppColors.orangeTag,
    AppColors.subjectPhysics,
    AppColors.successGreen,
  ];

  Widget _buildHomeworkItem(
    HomeworkModel hw,
    HomeworkController controller,
    int index,
  ) {
    final isActive = hw.isActive;
    final Color stripe = _stripePalette[index % _stripePalette.length];

    final Widget card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: isActive ? AppColors.white : AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: stripe,
              borderRadius: BorderRadius.circular(2),
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
                    Expanded(
                      child: Text(
                        hw.title,
                        style: AppTextStyles.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          // Mute the title on closed homework. Other cues
                          // (tinted background, no shadow, red CLOSED
                          // badge) finish the disabled treatment — we
                          // deliberately don't dim the whole card with
                          // Opacity so the stripe colour stays vivid.
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                    StatusBadge.fromLabel(
                      isActive
                          ? AppStrings.instActiveLabel
                          : AppStrings.instClosedLabel,
                    ),
                  ],
                ),
                AppSpacing.v12,
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    AppSpacing.h8,
                    Text(
                      DateFormatUtils.homeworkDueLabel(
                        hw.dueDate,
                        isActive: isActive,
                      ),
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    AppSpacing.h24,
                    Icon(
                      Icons.people_outline_rounded,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    AppSpacing.h8,
                    Text(
                      '${hw.submittedCount} ${AppStrings.instSubmissionsLabel}',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
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

    // Disabled when closed: just return the card with no GestureDetector
    // wrapper, so the tap is dead. The stripe colour is left at full
    // saturation; the muted title + tinted background + red CLOSED badge
    // do the "disabled" work.
    if (!isActive) return card;

    return GestureDetector(
      onTap: () async {
        final result = await Get.toNamed(
          AppRoutes.instituteHomeworkRating,
          arguments: hw,
        );
        if (result == true) {
          controller.fetchHomeworks();
        }
      },
      child: card,
    );
  }
}
