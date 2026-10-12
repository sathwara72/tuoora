import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_dashboard_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_timetable_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_institute_switcher_sheet.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    // Enforce immediate redirect if must_change_password == true
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authService.currentUser?.mustChangePassword == true) {
        Get.offAllNamed(AppRoutes.teacherChangePassword, arguments: true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Obx(() {
        final user = authService.currentUser;
        // Scrolls only when the content really doesn't fit (small screens /
        // large fonts); otherwise the page stays still.
        return LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, user),
                  _buildTodaySection(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style: AppTextStyles.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        AppSpacing.v12,
                        GridView.count(
                          padding: EdgeInsets.zero,
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: AppSpacing.s12,
                          crossAxisSpacing: AppSpacing.s12,
                          childAspectRatio: 1.45,
                          children: [
                            _DashboardTile(
                              icon: Icons.groups_rounded,
                              label: 'My Batches',
                              subtitle: 'Students, homework & exams',
                              accent: const Color(0xFFF97316),
                              bgColor: const Color(0xFFFFF7ED),
                              onTap: () =>
                                  Get.toNamed(AppRoutes.teacherBatches),
                            ),
                            _DashboardTile(
                              icon: Icons.calendar_month_rounded,
                              label: 'Time Table',
                              subtitle: 'Your weekly schedule',
                              accent: const Color(0xFF2563EB),
                              bgColor: const Color(0xFFEFF6FF),
                              onTap: () =>
                                  Get.toNamed(AppRoutes.teacherTimetable),
                            ),
                            _DashboardTile(
                              icon: Icons.event_available_rounded,
                              label: 'My Attendance',
                              subtitle: 'Check-in & leaves',
                              accent: const Color(0xFF0D9488),
                              bgColor: const Color(0xFFF0FDFA),
                              onTap: () =>
                                  Get.toNamed(AppRoutes.teacherSelfAttendance),
                            ),
                            _DashboardTile(
                              icon: Icons.receipt_long_rounded,
                              label: 'Salary Slips',
                              subtitle: 'Monthly payslips',
                              accent: const Color(0xFF6366F1),
                              bgColor: const Color(0xFFEEF2FF),
                              onTap: () =>
                                  Get.toNamed(AppRoutes.teacherSalaries),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTodaySection() {
    final c = Get.find<TeacherDashboardController>();
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Obx(() {
        final loading = c.isLoading.value;
        final slots = c.orderedSlots;
        final remaining = c.remainingCount;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Today's Classes",
                      style: AppTextStyles.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (!loading && slots.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrand.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        remaining == 0
                            ? 'All done'
                            : '$remaining of ${slots.length} left',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBrand,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (loading)
              const SizedBox(
                height: 100,
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
              )
            else if (slots.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.wb_sunny_rounded,
                          color: Color(0xFF0D9488),
                          size: 22,
                        ),
                      ),
                      AppSpacing.h12,
                      Expanded(
                        child: Text(
                          'No classes scheduled for today. Enjoy your day!',
                          style: AppTextStyles.outfit(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 118,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: slots.length,
                  separatorBuilder: (_, _) => AppSpacing.h12,
                  itemBuilder: (context, i) =>
                      _ClassCard(slot: slots[i], phase: c.phaseOf(slots[i])),
                ),
              ),
          ],
        );
      }),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    // Derived from the (white-label configurable) brand colour.
    final hsl = HSLColor.fromColor(AppColors.primaryBrand);
    final dark = hsl
        .withLightness((hsl.lightness - 0.14).clamp(0.0, 1.0))
        .toColor();
    final name = (user?.name as String?)?.trim() ?? '';
    final instituteName = user?.instituteName as String?;
    final role = user?.staffRole as String?;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 14,
        16,
        20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBrand, dark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrand.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.teacherProfile),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _getInitials(name),
                    style: AppTextStyles.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    Text(
                      name.isEmpty ? 'Teacher' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.outfit(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(
                Icons.calendar_today_rounded,
                DateFormat('EEEE, d MMM').format(DateTime.now()),
              ),
              if (role != null && role.isNotEmpty)
                _pill(Icons.badge_outlined, role),
            ],
          ),
          if (instituteName != null && instituteName.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.apartment_rounded,
                    size: 20,
                    color: AppColors.white,
                  ),
                  AppSpacing.h10,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACTIVE INSTITUTE',
                          style: AppTextStyles.outfit(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            color: AppColors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        Text(
                          instituteName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (user?.hasMultipleInstitutes == true)
                    InkWell(
                      onTap: () => TeacherInstituteSwitcherSheet.show(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.swap_horiz_rounded,
                              size: 16,
                              color: AppColors.primaryBrand,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Switch',
                              style: AppTextStyles.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBrand,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTextStyles.outfit(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'TM';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      return '$first$second'.toUpperCase();
    }
    final single = parts[0];
    return single.substring(0, single.length >= 2 ? 2 : 1).toUpperCase();
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accent;
  final Color bgColor;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accent,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 18,
                  color: accent.withValues(alpha: 0.6),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final TeacherTimetableSlot slot;
  final ClassPhase phase;

  const _ClassCard({required this.slot, required this.phase});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (phase) {
      case ClassPhase.ongoing:
        color = const Color(0xFF16A34A);
        label = 'Ongoing';
      case ClassPhase.upcoming:
        color = AppColors.primaryBrand;
        label = 'Upcoming';
      case ClassPhase.done:
        color = AppColors.textTertiary;
        label = 'Done';
    }
    final isDone = phase == ClassPhase.done;
    final time =
        '${TeacherDashboardController.formatTime(slot.startTime)} - '
        '${TeacherDashboardController.formatTime(slot.endTime)}';
    final where = [
      if (slot.batchName != null && slot.batchName!.isNotEmpty) slot.batchName!,
      if (slot.roomNo != null && slot.roomNo!.isNotEmpty) 'Room ${slot.roomNo}',
    ].join(' · ');

    return Opacity(
      opacity: isDone ? 0.6 : 1,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: phase == ClassPhase.ongoing
                ? color.withValues(alpha: 0.5)
                : const Color(0xFFF1F5F9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDone ? 0.03 : 0.10),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Row(
            children: [
              Container(width: 6, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: color,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              time,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              label,
                              style: AppTextStyles.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        slot.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.groups_rounded,
                            size: 15,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              where.isEmpty ? 'Class' : where,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.outfit(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
