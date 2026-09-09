import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/presentation/institute/controllers/exam_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/exam_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchExamsScreen extends StatefulWidget {
  const BatchExamsScreen({super.key});

  @override
  State<BatchExamsScreen> createState() => _BatchExamsScreenState();
}

class _BatchExamsScreenState extends State<BatchExamsScreen> {
  late final BatchModel batch;
  late final ExamController controller;

  @override
  void initState() {
    super.initState();
    batch = Get.arguments as BatchModel;
    controller = Get.put(ExamController(batch), tag: batch.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.exams,
              onBackTap: () => Get.back(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _buildTabs(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: AppSearchField(
                hintText: 'Search exams',
                onChanged: (val) => controller.searchQuery.value = val,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: () => controller.fetchExams(),
                child: Obx(() {
                  return CommonStateWidget(
                    isLoading: controller.isLoading.value,
                    isEmpty: controller.filteredExams.isEmpty,
                    emptyTitle: controller.searchQuery.value.isNotEmpty
                        ? 'No exams found'
                        : 'No exams yet',
                    emptySubtitle: controller.searchQuery.value.isNotEmpty
                        ? 'Try searching with a different title'
                        : 'Start by scheduling a new exam for this batch',
                    emptyIcon: controller.searchQuery.value.isNotEmpty
                        ? Icons.search_off_rounded
                        : Icons.fact_check_outlined,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: controller.filteredExams.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildExamCard(controller.filteredExams[index]);
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SubscriptionGuard.runAddAction(() {
          controller.startCreate();
          Get.toNamed(AppRoutes.instituteAddExam, arguments: batch.id);
        }),
        backgroundColor: SubscriptionGuard.blocksAdd
            ? AppColors.textMuted
            : AppColors.primaryBrand,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildTabs() {
    return Obx(() {
      final current = controller.selectedTab.value;
      return Row(
        children: [
          _tabPill(index: 0, label: 'All Exams', isSelected: current == 0),
          const SizedBox(width: 8),
          _tabPill(index: 1, label: 'Scheduled', isSelected: current == 1),
          const SizedBox(width: 8),
          _tabPill(index: 2, label: 'Completed', isSelected: current == 2),
        ],
      );
    });
  }

  Widget _tabPill({
    required int index,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.selectedTab.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(ExamModel exam) {
    if (exam.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'COMPLETED',
              style: AppTextStyles.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF059669),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }
    if (exam.isCancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'CANCELLED',
              style: AppTextStyles.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFDC2626),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'SCHEDULED',
            style: AppTextStyles.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2563EB),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(ExamModel exam) {
    final stats = exam.stats;
    final subjectText = (exam.subject != null && exam.subject!.trim().isNotEmpty)
        ? exam.subject!.trim().toUpperCase()
        : exam.examTypeLabel.toUpperCase();

    final enteredStr = stats != null
        ? '${stats.marksEnteredCount}/${stats.totalStudents}'
        : '—';
    final passedStr = stats != null ? '${stats.passedCount}' : '—';
    final avgStr = stats != null
        ? stats.averageMarks.toStringAsFixed(1)
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Subject tag + Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subjectText,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF97316),
                    letterSpacing: 0.8,
                  ),
                ),
                _statusBadge(exam),
              ],
            ),
            const SizedBox(height: 8),

            // Exam Title
            Text(
              exam.title,
              style: AppTextStyles.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // Info row: Date + Marks
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    exam.formattedDate,
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${exam.totalMarks.toStringAsFixed(0)} (Pass: ${exam.passingMarks.toStringAsFixed(0)})',
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stats row: ENTERED, PASSED, AVG
            Row(
              children: [
                Expanded(
                  child: _statMiniBox(
                    label: 'ENTERED',
                    value: enteredStr,
                    valueColor: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statMiniBox(
                    label: 'PASSED',
                    value: passedStr,
                    valueColor: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statMiniBox(
                    label: 'AVG',
                    value: avgStr,
                    valueColor: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bottom action row: [ View / Edit Marks ] [ Edit ] [ Delete ]
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: exam.isScheduled
                        ? () {
                            AppSnackBar.warning(
                              'Marks cannot be added for a scheduled exam. Please complete the exam first.',
                            );
                          }
                        : () async {
                            final result = await Get.toNamed(
                              AppRoutes.instituteExamMarks,
                              arguments: exam,
                            );
                            if (result == true) {
                              controller.fetchExams();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: exam.isScheduled
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF0F172A),
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      exam.isScheduled
                          ? Icons.schedule_rounded
                          : Icons.edit_note_rounded,
                      size: 20,
                    ),
                    label: Text(
                      exam.isScheduled ? 'Exam Scheduled' : 'View / Edit Marks',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Edit icon button
                _iconActionBtn(
                  icon: Icons.edit_outlined,
                  color: const Color(0xFF475569),
                  tooltip: 'Edit Exam',
                  onTap: () async {
                    controller.startEdit(exam);
                    final result = await Get.toNamed(
                      AppRoutes.instituteAddExam,
                      arguments: batch.id,
                    );
                    if (result == true) {
                      controller.fetchExams();
                    }
                  },
                ),
                const SizedBox(width: 8),
                // Delete icon button
                _iconActionBtn(
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFFEF4444),
                  tooltip: 'Delete Exam',
                  onTap: () => controller.deleteExamWithConfirmation(
                    exam,
                    popParent: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statMiniBox({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconActionBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 19, color: color),
        ),
      ),
    );
  }
}
