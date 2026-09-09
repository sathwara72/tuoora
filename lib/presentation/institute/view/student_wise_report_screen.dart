import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/institute/controllers/reports_controller.dart';
import 'package:tuoora/presentation/institute/models/report_models.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

class StudentWiseReportScreen extends StatefulWidget {
  const StudentWiseReportScreen({super.key});

  @override
  State<StudentWiseReportScreen> createState() =>
      _StudentWiseReportScreenState();
}

class _StudentWiseReportScreenState extends State<StudentWiseReportScreen> {
  final ReportsController controller = Get.find<ReportsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initStudentWiseReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: 'Student Wise Report',
              onBackTap: () => Get.back(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: () async {
                  final s = controller.selectedStudentForReport.value;
                  if (s != null) {
                    await controller.selectStudentForReport(s);
                  } else {
                    await controller.initStudentWiseReport();
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppSpacing.all16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFilterSection(),
                      AppSpacing.v16,
                      Obx(() {
                        if (controller.isStudentReportLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CommonLoading(),
                          );
                        }

                        final report = controller.studentWiseReport.value;
                        if (report == null) {
                          return const AppEmptyView(
                            icon: Icons.person_search_rounded,
                            title: 'No Student Report Selected',
                            message:
                                'Please select a batch and student from the dropdowns above to view their report.',
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildStudentSummaryCard(report),
                            AppSpacing.v16,
                            _buildFeeBalanceCard(report),
                            AppSpacing.v20,
                            _buildTabBar(report),
                            AppSpacing.v16,
                            _buildTabContent(report),
                            AppSpacing.v32,
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FILTERS (Batch & Student Pickers) ---
  Widget _buildFilterSection() {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Batch Selector
          Text(
            'SELECT BATCH',
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.fieldLabel,
            ),
          ),
          AppSpacing.v8,
          Obx(() {
            final selectedBatch =
                controller.selectedBatchForStudentReport.value;
            return GestureDetector(
              onTap: _showBatchPickerSheet,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    AppSpacing.h12,
                    Expanded(
                      child: Text(
                        selectedBatch?.title ?? 'Select a batch',
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selectedBatch != null
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.fieldLabel,
                    ),
                  ],
                ),
              ),
            );
          }),
          AppSpacing.v16,

          // Student Selector
          Text(
            'SELECT STUDENT',
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.fieldLabel,
            ),
          ),
          AppSpacing.v8,
          Obx(() {
            if (controller.isBatchStudentsLoading.value) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: const CommonLoading(size: 20, strokeWidth: 2),
              );
            }
            final selectedStudent =
                controller.selectedStudentForReport.value;
            return GestureDetector(
              onTap: controller.batchStudentsForReport.isEmpty
                  ? null
                  : _showStudentPickerSheet,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    AppSpacing.h12,
                    Expanded(
                      child: Text(
                        selectedStudent != null
                            ? '${selectedStudent.name} (${selectedStudent.enrollmentId})'
                            : (controller.batchStudentsForReport.isEmpty
                                  ? 'No students found in this batch'
                                  : 'Select a student'),
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selectedStudent != null
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.fieldLabel,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- STUDENT SUMMARY CARD (Matching Image 2) ---
  Widget _buildStudentSummaryCard(StudentWiseReportData report) {
    final student = report.student;
    final initials = student.name.trim().isNotEmpty
        ? student.name
            .trim()
            .split(' ')
            .take(2)
            .map((s) => s.isNotEmpty ? s[0].toUpperCase() : '')
            .join()
        : 'ST';

    final paymentStatus = report.financial.feeStatus;
    final isPaid = paymentStatus.toLowerCase().contains('full') ||
        paymentStatus.toLowerCase().contains('paid');

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD0E1FD),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: AppTextStyles.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: AppTextStyles.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.v2,
                    Text(
                      'ENROLLMENT ID: ${student.enrollmentId}',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.v16,

          // Stat Pills (AVG GRADE, PAYMENT STATUS, ATTENDANCE, EXAMS)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatBadge(
                  label: 'AVG GRADE',
                  value: '${report.homework.averageGrade}/10',
                  color: AppColors.textPrimary,
                  bgColor: AppColors.fieldBg,
                ),
                AppSpacing.h8,
                _buildStatBadge(
                  label: 'PAYMENT STATUS',
                  value: paymentStatus,
                  color: isPaid
                      ? AppColors.successGreen
                      : (paymentStatus.toLowerCase().contains('part')
                            ? AppColors.warningAmber
                            : AppColors.bohoRed),
                  bgColor: isPaid
                      ? AppColors.successGreen.withValues(alpha: 0.1)
                      : (paymentStatus.toLowerCase().contains('part')
                            ? AppColors.warningAmber.withValues(alpha: 0.1)
                            : AppColors.bohoRed.withValues(alpha: 0.1)),
                ),
                AppSpacing.h8,
                _buildStatBadge(
                  label: 'ATTENDANCE',
                  value: '${report.attendance.percentage}%',
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                ),
                AppSpacing.h8,
                _buildStatBadge(
                  label: 'EXAMS',
                  value: '${report.exams.totalExams}',
                  color: const Color(0xFF7C3AED),
                  bgColor: const Color(0xFFF5F3FF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 0.4,
            ),
          ),
          AppSpacing.v2,
          Text(
            value,
            style: AppTextStyles.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // --- FEE BALANCE CARD (Matching Image 2) ---
  Widget _buildFeeBalanceCard(StudentWiseReportData report) {
    final balance = report.financial.balance;
    final total = report.financial.monthlyFee;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: Color(0xFF3B82F6),
              ),
              AppSpacing.h6,
              Text(
                'FEE BALANCE',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          AppSpacing.v12,
          Text(
            'PENDING AMOUNT',
            style: AppTextStyles.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 0.4,
            ),
          ),
          AppSpacing.v4,
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '₹${balance.toStringAsFixed(0)} ',
                  style: AppTextStyles.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: '/ ₹${total.toStringAsFixed(0)} Total',
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.v12,
          Divider(height: 1, color: Colors.grey.shade200),
          AppSpacing.v12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STANDARD',
                    style: AppTextStyles.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  AppSpacing.v2,
                  Text(
                    report.student.standard.isNotEmpty
                        ? report.student.standard
                        : 'N/A',
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'BATCH',
                    style: AppTextStyles.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  AppSpacing.v2,
                  Text(
                    report.student.batchName,
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB BAR (Matching Image 3) ---
  Widget _buildTabBar(StudentWiseReportData report) {
    return Obx(() {
      final currentTab = controller.currentStudentReportTab.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabItem(
              index: 0,
              title: 'Academic & Info',
              icon: Icons.person_outline_rounded,
              isSelected: currentTab == 0,
            ),
            AppSpacing.h8,
            _buildTabItem(
              index: 1,
              title: 'Exams & Marks',
              badge: '${report.exams.totalExams}',
              icon: Icons.assignment_outlined,
              isSelected: currentTab == 1,
            ),
            AppSpacing.h8,
            _buildTabItem(
              index: 2,
              title: 'Attendance',
              badge: '${report.attendance.percentage}%',
              icon: Icons.calendar_month_outlined,
              isSelected: currentTab == 2,
            ),
            AppSpacing.h8,
            _buildTabItem(
              index: 3,
              title: 'Homework',
              badge: '${report.homework.totalSubmissions}',
              icon: Icons.menu_book_outlined,
              isSelected: currentTab == 3,
            ),
            AppSpacing.h8,
            _buildTabItem(
              index: 4,
              title: 'Fee History',
              badge: '${report.financial.feesHistory.length}',
              icon: Icons.receipt_long_outlined,
              isSelected: currentTab == 4,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTabItem({
    required int index,
    required String title,
    String? badge,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.currentStudentReportTab.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBrand : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.white : AppColors.primaryBrand,
            ),
            AppSpacing.h6,
            Text(
              title,
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
            if (badge != null) ...[
              AppSpacing.h6,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.white.withValues(alpha: 0.25)
                      : AppColors.primaryBrandLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.primaryBrand,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- TAB CONTENT ---
  Widget _buildTabContent(StudentWiseReportData report) {
    return Obx(() {
      switch (controller.currentStudentReportTab.value) {
        case 0:
          return _buildAcademicInfoTab(report);
        case 1:
          return _buildExamsTab(report);
        case 2:
          return _buildAttendanceTab(report);
        case 3:
          return _buildHomeworkTab(report);
        case 4:
          return _buildFeeHistoryTab(report);
        default:
          return _buildAcademicInfoTab(report);
      }
    });
  }

  // TAB 0: Academic & Info (Image 3)
  Widget _buildAcademicInfoTab(StudentWiseReportData report) {
    final s = report.student;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AppSpacing.h8,
              Text(
                'Academic & Contact Information',
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.v20,
          _buildInfoField('BATCH NAME', s.batchName),
          AppSpacing.v16,
          _buildInfoField('DATE OF ADMISSION', s.admissionDate),
          AppSpacing.v16,
          _buildInfoField('PARENT / GUARDIAN', s.guardianName),
          AppSpacing.v16,
          _buildActionInfoField(
            'PHONE NUMBER',
            s.phone,
            icon: Icons.phone_outlined,
            onTap: () async {
              final uri = Uri.parse('tel:${s.phone}');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
          ),
          AppSpacing.v16,
          _buildActionInfoField(
            'EMAIL ADDRESS',
            s.email,
            icon: Icons.email_outlined,
            onTap: () async {
              final uri = Uri.parse('mailto:${s.email}');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
          ),
          AppSpacing.v16,
          _buildInfoField('DATE OF BIRTH', s.dob),
          AppSpacing.v16,
          _buildInfoField('RESIDENTIAL ADDRESS', s.address),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 0.4,
          ),
        ),
        AppSpacing.v4,
        Text(
          value.isNotEmpty ? value : 'N/A',
          style: AppTextStyles.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionInfoField(
    String label,
    String value, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 0.4,
          ),
        ),
        AppSpacing.v4,
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryBrand),
              AppSpacing.h6,
              Text(
                value.isNotEmpty ? value : 'N/A',
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrand,
                ).copyWith(decoration: TextDecoration.underline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TAB 1: Exams & Marks
  Widget _buildExamsTab(StudentWiseReportData report) {
    final exams = report.exams;
    if (exams.list.isEmpty) {
      return const AppEmptyView(
        icon: Icons.assignment_outlined,
        title: 'No Exams Recorded',
        message: 'No exam records available for this student.',
      );
    }

    return Column(
      children: [
        _buildStatsBar([
          _StatBarItem('Total', '${exams.totalExams}'),
          _StatBarItem('Passed', '${exams.passedExams}', color: AppColors.successGreen),
          _StatBarItem('Failed', '${exams.failedExams}', color: AppColors.bohoRed),
          _StatBarItem('Avg Score', '${exams.averageScore}%'),
        ]),
        AppSpacing.v12,
        ...exams.list.map((exam) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: AppSpacing.all16,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exam.title,
                        style: AppTextStyles.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: exam.isPassed
                            ? AppColors.successGreen.withValues(alpha: 0.1)
                            : (exam.isAbsent
                                  ? AppColors.warningAmber.withValues(alpha: 0.1)
                                  : AppColors.bohoRed.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        exam.isAbsent
                            ? 'Absent'
                            : (exam.isPassed ? 'Passed' : 'Failed'),
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: exam.isPassed
                              ? AppColors.successGreen
                              : (exam.isAbsent
                                    ? AppColors.warningAmber
                                    : AppColors.bohoRed),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.v4,
                Text(
                  '${exam.subject} • ${exam.date}',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                AppSpacing.v12,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: ${exam.marksScored} / ${exam.totalMarks}',
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${exam.percentage.toStringAsFixed(0)}%',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBrand,
                      ),
                    ),
                  ],
                ),
                if (exam.remarks.isNotEmpty && exam.remarks != '-') ...[
                  AppSpacing.v8,
                  Text(
                    'Remarks: ${exam.remarks}',
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // TAB 2: Attendance
  Widget _buildAttendanceTab(StudentWiseReportData report) {
    final att = report.attendance;
    if (att.records.isEmpty) {
      return const AppEmptyView(
        icon: Icons.calendar_month_outlined,
        title: 'No Attendance Records',
        message: 'No attendance logs found for this student.',
      );
    }

    return Column(
      children: [
        _buildStatsBar([
          _StatBarItem('Total', '${att.totalDays}'),
          _StatBarItem('Present', '${att.presentDays}', color: AppColors.successGreen),
          _StatBarItem('Absent', '${att.absentDays}', color: AppColors.bohoRed),
          _StatBarItem('Attendance', '${att.percentage}%', color: AppColors.primaryBrand),
        ]),
        AppSpacing.v12,
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: att.records.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final record = att.records[index];
              final isPresent = record.status.toLowerCase() == 'present';
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.formattedDate,
                          style: AppTextStyles.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          record.day,
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPresent
                            ? AppColors.successGreen.withValues(alpha: 0.1)
                            : AppColors.bohoRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        record.status,
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isPresent
                              ? AppColors.successGreen
                              : AppColors.bohoRed,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // TAB 3: Homework
  Widget _buildHomeworkTab(StudentWiseReportData report) {
    final hw = report.homework;
    if (hw.list.isEmpty) {
      return const AppEmptyView(
        icon: Icons.menu_book_outlined,
        title: 'No Homework Records',
        message: 'No homework submissions found for this student.',
      );
    }

    return Column(
      children: [
        _buildStatsBar([
          _StatBarItem('Total', '${hw.totalSubmissions}'),
          _StatBarItem('Submitted', '${hw.submittedCount}', color: AppColors.successGreen),
          _StatBarItem('Avg Grade', '${hw.averageGrade}/10', color: AppColors.primaryBrand),
        ]),
        AppSpacing.v12,
        ...hw.list.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: AppSpacing.all16,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTextStyles.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrandLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.status,
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBrand,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.v4,
                Text(
                  '${item.subject} • Due: ${item.dueDate}',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                if (item.score != null) ...[
                  AppSpacing.v10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score',
                        style: AppTextStyles.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${item.score}/10',
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBrand,
                        ),
                      ),
                    ],
                  ),
                ],
                if (item.feedback.isNotEmpty && item.feedback != '-') ...[
                  AppSpacing.v8,
                  Text(
                    'Feedback: ${item.feedback}',
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // TAB 4: Fee History
  Widget _buildFeeHistoryTab(StudentWiseReportData report) {
    final fees = report.financial.feesHistory;
    if (fees.isEmpty) {
      return const AppEmptyView(
        icon: Icons.receipt_long_outlined,
        title: 'No Fee Records',
        message: 'No fee transactions recorded for this student.',
      );
    }

    return Column(
      children: [
        _buildStatsBar([
          _StatBarItem('Monthly Fee', '₹${report.financial.monthlyFee.toStringAsFixed(0)}'),
          _StatBarItem('Paid', '₹${report.financial.totalPaid.toStringAsFixed(0)}', color: AppColors.successGreen),
          _StatBarItem('Balance', '₹${report.financial.balance.toStringAsFixed(0)}', color: AppColors.bohoRed),
        ]),
        AppSpacing.v12,
        ...fees.map((fee) {
          final isPaid = fee.status.toLowerCase() == 'paid';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: AppSpacing.all16,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fee.monthYear,
                      style: AppTextStyles.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? AppColors.successGreen.withValues(alpha: 0.1)
                            : AppColors.bohoRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fee.status,
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isPaid
                              ? AppColors.successGreen
                              : AppColors.bohoRed,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.v10,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${fee.totalAmount.toStringAsFixed(0)}',
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Paid: ₹${fee.paidAmount.toStringAsFixed(0)}',
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
                if (fee.remaining > 0) ...[
                  AppSpacing.v6,
                  Text(
                    'Remaining: ₹${fee.remaining.toStringAsFixed(0)}',
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bohoRed,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // --- STATS BAR HELPER ---
  Widget _buildStatsBar(List<_StatBarItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          return Column(
            children: [
              Text(
                item.label,
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
              AppSpacing.v2,
              Text(
                item.value,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: item.color ?? AppColors.textPrimary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // --- BOTTOM SHEETS FOR PICKERS ---
  void _showBatchPickerSheet() {
    final batches = controller.batchController.batchesList;
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.6),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: AppSpacing.all20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppSpacing.v16,
            Text(
              'Select Batch',
              style: AppTextStyles.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.v12,
            Expanded(
              child: ListView.separated(
                itemCount: batches.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final b = batches[index];
                  final isSelected =
                      controller.selectedBatchForStudentReport.value?.id ==
                          b.id;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(
                      b.title,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryBrand
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${b.studentCount} students',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryBrand,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      Get.back();
                      controller.selectBatchForStudentReport(b);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showStudentPickerSheet() {
    final students = controller.batchStudentsForReport;
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.6),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: AppSpacing.all20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppSpacing.v16,
            Text(
              'Select Student',
              style: AppTextStyles.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.v12,
            Expanded(
              child: ListView.separated(
                itemCount: students.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final s = students[index];
                  final isSelected =
                      controller.selectedStudentForReport.value?.id == s.id;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(
                      s.name,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryBrand
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Enrollment ID: ${s.enrollmentId}',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryBrand,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      Get.back();
                      controller.selectStudentForReport(s);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _StatBarItem {
  final String label;
  final String value;
  final Color? color;

  _StatBarItem(this.label, this.value, {this.color});
}
