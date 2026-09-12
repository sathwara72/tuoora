import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_timetable_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_timetable_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherTimetableScreen extends GetView<TeacherTimetableController> {
  const TeacherTimetableScreen({super.key});

  String _getDayBadgeText(String rawDay) {
    switch (rawDay.toLowerCase()) {
      case 'monday':
        return 'MON';
      case 'tuesday':
        return 'TUE';
      case 'wednesday':
        return 'WED';
      case 'thursday':
        return 'THU';
      case 'friday':
        return 'FRI';
      case 'saturday':
        return 'SAT';
      case 'sunday':
        return 'SUN';
      default:
        return rawDay.length > 3
            ? rawDay.substring(0, 3).toUpperCase()
            : rawDay.toUpperCase();
    }
  }

  String _getFullDayLabel(String rawDay) {
    if (rawDay.isEmpty) return '';
    return rawDay[0].toUpperCase() + rawDay.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const TeacherAppBar(
              title: 'Timetable',
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: controller.fetchTimetable,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSpacing.v12,
                      _buildBatchFilterBar(),
                      AppSpacing.v8,
                      _buildDaySelector(),
                      AppSpacing.v16,
                      _buildSlotsSection(),
                      AppSpacing.v32,
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

  Widget _buildBatchFilterBar() {
    return Obx(() {
      final batches = controller.batches;
      if (batches.isEmpty) return const SizedBox.shrink();

      final selectedBatchId = controller.selectedFilterBatchId.value;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.filter_list_rounded,
                size: 18,
                color: Color(0xFF64748B),
              ),
              AppSpacing.h8,
              Text(
                'Batch:',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              AppSpacing.h8,
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: selectedBatchId,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(
                          'All Batches',
                          style: AppTextStyles.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBrand,
                          ),
                        ),
                      ),
                      ...batches.map((b) {
                        return DropdownMenuItem<int?>(
                          value: b.id,
                          child: Text(
                            b.name,
                            style: AppTextStyles.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: (id) => controller.selectFilterBatch(id),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDaySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: TeacherTimetableController.days.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final day = TeacherTimetableController.days[index];
            return Obx(() {
              final isSelected =
                  controller.selectedDay.value.toLowerCase() == day.toLowerCase();
              return GestureDetector(
                onTap: () => controller.selectDay(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBrand : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBrand
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primaryBrand.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getDayBadgeText(day),
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? AppColors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildSlotsSection() {
    return Obx(() {
      if (controller.isLoading.value && controller.allSlots.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CommonLoading()),
        );
      }

      final slots = controller.slotsForSelectedDay;
      final dayLabel = _getFullDayLabel(controller.selectedDay.value);

      if (slots.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_view_week_rounded,
                size: 56,
                color: AppColors.textTertiary.withValues(alpha: 0.4),
              ),
              AppSpacing.v12,
              Text(
                'No classes scheduled',
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.v4,
              Text(
                'No lecture schedule configured for $dayLabel',
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: AppSpacing.x16,
        child: Column(
          children: slots.map((slot) => _buildSlotCard(slot)).toList(),
        ),
      );
    });
  }

  Widget _buildSlotCard(TeacherTimetableSlot slot) {
    final timeDisplay = slot.timeSlot != null && slot.timeSlot!.isNotEmpty
        ? slot.timeSlot!
        : controller.formatTimeRange(slot.startTime, slot.endTime);
    final dayText = _getDayBadgeText(slot.dayOfWeek);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Day badge & Batch badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  dayText,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (slot.batchName != null && slot.batchName!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Text(
                    slot.batchName!,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.v8,

          // Row 2: Soft orange time pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4EC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD8C2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: AppColors.primaryBrand,
                ),
                const SizedBox(width: 5),
                Text(
                  timeDisplay,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBrand,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.v8,

          // Row 3: Subject Name
          Text(
            slot.subject,
            style: AppTextStyles.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),

          AppSpacing.v8,
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          AppSpacing.v8,

          // Row 4: Faculty / Teacher info
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
              AppSpacing.h8,
              Expanded(
                child: Text(
                  (slot.staffName != null && slot.staffName!.isNotEmpty)
                      ? slot.staffName!
                      : 'Teacher',
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF334155),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (slot.roomNo != null && slot.roomNo!.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.meeting_room_outlined,
                  size: 15,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                Text(
                  'Room ${slot.roomNo}',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
