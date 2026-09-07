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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(
              title: 'Timetable · ${controller.batch.name}',
              actions: [
                GestureDetector(
                  onTap: controller.addSlot,
                  child: Container(
                    width: AppSpacing.s40,
                    height: AppSpacing.s40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrand,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded, color: AppColors.white),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: AppSpacing.s44,
              child: Obx(
                () => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpacing.x16,
                  children: TeacherBatchTimetableController.days.map((day) {
                    final isSelected = controller.selectedDay.value == day;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.s8),
                      child: GestureDetector(
                        onTap: () => controller.selectDay(day),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryBrand : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryBrand : AppColors.borderGrey,
                            ),
                          ),
                          child: Text(
                            day.substring(0, 3).toUpperCase(),
                            style: AppTextStyles.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            AppSpacing.v12,
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }
                final slots = controller.slotsForSelectedDay;
                if (slots.isEmpty) {
                  return Center(
                    child: Text(
                      'No lectures scheduled.',
                      style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchTimetable,
                  child: ListView.separated(
                    padding: AppSpacing.x16,
                    itemCount: slots.length,
                    separatorBuilder: (_, __) => AppSpacing.v12,
                    itemBuilder: (context, index) {
                      final slot = slots[index];
                      return _SlotCard(
                        slot: slot,
                        onEdit: () => controller.editSlot(slot),
                        onDelete: () => controller.deleteSlot(slot),
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SlotCard({required this.slot, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.s48,
            height: AppSpacing.s48,
            decoration: BoxDecoration(
              color: AppColors.primaryBrand.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.schedule_rounded, color: AppColors.primaryBrand),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${slot.timeSlot ?? '${slot.startTime} - ${slot.endTime}'}'
                  '${slot.roomNo != null && slot.roomNo!.isNotEmpty ? ' · Room ${slot.roomNo}' : ''}',
                  style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textTertiary),
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
