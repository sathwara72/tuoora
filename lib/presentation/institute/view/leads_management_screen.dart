import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/institute/controllers/leads_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/data/models/lead_model.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeadsManagementScreen extends GetView<LeadsController> {
  const LeadsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(title: AppStrings.instLeadsManagementTitle),
            Expanded(
              child: Padding(
                padding: AppSpacing.x16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.v16,
                    _buildSearchField(),
                    AppSpacing.v20,
                    Expanded(
                      child: Obx(() {
                        return CommonStateWidget(
                          isLoading:
                              controller.isLoading.value &&
                              controller.leadsList.isEmpty,
                          isEmpty: controller.leadsList.isEmpty,
                          emptyTitle: AppStrings.noLeadsFound,
                          emptySubtitle:
                              AppStrings.startAddingLeadsToManageYour,
                          emptyIcon: Icons.leaderboard_outlined,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (!controller.isLoading.value &&
                                  scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent) {
                                controller.loadMoreLeads();
                              }
                              return false;
                            },
                            child: RefreshIndicator(
                              color: AppColors.primaryBrand,
                              onRefresh: () => controller.fetchLeads(page: 1),
                              child: ListView.separated(
                                padding: EdgeInsets.only(bottom: 100),
                                itemCount:
                                    controller.leadsList.length +
                                    (controller.currentPage.value <
                                            controller.lastPage.value
                                        ? 1
                                        : 0),
                                separatorBuilder: (_, _) => AppSpacing.v10,
                                itemBuilder: (context, index) {
                                  if (index == controller.leadsList.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CommonLoading(),
                                    );
                                  }
                                  final lead = controller.leadsList[index];
                                  return _buildLeadCard(lead);
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SubscriptionGuard.hideAddOnIOS
          ? null
          : FloatingActionButton(
              onPressed: () => SubscriptionGuard.runAddAction(() {
                controller.prepareForAdd();
                Get.toNamed(AppRoutes.instituteAddEditLead);
              }),
              backgroundColor: SubscriptionGuard.blocksAdd
                  ? AppColors.textMuted
                  : AppColors.primaryBrand,
              child: const Icon(Icons.add, color: AppColors.white),
            ),
    );
  }

  Widget _buildSearchField() {
    return AppSearchField(
      hintText: AppStrings.instSearchLeadsHint,
      onChanged: (value) => controller.searchQuery.value = value,
    );
  }

  Widget _buildLeadCard(Lead lead) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return GestureDetector(
      onTap: () {
        controller.selectedLead.value = lead;
        Get.toNamed(AppRoutes.instituteLeadDetails);
      },
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryBrandLight,
                  child: Text(
                    lead.fullName.isNotEmpty
                        ? lead.fullName
                              .trim()
                              .split(' ')
                              .map((e) => e.isNotEmpty ? e[0] : '')
                              .join('')
                              .toUpperCase()
                        : '?',
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ),
                AppSpacing.h16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.fullName,
                        style: AppTextStyles.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${AppStrings.instAppliedSuffix} ${dateFormat.format(lead.createdAt)}',
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.v16,
            if (lead.courseSelection != null &&
                lead.courseSelection!.isNotEmpty)
              Row(
                children: [
                  const Icon(
                    Icons.school_rounded,
                    color: AppColors.textTertiary,
                    size: 18,
                  ),
                  AppSpacing.h12,
                  Text(
                    lead.courseSelection!,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            AppSpacing.v8,
            Row(
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
                AppSpacing.h12,
                Text(
                  lead.phone,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            AppSpacing.v16,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () => controller.callLead(lead.phone),
                    icon: Icons.phone,
                    label: AppStrings.instCallBtn,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    borderRadius: 8,
                    fontSize: 14,
                  ),
                ),
                AppSpacing.h12,
                _buildActionBtn(AppImages.icEdit, () {
                  controller.prepareForEdit(lead);
                  Get.toNamed(AppRoutes.instituteAddEditLead);
                }),
                AppSpacing.h12,
                _buildActionBtn(AppImages.icDelete, () {
                  CommonDialog.showDeleteConfirmation(
                    title: AppStrings.deleteLead,
                    description: AppStrings.leadsManagementAreYouSureYouWantTo,
                    onConfirm: () => controller.deleteLead(lead.id),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.all12,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: AppActionIcon(asset: asset, size: 20),
      ),
    );
  }
}
