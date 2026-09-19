import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/enums/app_enums.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/data/models/daily_update_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/view/create_update_screen.dart';
import 'package:tuoora/presentation/institute/view/in_app_resource_viewer.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/presentation/institute/controllers/updates_controller.dart';
import 'package:intl/intl.dart';

class InstituteUpdatesScreen extends StatelessWidget {
  const InstituteUpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UpdatesController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(title: AppStrings.updates, isRoot: false),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchUpdates(),
                color: AppColors.primaryBrand,
                child: Obx(() {
                  return CommonStateWidget(
                    isLoading: controller.isLoading.value,
                    isEmpty: controller.updatesList.isEmpty,
                    emptyTitle: AppStrings.noUpdatesFound,
                    emptySubtitle:
                        AppStrings.broadcastYourFirstUpdateToStudents,
                    emptyIcon: Icons.campaign_outlined,
                    child: ListView.builder(
                      padding: AppSpacing.screenPaddingTop.add(
                        const EdgeInsets.only(bottom: 96),
                      ),
                      itemCount: controller.updatesList.length,
                      itemBuilder: (context, index) {
                        final update = controller.updatesList[index];

                        Color iconBg;
                        Color iconColor;
                        IconData icon;

                        final category = update.category;
                        switch (category) {
                          case UpdateCategory.Academic:
                            iconBg = AppColors.studentUpdateIconBg;
                            iconColor = AppColors.studentUpdateIconColor;
                            icon = Icons.school_rounded;
                            break;
                          case UpdateCategory.Administrative:
                            iconBg = AppColors.background;
                            iconColor = AppColors.textSecondary;
                            icon = Icons.admin_panel_settings_rounded;
                            break;
                          case UpdateCategory.Emergency:
                            iconBg = AppColors.errorBg;
                            iconColor = AppColors.errorRed;
                            icon = Icons.error_rounded;
                            break;
                          case UpdateCategory.Event:
                            iconBg = AppColors.errorBg;
                            iconColor = AppColors.bohoRed;
                            icon = Icons.celebration_rounded;
                            break;
                          case UpdateCategory.Holiday:
                            iconBg = AppColors.errorBg;
                            iconColor = AppColors.bohoRed;
                            icon = Icons.holiday_village;
                            break;
                          case UpdateCategory.Other:
                            iconBg = AppColors.warningBg;
                            iconColor = AppColors.orangeTag;
                            icon = Icons.campaign_rounded;
                            break;
                        }

                        return _buildTimelineItem(
                          update: update,
                          title: update.topic ?? "No Topic",
                          subtitle: update.description,
                          icon: icon,
                          iconBg: iconBg,
                          iconColor: iconColor,
                          badgeText: update.category.name.toUpperCase(),
                          badgeBg: iconBg,
                          badgeTextColor: iconColor,
                          timeText: update.timeAgo,
                          audienceText: update.audience,
                          dateText: update.createdAt != null
                              ? DateFormat(
                                  'yyyy-dd-MMM',
                                ).format(update.createdAt!)
                              : 'Recent',
                          isLast: index == controller.updatesList.length - 1,
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SubscriptionGuard.hideAddOnIOS
          ? null
          : FloatingActionButton(
              onPressed: () => SubscriptionGuard.runAddAction(
                () => Get.to(() => const CreateUpdateScreen()),
              ),
              backgroundColor: SubscriptionGuard.blocksAdd
                  ? AppColors.textMuted
                  : AppColors.primaryBrand,
              child: const Icon(Icons.add, color: AppColors.white),
            ),
    );
  }

  Widget _buildViewFileButton(DailyUpdate update) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: AppColors.primaryBrandLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          onTap: () => _showUpdateDialog(update),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.attach_file_rounded,
                  size: 14,
                  color: AppColors.primaryBrand,
                ),
                AppSpacing.h8,
                Text(
                  AppStrings.viewFile,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBrand,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Centred details dialog matching the delete dialog's radius/padding.
  // No Confirm / Close-Details buttons — the X icon at the top-right is
  // the only dismissal, per the spec.
  void _showUpdateDialog(DailyUpdate update) {
    CommonDialog.show(
      title: update.topic ?? 'Update',
      showButtons: false,
      showCloseIcon: true,
      onConfirm: () {},
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s10,
                  vertical: AppSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrandLight,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Text(
                  update.category.name.toUpperCase(),
                  style: AppTextStyles.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBrand,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              AppSpacing.h8,
              Text(
                update.createdAt != null
                    ? DateFormat('MMM d, yyyy').format(update.createdAt!)
                    : 'Recent',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          AppSpacing.v16,
          Row(
            children: [
              Text(
                AppStrings.target,
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fieldLabel,
                  letterSpacing: 0.6,
                ),
              ),
              Flexible(
                child: Text(
                  update.audience.toUpperCase(),
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBrand,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.v12,
          Text(
            update.description.isEmpty ? '—' : update.description,
            style: AppTextStyles.outfit(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          if (update.attachment != null &&
              update.attachment!.trim().isNotEmpty) ...[
            AppSpacing.v16,
            Material(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                onTap: () {
                  Get.back();
                  _openAttachment(update);
                },
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBrandLight,
                          borderRadius: BorderRadius.circular(AppSpacing.s8),
                        ),
                        child: const Icon(
                          Icons.attach_file_rounded,
                          color: AppColors.primaryBrand,
                          size: 18,
                        ),
                      ),
                      AppSpacing.h12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.viewFileAttachment,
                              style: AppTextStyles.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppStrings.clickToOpen,
                              style: AppTextStyles.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fieldLabel,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.fieldLabel,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openAttachment(DailyUpdate update) {
    final url = update.attachment;
    if (url == null || url.trim().isEmpty) return;
    final lower = url.toLowerCase();
    final isImage = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
    ].any(lower.endsWith);
    final isVideo = ['.mp4', '.mov', '.m4v', '.webm'].any(lower.endsWith);
    final title = update.topic ?? 'Attachment';
    if (isImage) {
      Get.to(() => InAppResourceViewer.image(url: url, title: title));
    } else if (isVideo) {
      Get.to(() => InAppResourceViewer.video(url: url, title: title));
    } else {
      Get.to(() => InAppResourceViewer.web(url: url, title: title));
    }
  }

  Widget _buildTimelineItem({
    required DailyUpdate update,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
    required String timeText,
    required String audienceText,
    required String dateText,
    bool isLast = false,
  }) {
    final hasAttachment =
        update.attachment != null && update.attachment!.trim().isNotEmpty;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: AppColors.borderGrey,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          AppSpacing.h16,
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.background, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: AppSpacing.cardPadding,
                        decoration: BoxDecoration(
                          color: badgeBg.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.cardRadius,
                          ),
                        ),
                        child: Text(
                          badgeText,
                          style: AppTextStyles.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                      Text(
                        timeText,
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.v12,
                  Text(
                    title,
                    style: AppTextStyles.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle.isNotEmpty && subtitle != title) ...[
                    AppSpacing.v8,
                    Text(
                      subtitle,
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (hasAttachment) ...[
                    AppSpacing.v12,
                    _buildViewFileButton(update),
                  ],
                  AppSpacing.v16,
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_alt_outlined,
                              size: 16,
                              color: AppColors.textMuted.withValues(alpha: 0.8),
                            ),
                            AppSpacing.h8,
                            Expanded(
                              child: Text(
                                audienceText,
                                style: AppTextStyles.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AppColors.textMuted.withValues(alpha: 0.8),
                          ),
                          AppSpacing.h8,
                          Text(
                            dateText,
                            style: AppTextStyles.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
