import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/batch_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:tuoora/core/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';

class BatchesScreen extends StatefulWidget {
  const BatchesScreen({super.key});

  @override
  State<BatchesScreen> createState() => _BatchesScreenState();
}

class _BatchesScreenState extends State<BatchesScreen> {
  final controller = Get.find<BatchController>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadBatches(isRefresh: true);
    });
  }

  Future<void> _pushAndRefresh(Future<dynamic>? push) async {
    await push;
    controller.loadBatches(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadBatches(isRefresh: false);
    }
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
                  title: AppStrings.instNavBatches,
                  onBackTap: () => Get.back(),
                ),
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: AppSearchField(
                    hintText: AppStrings.instBatchSearchHint,
                    onChanged: controller.onBatchSearchChanged,
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.loadBatches(isRefresh: true),
                    color: AppColors.primaryBrand,
                    child: Obx(() {
                      final isSearching = controller.batchSearchQuery.value
                          .trim()
                          .isNotEmpty;
                      return CommonStateWidget(
                        isLoading: controller.isLoading.value,
                        isEmpty: controller.batchesList.isEmpty,
                        emptyTitle: isSearching
                            ? 'No Batches Found'
                            : 'No Batches Found',
                        emptySubtitle: isSearching
                            ? 'Try searching with a different name.'
                            : 'Tap the + button to create your first batch and start managing students.',
                        emptyIcon: isSearching
                            ? Icons.search_off_rounded
                            : Icons.school_outlined,
                        child: ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: AppSpacing.x16.add(
                            const EdgeInsets.only(bottom: 96),
                          ),
                          itemCount:
                              controller.batchesList.length +
                              (controller.isMoreLoading.value ? 1 : 0),
                          separatorBuilder: (context, index) => AppSpacing.v16,
                          itemBuilder: (context, index) {
                            if (index < controller.batchesList.length) {
                              final batch = controller.batchesList[index];
                              return _buildBatchCard(batch, index);
                            } else {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => SubscriptionGuard.runAddAction(() {
          controller.initAddMode();
          _pushAndRefresh(Get.toNamed(AppRoutes.instituteAddBatch));
        }),
        backgroundColor: SubscriptionGuard.blocksAdd
            ? AppColors.textMuted
            : AppColors.primaryBrand,
        child: const Icon(Icons.add, color: AppColors.white, size: 28),
      ),
    );
  }

  static const List<Color> _stripePalette = <Color>[
    AppColors.instBrandOrange,
    AppColors.successGreen,
    AppColors.orangeTag,
    AppColors.subjectPhysics,
    AppColors.successGreen,
  ];

  Widget _buildBatchCard(BatchModel batch, int index) {
    final Color accent = _stripePalette[index % _stripePalette.length];

    return GestureDetector(
      onTap: () => _pushAndRefresh(
        Get.toNamed(AppRoutes.instituteBatchDetails, arguments: batch),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: AppSpacing.s10,
              offset: const Offset(0, AppSpacing.s4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: AppSpacing.s6, color: accent),
                Expanded(
                  child: Padding(
                    padding: AppSpacing.all16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                batch.title,
                                style: AppTextStyles.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            StatusBadge.fromLabel(batch.statusLabel),
                          ],
                        ),
                        if (batch.description.trim().isNotEmpty) ...[
                          AppSpacing.v4,
                          Text(
                            batch.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                        AppSpacing.v12,
                        Row(
                          children: [
                            const Icon(
                              Icons.people_outline_rounded,
                              size: AppSpacing.s18,
                              color: AppColors.fieldLabel,
                            ),
                            AppSpacing.h8,
                            Text(
                              batch.studentCount,
                              style: AppTextStyles.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            AppSpacing.h16,
                            Container(
                              width: AppSpacing.s2,
                              height: AppSpacing.s16,
                              color: AppColors.background,
                            ),
                            AppSpacing.h16,
                            Text(
                              '₹${batch.baseFee.toStringAsFixed(0)}',
                              style: AppTextStyles.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
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
      ),
    );
  }
}
