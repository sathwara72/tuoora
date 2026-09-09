import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/data/models/user_model.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batches_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_profile_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_self_attendance_controller.dart';

class TeacherInstituteSwitcherSheet extends StatefulWidget {
  const TeacherInstituteSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await Get.bottomSheet(
      const TeacherInstituteSwitcherSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  State<TeacherInstituteSwitcherSheet> createState() =>
      _TeacherInstituteSwitcherSheetState();
}

class _TeacherInstituteSwitcherSheetState
    extends State<TeacherInstituteSwitcherSheet> {
  final _authService = Get.find<AuthService>();
  final _authRepository = Get.find<AuthRepository>();

  int? _switchingInstituteId;

  Future<void> _selectInstitute(TeacherInstituteInfo institute) async {
    final currentUser = _authService.currentUser;
    if (currentUser?.instituteId == institute.id) {
      Get.back();
      return;
    }

    setState(() => _switchingInstituteId = institute.id);

    try {
      await _authRepository.switchTeacherInstitute(institute.id);

      // Refresh any active teacher controllers
      if (Get.isRegistered<TeacherBatchesController>()) {
        Get.find<TeacherBatchesController>().fetchBatches();
      }
      if (Get.isRegistered<TeacherProfileController>()) {
        Get.find<TeacherProfileController>().fetchProfile();
      }
      if (Get.isRegistered<TeacherSelfAttendanceController>()) {
        Get.find<TeacherSelfAttendanceController>().initLoad();
      }

      Get.back();
      AppSnackBar.success('Switched to ${institute.name}');
    } catch (e) {
      AppSnackBar.error(
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _switchingInstituteId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final institutes = user?.institutes ?? [];
    final activeInstituteId = user?.instituteId;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.fieldBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.v16,

          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: AppColors.primaryBrand,
                  size: 22,
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Switch Institute',
                      style: AppTextStyles.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Select an institute to manage its batches and students',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                onPressed: () => Get.back(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          AppSpacing.v20,

          // List of institutes
          if (institutes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                  ),
                  AppSpacing.v12,
                  Text(
                    'No additional institutes available',
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: institutes.length,
                separatorBuilder: (_, _) => AppSpacing.v12,
                itemBuilder: (context, index) {
                  final inst = institutes[index];
                  final isActive = inst.id == activeInstituteId;
                  final isSwitching = _switchingInstituteId == inst.id;

                  return _InstituteCard(
                    institute: inst,
                    isActive: isActive,
                    isSwitching: isSwitching,
                    onTap: () => _selectInstitute(inst),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _InstituteCard extends StatelessWidget {
  final TeacherInstituteInfo institute;
  final bool isActive;
  final bool isSwitching;
  final VoidCallback onTap;

  const _InstituteCard({
    required this.institute,
    required this.isActive,
    required this.isSwitching,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSwitching ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryBrand.withValues(alpha: 0.05)
              : AppColors.fieldBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.primaryBrand : AppColors.borderGrey,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Logo / Initial
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryBrand
                    : AppColors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                image: institute.logo != null && institute.logo!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(institute.logo!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: institute.logo == null || institute.logo!.isEmpty
                  ? Center(
                      child: Text(
                        institute.name.isNotEmpty
                            ? institute.name[0].toUpperCase()
                            : 'I',
                        style: AppTextStyles.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isActive ? AppColors.white : AppColors.textPrimary,
                        ),
                      ),
                    )
                  : null,
            ),
            AppSpacing.h12,

            // Name & Code/Address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    institute.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (institute.code != null || institute.address != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      institute.code ?? institute.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppSpacing.h8,

            // Active or Action
            if (isSwitching)
              const SizedBox(
                width: 24,
                height: 24,
                child: CommonLoading(size: 20),
              )
            else if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Active',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: Text(
                  'Select',
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
