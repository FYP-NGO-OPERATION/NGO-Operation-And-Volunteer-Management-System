import 'package:flutter_test/flutter_test.dart';
import 'package:ngo_volunteer_app/utils/validators.dart';

/// Unit tests for form validation logic.
/// Covers email, password, name, phone, and required field validators.
void main() {
  group('Validators.email', () {
    test('returns error for null input', () {
      expect(Validators.email(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.email(''), 'Email is required');
    });

    test('returns error for invalid email format', () {
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('missing@domain'), isNotNull);
      expect(Validators.email('@nodomain.com'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('test.user@domain.co'), isNull);
    });

    test('trims whitespace before validating', () {
      expect(Validators.email('  user@example.com  '), isNull);
    });
  });

  group('Validators.password', () {
    test('returns error for null input', () {
      expect(Validators.password(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.password(''), 'Password is required');
    });

    test('returns error for short password', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('ab'), isNotNull);
    });

    test('returns null for valid password (6+ chars)', () {
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('securePassword!'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('returns error when passwords do not match', () {
      expect(Validators.confirmPassword('abc', '123'), isNotNull);
    });

    test('returns error for empty confirmation', () {
      expect(Validators.confirmPassword('', 'password'), isNotNull);
    });

    test('returns null when passwords match', () {
      expect(Validators.confirmPassword('mypass', 'mypass'), isNull);
    });
  });

  group('Validators.name', () {
    test('returns error for null input', () {
      expect(Validators.name(null), isNotNull);
    });

    test('returns error for single character', () {
      expect(Validators.name('A'), isNotNull);
    });

    test('returns error for name exceeding 50 characters', () {
      final longName = 'A' * 51;
      expect(Validators.name(longName), isNotNull);
    });

    test('returns null for valid name', () {
      expect(Validators.name('Ali'), isNull);
      expect(Validators.name('Muhammad Ahmed'), isNull);
    });
  });

  group('Validators.phone', () {
    test('returns error for null input', () {
      expect(Validators.phone(null), isNotNull);
    });

    test('returns error for non-Pakistani format', () {
      expect(Validators.phone('12345678901'), isNotNull);
      expect(Validators.phone('0412345678'), isNotNull);
    });

    test('returns error for wrong length', () {
      expect(Validators.phone('0312345'), isNotNull);
      expect(Validators.phone('031234567890'), isNotNull);
    });

    test('returns null for valid Pakistani phone', () {
      expect(Validators.phone('03001234567'), isNull);
      expect(Validators.phone('03121234567'), isNull);
    });

    test('handles dashes and spaces', () {
      expect(Validators.phone('0300-1234567'), isNull);
      expect(Validators.phone('0300 1234567'), isNull);
    });
  });

  group('Validators.phoneOptional', () {
    test('returns null for empty input (optional)', () {
      expect(Validators.phoneOptional(null), isNull);
      expect(Validators.phoneOptional(''), isNull);
    });

    test('validates when value is provided', () {
      expect(Validators.phoneOptional('invalid'), isNotNull);
      expect(Validators.phoneOptional('03001234567'), isNull);
    });
  });

  group('Validators.required', () {
    test('returns error for null input', () {
      expect(Validators.required(null), isNotNull);
    });

    test('returns error for empty/whitespace input', () {
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('   '), isNotNull);
    });

    test('returns null for valid input', () {
      expect(Validators.required('Hello'), isNull);
    });

    test('uses custom field name in error message', () {
      final result = Validators.required('', 'Campaign Title');
      expect(result, contains('Campaign Title'));
    });
  });
}
