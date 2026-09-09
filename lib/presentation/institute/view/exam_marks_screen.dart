import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/presentation/institute/controllers/exam_controller.dart';
import 'package:tuoora/presentation/institute/controllers/exam_marks_controller.dart';
import 'package:tuoora/presentation/institute/models/exam_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

class ExamMarksScreen extends StatelessWidget {
  const ExamMarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExamModel exam = Get.arguments as ExamModel;
    final controller = Get.put(ExamMarksController(exam), tag: exam.id);
    final examController = Get.isRegistered<ExamController>(tag: exam.batchId)
        ? Get.find<ExamController>(tag: exam.batchId)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: 'View / Edit Marks',
              onBackTap: () => Get.back(),
              actions: examController == null
                  ? null
                  : [
                      IconButton(
                        onPressed: () async {
                          examController.startEdit(exam);
                          final result = await Get.toNamed(
                            AppRoutes.instituteAddExam,
                            arguments: exam.batchId,
                          );
                          if (result == true) {
                            controller.fetchMarks();
                          }
                        },
                        icon: const AppActionIcon(asset: AppImages.icEdit),
                      ),
                      IconButton(
                        onPressed: () =>
                            examController.deleteExamWithConfirmation(
                          exam,
                          popParent: true,
                        ),
                        icon: const AppActionIcon(asset: AppImages.icDelete),
                      ),
                      AppSpacing.h8,
                    ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBrand,
                    ),
                  );
                }

                final rows = controller.filteredRows;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Header Card with Title, Subject, Date, Total & Passing Marks
                            _buildHeaderCard(exam),
                            const SizedBox(height: 14),

                            // 2. Summary Statistics Row
                            _buildStatsBar(controller),
                            const SizedBox(height: 14),

                            // 3. Search & Bulk Actions Bar
                            _buildQuickActionsBar(controller, exam),
                            const SizedBox(height: 14),

                            // 4. Student Marks List
                            if (rows.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    controller.searchQuery.value.isNotEmpty
                                        ? 'No matching students found'
                                        : 'No students enrolled in this batch',
                                    style: AppTextStyles.outfit(
                                      fontSize: 14,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: rows.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final row = rows[index];
                                  return _buildStudentCard(
                                    controller: controller,
                                    exam: exam,
                                    row: row,
                                    index: index + 1,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    // 5. Sticky Bottom Action Bar
                    _buildBottomBar(controller, exam),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ExamModel exam) {
    final subjectText = (exam.subject != null && exam.subject!.trim().isNotEmpty)
        ? exam.subject!.trim().toUpperCase()
        : exam.examTypeLabel.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                ),
                child: Text(
                  subjectText,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEA580C),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              if (exam.batchName != null && exam.batchName!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Batch: ${exam.batchName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            exam.title,
            style: AppTextStyles.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Date: ${exam.formattedDate} • Total Marks: ${exam.totalMarks.toStringAsFixed(0)} • Passing Marks: ${exam.passingMarks.toStringAsFixed(0)}',
            style: AppTextStyles.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(ExamMarksController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _statBox(
            label: 'TOTAL STUDENTS',
            value: '${controller.totalStudentsCount}',
            valueColor: const Color(0xFF0F172A),
          ),
          const SizedBox(width: 8),
          _statBox(
            label: 'PRESENT',
            value: '${controller.presentStudentsCount}/${controller.totalStudentsCount}',
            valueColor: const Color(0xFF0284C7),
          ),
          const SizedBox(width: 8),
          _statBox(
            label: 'ABSENT',
            value: '${controller.absentStudentsCount}',
            valueColor: const Color(0xFFEA580C),
          ),
          const SizedBox(width: 8),
          _statBox(
            label: 'PASSED',
            value: '${controller.passedStudentsCount}',
            valueColor: const Color(0xFF10B981),
          ),
          const SizedBox(width: 8),
          _statBox(
            label: 'PASS RATE',
            value: '${controller.passRatePercent.toStringAsFixed(0)}%',
            valueColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _statBox({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildQuickActionsBar(ExamMarksController controller, ExamModel exam) {
    return Column(
      children: [
        // Search Input
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            onChanged: (val) => controller.searchQuery.value = val,
            style: AppTextStyles.outfit(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search student by name or ID...',
              hintStyle: AppTextStyles.outfit(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Quick Bulk Actions: Fill Passing Marks, Clear All
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () => controller.fillPassingMarks(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: AppColors.white,
              ),
              icon: const Icon(
                Icons.bolt_rounded,
                size: 16,
                color: Color(0xFF10B981),
              ),
              label: Text(
                'Fill Passing Marks (${exam.passingMarks.toStringAsFixed(0)})',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => controller.clearAllMarks(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: AppColors.white,
              ),
              child: Text(
                'Clear All',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentCard({
    required ExamMarksController controller,
    required ExamModel exam,
    required ExamMarkRow row,
    required int index,
  }) {
    final marksCtrl = controller.marksControllers[row.studentId];
    final remarksCtrl = controller.remarksControllers[row.studentId];
    final isAbsent = row.isAbsent;

    // Calculate pass status & percentage
    final text = marksCtrl?.text.trim() ?? '';
    final marks = isAbsent ? null : double.tryParse(text);
    final percent = (marks != null && exam.totalMarks > 0)
        ? ((marks / exam.totalMarks) * 100).round()
        : null;
    final isPass = (marks != null) ? marks >= exam.passingMarks : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAbsent
              ? const Color(0xFFFED7AA)
              : (isPass == true
                  ? const Color(0xFFA7F3D0)
                  : const Color(0xFFE2E8F0)),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Roll/Index, Avatar/Name/ID, Status Badge
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildStudentAvatar(row.profileImage, row.studentName),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      row.enrollmentId != null &&
                              row.enrollmentId!.trim().isNotEmpty
                          ? 'Enrollment ID: ${row.enrollmentId!.trim()}'
                          : 'ID: ${row.studentId}',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Status Badge
              if (isAbsent)
                _badgePill(
                  label: 'ABSENT',
                  color: const Color(0xFFEA580C),
                  bgColor: const Color(0xFFFFF7ED),
                  borderColor: const Color(0xFFFFEDD5),
                )
              else if (marks != null)
                _badgePill(
                  label: isPass == true ? '● PASS ($percent%)' : '● FAIL ($percent%)',
                  color: isPass == true
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                  bgColor: isPass == true
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF2F2),
                  borderColor: isPass == true
                      ? const Color(0xFFA7F3D0)
                      : const Color(0xFFFECACA),
                )
              else
                _badgePill(
                  label: 'NOT ENTERED',
                  color: const Color(0xFF64748B),
                  bgColor: const Color(0xFFF1F5F9),
                  borderColor: const Color(0xFFE2E8F0),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2: Marks Input Field and Absent Checkbox
          Row(
            children: [
              // Marks Input Field
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MARKS (/${exam.totalMarks.toStringAsFixed(0)})',
                      style: AppTextStyles.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: isAbsent ? const Color(0xFFF1F5F9) : AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isAbsent
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: marksCtrl,
                        enabled: !isAbsent,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        onChanged: (_) => controller.rows.refresh(),
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '0-${exam.totalMarks.toStringAsFixed(0)}',
                          hintStyle: AppTextStyles.outfit(
                            fontSize: 13,
                            color: const Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Absent Checkbox
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'ABSENT',
                    style: AppTextStyles.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => controller.toggleAbsent(
                      row.studentId,
                      !isAbsent,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isAbsent
                            ? const Color(0xFF2563EB)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isAbsent
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isAbsent
                          ? const Icon(
                              Icons.check_rounded,
                              size: 22,
                              color: AppColors.white,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: Remarks Input Field
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: remarksCtrl,
              style: AppTextStyles.outfit(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Good effort, work on numericals...',
                hintStyle: AppTextStyles.outfit(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgePill({
    required String label,
    required Color color,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: AppTextStyles.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStudentAvatar(String? imageUrl, String name) {
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.contains('ui-avatars.com')) {
      return Container(
        width: 38,
        height: 38,
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
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFFFFEDD5),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFEA580C),
        ),
      ),
    );
  }

  Widget _buildBottomBar(ExamMarksController controller, ExamModel exam) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (exam.isScheduled) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Color(0xFFB45309),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This exam is scheduled. Marks can only be entered once the exam is completed.',
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ElevatedButton.icon(
              onPressed: exam.isScheduled
                  ? () => AppSnackBar.warning(
                        'Marks cannot be added for a scheduled exam.',
                      )
                  : (controller.isSaving.value
                      ? null
                      : () => controller.saveMarks()),
              style: ElevatedButton.styleFrom(
                backgroundColor: exam.isScheduled
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFFEA580C),
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: controller.isSaving.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Icon(
                      exam.isScheduled
                          ? Icons.lock_outline_rounded
                          : Icons.check_rounded,
                      size: 20,
                    ),
              label: Text(
                exam.isScheduled
                    ? 'EXAM SCHEDULED (LOCKED)'
                    : (controller.isSaving.value ? 'SAVING...' : 'SAVE ALL MARKS'),
                style: AppTextStyles.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
