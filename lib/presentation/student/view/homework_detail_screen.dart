import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:tuoora/core/widgets/app_back_button.dart';

class StudentHomeworkDetailScreen extends StatefulWidget {
  const StudentHomeworkDetailScreen({super.key});

  @override
  State<StudentHomeworkDetailScreen> createState() =>
      _StudentHomeworkDetailScreenState();
}

class _StudentHomeworkDetailScreenState
    extends State<StudentHomeworkDetailScreen> {
  double _progress = 0.05; // Starting at 5%
  bool _isSubmitted = false;

  void _incrementProgress() {
    setState(() {
      if (_progress < 1.0) {
        _progress = (_progress + 0.50).clamp(0.0, 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Center(child: AppBackButton()),
        ),
        title: Text(
          AppStrings.homeworkDetails,
          style: AppTextStyles.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.x24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.v16,
            _buildFeaturedHeaderCard(),
            AppSpacing.v32,
            _buildInstructionsCard(),
            AppSpacing.v24,
            _buildTutorProfile(),
            AppSpacing.v32,
            _buildAttachmentsSection(),
            AppSpacing.v40,
            _buildProgressCard(),
            AppSpacing.v32,
            _buildSubmitButton(),
            AppSpacing.v40,
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedHeaderCard() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.all32,
      decoration: BoxDecoration(
        color: AppColors.subjectPhysics,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrand.withValues(alpha: 0.2),
            blurRadius: AppSpacing.s20,
            offset: const Offset(0, AppSpacing.s10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.s12),
            ),
            child: Text(
              AppStrings.mathematics,
              style: AppTextStyles.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          AppSpacing.v24,
          Text(
            AppStrings.advancedNcalculus,
            style: AppTextStyles.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              height: 1.1,
            ),
          ),
          AppSpacing.v32,
          Row(
            children: [
              _buildStatusChip(
                Icons.calendar_month_outlined,
                'Due: Oct 24, 2023',
                AppColors.white.withValues(alpha: 0.1),
              ),
              AppSpacing.h12,
              _buildStatusChip(
                Icons.access_time_rounded,
                _isSubmitted ? 'Status: Submitted' : 'Status: Pending',
                _isSubmitted
                    ? AppColors.greenText.withValues(alpha: 0.8)
                    : AppColors.bohoRed.withValues(alpha: 0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(IconData icon, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.s12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white, size: AppSpacing.s14),
          AppSpacing.h6,
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: AppSpacing.all24,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: AppSpacing.s10,
            offset: const Offset(0, AppSpacing.s4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.all10,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.s10),
                ),
                child: const Icon(
                  Icons.description,
                  color: AppColors.primaryBrand,
                  size: AppSpacing.s18,
                ),
              ),
              AppSpacing.h16,
              Text(
                AppStrings.instructionsFromNtutor,
                style: AppTextStyles.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkSlate,
                  height: 1.2,
                ),
              ),
            ],
          ),
          AppSpacing.v24,
          Text(
            AppStrings.welcomeToTheFinalModuleOf,
            style: AppTextStyles.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          AppSpacing.v20,
          Text(
            AppStrings.specificTasks,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkSlate,
            ),
          ),
          AppSpacing.v12,
          _buildBulletItem(
            'Calculate the line integrals for the provided vector fields.',
          ),
          _buildBulletItem(
            'Provide a step-by-step derivation of the surface normal vectors.',
          ),
          _buildBulletItem(
            'Compare your analytical results with the numerical approximations found in Chapter 4.',
          ),
          AppSpacing.v24,
          Container(
            padding: AppSpacing.all20,
            decoration: BoxDecoration(
              color: AppColors.surfaceBg,
              borderRadius: BorderRadius.circular(AppSpacing.s16),
              border: const Border(
                left: BorderSide(
                  color: AppColors.primaryBrand,
                  width: AppSpacing.s4,
                ),
              ),
            ),
            child: Text(
              AppStrings.graphsMustBePlottedClearlyHand,
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: AppColors.primaryBrand,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.s6),
            child: Icon(
              Icons.circle,
              size: AppSpacing.s6,
              color: AppColors.textMuted,
            ),
          ),
          AppSpacing.h12,
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorProfile() {
    return Container(
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.s20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSpacing.s22,
            backgroundImage: CachedNetworkImageProvider(
              'https://i.pravatar.cc/150?img=12',
            ),
          ),
          AppSpacing.h16,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.assignedTutor,
                style: AppTextStyles.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              AppSpacing.v2,
              Text(
                AppStrings.drElenaVance,
                style: AppTextStyles.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkSlate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.link_rounded,
              color: AppColors.fieldLabel,
              size: AppSpacing.s24,
            ),
            AppSpacing.h12,
            Text(
              AppStrings.attachments,
              style: AppTextStyles.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        AppSpacing.v20,
        Container(
          padding: AppSpacing.all24,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: AppSpacing.s10,
                offset: const Offset(0, AppSpacing.s4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildFileCard(
                'Study_Guide_Calculus.pdf',
                'STUDY GUIDE',
                Icons.picture_as_pdf_rounded,
              ),
              AppSpacing.v16,
              _buildFileCard(
                'problem_set_v2.pdf',
                'PROBLEM SET',
                Icons.description_rounded,
              ),
              AppSpacing.v24,
              Text(
                AppStrings.tipOpenBothFilesToReach,
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileCard(String name, String type, IconData icon) {
    return InkWell(
      onTap: _incrementProgress,
      borderRadius: BorderRadius.circular(AppSpacing.s16),
      child: Container(
        padding: AppSpacing.all16,
        decoration: BoxDecoration(
          color: AppColors.surfaceBg,
          borderRadius: BorderRadius.circular(AppSpacing.s16),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.all10,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.s10),
              ),
              child: Icon(icon, color: AppColors.error, size: AppSpacing.s18),
            ),
            AppSpacing.h16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkSlate,
                    ),
                  ),
                  Text(
                    type,
                    style: AppTextStyles.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.file_download_outlined,
              color: AppColors.textTertiary,
              size: AppSpacing.s22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: AppSpacing.all24,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.s20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.yourProgress,
                style: AppTextStyles.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.v12,
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: AppSpacing.s12,
              backgroundColor: AppColors.borderLightGray,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryBrand,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool isEnabled = _progress >= 1.0 && !_isSubmitted;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.primaryBrand.withValues(alpha: 0.3),
                  blurRadius: AppSpacing.s20,
                  offset: const Offset(0, AppSpacing.s10),
                ),
              ]
            : null,
      ),
      child: AppButton(
        label: _isSubmitted ? 'Submitted' : 'Submit Assignment',
        icon: _isSubmitted
            ? Icons.check_circle_rounded
            : Icons.note_add_rounded,
        backgroundColor: AppColors.primaryBrand,
        isDisabled: !isEnabled,
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 20),
        onPressed: isEnabled
            ? () {
                setState(() => _isSubmitted = true);
                AppSnackBar.success(AppStrings.homeworkSubmittedSuccessfully);
              }
            : null,
      ),
    );
  }
}
