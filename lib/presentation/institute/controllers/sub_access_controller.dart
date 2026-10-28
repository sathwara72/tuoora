import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/models/sub_access_model.dart';
import 'package:tuoora/data/repositories/sub_access_repository.dart';

/// Access Share: lets the owner manage sub-access users and their
/// permissions (list, add/edit, delete, enable/disable, log out, reset password).
class SubAccessController extends GetxController {
  final SubAccessRepository _repository;

  SubAccessController(this._repository);

  final isLoading = false.obs;
  final isSaving = false.obs;
  final users = <SubAccessUser>[].obs;
  final permissionGroups = <SubAccessPermissionGroup>[].obs;
  final searchQuery = ''.obs;

  /// Ids with a row action (toggle / logout / reset / delete) in progress.
  final busyIds = <int>{}.obs;

  // Add / edit form
  final editingUser = Rxn<SubAccessUser>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final selectedPermissions = <String>{}.obs;
  final isPasswordVisible = false.obs;
  final nameError = RxnString();
  final emailError = RxnString();
  final phoneError = RxnString();
  final passwordError = RxnString();

  bool get isEditing => editingUser.value != null;

  List<SubAccessUser> get filteredUsers {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return users;
    return users
        .where(
          (u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q) ||
              (u.phone ?? '').contains(q),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final result = await _repository.list();
      users.assignAll(result.users);
      if (result.groups.isNotEmpty) permissionGroups.assignAll(result.groups);
    } catch (e) {
      AppSnackBar.error(_message(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _ensurePermissions() async {
    if (permissionGroups.isNotEmpty) return;
    try {
      permissionGroups.assignAll(await _repository.getPermissions());
    } catch (e) {
      AppSnackBar.error(_message(e));
    }
  }

  void prepareForAdd() {
    editingUser.value = null;
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    selectedPermissions.clear();
    _clearErrors();
    _ensurePermissions();
  }

  void prepareForEdit(SubAccessUser user) {
    editingUser.value = user;
    nameController.text = user.name;
    emailController.text = user.email;
    phoneController.text = user.phone ?? '';
    passwordController.clear();
    selectedPermissions
      ..clear()
      ..addAll(user.permissions);
    _clearErrors();
    _ensurePermissions();
  }

  void _clearErrors() {
    nameError.value = null;
    emailError.value = null;
    phoneError.value = null;
    passwordError.value = null;
    isPasswordVisible.value = false;
  }

  void togglePermission(String key, bool selected) {
    if (selected) {
      selectedPermissions.add(key);
    } else {
      selectedPermissions.remove(key);
    }
  }

  bool isGroupFullySelected(SubAccessPermissionGroup group) =>
      group.permissions.every((p) => selectedPermissions.contains(p.key));

  void toggleGroup(SubAccessPermissionGroup group, bool selected) {
    for (final p in group.permissions) {
      togglePermission(p.key, selected);
    }
  }

  bool _validate() {
    nameError.value = ValidationUtils.validateRequired(
      nameController.text,
      'Name',
    );
    final email = emailController.text.trim();
    emailError.value = email.isEmpty
        ? 'Email is required'
        : ValidationUtils.validateOptionalEmail(email);
    final phone = phoneController.text.trim();
    phoneError.value = phone.isEmpty
        ? null
        : ValidationUtils.validatePhone(phone);
    final password = passwordController.text;
    if (!isEditing && password.isEmpty) {
      passwordError.value = 'Password is required';
    } else if (password.isNotEmpty && password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
    } else {
      passwordError.value = null;
    }
    return nameError.value == null &&
        emailError.value == null &&
        phoneError.value == null &&
        passwordError.value == null;
  }

  Future<void> save() async {
    if (!_validate()) return;
    try {
      isSaving.value = true;
      final data = <String, dynamic>{
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
        'permissions': selectedPermissions.toList(),
        if (passwordController.text.isNotEmpty)
          'password': passwordController.text,
      };
      final editing = editingUser.value;
      if (editing != null) {
        final updated = await _repository.update(editing.id, data);
        final i = users.indexWhere((u) => u.id == editing.id);
        if (i != -1) users[i] = updated;
      } else {
        final created = await _repository.create(data);
        users.insert(0, created);
      }
      Get.back();
      AppSnackBar.success(
        editing != null ? 'Sub-access updated' : 'Sub-access user added',
      );
    } catch (e) {
      if (e is ValidationException) {
        _applyValidationErrors(e.errors);
        AppSnackBar.error('Please fix the errors below');
      } else {
        AppSnackBar.error(_message(e));
      }
    } finally {
      isSaving.value = false;
    }
  }

  void _applyValidationErrors(Map<String, dynamic> errors) {
    String? first(String key) {
      final v = errors[key];
      if (v is List && v.isNotEmpty) return v.first.toString();
      return v?.toString();
    }

    nameError.value = first('name');
    emailError.value = first('email');
    phoneError.value = first('phone');
    passwordError.value = first('password');
  }

  Future<void> toggleStatus(SubAccessUser user) async {
    await _runRowAction(user.id, () async {
      final newStatus = await _repository.toggleStatus(user.id);
      final i = users.indexWhere((u) => u.id == user.id);
      if (i != -1) users[i] = users[i].copyWith(status: newStatus);
      AppSnackBar.success(
        newStatus == 'active'
            ? '${user.name} is now active'
            : '${user.name} is now disabled',
      );
    });
  }

  Future<void> forceLogout(SubAccessUser user) async {
    await _runRowAction(user.id, () async {
      AppSnackBar.success(await _repository.forceLogout(user.id));
    });
  }

  Future<bool> resetPassword(SubAccessUser user, String password) async {
    var ok = false;
    await _runRowAction(user.id, () async {
      AppSnackBar.success(await _repository.resetPassword(user.id, password));
      ok = true;
    });
    return ok;
  }

  Future<void> delete(SubAccessUser user) async {
    await _runRowAction(user.id, () async {
      await _repository.delete(user.id);
      users.removeWhere((u) => u.id == user.id);
      AppSnackBar.success('Sub-access user deleted');
    });
  }

  Future<void> _runRowAction(int id, Future<void> Function() action) async {
    if (busyIds.contains(id)) return;
    busyIds.add(id);
    try {
      await action();
    } catch (e) {
      AppSnackBar.error(_message(e));
    } finally {
      busyIds.remove(id);
    }
  }

  String _message(Object e) => e.toString().replaceAll('Exception: ', '');

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
