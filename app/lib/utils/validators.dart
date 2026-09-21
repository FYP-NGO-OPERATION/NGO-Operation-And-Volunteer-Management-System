/// Form validation helper methods.
class Validators {
  Validators._();

  /// Validate email format using RFC 5322 strict pattern
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Strict RFC 5322 regex for email validation
    final emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$");
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password (min 6 characters)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate confirm password matches
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate required field
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate name (2-30 characters, strictly letters and spaces)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 30) {
      return 'Name must be less than 30 characters';
    }
    // Reject numbers and special characters
    final nameRegex = RegExp(r"^[a-zA-Z\s]+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name must contain only letters and spaces';
    }
    return null;
  }

  /// Validate Pakistani phone number (03XX-XXXXXXX)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove dashes and spaces
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    if (cleaned.length != 11 || !cleaned.startsWith('03')) {
      return 'Enter valid phone (03XX-XXXXXXX)';
    }
    return null;
  }

  /// Validate phone (optional - only validate if not empty)
  static String? phoneOptional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    return phone(value);
  }
}
