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
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: SizedBox(
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: slots.length,
                    separatorBuilder: (_, _) => AppSpacing.v12,
                    itemBuilder: (context, index) {
                      final slot = slots[index];
                      return _SlotCard(
                        slot: slot,
                        onEdit: () => controller.editSlot(slot),
                        onDelete: () => controller.confirmDeleteSlot(slot),
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

  const _SlotCard({
    required this.slot,
    required this.onEdit,
    required this.onDelete,
  });

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
            width: AppSpacing.s44,
            height: AppSpacing.s44,
            decoration: BoxDecoration(
              color: AppColors.primaryBrand.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.schedule_rounded, color: AppColors.primaryBrand, size: 22),
            ),
          ),
          AppSpacing.h12,
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
                const SizedBox(height: 2),
                Text(
                  '${slot.timeSlot ?? '${slot.startTime} - ${slot.endTime}'}'
                  '${slot.roomNo != null && slot.roomNo!.isNotEmpty ? ' · Room ${slot.roomNo}' : ''}',
                  style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.fieldBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.fieldBorder),
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          AppSpacing.h8,
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.bohoRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.bohoRed.withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 16,
                color: AppColors.bohoRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
