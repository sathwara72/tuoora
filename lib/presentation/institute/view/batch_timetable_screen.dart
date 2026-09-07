import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/presentation/institute/controllers/timetable_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/timetable_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchTimetableScreen extends StatefulWidget {
  const BatchTimetableScreen({super.key});

  @override
  State<BatchTimetableScreen> createState() => _BatchTimetableScreenState();
}

class _BatchTimetableScreenState extends State<BatchTimetableScreen> {
  late final BatchModel batch;
  late final TimetableController controller;

  @override
  void initState() {
    super.initState();
    batch = Get.arguments as BatchModel;
    controller = Get.put(TimetableController(batch), tag: batch.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.timetable,
              onBackTap: () => Get.back(),
            ),
            AppSpacing.v12,
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: () => controller.fetchTimetable(),
                child: Obx(() {
                  return CommonStateWidget(
                    isLoading: controller.isLoading.value,
                    isEmpty: controller.slots.isEmpty,
                    emptyTitle: 'No lectures scheduled',
                    emptySubtitle: 'Tap + to add your first lecture slot',
                    emptyIcon: Icons.calendar_view_week_rounded,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.x16.add(AppSpacing.bottom16),
                      child: Column(
                        children: controller.sortedSlots
                            .map((slot) => _buildSlotItem(slot))
                            .toList(),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SubscriptionGuard.runAddAction(() {
          controller.startCreate();
          Get.toNamed(AppRoutes.instituteAddTimetableSlot, arguments: batch.id);
        }),
        backgroundColor: SubscriptionGuard.blocksAdd
            ? AppColors.textMuted
            : AppColors.primaryBrand,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildSlotItem(TimetableSlot slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DayOfWeek.shortLabelFor(slot.dayOfWeek).toUpperCase(),
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      controller.startEdit(slot);
                      Get.toNamed(
                        AppRoutes.instituteAddTimetableSlot,
                        arguments: batch.id,
                      );
                    },
                    icon: const AppActionIcon(asset: AppImages.icEdit),
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                  ),
                  AppSpacing.h8,
                  IconButton(
                    onPressed: () =>
                        controller.deleteSlotWithConfirmation(slot),
                    icon: const AppActionIcon(asset: AppImages.icDelete),
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.v12,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBrandLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: AppColors.primaryBrand,
                ),
                AppSpacing.h6,
                Text(
                  slot.timeSlot ?? '${slot.startTime} - ${slot.endTime}',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBrand,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.v12,
          Text(
            slot.subject,
            style: AppTextStyles.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if ((slot.staffName != null && slot.staffName!.isNotEmpty) ||
              (slot.roomNo != null && slot.roomNo!.isNotEmpty)) ...[
            AppSpacing.v12,
            Divider(height: 1, color: AppColors.background),
            AppSpacing.v12,
          ],
          if (slot.staffName != null && slot.staffName!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                AppSpacing.h8,
                Text(
                  slot.staffName!,
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
          if (slot.roomNo != null && slot.roomNo!.isNotEmpty) ...[
            AppSpacing.v8,
            Row(
              children: [
                const Icon(
                  Icons.meeting_room_outlined,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                AppSpacing.h8,
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Room: ',
                        style: AppTextStyles.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      TextSpan(
                        text: slot.roomNo!,
                        style: AppTextStyles.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
