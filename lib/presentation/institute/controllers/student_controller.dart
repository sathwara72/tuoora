import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_pickers.dart';
import 'package:tuoora/data/repositories_impl/student_repository_impl.dart';
import 'package:tuoora/presentation/institute/controllers/institute_controller.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuoora/data/models/student_model.dart';
import 'package:tuoora/presentation/institute/controllers/batch_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/api/api_exception.dart';

class InstituteStudentController extends GetxController {
  final StudentRepositoryImpl _studentRepository =
      Get.find<StudentRepositoryImpl>();

  final selectedGrade = AppStrings.instGradeHint.obs;
  final selectedImagePath = Rxn<String>();
  final isLoading = false.obs;
  final isFormValid = false.obs;
  final triedToSave = false.obs;
  final currentStudent = Rxn<Student>();
  final isSendingFeeReminder = false.obs;

  final nameController = TextEditingController();
  final parentNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();
  final standardController = TextEditingController();

  final nameError = RxnString();
  final parentNameError = RxnString();
  final phoneError = RxnString();
  final emailError = RxnString();
  final dobError = RxnString();
  final standardError = RxnString();

  final editingStudentId = Rxn<dynamic>();
  final selectedProfileBatchId = Rxn<dynamic>();
  final selectedBatchId = RxnString();
  final availableBatches = <BatchModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(validateForm);
    parentNameController.addListener(validateForm);
    phoneController.addListener(validateForm);
    emailController.addListener(validateForm);
    dobController.addListener(validateForm);
    addressController.addListener(validateForm);
    standardController.addListener(validateForm);
    handleArguments();
    fetchAvailableBatches();
  }

  void fetchAvailableBatches() {
    if (Get.isRegistered<BatchController>()) {
      final batchController = Get.find<BatchController>();
      if (batchController.batchesList.isEmpty) {
        batchController.loadBatches();
      }
      ever(batchController.batchesList, (batches) {
        availableBatches.assignAll(batches);
      });
      availableBatches.assignAll(batchController.batchesList);
    }
  }

  void handleArguments() {
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;

      if (args['student'] != null) {
        if (args['student'] is Student) {
          final student = args['student'] as Student;
          editingStudentId.value = student.id;
          currentStudent.value = student;
          preFillData(student);
          return;
        } else if (args['student'] is Map) {
          final student = Student.fromJson(args['student']);
          editingStudentId.value = student.id;
          currentStudent.value = student;
          preFillData(student);
          return;
        }
      }

      editingStudentId.value = args['studentId'];

      if (editingStudentId.value != null) {
        currentStudent.value = null;
        fetchStudentDetails(editingStudentId.value!);
      }
    } else {
      clearForm();
    }
  }

  void clearForm() {
    editingStudentId.value = null;
    currentStudent.value = null;
    nameController.clear();
    parentNameController.clear();
    phoneController.clear();
    emailController.clear();
    dobController.clear();
    addressController.clear();
    standardController.clear();
    selectedImagePath.value = null;
    selectedBatchId.value = null;
    selectedProfileBatchId.value = null;

    nameError.value = null;
    parentNameError.value = null;
    phoneError.value = null;
    emailError.value = null;
    dobError.value = null;
    standardError.value = null;
    triedToSave.value = false;

    validateForm();
  }

  @override
  void onClose() {
    nameController.dispose();
    parentNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    dobController.dispose();
    addressController.dispose();
    standardController.dispose();
    super.onClose();
  }

  void validateForm() {
    final nErr = ValidationUtils.validateRequired(nameController.text, 'Name');
    final pnErr = ValidationUtils.validateRequired(
      parentNameController.text,
      'Guardian Name',
    );
    final pErr = ValidationUtils.validatePhone(phoneController.text);
    final eErr = ValidationUtils.validateEmail(emailController.text);
    final dErr = ValidationUtils.validateRequired(
      dobController.text,
      'Date of Birth',
    );
    final sErr = ValidationUtils.validateRequired(
      standardController.text,
      'Grade/Standard',
    );

    if (triedToSave.value) {
      nameError.value = nErr;
      parentNameError.value = pnErr;
      phoneError.value = pErr;
      emailError.value = eErr;
      dobError.value = dErr;
      standardError.value = sErr;
    }

    isFormValid.value =
        nErr == null &&
        pnErr == null &&
        pErr == null &&
        eErr == null &&
        dErr == null &&
        sErr == null;
  }

  Future<void> fetchStudentDetails(dynamic id, {dynamic batchId}) async {
    try {
      isLoading.value = true;
      final effectiveBatchId = batchId ?? selectedProfileBatchId.value;
      final student = await _studentRepository.getStudentById(
        id,
        batchId: effectiveBatchId,
      );
      currentStudent.value = student;
      preFillData(student);
    } catch (e) {
      debugPrint('Error fetching student: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> switchProfileBatch(dynamic batchId) async {
    final student = currentStudent.value;
    if (student == null) return;
    selectedProfileBatchId.value = batchId;
    await fetchStudentDetails(student.id, batchId: batchId);
  }

  void preFillData(Student student) {
    editingStudentId.value = student.id;
    nameController.text = student.name;
    emailController.text = student.email;
    dobController.text = student.dob;
    parentNameController.text = student.guardianName ?? '';
    phoneController.text = student.phone;
    standardController.text = student.standard;

    validateForm();
  }

  void setGrade(String grade) {
    selectedGrade.value = grade;
  }

  Future<void> selectDOB(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    if (dobController.text.isNotEmpty) {
      try {
        final parts = dobController.text.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          final existingDate = DateTime(year, month, day);
          if (existingDate.isBefore(DateTime.now())) {
            initialDate = existingDate;
          }
        }
      } catch (e) {
        debugPrint('Error parsing DOB: $e');
      }
    }

    final DateTime? picked = await AppPickers.date(
      context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      validateForm();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      AppSnackBar.error('Could not pick image: $e');
    }
  }

  void showImagePickerSourceSheet(BuildContext context) {
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
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.primaryBrand,
              ),
              title: Text(
                AppStrings.labelCamera,
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            AppSpacing.v8,
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.primaryBrand,
              ),
              title: Text(
                AppStrings.labelGallery,
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
            AppSpacing.v16,
          ],
        ),
      ),
    );
  }

  Future<void> saveStudent({bool isEdit = false}) async {
    triedToSave.value = true;
    validateForm();

    if (!isFormValid.value) return;

    try {
      isLoading.value = true;

      final studentData = {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'guardian_name': parentNameController.text,
        'dob': dobController.text,
        'standard': standardController.text,
        if (selectedBatchId.value != null) 'batch_id': selectedBatchId.value,
        if (selectedImagePath.value != null)
          'profile_image_url': selectedImagePath.value,
      };

      if (isEdit && editingStudentId.value != null) {
        await _studentRepository.updateStudent(
          editingStudentId.value!,
          studentData,
        );
      } else {
        await _studentRepository.createStudent(studentData);
      }

      if (Get.isRegistered<InstituteController>()) {
        Get.find<InstituteController>().fetchStudents(reset: true);
      }

      if (isEdit) {
        Get.back();
        Get.back();
      } else {
        Get.back();
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        AppSnackBar.success(
          isEdit
              ? 'Student updated successfully'
              : 'Student added successfully',
        );
      });
    } catch (e) {
      if (e is ValidationException) {
        _handleValidationErrors(e.errors);
        AppSnackBar.error(AppStrings.validationErrorsBelow);
      } else {
        AppSnackBar.error('Failed to save student: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _handleValidationErrors(Map<String, dynamic> errors) {
    if (errors.containsKey('name')) {
      nameError.value = (errors['name'] as List).first.toString();
    }
    if (errors.containsKey('guardian_name')) {
      parentNameError.value = (errors['guardian_name'] as List).first
          .toString();
    }
    if (errors.containsKey('phone')) {
      phoneError.value = (errors['phone'] as List).first.toString();
    }
    if (errors.containsKey('email')) {
      emailError.value = (errors['email'] as List).first.toString();
    }
    if (errors.containsKey('dob')) {
      dobError.value = (errors['dob'] as List).first.toString();
    }
    if (errors.containsKey('standard')) {
      standardError.value = (errors['standard'] as List).first.toString();
    }
    isFormValid.value = false;
  }

  final isPayingInstallment = false.obs;

  Future<bool> payInstallment(
    int installmentId, {
    required double amount,
    String paymentMethod = 'Cash',
  }) async {
    try {
      isPayingInstallment.value = true;
      await _studentRepository.payInstallment(
        installmentId,
        amount: amount,
        paymentMethod: paymentMethod,
      );
      AppSnackBar.success('Milestone payment recorded successfully');

      final student = currentStudent.value;
      if (student != null) {
        await fetchStudentDetails(student.id, batchId: selectedProfileBatchId.value);
      }
      return true;
    } catch (e) {
      AppSnackBar.error('Payment failed: $e');
      return false;
    } finally {
      isPayingInstallment.value = false;
    }
  }

  Future<void> sendFeeReminder() async {
    final student = currentStudent.value;
    if (student == null) return;
    try {
      isSendingFeeReminder.value = true;
      await _studentRepository.sendFeeReminder(student.id);
      AppSnackBar.success(
        'Fee reminder sent to ${student.name}',
        title: AppStrings.reminderSent,
      );
    } catch (e) {
      AppSnackBar.error('Failed to send fee reminder: $e');
    } finally {
      isSendingFeeReminder.value = false;
    }
  }

  Future<void> sendPassword() async {
    final student = currentStudent.value;
    if (student == null) return;
    try {
      isLoading.value = true;
      final message = await _studentRepository.sendPassword(student.id);
      AppSnackBar.success(message);
    } catch (e) {
      AppSnackBar.error('Failed to send password: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String newPassword) async {
    final student = currentStudent.value;
    if (student == null) return;
    try {
      isLoading.value = true;
      await _studentRepository.resetPassword(student.id, newPassword);
      Get.back(); // Close the dialog
      AppSnackBar.success('Password updated successfully');
    } catch (e) {
      AppSnackBar.error('Failed to reset password: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStudent() async {
    if (editingStudentId.value == null) return;
    try {
      isLoading.value = true;
      final success = await _studentRepository.deleteStudent(
        editingStudentId.value!,
      );
      if (success) {
        final instController = Get.find<InstituteController>();
        instController.students.removeWhere(
          (s) => s.id == editingStudentId.value,
        );
        instController.students.refresh();

        Get.back();
        instController.fetchStudents(reset: true);
      }
    } catch (e) {
      AppSnackBar.error('Delete failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void discardChanges() {
    Get.back();
  }

  void showGradeSelection(BuildContext context, List<String> grades) {
    Get.bottomSheet(
      Container(
        padding: AppSpacing.all24,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...grades.map(
              (grade) => ListTile(
                title: Text(grade),
                onTap: () {
                  selectedGrade.value = grade;
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
