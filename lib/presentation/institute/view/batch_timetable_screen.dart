import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:tuoora/presentation/institute/controllers/timetable_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/timetable_model.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

class BatchTimetableScreen extends StatefulWidget {
  const BatchTimetableScreen({super.key});

  @override
  State<BatchTimetableScreen> createState() => _BatchTimetableScreenState();
}

typedef TimetableScreen = BatchTimetableScreen;

class _BatchTimetableScreenState extends State<BatchTimetableScreen> {
  late final TimetableController controller;
  BatchModel? scopedBatch;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is BatchModel) {
      scopedBatch = args;
    }

    if (Get.isRegistered<TimetableController>()) {
      controller = Get.find<TimetableController>();
    } else {
      controller = Get.put(TimetableController(scopedBatch));
    }

    controller.initialize(scopedBatch);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: scopedBatch != null
                  ? 'Timetable · ${scopedBatch!.title}'
                  : 'Timetable',
              onBackTap: () => Get.back(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: () => controller.fetchTimetable(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSpacing.v12,
                      // Optional Batch Filter and Day Tabs (only on main timetable)
                      if (scopedBatch == null) ...[
                        _buildBatchFilterBar(),
                        AppSpacing.v8,
                        _buildDaySelector(),
                        AppSpacing.v16,
                      ],

                      // Timetable Slots List
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddScheduleTap(),
        backgroundColor: SubscriptionGuard.blocksAdd
            ? AppColors.textMuted
            : AppColors.primaryBrand,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  void _onAddScheduleTap() {
    SubscriptionGuard.runAddAction(() {
      controller.startCreate(scopedBatch, scopedBatch != null);
      Get.toNamed(
        AppRoutes.instituteAddTimetableSlot,
        arguments: scopedBatch,
      );
    });
  }



  Widget _buildBatchFilterBar() {
    return Obx(() {
      final batches = controller.batchesList;
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
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: selectedBatchId,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
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
                        return DropdownMenuItem<String?>(
                          value: b.id,
                          child: Text(
                            b.title,
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
          itemCount: DayOfWeek.values.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final day = DayOfWeek.values[index];
            return Obx(() {
              final isSelected =
                  controller.selectedDay.value.toLowerCase() ==
                      day.toLowerCase();
              return GestureDetector(
                onTap: () => controller.selectDay(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBrand
                        : AppColors.white,
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
                      DayOfWeek.shortLabelFor(day),
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.white
                            : const Color(0xFF64748B),
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

  Widget _buildSlotsSection() {
    return Obx(() {
      final isMainTimetable = scopedBatch == null;
      final slots = isMainTimetable
          ? controller.slotsForSelectedDay
          : controller.allSortedSlots;

      final emptySubtitle = isMainTimetable
          ? 'Add a lecture slot for ${DayOfWeek.labelFor(controller.selectedDay.value)}'
          : 'No lecture schedule configured yet.\nTap + to add one.';

      return CommonStateWidget(
        isLoading: controller.isLoading.value,
        isEmpty: slots.isEmpty,
        emptyTitle: 'No classes scheduled',
        emptySubtitle: emptySubtitle,
        emptyIcon: Icons.calendar_view_week_rounded,
        child: Padding(
          padding: AppSpacing.x16,
          child: Column(
            children: slots.map((slot) => _buildSlotCard(slot)).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildSlotCard(TimetableSlot slot) {
    final timeDisplay = slot.timeSlot != null && slot.timeSlot!.isNotEmpty
        ? slot.timeSlot!
        : controller.formatTimeRange(slot.startTime, slot.endTime);
    final dayText = _getDayBadgeText(slot.dayOfWeek);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
          // Row 1: Day badge (MON, TUE, etc.) & Action icons (Edit & Delete)
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      controller.startEdit(slot, isLocked: true);
                      Get.toNamed(
                        AppRoutes.instituteAddTimetableSlot,
                        arguments: {
                          'slot': slot,
                          'batch': scopedBatch ?? controller.currentBatch.value,
                        },
                      );
                    },
                    icon: const AppActionIcon(asset: AppImages.icEdit),
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                  ),
                  AppSpacing.h8,
                  IconButton(
                    onPressed: () => controller.deleteSlotWithConfirmation(slot),
                    icon: const AppActionIcon(asset: AppImages.icDelete),
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                  ),
                ],
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

          if (scopedBatch == null && slot.batchName != null) ...[
            AppSpacing.v4,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                slot.batchName!,
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],

          AppSpacing.v8,
          // Row 4: Divider
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          AppSpacing.v8,

          // Row 5: Faculty info
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
                      : 'Teacher Not Assigned',
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
          AppSpacing.v4,

          // Row 6: Room info
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
