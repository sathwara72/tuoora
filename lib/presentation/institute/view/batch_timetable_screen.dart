import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/services/auth_service.dart';
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
      floatingActionButton: SubscriptionGuard.hideAddOnIOS || !_canEdit
          ? null
          : FloatingActionButton(
              onPressed: () => _onAddScheduleTap(),
              backgroundColor: SubscriptionGuard.blocksAdd
                  ? AppColors.textMuted
                  : AppColors.primaryBrand,
              child: const Icon(Icons.add, color: AppColors.white),
            ),
    );
  }

  /// Add / edit / delete lectures needs the TimeTable permission (also
  /// reached from Batch Details, not only the dashboard tile).
  bool get _canEdit => Get.find<AuthService>().can('academics.timetable');

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
        // Two cards per row; both cards in a row share the taller height.
        child: Padding(
          padding: AppSpacing.x16,
          child: Column(
            children: [
              for (var i = 0; i < slots.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildSlotCard(slots[i])),
                        const SizedBox(width: 10),
                        Expanded(
                          child: i + 1 < slots.length
                              ? _buildSlotCard(slots[i + 1])
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
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
    final isCancelled = slot.status.toLowerCase() == 'cancelled';
    final accent = isCancelled ? const Color(0xFFE11D48) : AppColors.primaryBrand;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isCancelled ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
        ),
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
          // Day badge + edit / delete
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCancelled ? const Color(0xFFFFE4E6) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  dayText,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isCancelled ? const Color(0xFFBE123C) : const Color(0xFF475569),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              if (_canEdit) ...[
              _slotAction(
                AppImages.icEdit,
                () {
                  controller.startEdit(slot, isLocked: true);
                  Get.toNamed(
                    AppRoutes.instituteAddTimetableSlot,
                    arguments: {
                      'slot': slot,
                      'batch': scopedBatch ?? controller.currentBatch.value,
                    },
                  );
                },
              ),
              const SizedBox(width: 4),
              _slotAction(
                AppImages.icDelete,
                () => controller.deleteSlotWithConfirmation(slot),
              ),
              ],
            ],
          ),
          if (isCancelled) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFDA4AF)),
              ),
              child: Text(
                'CANCELLED',
                style: AppTextStyles.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFBE123C),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),

          // Timing pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCancelled ? const Color(0xFFFFF1F2) : const Color(0xFFFFF4EC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCancelled ? const Color(0xFFFFE4E6) : const Color(0xFFFFD8C2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded, size: 12, color: accent),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    timeDisplay,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Subject
          Text(
            slot.subject,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isCancelled ? const Color(0xFF64748B) : const Color(0xFF0F172A),
              decoration: isCancelled ? TextDecoration.lineThrough : null,
            ),
          ),

          if (scopedBatch == null && slot.batchName != null) ...[
            AppSpacing.v4,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                slot.batchName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],

          // Pushes teacher / room to the bottom so cards in a row line up.
          const Spacer(),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          _slotInfo(
            Icons.person_outline_rounded,
            (slot.staffName != null && slot.staffName!.isNotEmpty)
                ? slot.staffName!
                : 'Teacher Not Assigned',
          ),
          AppSpacing.v4,
          _slotInfo(
            Icons.meeting_room_outlined,
            'Room: ${(slot.roomNo != null && slot.roomNo!.isNotEmpty) ? slot.roomNo! : 'N/A'}',
          ),
        ],
      ),
    );
  }

  Widget _slotAction(String asset, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: AppActionIcon(asset: asset, size: 18),
      ),
    );
  }

  Widget _slotInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}
