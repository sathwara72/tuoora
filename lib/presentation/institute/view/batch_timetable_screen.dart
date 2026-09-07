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
                      // Header Card matching web screenshot
                      _buildHeaderCard(),
                      AppSpacing.v16,

                      // Day Selector Tabs (Monday .. Sunday)
                      _buildDayTabs(),
                      AppSpacing.v12,

                      // Optional Batch Filter (when viewing all batches)
                      if (scopedBatch == null) _buildBatchFilterBar(),

                      // Timetable Slots List for the selected day
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
      controller.startCreate(scopedBatch);
      Get.toNamed(
        AppRoutes.instituteAddTimetableSlot,
        arguments: scopedBatch,
      );
    });
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: AppSpacing.x16,
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
      child: Row(
        children: [
          // Orange icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4EC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD8C2)),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primaryBrand,
              size: 24,
            ),
          ),
          AppSpacing.h12,
          // Title & subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timetable',
                  style: AppTextStyles.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scopedBatch != null
                      ? 'Academic schedule for ${scopedBatch!.title}'
                      : 'Academic schedule sheet across all days & batches',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppSpacing.h8,
          // "+ Add Class Schedule" pill button
          InkWell(
            onTap: _onAddScheduleTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: SubscriptionGuard.blocksAdd
                    ? AppColors.textMuted
                    : AppColors.primaryBrand,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBrand.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Add Schedule',
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTabs() {
    final days = DayOfWeek.values;

    return Obx(() {
      final activeDay = controller.selectedDay.value.toLowerCase();

      return SizedBox(
        height: 44,
        child: ListView.separated(
          padding: AppSpacing.x16,
          scrollDirection: Axis.horizontal,
          itemCount: days.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final day = days[index];
            final isSelected = day == activeDay;
            final count = controller.countForDay(day);

            return InkWell(
              onTap: () => controller.selectDay(day),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBrand
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBrand
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBrand.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      day.toUpperCase(),
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF475569),
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ] else if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: AppTextStyles.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
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

  Widget _buildSlotsSection() {
    return Obx(() {
      final daySlots = controller.slotsForSelectedDay;
      final currentDayLabel = DayOfWeek.labelFor(controller.selectedDay.value);

      return CommonStateWidget(
        isLoading: controller.isLoading.value,
        isEmpty: daySlots.isEmpty,
        emptyTitle: 'No classes on $currentDayLabel',
        emptySubtitle: 'No lecture schedule configured for this day.\nTap + Add Schedule to add one.',
        emptyIcon: Icons.calendar_view_week_rounded,
        child: Padding(
          padding: AppSpacing.x16,
          child: Column(
            children: daySlots.map((slot) => _buildSlotCard(slot)).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildSlotCard(TimetableSlot slot) {
    final timeDisplay = slot.timeSlot != null && slot.timeSlot!.isNotEmpty
        ? slot.timeSlot!
        : controller.formatTimeRange(slot.startTime, slot.endTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Time badge & action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Soft orange time pill
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
              // Action buttons (Edit & Delete)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      controller.startEdit(slot);
                      Get.toNamed(
                        AppRoutes.instituteAddTimetableSlot,
                        arguments: {'slot': slot},
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
          AppSpacing.v10,

          // Subject Name
          Text(
            slot.subject,
            style: AppTextStyles.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          AppSpacing.v6,

          // Batch info pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              slot.batchName ?? 'Batch #${slot.batchId}',
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Faculty and room info
          if ((slot.staffName != null && slot.staffName!.isNotEmpty) ||
              (slot.roomNo != null && slot.roomNo!.isNotEmpty)) ...[
            AppSpacing.v10,
            Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15)),
            AppSpacing.v10,
          ],

          if (slot.staffName != null && slot.staffName!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 15,
                  color: Color(0xFF94A3B8),
                ),
                AppSpacing.h6,
                Expanded(
                  child: Text(
                    slot.staffName!,
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          if (slot.roomNo != null && slot.roomNo!.isNotEmpty) ...[
            AppSpacing.v6,
            Row(
              children: [
                const Icon(
                  Icons.meeting_room_outlined,
                  size: 15,
                  color: Color(0xFF94A3B8),
                ),
                AppSpacing.h6,
                Text(
                  'Room: ${slot.roomNo!}',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
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
