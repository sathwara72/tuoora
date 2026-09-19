import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/presentation/institute/controllers/staff_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/data/models/staff_model.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffListScreen extends GetView<StaffController> {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(title: AppStrings.staffManagement),
            Expanded(
              child: Padding(
                padding: AppSpacing.x16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.v16,
                    _buildSearchBar(),
                    AppSpacing.v20,
                    Expanded(
                      child: Obx(() {
                        final staffs = controller.staffList;
                        return CommonStateWidget(
                          isLoading:
                              controller.isLoading.value && staffs.isEmpty,
                          isEmpty: staffs.isEmpty,
                          emptyTitle: AppStrings.noStaffFound,
                          emptySubtitle: controller.searchQuery.value.isEmpty
                              ? 'You haven\'t added any staff members yet.'
                              : 'No staff members match your search.',
                          emptyIcon: Icons.people_outline_rounded,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (!controller.isLoading.value &&
                                  scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent) {
                                controller.loadMoreStaff();
                              }
                              return false;
                            },
                            child: RefreshIndicator(
                              color: AppColors.primaryBrand,
                              onRefresh: () => controller.fetchStaffs(page: 1),
                              child: CustomScrollView(
                                slivers: [
                                  SliverPadding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    sliver: SliverGrid(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 0.8,
                                      ),
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          return _buildStaffCard(staffs[index]);
                                        },
                                        childCount: staffs.length,
                                      ),
                                    ),
                                  ),
                                  if (controller.currentPage.value <
                                      controller.lastPage.value)
                                    const SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 24.0),
                                        child: Center(
                                          child: CommonLoading(),
                                        ),
                                      ),
                                    ),
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 96), // Space for FAB
                                  ),
                                ],
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
                Get.toNamed(AppRoutes.instituteAddEditStaff);
              }),
              backgroundColor: SubscriptionGuard.blocksAdd
                  ? AppColors.textMuted
                  : AppColors.primaryBrand,
              child: const Icon(Icons.add, color: AppColors.white, size: 32),
            ),
    );
  }

  Widget _buildSearchBar() {
    return AppSearchField(
      hintText: AppStrings.searchStaff,
      onChanged: (value) => controller.searchQuery.value = value,
    );
  }

  Widget _buildStaffCard(Staff staff) {
    return GestureDetector(
      onTap: () {
        controller.selectStaff(staff);
        Get.toNamed(AppRoutes.instituteStaffDetails);
      },
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.background),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStaffAvatar(staff.profileUrl ?? '', staff.fullName, size: 60),
            AppSpacing.v8,
            Text(
              staff.fullName,
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
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
