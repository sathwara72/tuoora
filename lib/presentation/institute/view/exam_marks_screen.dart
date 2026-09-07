import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:tuoora/presentation/institute/controllers/exam_controller.dart';
import 'package:tuoora/presentation/institute/controllers/exam_marks_controller.dart';
import 'package:tuoora/presentation/institute/models/exam_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/institute_bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: 'Exam Marks',
              onBackTap: () => Get.back(),
              actions: examController == null
                  ? null
                  : [
                      IconButton(
                        onPressed: () {
                          examController.startEdit(exam);
                          Get.toNamed(
                            AppRoutes.instituteAddExam,
                            arguments: exam.batchId,
                          );
                        },
                        icon: const AppActionIcon(asset: AppImages.icEdit),
                      ),
                      IconButton(
                        onPressed: () =>
                            examController.deleteExamWithConfirmation(exam),
                        icon: const AppActionIcon(asset: AppImages.icDelete),
                      ),
                      AppSpacing.h8,
                    ],
            ),
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBrand,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: AppSpacing.x16.add(AppSpacing.y16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(exam),
                            AppSpacing.v24,
                            if (controller.stats.value != null) ...[
                              _buildStatsSection(controller.stats.value!),
                              AppSpacing.v24,
                            ],
                            Column(
                              children: controller.rows
                                  .map(
                                    (row) => _buildStudentMarkCard(
                                      controller,
                                      exam,
                                      row,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value || controller.rows.isEmpty) {
          return const SizedBox.shrink();
        }
        return InstituteBottomButton(
          label: 'Save Marks',
          icon: Icons.check_circle_rounded,
          isLoading: controller.isSaving.value,
          onTap: () => controller.saveMarks(),
        );
      }),
    );
  }

  Widget _buildHeader(ExamModel exam) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              (exam.subject ?? exam.examTypeLabel).toUpperCase(),
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBrandLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                exam.examTypeLabel.toUpperCase(),
                style: AppTextStyles.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrand,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.v8,
        Text(
          exam.title,
          style: AppTextStyles.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.v8,
        Text(
          '${exam.formattedDate} · Total ${exam.totalMarks.toStringAsFixed(0)} · Pass ${exam.passingMarks.toStringAsFixed(0)}',
          style: AppTextStyles.outfit(
            fontSize: 14,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(ExamStats stats) {
    return Container(
      padding: AppSpacing.all20,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successBg),
      ),
      child: Row(
        children: [
          _statTile('${stats.presentCount}/${stats.totalStudents}', 'Present'),
          _statTile(stats.averageMarks.toStringAsFixed(1), 'Average'),
          _statTile(stats.highestMarks?.toStringAsFixed(0) ?? '—', 'Highest'),
          _statTile('${stats.passPercentage.toStringAsFixed(0)}%', 'Pass %'),
        ],
      ),
    );
  }

  Widget _statTile(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.v4,
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentMarkCard(
    ExamMarksController controller,
    ExamModel exam,
    ExamMarkRow row,
  ) {
    final isAbsent = row.isAbsent;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStudentAvatar(row.profileImage, row.studentName),
              AppSpacing.h16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.studentName,
                      style: AppTextStyles.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (row.enrollmentId != null &&
                        row.enrollmentId!.isNotEmpty)
                      Text(
                        'ID: ${row.enrollmentId}',
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => controller.toggleAbsent(row.studentId, !isAbsent),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isAbsent ? AppColors.errorBg : AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Absent',
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAbsent
                          ? AppColors.error
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!isAbsent) ...[
            AppSpacing.v12,
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.marksControllers[row.studentId],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.fieldBg,
                      hintText: 'Marks obtained',
                      suffixText: '/ ${exam.totalMarks.toStringAsFixed(0)}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    style: AppTextStyles.outfit(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentAvatar(String? imageUrl, String name) {
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.contains('ui-avatars.com')) {
      return Container(
        width: 44,
        height: 44,
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
      if (names.length > 1)
        initials += names[names.length - 1][0].toUpperCase();
    }

    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.primaryBrandLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBrand,
          ),
        ),
      ),
    );
  }
}
