import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_timetable_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_timetable_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherBatchTimetableScreen extends GetView<TeacherBatchTimetableController> {
  const TeacherBatchTimetableScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(
              title: 'Timetable · ${controller.batch.name}',
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }
                final slots = controller.allSortedSlots;
                if (slots.isEmpty) {
                  return Center(
                    child: Text(
                      'No lecture schedule configured yet.',
                      style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primaryBrand,
                  onRefresh: controller.fetchTimetable,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: slots.length,
                    separatorBuilder: (_, _) => AppSpacing.v12,
                    itemBuilder: (context, index) {
                      final slot = slots[index];
                      return _SlotCard(
                        slot: slot,
                        dayText: _getDayBadgeText(slot.dayOfWeek),
                        timeDisplay: slot.timeSlot != null && slot.timeSlot!.isNotEmpty
                            ? slot.timeSlot!
                            : controller.formatTimeRange(slot.startTime, slot.endTime),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final TeacherTimetableSlot slot;
  final String dayText;
  final String timeDisplay;

  const _SlotCard({
    required this.slot,
    required this.dayText,
    required this.timeDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Row 1: Day badge (TUE, MON, etc.)
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
          AppSpacing.v10,

          // Row 2: Soft orange/brand time pill
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
                  size: 14,
                  color: AppColors.primaryBrand,
                ),
                const SizedBox(width: 6),
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
          AppSpacing.v10,

          // Row 3: Subject Name
          Text(
            slot.subject,
            style: AppTextStyles.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          AppSpacing.v10,

          // Row 4: Faculty info (Teacher Name)
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
                      : 'Faculty Not Assigned',
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF334155),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.v6,

          // Row 5: Room info
          Row(
            children: [
              const Icon(
                Icons.meeting_room_outlined,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
              AppSpacing.h8,
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                    children: [
                      const TextSpan(text: 'Room: '),
                      TextSpan(
                        text: (slot.roomNo != null && slot.roomNo!.isNotEmpty)
                            ? slot.roomNo!
                            : 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
