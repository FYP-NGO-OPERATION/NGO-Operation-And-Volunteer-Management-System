import 'package:flutter/services.dart';

/// Auto-formats Pakistani phone number as 03XX-XXXXXXX
/// Inserts hyphen after the 4th digit automatically.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digits
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 11 digits
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;

    // Format: 03XX-XXXXXXX
    String formatted;
    if (limited.length <= 4) {
      formatted = limited;
    } else {
      formatted = '${limited.substring(0, 4)}-${limited.substring(4)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
