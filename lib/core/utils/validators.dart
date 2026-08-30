class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return ' is required';
    }
    return null;
  }

  static String? validateNumberRange(
    String? value,
    String fieldName, {
    required double min,
    required double max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return ' is required';
    }
    final numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return 'Please enter a valid number';
    }
    if (numValue < min || numValue > max) {
      return ' must be between  and ';
    }
    return null;
  }

  static String? validateIntegerRange(
    String? value,
    String fieldName, {
    required int min,
    required int max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return ' is required';
    }
    final intValue = int.tryParse(value.trim());
    if (intValue == null) {
      return 'Please enter a valid whole number';
    }
    if (intValue < min || intValue > max) {
      return ' must be between  and ';
    }
    return null;
  }
}
