import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/presentation/institute/models/timetable_model.dart'
    show DayOfWeek;
import 'package:tuoora/presentation/student/controllers/student_timetable_controller.dart';
import 'package:tuoora/presentation/student/models/student_timetable_model.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';

class StudentTimetableScreen extends GetView<StudentTimetableController> {
  const StudentTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const StudentAppBar(
              title: AppStrings.labelTimetable,
              showDefaultActions: false,
            ),
            Padding(
              padding: AppSpacing.x16.add(AppSpacing.y16),
              child: _buildDaySelector(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: controller.loadTimetable,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBrand,
                      ),
                    );
                  }

                  if (controller.slotsForSelectedDay.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        AppEmptyView(
                          icon: Icons.calendar_view_week_rounded,
                          title: 'No lectures scheduled',
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.x16.add(AppSpacing.bottom16),
                    itemCount: controller.slotsForSelectedDay.length,
                    separatorBuilder: (_, __) => AppSpacing.v10,
                    itemBuilder: (context, index) =>
                        _buildSlotCard(controller.slotsForSelectedDay[index]),
                  );
                }),
              ),
            ),
          ],
        ),
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

  Widget _buildSlotCard(StudentTimetableSlot slot) {
    return Container(
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 56,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.v8,
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    AppSpacing.h6,
                    Text(
                      slot.timeSlot ?? '',
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
                        size: 14,
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
                        size: 14,
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
        ],
      ),
    );
  }
}
