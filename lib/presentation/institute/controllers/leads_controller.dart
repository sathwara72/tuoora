import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/utils/url_launcher_utils.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/data/models/lead_model.dart';
import 'package:tuoora/data/repositories_impl/leads_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadsController extends GetxController {
  final LeadsRepositoryImpl _leadsRepository = Get.find<LeadsRepositoryImpl>();

  final leadsList = <Lead>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final triedToSave = false.obs;

  // Pagination
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final totalItems = 0.obs;

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final referenceController = TextEditingController();
  final courseController = TextEditingController();
  final notesController = TextEditingController();
  final noteTitleController = TextEditingController();

  // Field-specific errors
  final nameError = RxnString();
  final phoneError = RxnString();
  final emailError = RxnString();
  final courseError = RxnString();
  final addressError = RxnString();
  final referenceError = RxnString();
  final noteError = RxnString();
  final noteTitleError = RxnString();

  // Selected lead for details/edit
  final selectedLead = Rxn<Lead>();
  final editingLeadId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    fetchLeads();

    // Search debouncing
    debounce(
      searchQuery,
      (_) => fetchLeads(page: 1),
      time: const Duration(milliseconds: 500),
    );

    // Validation listeners
    nameController.addListener(() => _clearError(nameError));
    phoneController.addListener(() => _clearError(phoneError));
    emailController.addListener(() => _clearError(emailError));
    courseController.addListener(() => _clearError(courseError));
    addressController.addListener(() => _clearError(addressError));
    referenceController.addListener(() => _clearError(referenceError));
  }

  void _clearError(RxnString error) {
    if (triedToSave.value && error.value != null) {
      error.value = null;
    }
  }

  bool _isLoadingMore = false;
  int _requestId = 0;

  Future<void> fetchLeads({int page = 1}) async {
    final requestId = ++_requestId;
    try {
      if (page == 1) isLoading.value = true;
      final response = await _leadsRepository.getLeads(
        page: page,
        search: searchQuery.value,
      );

      // A newer search or refresh has replaced the list; drop this response.
      if (requestId != _requestId) return;

      if (page == 1) {
        leadsList.assignAll(response.data);
      } else {
        // Page offsets shift when items are added, so skip rows already shown.
        final loadedIds = leadsList.map((item) => item.id).toSet();
        leadsList.addAll(response.data.where((item) => loadedIds.add(item.id)));
      }

      currentPage.value = response.currentPage;
      lastPage.value = response.lastPage;
      totalItems.value = response.total;
    } catch (e) {
      if (requestId == _requestId) {
        AppSnackBar.error('Failed to load leads: $e');
      }
    } finally {
      if (page == 1 && requestId == _requestId) isLoading.value = false;
    }
  }

  Future<void> loadMoreLeads() async {
    if (_isLoadingMore ||
        isLoading.value ||
        currentPage.value >= lastPage.value) {
      return;
    }
    _isLoadingMore = true;
    try {
      await fetchLeads(page: currentPage.value + 1);
    } finally {
      _isLoadingMore = false;
    }
  }

  void prepareForAdd() {
    editingLeadId.value = null;
    selectedLead.value = null;
    _clearForm();
  }

  void prepareForEdit(Lead lead) {
    editingLeadId.value = lead.id;
    selectedLead.value = lead;
    nameController.text = lead.fullName;
    emailController.text = lead.email;
    phoneController.text = lead.phone;
    addressController.text = lead.address ?? '';
    referenceController.text = lead.reference ?? '';
    courseController.text = lead.courseSelection ?? '';

    noteTitleController.clear();
    notesController.clear();

    triedToSave.value = false;
    _resetErrors();
  }

  void _clearForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    referenceController.clear();
    courseController.clear();
    notesController.clear();
    noteTitleController.clear();
    triedToSave.value = false;
    _resetErrors();
  }

  void _resetErrors() {
    nameError.value = null;
    phoneError.value = null;
    emailError.value = null;
    courseError.value = null;
    addressError.value = null;
    referenceError.value = null;
    noteError.value = null;
    noteTitleError.value = null;
  }

  Future<void> saveLead() async {
    triedToSave.value = true;
    if (!_validateForm()) return;

    try {
      isLoading.value = true;
      final leadData = {
        'full_name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'reference': referenceController.text.trim(),
        'course_selection': courseController.text.trim(),
      };

      if (editingLeadId.value == null) {
        await _leadsRepository.createLead(leadData);
        searchQuery.value = '';
        Get.back();
        AppSnackBar.success(AppStrings.leadCreatedSuccessfully);
      } else {
        await _leadsRepository.updateLead(editingLeadId.value!, leadData);
        Get.back();
        AppSnackBar.success(AppStrings.leadUpdatedSuccessfully);
      }
      fetchLeads(page: 1);
    } catch (e) {
      if (e is ValidationException) {
        _handleValidationErrors(e.errors);
        AppSnackBar.error(AppStrings.validationErrorsBelow);
      } else {
        AppSnackBar.error('Failed to save lead: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _handleValidationErrors(Map<String, dynamic> errors) {
    if (errors.containsKey('full_name')) {
      nameError.value = (errors['full_name'] as List).first.toString();
    }
    if (errors.containsKey('phone')) {
      phoneError.value = (errors['phone'] as List).first.toString();
    }
    if (errors.containsKey('email')) {
      emailError.value = (errors['email'] as List).first.toString();
    }
    if (errors.containsKey('course_selection')) {
      courseError.value = (errors['course_selection'] as List).first.toString();
    }
    if (errors.containsKey('address')) {
      addressError.value = (errors['address'] as List).first.toString();
    }
    if (errors.containsKey('reference')) {
      referenceError.value = (errors['reference'] as List).first.toString();
    }
    if (errors.containsKey('title')) {
      noteTitleError.value = (errors['title'] as List).first.toString();
    }
    if (errors.containsKey('note')) {
      noteError.value = (errors['note'] as List).first.toString();
    }
  }

  bool _validateForm() {
    bool isValid = true;

    final nErr = ValidationUtils.validateRequired(
      nameController.text,
      'Full Name',
    );
    nameError.value = nErr;
    if (nErr != null) isValid = false;

    final pErr = ValidationUtils.validatePhone(phoneController.text);
    phoneError.value = pErr;
    if (pErr != null) isValid = false;

    final eErr = ValidationUtils.validateEmail(emailController.text);
    emailError.value = eErr;
    if (eErr != null) isValid = false;

    final cErr = ValidationUtils.validateRequired(
      courseController.text,
      'Course',
    );
    courseError.value = cErr;
    if (cErr != null) isValid = false;

    final aErr = ValidationUtils.validateRequired(
      addressController.text,
      'Address',
    );
    addressError.value = aErr;
    if (aErr != null) isValid = false;

    final rErr = ValidationUtils.validateRequired(
      referenceController.text,
      'Reference',
    );
    referenceError.value = rErr;
    if (rErr != null) isValid = false;

    // if (editingLeadId.value == null) {
    //   final ntErr = ValidationUtils.validateRequired(
    //     noteTitleController.text,
    //     'Note Title',
    //   );
    //   noteTitleError.value = ntErr;
    //   if (ntErr != null) isValid = false;
    //
    //   final nCerr = ValidationUtils.validateRequired(
    //     notesController.text,
    //     'Note',
    //   );
    //   noteError.value = nCerr;
    //   if (nCerr != null) isValid = false;
    // }

    return isValid;
  }

  Future<void> deleteLead(int id) async {
    try {
      isLoading.value = true;
      Get.dialog(
        const Center(child: CommonLoading()),
        barrierDismissible: false,
      );
      await _leadsRepository.deleteLead(id);
      leadsList.removeWhere((l) => l.id == id);
      Get.back(); // Dismiss loading dialog
      AppSnackBar.success(AppStrings.leadDeletedSuccessfully);
    } catch (e) {
      Get.back(); // Dismiss loading dialog
      AppSnackBar.error('Failed to delete lead: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> callLead(String phone) => UrlLauncherUtils.callPhone(phone);

  Future<void> addLeadNote() async {
    if (selectedLead.value == null) return;

    final title = noteTitleController.text.trim();
    final note = notesController.text.trim();

    triedToSave.value = true;
    _resetErrors();

    bool isValid = true;
    if (title.isEmpty) {
      noteTitleError.value = 'Note title is required';
      isValid = false;
    }
    if (note.isEmpty) {
      noteError.value = 'Note description is required';
      isValid = false;
    }

    if (!isValid) return;

    try {
      isLoading.value = true;
      final newNote = await _leadsRepository.addLeadNote(
        selectedLead.value!.id,
        {'title': title, 'note': note},
      );

      // Update current lead's notes
      final currentLead = selectedLead.value!;
      final updatedNotes = List<LeadNote>.from(currentLead.notes);
      updatedNotes.insert(0, newNote);

      selectedLead.value = Lead(
        id: currentLead.id,
        instituteId: currentLead.instituteId,
        fullName: currentLead.fullName,
        phone: currentLead.phone,
        email: currentLead.email,
        status: currentLead.status,
        address: currentLead.address,
        courseSelection: currentLead.courseSelection,
        reference: currentLead.reference,
        notes: updatedNotes,
        createdAt: currentLead.createdAt,
      );

      // Clear main list cache if necessary, or update it
      final index = leadsList.indexWhere((l) => l.id == currentLead.id);
      if (index != -1) {
        leadsList[index] = selectedLead.value!;
        leadsList.refresh();
      }

      noteTitleController.clear();
      notesController.clear();
      triedToSave.value = false;

      Get.back(); // Close dialog
      AppSnackBar.success(AppStrings.interactionNoteAddedSuccessfully);
    } catch (e) {
      if (e is ValidationException) {
        _handleValidationErrors(e.errors);
      } else {
        AppSnackBar.error('Failed to add note: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    referenceController.dispose();
    courseController.dispose();
    notesController.dispose();
    noteTitleController.dispose();
    super.onClose();
  }
}
