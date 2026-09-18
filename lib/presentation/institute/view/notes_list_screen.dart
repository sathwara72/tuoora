import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/institute/controllers/notes_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/data/models/note_model.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:tuoora/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotesListScreen extends GetView<NotesController> {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Obx(
              () => InstituteAppBar(
                title: controller.isBookmarkView.value
                    ? AppStrings.instBookmarkedNotes
                    : AppStrings.instNotesManagementTitle,
                actions: [
                  IconButton(
                    onPressed: () => controller.toggleBookmarkView(),
                    icon: Icon(
                      controller.isBookmarkView.value
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ],
              ),
            ),
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
                        final notes = controller.filteredNotes;
                        return CommonStateWidget(
                          isLoading:
                              controller.isLoading.value && notes.isEmpty,
                          isEmpty: notes.isEmpty,
                          emptyTitle: controller.isBookmarkView.value
                              ? AppStrings.instNoBookmarkedNotesFound
                              : 'No Notes Found',
                          emptySubtitle: controller.isBookmarkView.value
                              ? AppStrings.instNoBookmarkedNotesSubtitle
                              : 'Start creating notes to keep track of important information.',
                          emptyIcon: controller.isBookmarkView.value
                              ? Icons.bookmark_border_rounded
                              : Icons.note_alt_outlined,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (!controller.isLoading.value &&
                                  scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent) {
                                controller.loadMoreNotes();
                              }
                              return false;
                            },
                            child: RefreshIndicator(
                              color: AppColors.primaryBrand,
                              onRefresh: () => controller.fetchNotes(page: 1),
                              child: ListView.separated(
                                itemCount:
                                    notes.length +
                                    (controller.currentPage.value <
                                            controller.lastPage.value
                                        ? 1
                                        : 0),
                                separatorBuilder: (_, _) => AppSpacing.v10,
                                itemBuilder: (context, index) {
                                  if (index == notes.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CommonLoading(),
                                    );
                                  }
                                  final note = notes[index];
                                  return _buildNoteCard(note);
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
                Get.toNamed(AppRoutes.instituteAddEditNote);
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
      hintText: AppStrings.instSearchNotesHint,
      onChanged: (value) => controller.searchQuery.value = value,
    );
  }

  Widget _buildNoteCard(Note note) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    Color catColor = AppColors.primaryBrand;
    if (note.categoryRelation != null) {
      try {
        catColor = Color(
          int.parse(note.categoryRelation!.color.replaceAll('#', '0xFF')),
        );
      } catch (_) {
        catColor = AppColors.primaryBrand;
      }
    }

    return GestureDetector(
      onTap: () {
        controller.prepareForEdit(note);
        Get.toNamed(AppRoutes.instituteAddEditNote);
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
            if (note.imageUrl != null && note.imageUrl!.isNotEmpty) ...[
              AppNetworkImage(
                url: note.imageUrl!,
                width: double.infinity,
                height: 160,
                borderRadius: BorderRadius.circular(8),
              ),
              AppSpacing.v12,
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: AppTextStyles.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      AppSpacing.v8,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.cardRadius,
                          ),
                          border: Border.all(
                            color: catColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          note.category,
                          style: AppTextStyles.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: catColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.toggleBookmark(note),
                  child: Obx(() {
                    final liveNote = controller.notesList.firstWhere(
                      (n) => n.id == note.id,
                      orElse: () => note,
                    );
                    return Icon(
                      liveNote.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: AppColors.primaryBrand,
                      size: 24,
                    );
                  }),
                ),
              ],
            ),
            AppSpacing.v12,
            Text(
              note.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.outfit(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.v10,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(note.createdAt),
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showDeleteConfirmation(note),
                  child: const AppActionIcon(
                    asset: AppImages.icDelete,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Note note) {
    CommonDialog.showDeleteConfirmation(
      title: AppStrings.instDeleteNoteTitle,
      description: AppStrings.instDeleteNoteConfirm,
      onConfirm: () => controller.deleteNote(note.id),
    );
  }
}
