import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/institute_controller.dart';
import 'package:tuoora/presentation/institute/controllers/student_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentsRegistryScreen extends StatefulWidget {
  const StudentsRegistryScreen({super.key});

  @override
  State<StudentsRegistryScreen> createState() => _StudentsRegistryScreenState();
}

class _StudentsRegistryScreenState extends State<StudentsRegistryScreen> {
  final controller = Get.find<InstituteController>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch on every screen creation so the user sees fresh data each
    // time the registry is opened (not just the first time).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchStudents(reset: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !controller.isLoadingStudents.value &&
        !controller.isLoadMore.value) {
      controller.loadMoreStudents();
    }
  }

  /// Awaits a navigation push then refreshes the registry. Covers the
  /// "go to sub-screen, come back" path that doesn't re-fire initState
  /// (the previous route's State is preserved by the Navigator).
  Future<void> _pushAndRefresh(Future<dynamic>? push) async {
    await push;
    controller.fetchStudents(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                InstituteAppBar(
                  title: AppStrings.instNavStudents,
                  onBackTap: () => Get.back(),
                ),
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: AppSearchField(
                    hintText: AppStrings.instStudentSearchHint,
                    onChanged: controller.onSearchChanged,
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchStudents(reset: true),
                    color: AppColors.primaryBrand,
                    child: Obx(() {
                      final isSearching =
                          controller.searchQuery.value.trim().isNotEmpty;
                      return CommonStateWidget(
                        isLoading: controller.isLoadingStudents.value,
                        isEmpty: controller.students.isEmpty,
                        emptyTitle: isSearching
                            ? 'No students found'
                            : 'No students available',
                        emptySubtitle: isSearching
                            ? 'Try searching with a different name'
                            : 'Start by adding a new student to the registry',
                        emptyIcon: isSearching
                            ? Icons.search_off_rounded
                            : Icons.people_outline_rounded,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: AppSpacing.x16.add(
                            const EdgeInsets.only(bottom: 96),
                          ),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: controller.students.length +
                              (controller.isLoadMore.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == controller.students.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CommonLoading(
                                    size: 20,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            final student = controller.students[index];
                            return Padding(
                              padding: AppSpacing.bottom16,
                              child: _buildStudentCard(
                                name: student.name,
                                id: student.id,
                                grade: student.grade,
                                imageUrl: student.imageUrl,
                              ),
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
        ],
      ),
      floatingActionButton: SubscriptionGuard.hideAddOnIOS
          ? null
          : FloatingActionButton(
              onPressed: () => SubscriptionGuard.runAddAction(
                () => _pushAndRefresh(
                  Get.toNamed(AppRoutes.instituteAddEditStudent),
                ),
              ),
              backgroundColor: SubscriptionGuard.blocksAdd
                  ? AppColors.textMuted
                  : AppColors.primaryBrand,
              child: const Icon(Icons.add, color: AppColors.white, size: 28),
            ),
    );
  }

  Widget _buildStudentCard({
    required String name,
    required int id,
    required String grade,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Get.delete<InstituteStudentController>();
        // Re-fetch the registry when the profile is closed so any
        // edit/delete done over there is reflected back here.
        _pushAndRefresh(
          Get.toNamed(
            AppRoutes.instituteStudentProfile,
            arguments: {
              'studentId': id,
              'student': controller.students.firstWhere((s) => s.id == id),
            },
          ),
        );
      },
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              offset: const Offset(0, AppSpacing.s4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildStudentAvatar(imageUrl, name),
            AppSpacing.h16,
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
                  AppSpacing.v4,
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.school_rounded,
                            size: AppSpacing.s18,
                            color: AppColors.fieldLabel,
                          ),
                          AppSpacing.h4,
                          Text(
                            grade,
                            style: AppTextStyles.outfit(
                              fontSize: AppSpacing.s16,
                              fontWeight: FontWeight.w500,
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
          ],
        ),
      ),
    );
  }

  Widget _buildStudentAvatar(String imageUrl, String name) {
    if (imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.contains('ui-avatars.com')) {
      return Container(
        width: AppSpacing.s64,
        height: AppSpacing.s64,
        decoration: BoxDecoration(
          color: AppColors.primaryBrandLight,
          shape: BoxShape.circle,
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final names = name.trim().split(' ');
    String initials = '';
    if (names.isNotEmpty) {
      initials += names[0][0].toUpperCase();
      if (names.length > 1) {
        initials += names[names.length - 1][0].toUpperCase();
      }
    }

    return Container(
      width: AppSpacing.s64,
      height: AppSpacing.s64,
      decoration: const BoxDecoration(
        color: AppColors.primaryBrandLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBrand,
          ),
        ),
      ),
    );
  }
}
