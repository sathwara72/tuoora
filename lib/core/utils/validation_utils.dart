class ValidationUtils {
  static String? validateOptionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validateOptionalPassword(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static bool isPasswordValid(String password) {
    if (password.length < 8 || password.length > 15) return false;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasDigit && hasSpecial;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8 || value.length > 15) {
      return 'Password must be between 8 and 15 characters';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  static String? validateAmount(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Enter a valid amount';
    }
    if (amount <= 0) {
      return '$fieldName must be greater than zero';
    }
    return null;
  }

  static String? validateStaffSelection(dynamic staff) {
    if (staff == null) {
      return 'Please select a staff member to continue.';
    }
    return null;
  }

  static String? validateRoleSelection(dynamic role) {
    if (role == null) {
      return 'Please select a staff role to continue.';
    }
    return null;
  }

  static String? validateDepartmentSelection(dynamic department) {
    if (department == null) {
      return 'Please select a staff department to continue.';
    }
    return null;
  }

  static String? validateCategorySelection(dynamic category) {
    if (category == null) {
      return 'Please select a category to continue.';
    }
    return null;
  }

  static String? validateStudentSelection(dynamic student) {
    if (student == null) {
      return 'Please select a student to continue.';
    }
    return null;
  }

  static String? validateDaysSelection(List<dynamic> days) {
    if (days.isEmpty) {
      return 'Please select at least one day to continue.';
    }
    return null;
  }

  static String? validateDateSelection(dynamic date, String fieldName) {
    if (date == null) {
      return 'Please select $fieldName to continue.';
    }
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}

