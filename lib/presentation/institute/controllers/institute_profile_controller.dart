import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/data/models/institute_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class InstituteProfileController extends GetxController {
  final InstituteRepositoryImpl _instituteRepository;

  InstituteProfileController(this._instituteRepository);

  // Current Profile Model
  final profile = Rxn<InstituteProfile>();

  // Observable fields for UI display
  final instituteName = "".obs;
  final profileImagePath = RxnString();
  final ownerName = "".obs;
  final email = "".obs;
  final phone = "".obs;
  final addressLine1 = "".obs;
  final addressLine2 = "".obs;
  final city = "".obs;
  final state = "".obs;
  final country = "".obs;
  final pincode = "".obs;

  final isLoading = false.obs;
  final triedToSave = false.obs;

  final instituteNameError = RxnString();
  final ownerNameError = RxnString();
  final emailError = RxnString();
  final phoneError = RxnString();
  final addressError = RxnString();
  final cityError = RxnString();
  final stateError = RxnString();
  final countryError = RxnString();
  final pincodeError = RxnString();

  // ----- UPI Payment Settings (edit screen + profile-view card) -----
  /// Saved merchant UPI handle (e.g. `merchant@bank`). Empty when the
  /// institute hasn't configured it yet.
  final upiId = ''.obs;

  /// Server-hosted QR image URL once saved. Becomes null after the user
  /// picks a fresh local file but hasn't hit Save yet — at which point
  /// [upiQrLocalPath] takes over for the preview.
  final upiQrCodeUrl = RxnString();

  /// Local file path of a freshly-picked QR image. Cleared after Save.
  final upiQrLocalPath = RxnString();

  /// Saving spinner for the edit screen's Save button.
  final isSavingPayment = false.obs;

  final upiIdError = RxnString();
  final upiQrError = RxnString();

  // Controllers for text fields (for editing)
  late TextEditingController nameController;
  late TextEditingController ownerController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressLine1Controller;
  late TextEditingController addressLine2Controller;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController countryController;
  late TextEditingController pincodeController;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    fetchProfile();
  }

  void _initializeControllers() {
    nameController = TextEditingController(text: instituteName.value);
    ownerController = TextEditingController(text: ownerName.value);
    emailController = TextEditingController(text: email.value);
    phoneController = TextEditingController(text: phone.value);
    addressLine1Controller = TextEditingController(text: addressLine1.value);
    addressLine2Controller = TextEditingController(text: addressLine2.value);
    cityController = TextEditingController(text: city.value);
    stateController = TextEditingController(text: state.value);
    countryController = TextEditingController(text: country.value);
    pincodeController = TextEditingController(text: pincode.value);

    _addListeners();
  }

  void _addListeners() {
    nameController.addListener(() => _clearError(instituteNameError));
    ownerController.addListener(() => _clearError(ownerNameError));
    emailController.addListener(() => _clearError(emailError));
    phoneController.addListener(() => _clearError(phoneError));
    addressLine1Controller.addListener(() => _clearError(addressError));
    cityController.addListener(() => _clearError(cityError));
    stateController.addListener(() => _clearError(stateError));
    countryController.addListener(() => _clearError(countryError));
    pincodeController.addListener(() => _clearError(pincodeError));
  }

  void _clearError(RxnString error) {
    if (triedToSave.value && error.value != null) {
      error.value = null;
    }
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final data = await _instituteRepository.getProfile();
      profile.value = data;

      instituteName.value = data.instituteName ?? '';
      ownerName.value = data.name;
      email.value = data.email;
      phone.value = data.phone;
      addressLine1.value = data.address ?? '';
      addressLine2.value = data.addressLine2 ?? '';
      city.value = data.city ?? '';
      state.value = data.state ?? '';
      country.value = data.country ?? 'India';
      pincode.value = data.pincode ?? '';

      if (data.logoUrl != null) {
        profileImagePath.value = data.logoUrl;
      }

      upiId.value = data.upiId ?? '';
      upiQrCodeUrl.value = data.upiQrCodeUrl;
      upiQrLocalPath.value = null;

      _initializeControllers();
    } catch (e) {
      AppSnackBar.error(AppStrings.errFailedLoadProfile);
    } finally {
      isLoading.value = false;
    }
  }

  bool get hasUpiPayment =>
      upiId.value.trim().isNotEmpty || (upiQrCodeUrl.value ?? '').isNotEmpty;

  String? get upiQrPreviewSource => upiQrLocalPath.value ?? upiQrCodeUrl.value;

  Future<void> pickUpiQrImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (status.isPermanentlyDenied) {
          openAppSettings();
          return;
        } else if (!status.isGranted) {
          return;
        }
      } else if (source == ImageSource.gallery) {
        if (Platform.isIOS) {
          final status = await Permission.photos.request();
          if (status.isPermanentlyDenied) {
            openAppSettings();
            return;
          } else if (!status.isGranted && !status.isLimited) {
            return;
          }
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        upiQrLocalPath.value = image.path;
        upiQrError.value = null;
      }
    } catch (_) {
      AppSnackBar.error(AppStrings.errFailedPickImage);
    }
  }

  Future<void> savePaymentSettings(String upiIdInput) async {
    final trimmed = upiIdInput.trim();
    upiIdError.value = null;
    final hasFreshQr = (upiQrLocalPath.value ?? '').isNotEmpty;
    final hasSavedQr = (upiQrCodeUrl.value ?? '').isNotEmpty;
    upiQrError.value = (hasFreshQr || hasSavedQr)
        ? null
        : 'Please upload a UPI QR code image';
    if (upiQrError.value != null) {
      AppSnackBar.error(upiQrError.value!);
      return;
    }

    try {
      isSavingPayment.value = true;
      final result = await _instituteRepository.updatePaymentSettings(
        upiId: trimmed,
        qrImagePath: upiQrLocalPath.value,
      );
      // Cache new values + sync them onto the profile object so the
      // profile view's Obx-wrapped card reflects them without a reload.
      upiId.value = result.upiId;
      upiQrCodeUrl.value = result.upiQrCodeUrl;
      upiQrLocalPath.value = null;
      final p = profile.value;
      if (p != null) {
        profile.value = p.copyWithPayment(
          upiId: result.upiId,
          upiQrCodeUrl: result.upiQrCodeUrl,
        );
      }
      AppSnackBar.success(AppStrings.paymentSettingsSaved);
      Get.back();
    } catch (e) {
      AppSnackBar.error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isSavingPayment.value = false;
    }
  }

  Future<void> pickImage() async {
    Get.bottomSheet(
      Container(
        padding: AppSpacing.all32,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                final status = await Permission.camera.request();
                if (status.isPermanentlyDenied) {
                  openAppSettings();
                  return;
                } else if (!status.isGranted) {
                  return;
                }
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 75,
                  maxWidth: 1080,
                  maxHeight: 1080,
                );
                if (image != null) {
                  profileImagePath.value = image.path;
                }
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
                if (Platform.isIOS) {
                  final status = await Permission.photos.request();
                  if (status.isPermanentlyDenied) {
                    openAppSettings();
                    return;
                  } else if (!status.isGranted && !status.isLimited) {
                    return;
                  }
                }
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 75,
                  maxWidth: 1080,
                  maxHeight: 1080,
                );
                if (image != null) {
                  profileImagePath.value = image.path;
                }
              },
            ),
            AppSpacing.v16,
          ],
        ),
      ),
    );
  }

  Future<void> saveProfile() async {
    triedToSave.value = true;
    _resetErrors();

    final nameErr = ValidationUtils.validateRequired(
      nameController.text,
      'Institute name',
    );
    instituteNameError.value = nameErr;
    if (nameErr != null) return;

    final ownerErr = ValidationUtils.validateRequired(
      ownerController.text,
      'Owner name',
    );
    ownerNameError.value = ownerErr;
    if (ownerErr != null) return;

    final emailErr = ValidationUtils.validateEmail(emailController.text);
    emailError.value = emailErr;
    if (emailErr != null) return;

    final phoneErr = ValidationUtils.validatePhone(phoneController.text);
    phoneError.value = phoneErr;
    if (phoneErr != null) return;

    final pincodeText = pincodeController.text.trim();
    if (pincodeText.isNotEmpty && pincodeText.length != 6) {
      pincodeError.value = 'Pincode must be 6 digits';
      return;
    }

    try {
      isLoading.value = true;
      final updateData = {
        'name': ownerController.text,
        'institute_name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressLine1Controller.text,
        'address_line_2': addressLine2Controller.text,
        'city': cityController.text,
        'state': stateController.text,
        'country': countryController.text,
        'pincode': pincodeController.text,
        if (profileImagePath.value != null) 'logo_url': profileImagePath.value,
      };

      await _instituteRepository.updateProfile(updateData);

      await fetchProfile();

      Get.back();
      AppSnackBar.success(AppStrings.profileUpdated);
    } catch (e) {
      if (e is ValidationException) {
        _handleValidationErrors(e.errors);
        AppSnackBar.error(AppStrings.validationErrorsBelow);
      } else {
        AppSnackBar.error('Failed to update profile: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _handleValidationErrors(Map<String, dynamic> errors) {
    if (errors.containsKey('institute_name')) {
      instituteNameError.value = (errors['institute_name'] as List).first
          .toString();
    }
    if (errors.containsKey('name')) {
      ownerNameError.value = (errors['name'] as List).first.toString();
    }
    if (errors.containsKey('email')) {
      emailError.value = (errors['email'] as List).first.toString();
    }
    if (errors.containsKey('phone')) {
      phoneError.value = (errors['phone'] as List).first.toString();
    }
    if (errors.containsKey('address')) {
      addressError.value = (errors['address'] as List).first.toString();
    }
    if (errors.containsKey('city')) {
      cityError.value = (errors['city'] as List).first.toString();
    }
    if (errors.containsKey('state')) {
      stateError.value = (errors['state'] as List).first.toString();
    }
    if (errors.containsKey('country')) {
      countryError.value = (errors['country'] as List).first.toString();
    }
    if (errors.containsKey('pincode')) {
      pincodeError.value = (errors['pincode'] as List).first.toString();
    }
  }

  void _resetErrors() {
    instituteNameError.value = null;
    ownerNameError.value = null;
    emailError.value = null;
    phoneError.value = null;
    addressError.value = null;
    cityError.value = null;
    stateError.value = null;
    countryError.value = null;
    pincodeError.value = null;
  }

  void discardChanges() {
    _initializeControllers();
    Get.back();
  }

  void logout() async {
    CommonLoading.show();
    try {
      await Get.find<AuthRepository>().logout('INSTITUTE');
    } catch (_) {}
    final authService = Get.find<AuthService>();
    await authService.clearSession();
    CommonLoading.dismiss();
    Get.offAllNamed(AppRoutes.roleSelection);
  }

  Future<void> deleteAccount() async {
    CommonLoading.show();
    try {
      await _instituteRepository.deleteAccount();
      final authService = Get.find<AuthService>();
      await authService.clearSession();
      CommonLoading.dismiss();
      Get.offAllNamed(AppRoutes.roleSelection);
      AppSnackBar.success(AppStrings.accountDeletedSuccessfully);
    } catch (e) {
      CommonLoading.dismiss();
      AppSnackBar.error(
        e.toString().replaceAll('Exception: ', ''),
        title: AppStrings.accountDeletionFailed,
      );
    }
  }

  Future<void> deleteDeviceSession(int sessionId) async {
    final p = profile.value;
    final session = p?.activeSessions?.firstWhereOrNull(
      (s) => s.id == sessionId,
    );
    if (session != null && session.isCurrent == true) {
      logout();
      return;
    }

    CommonLoading.show();
    try {
      await _instituteRepository.deleteDeviceSession(sessionId);
      if (p != null && p.activeSessions != null) {
        p.activeSessions!.removeWhere((s) => s.id == sessionId);
        profile.refresh();
      }
      CommonLoading.dismiss();
      AppSnackBar.success(AppStrings.deviceLogout);
    } catch (e) {
      CommonLoading.dismiss();
      AppSnackBar.error(
        e.toString().replaceAll('Exception: ', ''),
        title: 'Logout Failed',
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    ownerController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    pincodeController.dispose();
    super.onClose();
  }
}
