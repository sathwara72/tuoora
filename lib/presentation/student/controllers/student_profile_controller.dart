import 'package:tuoora/data/repositories/student_exam_repository.dart';
import 'dart:io';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/models/student_profile_model.dart';
import 'package:tuoora/data/repositories/student_profile_repository.dart';
import 'package:tuoora/core/widgets/common_loading.dart';

class StudentProfileController extends GetxController {
  final RxString profileImagePath = ''.obs;
  final ImagePicker _picker = ImagePicker();

  final RxBool isLoading = true.obs;
  final RxBool isUploadingAvatar = false.obs;
  final Rxn<StudentProfileModel> profileData = Rxn<StudentProfileModel>();
  late final StudentProfileRepository _repository;

  @override
  void onInit() {
    super.onInit();
    _repository = StudentProfileRepository(Get.find<ApiClient>());
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      var data = await _repository.getProfile();

      // If examPct is 0 or unpopulated, fetch from StudentExamRepository as fallback
      if (data.stats.examPct == 0) {
        try {
          final examRepo = StudentExamRepository(Get.find<ApiClient>());
          final examData = await examRepo.getExams();
          final examAvg = examData.overallStats.averagePercentage.round();
          if (examAvg > 0) {
            final updatedPerf = ((data.stats.attendancePct + data.stats.homeworkPct + examAvg) / 3).round();
            data = data.copyWithStats(
              data.stats.copyWith(
                examPct: examAvg,
                performanceScore: updatedPerf > 0 ? updatedPerf : data.stats.performanceScore,
              ),
            );
          }
        } catch (_) {}
      }

      profileData.value = data;
    } catch (e) {
      AppSnackBar.error(AppStrings.errFailedLoadProfile);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      CommonLoading.show();
      await _repository.deleteAccount();
      final authService = Get.find<AuthService>();
      await authService.clearSession();
      Get.offAllNamed(AppRoutes.roleSelection);
      AppSnackBar.success(AppStrings.accountDeletedSuccessfully);
    } catch (e) {
      AppSnackBar.error(
        e.toString().replaceAll('Exception: ', ''),
        title: AppStrings.accountDeletionFailed,
      );
    } finally {
      CommonLoading.dismiss();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    final previousLocalPath = profileImagePath.value;
    profileImagePath.value = image.path;

    try {
      isUploadingAvatar.value = true;
      final newAvatarUrl = await _repository.uploadAvatar(File(image.path));

      final existing = profileData.value;
      if (existing != null) {
        profileData.value = existing.copyWithAvatarUrl(newAvatarUrl);
      }
      AppSnackBar.success(AppStrings.profilePhotoUpdated);
    } catch (e) {
      profileImagePath.value = previousLocalPath;
      AppSnackBar.error(
        e.toString().replaceAll('Exception: ', ''),
        title: AppStrings.uploadFailed,
      );
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  void showImagePickerOptions() {
    Get.bottomSheet(
      // SafeArea(top:false) pushes the sheet content above the system
      // gesture / navigation area so the Camera / Gallery tiles stay
      // fully tappable on phones with a bottom nav bar.
      SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s24,
            AppSpacing.s24,
            AppSpacing.s24,
            AppSpacing.s16,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle for affordance
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: AppSpacing.all8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBrandLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primaryBrand,
                  ),
                ),
                title: Text(
                  AppStrings.labelCamera,
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () async {
                  Get.back();
                  await pickImage(ImageSource.camera);
                },
              ),
              AppSpacing.v8,
              ListTile(
                leading: Container(
                  padding: AppSpacing.all8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBrandLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primaryBrand,
                  ),
                ),
                title: Text(
                  AppStrings.labelGallery,
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () async {
                  Get.back();
                  await pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
