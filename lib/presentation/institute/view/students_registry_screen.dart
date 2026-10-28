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
import 'package:tuoora/core/services/auth_service.dart';

class StudentsRegistryScreen extends StatefulWidget {
  const StudentsRegistryScreen({super.key});

  @override
  State<StudentsRegistryScreen> createState() => _StudentsRegistryScreenState();
}

class _StudentsRegistryScreenState extends State<StudentsRegistryScreen> {
  final controller = Get.find<InstituteController>();
  final _scrollController = ScrollController();
  Worker? _fillWorker;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // The grid shows many students per screen, so a page may not fill it;
    // with nothing to scroll, load the next page straight away.
    _fillWorker = ever(controller.students, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fillViewport());
    });
    // Fetch on every screen creation so the user sees fresh data each
    // time the registry is opened (not just the first time).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchStudents(reset: true);
    });
  }

  void _fillViewport() {
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent <= 0 &&
        !controller.isLoadingStudents.value &&
        !controller.isLoadMore.value) {
      controller.loadMoreStudents();
    }
  }

  @override
  void dispose() {
    _fillWorker?.dispose();
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
                      final isSearching = controller.searchQuery.value
                          .trim()
                          .isNotEmpty;
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
                        // 3-column grid, same card style as Staff.
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: AppSpacing.x16.add(
                                const EdgeInsets.only(bottom: 16),
                              ),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.8,
                                    ),
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final student = controller.students[index];
                                  return _buildStudentCard(
                                    name: student.name,
                                    id: student.id,
                                    imageUrl: student.imageUrl,
                                  );
                                }, childCount: controller.students.length),
                              ),
                            ),
                            if (controller.isLoadMore.value)
                              const SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                    child: CommonLoading(
                                      size: 20,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                            // Space for the add button.
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 96),
                            ),
                          ],
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
      floatingActionButton: SubscriptionGuard.hideAddOnIOS ||
              !Get.find<AuthService>().can('students.create')
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
            _buildStudentAvatar(imageUrl, name),
            AppSpacing.v8,
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
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
        width: 56,
        height: 56,
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

    final names = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((n) => n.isNotEmpty)
        .toList();
    String initials = '';
    if (names.isNotEmpty) {
      initials += names.first[0].toUpperCase();
      if (names.length > 1) {
        initials += names.last[0].toUpperCase();
      }
    }

    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.primaryBrandLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBrand,
          ),
        ),
      ),
    );
  }
}
