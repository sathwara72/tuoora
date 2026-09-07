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
            Padding(
              padding: AppSpacing.x16.add(AppSpacing.y16),
              child: _buildDaySelector(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: () => controller.fetchTimetable(),
                child: Obx(() {
                  return CommonStateWidget(
                    isLoading: controller.isLoading.value,
                    isEmpty: controller.slotsForSelectedDay.isEmpty,
                    emptyTitle: 'No lectures scheduled',
                    emptySubtitle:
                        'Add a lecture slot for ${controller.selectedDay.value.isEmpty ? 'this day' : DayOfWeek.labelFor(controller.selectedDay.value)}',
                    emptyIcon: Icons.calendar_view_week_rounded,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.x16.add(AppSpacing.bottom16),
                      child: Column(
                        children: controller.slotsForSelectedDay
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

  Widget _buildDaySelector() {
    return SizedBox(
      height: 64,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: DayOfWeek.values.map((day) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Obx(() {
                final isSelected = controller.selectedDay.value == day;
                return GestureDetector(
                  onTap: () => controller.selectDay(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 56,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBrand
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBrand
                            : AppColors.fieldBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        DayOfWeek.shortLabelFor(day),
                        style: AppTextStyles.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSlotItem(TimetableSlot slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryBrand,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AppSpacing.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.subject,
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.v8,
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 15,
                      color: AppColors.textTertiary,
                    ),
                    AppSpacing.h6,
                    Text(
                      slot.timeSlot ?? '${slot.startTime} - ${slot.endTime}',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                if (slot.staffName != null && slot.staffName!.isNotEmpty) ...[
                  AppSpacing.v6,
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 15,
                        color: AppColors.textTertiary,
                      ),
                      AppSpacing.h6,
                      Text(
                        slot.staffName!,
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (slot.roomNo != null && slot.roomNo!.isNotEmpty) ...[
                  AppSpacing.v6,
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.textTertiary,
                      ),
                      AppSpacing.h6,
                      Text(
                        slot.roomNo!,
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
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
                padding: const EdgeInsets.all(4),
              ),
              AppSpacing.v8,
              IconButton(
                onPressed: () => controller.deleteSlotWithConfirmation(slot),
                icon: const AppActionIcon(asset: AppImages.icDelete),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
