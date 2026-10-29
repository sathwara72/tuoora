import 'package:tuoora/core/widgets/app_pickers.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/data/models/student_model.dart';
import 'package:tuoora/presentation/institute/models/fee_record.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/utils/currency_utils.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/data/repositories_impl/student_repository_impl.dart';
import 'institute_controller.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/api/api_exception.dart';

class RecordFeeController extends GetxController {
  final InstituteController instituteController =
      Get.find<InstituteController>();
  final InstituteRepositoryImpl _instituteRepository =
      Get.find<InstituteRepositoryImpl>();
  final StudentRepositoryImpl _studentRepository =
      Get.find<StudentRepositoryImpl>();

  final searchQuery = ''.obs;
  final isStudentSelected = false.obs;
  final selectedStudent = Rxn<Student>();
  final filteredStudents = <Student>[].obs;

  final selectedMonth = ''.obs;
  final amount = ''.obs;
  final paymentMethod = 'Cash'.obs;
  final selectedRecordDate = DateTime.now().obs;
  final isLoading = false.obs;

  final triedToSave = false.obs;
  final studentError = RxnString();
  final amountError = RxnString();

  /// True when every required field has a usable value, so the Preview
  /// Receipt action is safe to show. Mirrors the conditions [validateForm]
  /// would assert without mutating the error fields.
  bool get canPreview {
    if (selectedStudent.value == null) return false;
    final trimmed = amount.value.trim();
    if (trimmed.isEmpty) return false;
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed <= 0) return false;
    return true;
  }

  bool validateForm() {
    bool isValid = true;

    final studentVal = ValidationUtils.validateStudentSelection(
      selectedStudent.value,
    );
    studentError.value = studentVal;
    if (studentVal != null) isValid = false;

    final amountVal = ValidationUtils.validateAmount(amount.value, 'Amount');
    amountError.value = amountVal;
    if (amountVal != null) {
      isValid = false;
    } else if (selectedStudent.value != null) {
      final parsedAmount = double.tryParse(amount.value) ?? 0;
      final pendingFees = selectedStudent.value!.totalDue;
      if (parsedAmount > pendingFees) {
        amountError.value =
            'Amount cannot exceed pending fees of ${formatRupees(pendingFees)}';
        isValid = false;
      }
    }

    return isValid;
  }

  @override
  void onInit() {
    super.onInit();
    selectedMonth.value = DateFormat('MMMM yyyy').format(DateTime.now());
    // Initialize results with all students
    filteredStudents.assignAll(instituteController.students);

    // Setup search listener
    debounce(
      searchQuery,
      (_) => _performSearch(),
      time: const Duration(milliseconds: 300),
    );

    // Clear error when typing amount
    ever(amount, (_) {
      if (triedToSave.value && amountError.value != null) {
        amountError.value = null;
      }
    });
  }

  Future<void> _performSearch() async {
    if (searchQuery.value.isEmpty) {
      filteredStudents.assignAll(instituteController.students);
    } else {
      try {
        final students = await _studentRepository.listStudents(
          search: searchQuery.value,
        );
        filteredStudents.assignAll(students);
      } catch (e) {
        // Fallback to local filter if API fails
        filteredStudents.assignAll(
          instituteController.students
              .where(
                (s) =>
                    s.name.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ||
                    s.id.toString().toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ),
              )
              .toList(),
        );
      }
    }
  }

  final feeHistory = <FeePayment>[].obs;
  final isHistoryLoading = false.obs;
  final historyError = RxnString();

  /// The student has paid at least once, so there is history to show.
  bool get hasPaidBefore => (selectedStudent.value?.totalPaid ?? 0) > 0;

  Future<void> loadFeeHistory() async {
    final student = selectedStudent.value;
    if (student == null) return;
    try {
      isHistoryLoading.value = true;
      historyError.value = null;
      feeHistory.assignAll(
        await _instituteRepository.getStudentPayments(student.id),
      );
    } catch (e) {
      historyError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  void selectStudent(Student student) {
    selectedStudent.value = student;
    feeHistory.clear();
    isStudentSelected.value = true;
    searchQuery.value = '';
    studentError.value = null;
  }

  void changeStudent() {
    isStudentSelected.value = false;
    selectedStudent.value = null;
    _performSearch();
  }

  void setPaymentMethod(String method) {
    paymentMethod.value = method;
  }

  Future<void> selectRecordDate(BuildContext context) async {
    final DateTime? picked = await AppPickers.date(
      context,
      initialDate: selectedRecordDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedRecordDate.value = picked;
    }
  }

  Future<void> saveRecord() async {
    triedToSave.value = true;
    if (!validateForm()) return;

    try {
      isLoading.value = true;
      final data = {
        'student_id': selectedStudent.value!.id,
        'total_amount': double.parse(amount.value),
        'paid_amount': double.parse(amount.value),
        "status": "Paid",
        'date': DateFormat('yyyy-MM-dd').format(selectedRecordDate.value),
        'payment_method': paymentMethod.value,
      };

      await _instituteRepository.createFee(data);

      await instituteController.refreshFees();

      Get.back();
      AppSnackBar.success(AppStrings.feeRecordCreatedAndCollectedSuccessfully);
    } catch (e) {
      if (e is ValidationException) {
        _handleValidationErrors(e.errors);
        AppSnackBar.error(AppStrings.validationErrorsBelow);
      } else {
        final message = e.toString().replaceAll('Exception: ', '');
        // Over-payment 422s ("…more than the pending fee…", "…no pending
        // fees.") belong to the amount field.
        if (message.toLowerCase().contains('pending fee')) {
          amountError.value = message;
        }
        AppSnackBar.error(message);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _handleValidationErrors(Map<String, dynamic> errors) {
    if (errors.containsKey('student_id')) {
      studentError.value = (errors['student_id'] as List).first.toString();
    }
    if (errors.containsKey('total_amount')) {
      amountError.value = (errors['total_amount'] as List).first.toString();
    }
  }
}
