/// Input sanitization utilities to prevent XSS and injection attacks.
class Sanitizer {
  Sanitizer._();

  /// Strip HTML tags from user input
  static String stripHtml(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Sanitize a general text field: trim, strip HTML, limit length
  static String text(String input, {int maxLength = 1000}) {
    String clean = input.trim();
    clean = stripHtml(clean);
    // Remove control characters (except newlines and tabs)
    clean = clean.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
    if (clean.length > maxLength) {
      clean = clean.substring(0, maxLength);
    }
    return clean;
  }

  /// Sanitize a name field: trim, strip HTML, only allow safe chars
  static String name(String input, {int maxLength = 100}) {
    String clean = text(input, maxLength: maxLength);
    // Allow letters, spaces, hyphens, apostrophes, dots
    clean = clean.replaceAll(RegExp(r"[^a-zA-Z\s\-'.\u0600-\u06FF]"), '');
    return clean;
  }

  /// Sanitize a phone number: keep only digits and +
  static String phone(String input) {
    return input.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Sanitize an email: trim, lowercase
  static String email(String input) {
    return input.trim().toLowerCase();
  }

  /// Sanitize a CNIC: keep only digits and -
  static String cnic(String input) {
    return input.replaceAll(RegExp(r'[^\d-]'), '');
  }

  /// Sanitize a monetary amount string: keep only digits and .
  static String amount(String input) {
    return input.replaceAll(RegExp(r'[^\d.]'), '');
  }

  /// Validate and sanitize a URL
  static String? url(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return null; // Invalid URL
    }
    return trimmed;
  }
}
