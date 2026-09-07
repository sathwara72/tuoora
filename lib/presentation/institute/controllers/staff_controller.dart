import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/models/staff_model.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StaffController extends GetxController {
  final InstituteRepositoryImpl _repository;

  StaffController(this._repository);

  final isLoading = false.obs;
  final isSaving = false.obs;
  final staffList = <Staff>[].obs;
  final searchQuery = ''.obs;
  final selectedStaff = Rxn<Staff>();
  final selectedImagePath = Rxn<String>();

  // Metadata
  final departments = <StaffDepartment>[].obs;
  final isLoadingMetadata = false.obs;

  // Pagination
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final totalItems = 0.obs;

  // Tab index for bottom navigation
  final currentTabIndex = 0.obs;

  // Salary History State
  final salaryList = <StaffSalary>[].obs;
  final isLoadingSalary = false.obs;
  final totalSalaryAmount = '0.00'.obs;
  final salaryCurrentPage = 1.obs;
  final salaryLastPage = 1.obs;

  // Attendance History State
  final attendanceList = <StaffAttendance>[].obs;
  final isLoadingAttendance = false.obs;
  final totalPresent = 0.obs;
  final totalAbsent = 0.obs;
  final attendanceCurrentPage = 1.obs;
  final attendanceLastPage = 1.obs;
  final selectedAttendanceMonth = DateTime.now().obs;

  // Global Attendance Logs (for StaffMainScreen)
  final globalAttendanceList = <StaffAttendance>[].obs;
  final isLoadingGlobalAttendance = false.obs;
  final globalAttendanceCurrentPage = 1.obs;
  final globalAttendanceLastPage = 1.obs;
  final selectedGlobalAttendanceMonth = DateTime.now().obs;

  // Global Salary State (for StaffMainScreen)
  final globalSalaryList = <StaffSalary>[].obs;
  final isLoadingGlobalSalaries = false.obs;
  final totalGlobalSalaryAmount = '0.00'.obs;
  final globalSalaryCurrentPage = 1.obs;
  final globalSalaryLastPage = 1.obs;
  final selectedSalaryMonth = DateTime.now().obs;

  bool get canGoToNextSalaryMonth {
    final now = DateTime.now();
    if (selectedSalaryMonth.value.year < now.year) return true;
    if (selectedSalaryMonth.value.year == now.year &&
        selectedSalaryMonth.value.month < now.month) {
      return true;
    }
    return false;
  }

  bool get canGoToNextAttendanceMonth {
    final now = DateTime.now();
    if (selectedGlobalAttendanceMonth.value.year < now.year) return true;
    if (selectedGlobalAttendanceMonth.value.year == now.year &&
        selectedGlobalAttendanceMonth.value.month < now.month) {
      return true;
    }
    return false;
  }

  bool get canGoToNextStaffAttendanceMonth {
    final now = DateTime.now();
    if (selectedAttendanceMonth.value.year < now.year) return true;
    if (selectedAttendanceMonth.value.year == now.year &&
        selectedAttendanceMonth.value.month < now.month) {
      return true;
    }
    return false;
  }

  bool get canGoToPrevStaffAttendanceMonth {
    final staff = selectedStaff.value;
    if (staff == null) return true;
    final createdAt = staff.createdAt;
    if (createdAt == null) return true;

    final prevMonthDate = DateTime(
      selectedAttendanceMonth.value.year,
      selectedAttendanceMonth.value.month - 1,
    );
    final createdMonthStart = DateTime(createdAt.year, createdAt.month, 1);
    if (prevMonthDate.isBefore(createdMonthStart)) {
      return false;
    }
    return true;
  }

  // Add/Edit Staff Reactive State
  final selectedDepartmentIds = <int>[].obs;
  final isDepartmentPickerOpen = false.obs;
  final employmentType = 'Salary'.obs;

  final staffNameController = TextEditingController();
  final staffEmailController = TextEditingController();
  final staffPhoneController = TextEditingController();
  final staffSalaryController = TextEditingController();
  final addStaffFormKey = GlobalKey<FormState>();

  // Form field errors
  final staffNameError = RxnString();
  final staffEmailError = RxnString();
  final staffPhoneError = RxnString();
  final staffSalaryError = RxnString();
  final deptError = RxnString();
  final triedToSave = false.obs;

  // Staff account management (staff profile screen)
  final isSendingPassword = false.obs;
  final isTogglingBlock = false.obs;

  // Log Attendance State
  final selectedLogStaff = Rxn<Staff>();
  final selectedLogDate = DateTime.now().obs;
  final isPresent = true.obs;
  final logSearchQuery = ''.obs;
  final logNotesController = TextEditingController();
  final filteredLogStaffs = <Staff>[].obs;

  // Add Salary State
  final selectedAddSalaryStaff = Rxn<Staff>();
  final salarySearchQuery = ''.obs;
  final selectedSalaryDate = DateTime.now().obs;
  final isOnlinePayment = true.obs;
  final salaryAmountController = TextEditingController();
  final salaryNotesController = TextEditingController();
  final salaryDateController = TextEditingController();
  final salaryDeductionController = TextEditingController();
  // Read-only display of the leaves count returned by the salary preview
  // endpoint. Kept as a TextEditingController so the leaves tile can reuse
  // the same AppInputField widget as every other input, guaranteeing the
  // row aligns horizontally with the deduction field next to it.
  final salaryLeavesDisplayController = TextEditingController(text: '0');
  final filteredSalaryStaffs = <Staff>[].obs;
  final salaryPreview = Rxn<SalaryPreview>();
  final isLoadingSalaryPreview = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMetadata();
    fetchStaffs();
    debounce(
      searchQuery,
      (_) => fetchStaffs(page: 1),
      time: const Duration(milliseconds: 500),
    );

    // Validation listeners
    staffNameController.addListener(() => _clearError(staffNameError));
    staffEmailController.addListener(() => _clearError(staffEmailError));
    staffPhoneController.addListener(() => _clearError(staffPhoneError));
    staffSalaryController.addListener(() => _clearError(staffSalaryError));
    ever(selectedDepartmentIds, (_) => _clearError(deptError));

    // Initialize salary date controller
    salaryDateController.text = DateFormat(
      'MM/dd/yyyy',
    ).format(selectedSalaryDate.value);
    selectedSalaryDate.listen((date) {
      salaryDateController.text = DateFormat('MM/dd/yyyy').format(date);
    });

    // Keep the Total Disbursement summary in sync — any edit to salary
    // amount OR deduction recomputes the net via GetBuilder.update(). Wired
    // here (not via onChanged in the view) so the behaviour can't be lost
    // to an accidental edit in the screen widget.
    salaryAmountController.addListener(update);
    salaryDeductionController.addListener(update);
  }

  /// Wipes the Add Salary form so re-opening the screen starts clean —
  /// otherwise the controller is alive for the whole session and previous
  /// staff / amount / deduction values bleed into a fresh visit.
  void initAddSalaryMode() {
    selectedAddSalaryStaff.value = null;
    salaryPreview.value = null;
    isLoadingSalaryPreview.value = false;
    salaryAmountController.clear();
    salaryDeductionController.clear();
    salaryNotesController.clear();
    salaryLeavesDisplayController.text = '0';
    selectedSalaryDate.value = DateTime.now();
    isOnlinePayment.value = true;
    salarySearchQuery.value = '';
    filteredSalaryStaffs.clear();
  }

  void _clearError(RxnString error) {
    if (triedToSave.value && error.value != null) {
      error.value = null;
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
    if (index == 1) {
      fetchGlobalAttendance(page: 1);
    } else if (index == 2) {
      fetchGlobalSalaries(page: 1);
    }
  }

  Future<void> fetchMetadata() async {
    try {
      isLoadingMetadata.value = true;
      final depts = await _repository.getStaffDepartments();
      departments.assignAll(depts);
    } catch (e) {
      AppSnackBar.error('Failed to load departments: $e');
    } finally {
      isLoadingMetadata.value = false;
    }
  }

  Future<void> fetchStaffs({int page = 1}) async {
    try {
      if (page == 1) isLoading.value = true;
      final response = await _repository.listStaff(
        page: page,
        search: searchQuery.value,
      );
      if (page == 1) {
        staffList.assignAll(response.items);
      } else {
        staffList.addAll(response.items);
      }
      currentPage.value = response.currentPage;
      lastPage.value = response.lastPage;
      totalItems.value = response.total;
    } catch (e) {
      AppSnackBar.error('Failed to load staff: $e');
    } finally {
      if (page == 1) isLoading.value = false;
    }
  }

  Future<void> fetchSalaryHistory({int page = 1}) async {
    if (selectedStaff.value == null) return;
    try {
      if (page == 1) isLoadingSalary.value = true;
      final response = await _repository.getStaffSalaries(
        selectedStaff.value!.id,
        page: page,
      );
      if (page == 1) {
        final items = response.items;
        items.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
        salaryList.assignAll(items);
      } else {
        salaryList.addAll(response.items);
        salaryList.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      }
      totalSalaryAmount.value = response.totalAmount;
      salaryCurrentPage.value = response.currentPage;
      salaryLastPage.value = response.lastPage;
    } catch (e) {
      AppSnackBar.error('Failed to load salary history: $e');
    } finally {
      if (page == 1) isLoadingSalary.value = false;
    }
  }

  Future<void> fetchAttendanceHistory({int page = 1}) async {
    if (selectedStaff.value == null) return;
    try {
      if (page == 1) isLoadingAttendance.value = true;
      final response = await _repository.getStaffAttendance(
        selectedStaff.value!.id,
        page: page,
        month: DateFormat('MM').format(selectedAttendanceMonth.value),
        year: DateFormat('yyyy').format(selectedAttendanceMonth.value),
      );
      if (page == 1) {
        final items = response.items;
        items.sort((a, b) => b.date.compareTo(a.date));
        attendanceList.assignAll(items);
      } else {
        attendanceList.addAll(response.items);
        attendanceList.sort((a, b) => b.date.compareTo(a.date));
      }
      totalPresent.value = response.totalPresent;
      totalAbsent.value = response.totalAbsent;
      attendanceCurrentPage.value = response.currentPage;
      attendanceLastPage.value = response.lastPage;
    } catch (e) {
      AppSnackBar.error('Failed to load attendance history: $e');
    } finally {
      if (page == 1) isLoadingAttendance.value = false;
    }
  }

  Future<void> fetchGlobalSalaries({int? page}) async {
    final isInitialFetch = page == null || page == 1;
    try {
      if (isInitialFetch) isLoadingGlobalSalaries.value = true;
      final response = await _repository.getGlobalSalaries(
        page: page,
        month: selectedSalaryMonth.value.month.toString(),
        year: selectedSalaryMonth.value.year.toString(),
      );
      if (isInitialFetch) {
        final items = response.items;
        items.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
        globalSalaryList.assignAll(items);
      } else {
        globalSalaryList.addAll(response.items);
        globalSalaryList.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      }
      totalGlobalSalaryAmount.value = response.totalAmount;
      globalSalaryCurrentPage.value = response.currentPage;
      globalSalaryLastPage.value = response.lastPage;
    } catch (e) {
      AppSnackBar.error('Failed to load salary logs: $e');
    } finally {
      if (isInitialFetch) isLoadingGlobalSalaries.value = false;
    }
  }

  Future<void> saveSalaryRecord() async {
    final staffError = ValidationUtils.validateStaffSelection(
      selectedAddSalaryStaff.value,
    );
    if (staffError != null) {
      AppSnackBar.error(staffError);
      return;
    }

    final amountError = ValidationUtils.validateAmount(
      salaryAmountController.text,
      'Salary amount',
    );
    if (amountError != null) {
      AppSnackBar.error(amountError);
      return;
    }

    try {
      isSaving.value = true;
      final deductionRaw = salaryDeductionController.text.trim();
      final data = {
        'staff_id': selectedAddSalaryStaff.value?.id,
        'base_salary': salaryAmountController.text.trim(),
        'payment_date': DateFormat(
          'yyyy-MM-dd',
        ).format(selectedSalaryDate.value),
        'status': 'Paid',
        'payment_method': isOnlinePayment.value ? 'Online' : 'Cash',
        if (deductionRaw.isNotEmpty) 'deductions': deductionRaw,
        if (salaryNotesController.text.isNotEmpty)
          'notes': salaryNotesController.text.trim(),
      };

      await _repository.logSalary(data);
      AppSnackBar.success(AppStrings.salaryRecordSavedSuccessfully);

      fetchGlobalSalaries(page: 1);

      if (selectedStaff.value != null &&
          selectedStaff.value!.id == selectedAddSalaryStaff.value!.id) {
        fetchSalaryHistory(page: 1);
      }

      // Robust navigation: go back to StaffMainScreen and set tab to Salary
      Get.until((route) => route.settings.name == AppRoutes.instituteStaffs);
      currentTabIndex.value = 2;
    } catch (e) {
      AppSnackBar.error('Failed to save salary record: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> fetchGlobalAttendance({int? page}) async {
    try {
      final isInitialFetch = page == null || page == 1;
      if (isInitialFetch) isLoadingGlobalAttendance.value = true;
      final response = await _repository.getAttendanceLogs(
        page: page,
        month: selectedGlobalAttendanceMonth.value.month.toString(),
        year: selectedGlobalAttendanceMonth.value.year.toString(),
      );
      if (isInitialFetch) {
        final items = response.items;
        items.sort((a, b) => b.date.compareTo(a.date));
        globalAttendanceList.assignAll(items);
      } else {
        globalAttendanceList.addAll(response.items);
        globalAttendanceList.sort((a, b) => b.date.compareTo(a.date));
      }
      globalAttendanceCurrentPage.value = response.currentPage;
      globalAttendanceLastPage.value = response.lastPage;
    } catch (e) {
      AppSnackBar.error('Failed to load attendance logs: $e');
    } finally {
      if (page == null || page == 1) isLoadingGlobalAttendance.value = false;
    }
  }

  Future<void> saveAttendanceRecord() async {
    final staffError = ValidationUtils.validateStaffSelection(
      selectedLogStaff.value,
    );
    if (staffError != null) {
      AppSnackBar.error(staffError);
      return;
    }

    try {
      isSaving.value = true;
      final data = {
        'date': DateFormat('yyyy-MM-dd').format(selectedLogDate.value),
        'staff_id': selectedLogStaff.value!.id,
        'status': isPresent.value ? 'Present' : 'Absent',
        'note': logNotesController.text.trim(),
      };

      await _repository.logStaffAttendance(data);
      AppSnackBar.success(AppStrings.attendanceLoggedSuccessfully);

      // Refresh logs
      fetchGlobalAttendance(page: 1);

      // If we are on a specific staff's profile, refresh their attendance too
      if (selectedStaff.value?.id == selectedLogStaff.value!.id) {
        fetchAttendanceHistory(page: 1);
      }

      // Robust navigation: go back to StaffMainScreen and set tab to Attendance
      Get.until((route) => route.settings.name == AppRoutes.instituteStaffs);
      currentTabIndex.value = 1;
      fetchGlobalAttendance(page: 1); // Refresh logs to show new entry

      // Reset state
      selectedLogStaff.value = null;
      logNotesController.clear();
    } catch (e) {
      AppSnackBar.error('Failed to log attendance: $e');
    } finally {
      isSaving.value = false;
    }
  }

  void nextMonth() {
    selectedAttendanceMonth.value = DateTime(
      selectedAttendanceMonth.value.year,
      selectedAttendanceMonth.value.month + 1,
    );
    fetchAttendanceHistory(page: 1);
  }

  void previousMonth() {
    selectedAttendanceMonth.value = DateTime(
      selectedAttendanceMonth.value.year,
      selectedAttendanceMonth.value.month - 1,
    );
    fetchAttendanceHistory(page: 1);
  }

  // Local searching for Log/Add screens
  void searchLogStaff(String query) {
    logSearchQuery.value = query;
    if (query.isEmpty) {
      filteredLogStaffs.clear();
    } else {
      filteredLogStaffs.assignAll(
        staffList.where(
          (s) =>
              s.fullName.toLowerCase().contains(query.toLowerCase()) ||
              (s.role?.name ?? "").toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void searchSalaryStaff(String query) {
    salarySearchQuery.value = query;
    if (query.isEmpty) {
      filteredSalaryStaffs.clear();
    } else {
      filteredSalaryStaffs.assignAll(
        staffList.where(
          (s) =>
              s.fullName.toLowerCase().contains(query.toLowerCase()) ||
              (s.role?.name ?? "").toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void selectLogDate(DateTime date) => selectedLogDate.value = date;
  void toggleStatus(bool present) => isPresent.value = present;
  void setLogStaff(Staff staff) {
    selectedLogStaff.value = staff;
    logSearchQuery.value = '';
    filteredLogStaffs.clear();
  }

  void selectLogStaffById(int? id) {
    if (id == null) {
      removeLogStaff();
      return;
    }
    final staff = staffList.firstWhereOrNull((s) => s.id == id);
    if (staff != null) setLogStaff(staff);
  }

  void removeLogStaff() => selectedLogStaff.value = null;

  void selectSalaryMonth(DateTime date) => selectedSalaryMonth.value = date;
  void setSalaryStaff(Staff staff) {
    selectedAddSalaryStaff.value = staff;
    salarySearchQuery.value = '';
    filteredSalaryStaffs.clear();
    salaryAmountController.text = staff.baseSalary;
    salaryDeductionController.clear();
    fetchSalaryPreview(staff.id);
  }

  /// Dropdown helper — looks up the [Staff] in [staffList] by id and
  /// delegates to [setSalaryStaff] so the same selection side-effects
  /// (preview fetch, amount prefill) fire regardless of entry path.
  void selectSalaryStaffById(int? id) {
    if (id == null) {
      removeSalaryStaff();
      return;
    }
    final staff = staffList.firstWhereOrNull((s) => s.id == id);
    if (staff != null) setSalaryStaff(staff);
  }

  void removeSalaryStaff() {
    selectedAddSalaryStaff.value = null;
    salaryPreview.value = null;
    salaryDeductionController.clear();
  }

  Future<void> fetchSalaryPreview(int staffId) async {
    try {
      isLoadingSalaryPreview.value = true;
      salaryPreview.value = null;
      salaryLeavesDisplayController.text = '0';
      final preview = await _repository.getSalaryPreview(staffId);
      salaryPreview.value = preview;
      salaryLeavesDisplayController.text = preview.leaves.toString();
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToLoadSalaryPreview);
    } finally {
      isLoadingSalaryPreview.value = false;
    }
  }
  void selectSalaryDate(DateTime date) => selectedSalaryDate.value = date;
  void togglePaymentMethod(bool isOnline) => isOnlinePayment.value = isOnline;

  Future<void> loadMoreStaff() async {
    if (currentPage.value < lastPage.value && !isLoading.value) {
      await fetchStaffs(page: currentPage.value + 1);
    }
  }

  Future<void> saveStaff() async {
    triedToSave.value = true;
    _resetFormErrors();

    // Perform manual validation to populate error observables
    staffNameError.value = ValidationUtils.validateRequired(
      staffNameController.text,
      'Full name',
    );
    staffEmailError.value = ValidationUtils.validateEmail(
      staffEmailController.text,
    );
    staffPhoneError.value = ValidationUtils.validatePhone(
      staffPhoneController.text,
    );
    staffSalaryError.value = ValidationUtils.validateAmount(
      staffSalaryController.text,
      employmentType.value == 'Salary' ? 'Base Salary' : 'Hourly Rate',
    );
    deptError.value = selectedDepartmentIds.isEmpty
        ? 'Please select at least one department'
        : null;

    // Check if any validation failed
    if (staffNameError.value != null ||
        staffEmailError.value != null ||
        staffPhoneError.value != null ||
        staffSalaryError.value != null ||
        deptError.value != null) {
      return;
    }

    try {
      isSaving.value = true;
      final data = {
        'full_name': staffNameController.text.trim(),
        'email': staffEmailController.text.trim(),
        'phone': staffPhoneController.text.trim(),
        'staff_department_ids': selectedDepartmentIds.join(','),
        'employment_type': employmentType.value,
        'base_salary': staffSalaryController.text.trim(),
      };

      if (selectedStaff.value != null) {
        final updated = await _repository.updateStaff(
          selectedStaff.value!.id,
          data,
          selectedImagePath.value,
        );
        int index = staffList.indexWhere((s) => s.id == updated.id);
        if (index != -1) staffList[index] = updated;
        selectedStaff.value = updated;
        AppSnackBar.success(AppStrings.staffUpdatedSuccessfully);
      } else {
        final created = await _repository.createStaff(
          data,
          selectedImagePath.value,
        );
        staffList.insert(0, created);
        AppSnackBar.success(AppStrings.staffCreatedSuccessfully);
      }

      // Robust navigation: go back to StaffMainScreen and set tab to Staff
      Get.until((route) => route.settings.name == AppRoutes.instituteStaffs);
      currentTabIndex.value = 0;
    } catch (e) {
      if (e is ValidationException) {
        _handleValidationErrors(e.errors);
        AppSnackBar.error(AppStrings.validationErrorsBelow);
      } else {
        AppSnackBar.error('Failed to save staff: $e');
      }
    } finally {
      isSaving.value = false;
    }
  }

  void _handleValidationErrors(Map<String, dynamic> errors) {
    if (errors.containsKey('full_name')) {
      staffNameError.value = (errors['full_name'] as List).first.toString();
    }
    if (errors.containsKey('phone')) {
      staffPhoneError.value = (errors['phone'] as List).first.toString();
    }
    if (errors.containsKey('email')) {
      staffEmailError.value = (errors['email'] as List).first.toString();
    }
    if (errors.containsKey('base_salary')) {
      staffSalaryError.value = (errors['base_salary'] as List).first.toString();
    }
    if (errors.containsKey('staff_department_id')) {
      deptError.value = (errors['staff_department_id'] as List).first
          .toString();
    }
  }

  void _resetFormErrors() {
    staffNameError.value = null;
    staffEmailError.value = null;
    staffPhoneError.value = null;
    staffSalaryError.value = null;
    deptError.value = null;
  }

  Future<void> deleteStaff(int id) async {
    try {
      isLoading.value = true;
      await _repository.deleteStaff(id);
      staffList.removeWhere((s) => s.id == id);
      AppSnackBar.success(AppStrings.staffDeletedSuccessfully);

      if (Get.currentRoute == AppRoutes.instituteStaffDetails) {
        Get.back();
      }
    } catch (e) {
      AppSnackBar.error('Failed to delete staff: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendStaffPassword() async {
    final staff = selectedStaff.value;
    if (staff == null) return;
    try {
      isSendingPassword.value = true;
      final message = await _repository.sendStaffPassword(staff.id);
      AppSnackBar.success(message);
    } catch (e) {
      AppSnackBar.error('Failed to send password: $e');
    } finally {
      isSendingPassword.value = false;
    }
  }

  Future<void> changeStaffEmail(String email) async {
    final staff = selectedStaff.value;
    if (staff == null) return;
    try {
      isSaving.value = true;
      final updated = await _repository.changeStaffEmail(staff.id, email);
      selectedStaff.value = updated;
      final index = staffList.indexWhere((s) => s.id == updated.id);
      if (index != -1) staffList[index] = updated;
      Get.back();
      AppSnackBar.success('Staff login email updated successfully!');
    } catch (e) {
      AppSnackBar.error(_firstErrorMessage(e, 'Failed to update email'));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleStaffBlock() async {
    final staff = selectedStaff.value;
    if (staff == null) return;
    try {
      isTogglingBlock.value = true;
      final updated = await _repository.toggleStaffBlock(
        staff.id,
        !staff.isLoginBlocked,
      );
      selectedStaff.value = updated;
      final index = staffList.indexWhere((s) => s.id == updated.id);
      if (index != -1) staffList[index] = updated;
      AppSnackBar.success(
        updated.isLoginBlocked
            ? 'Staff login has been blocked.'
            : 'Staff login has been unblocked.',
      );
    } catch (e) {
      AppSnackBar.error('Failed to update login access: $e');
    } finally {
      isTogglingBlock.value = false;
    }
  }

  String _firstErrorMessage(Object e, String fallback) {
    if (e is ValidationException) {
      final first = e.errors.values.first;
      return first is List ? first.first.toString() : first.toString();
    }
    return '$fallback: $e';
  }

  void clearStaffForm() {
    staffNameController.clear();
    staffEmailController.clear();
    staffPhoneController.clear();
    staffSalaryController.clear();
    selectedDepartmentIds.clear();
    isDepartmentPickerOpen.value = false;
    employmentType.value = 'Salary';
    selectedImagePath.value = null;
    selectedStaff.value = null;
    triedToSave.value = false;
    _resetFormErrors();
  }

  void loadStaffForEdit(Staff staff) {
    selectedStaff.value = staff;
    staffNameController.text = staff.fullName;
    staffEmailController.text = staff.email;
    staffPhoneController.text = staff.phone;
    staffSalaryController.text = staff.baseSalary;
    selectedDepartmentIds.assignAll(staff.departmentIds);
    employmentType.value = staff.employmentType;
    selectedImagePath.value = null;
    triedToSave.value = false;
    _resetFormErrors();
  }

  /// Toggles a department's selection for the multi-select department field
  /// on the Add/Edit Staff form.
  void toggleDepartment(int departmentId) {
    if (selectedDepartmentIds.contains(departmentId)) {
      selectedDepartmentIds.remove(departmentId);
    } else {
      selectedDepartmentIds.add(departmentId);
    }
  }

  void selectStaff(Staff staff) {
    selectedStaff.value = staff;
    fetchSalaryHistory(page: 1);
    fetchAttendanceHistory(page: 1);
  }

  void prepareForAdd() => clearStaffForm();

  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (image != null) selectedImagePath.value = image.path;
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

  @override
  void onClose() {
    staffNameController.dispose();
    staffEmailController.dispose();
    staffPhoneController.dispose();
    staffSalaryController.dispose();
    salaryAmountController.dispose();
    salaryNotesController.dispose();
    salaryDateController.dispose();
    salaryDeductionController.dispose();
    salaryLeavesDisplayController.dispose();
    logNotesController.dispose();
    super.onClose();
  }
}
