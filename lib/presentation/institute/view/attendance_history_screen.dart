import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/status_badge.dart';
import 'package:tuoora/presentation/institute/controllers/staff_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:get/get.dart';

class AttendanceHistoryScreen extends GetView<StaffController> {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.globalAttendanceList.isEmpty) {
      controller.fetchGlobalAttendance(page: 1);
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(title: AppStrings.attendanceManagement),
            Expanded(
              child: Obx(() {
                return CommonStateWidget(
                  isLoading: controller.isLoadingGlobalAttendance.value,
                  isEmpty: controller.globalAttendanceList.isEmpty,
                  emptyTitle: AppStrings.noRecordsFound,
                  emptySubtitle: AppStrings.noAttendanceLogsFoundForThis,
                  emptyIcon: Icons.calendar_today_outlined,
                  child: RefreshIndicator(
                    color: AppColors.primaryBrand,
                    onRefresh: () => controller.fetchGlobalAttendance(page: 1),
                    child: ListView.builder(
                      padding: AppSpacing.screenPaddingTop.add(
                        const EdgeInsets.only(bottom: 96),
                      ),
                      itemCount: controller.globalAttendanceList.length,
                      itemBuilder: (context, index) {
                        final attendance =
                            controller.globalAttendanceList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildAttendanceCard(
                            attendance.staff?.fullName ?? 'Unknown Staff',
                            attendance.note ?? '',
                            attendance.status,
                            attendance.staff?.profileUrl ?? '',
                            attendance.date,
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: SubscriptionGuard.hideAddOnIOS
          ? null
          : _buildLogAttendanceButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAttendanceCard(
    String name,
    String remark,
    String status,
    String imageUrl,
    String date,
  ) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.background),
      ),
      child: Row(
        children: [
          _buildStaffAvatar(imageUrl, name, size: 38),
          AppSpacing.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            date,
                            style: AppTextStyles.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge.fromLabel(status),
                  ],
                ),
                if (remark.isNotEmpty) ...[
                  AppSpacing.v4,
                  Text(
                    '"$remark"',
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogAttendanceButton() {
    return FloatingActionButton(
      onPressed: () => SubscriptionGuard.runAddAction(() {
        Get.toNamed(AppRoutes.instituteLogStaffAttendance);
      }),
      backgroundColor: SubscriptionGuard.blocksAdd
          ? AppColors.textMuted
          : AppColors.primaryBrand,
      child: const Icon(Icons.add, color: AppColors.white, size: 32),
    );
  }

  Widget _buildStaffAvatar(String imageUrl, String name, {double size = 48}) {
    if (imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.contains('ui-avatars.com')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primaryBrand.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryBrand.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          getInitials(name),
          style: AppTextStyles.outfit(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBrand,
          ),
        ),
      ),
    );
  }

  String getInitials(String name) {
    if (name.isEmpty) return 'ST';
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = names.length > 1 ? 2 : 1;
    for (var i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0];
      }
    }
    return initials.toUpperCase();
  }
}
