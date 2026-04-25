import 'package:flutter_test/flutter_test.dart';
import 'package:ngo_volunteer_app/enums/app_enums.dart';

/// Unit tests for enum serialization, deserialization, and helper methods.
void main() {
  group('CampaignType', () {
    test('fromString returns correct enum for valid values', () {
      expect(CampaignType.fromString('winterDrive'), CampaignType.winterDrive);
      expect(CampaignType.fromString('ramadan'), CampaignType.ramadan);
      expect(CampaignType.fromString('education'), CampaignType.education);
    });

    test('fromString returns custom for unknown values', () {
      expect(CampaignType.fromString('unknown'), CampaignType.custom);
      expect(CampaignType.fromString(''), CampaignType.custom);
    });

    test('all values have labels and icons', () {
      for (final type in CampaignType.values) {
        expect(type.label, isNotEmpty);
        expect(type.icon, isNotEmpty);
      }
    });
  });

  group('CampaignStatus', () {
    test('fromString returns correct enum', () {
      expect(CampaignStatus.fromString('upcoming'), CampaignStatus.upcoming);
      expect(CampaignStatus.fromString('active'), CampaignStatus.active);
      expect(CampaignStatus.fromString('completed'), CampaignStatus.completed);
    });

    test('fromString defaults to upcoming for unknown', () {
      expect(CampaignStatus.fromString('invalid'), CampaignStatus.upcoming);
    });

    test('all statuses have labels', () {
      for (final status in CampaignStatus.values) {
        expect(status.label, isNotEmpty);
      }
    });
  });

  group('DonationCategory', () {
    test('fromString returns correct enum', () {
      expect(DonationCategory.fromString('money'), DonationCategory.money);
      expect(DonationCategory.fromString('clothes'), DonationCategory.clothes);
      expect(DonationCategory.fromString('food'), DonationCategory.food);
    });

    test('fromString defaults to other for unknown', () {
      expect(DonationCategory.fromString('xyz'), DonationCategory.other);
    });

    test('money category is first (most common)', () {
      expect(DonationCategory.values.first, DonationCategory.money);
    });
  });

  group('PaymentMethod', () {
    test('fromString returns correct enum', () {
      expect(PaymentMethod.fromString('cash'), PaymentMethod.cash);
      expect(PaymentMethod.fromString('jazzCash'), PaymentMethod.jazzCash);
      expect(PaymentMethod.fromString('easyPaisa'), PaymentMethod.easyPaisa);
    });

    test('fromString defaults to cash for unknown', () {
      expect(PaymentMethod.fromString('bitcoin'), PaymentMethod.cash);
    });

    test('all payment methods have labels and icons', () {
      for (final method in PaymentMethod.values) {
        expect(method.label, isNotEmpty);
        expect(method.icon, isNotEmpty);
      }
    });
  });

  group('ExpenseCategory', () {
    test('fromString returns correct enum', () {
      expect(ExpenseCategory.fromString('purchase'), ExpenseCategory.purchase);
      expect(ExpenseCategory.fromString('transport'), ExpenseCategory.transport);
    });

    test('fromString defaults to other for unknown', () {
      expect(ExpenseCategory.fromString('fake'), ExpenseCategory.other);
    });
  });

  group('HelpType', () {
    test('fromString returns correct enum', () {
      expect(HelpType.fromString('ration'), HelpType.ration);
      expect(HelpType.fromString('medical'), HelpType.medical);
      expect(HelpType.fromString('education'), HelpType.education);
    });

    test('fromString defaults to custom for unknown', () {
      expect(HelpType.fromString('unknown_type'), HelpType.custom);
    });

    test('all help types have labels and icons', () {
      for (final type in HelpType.values) {
        expect(type.label, isNotEmpty);
        expect(type.icon, isNotEmpty);
      }
    });
  });

  group('UserRole', () {
    test('has correct labels', () {
      expect(UserRole.admin.label, 'Admin');
      expect(UserRole.volunteer.label, 'Volunteer');
    });

    test('has exactly 2 roles', () {
      expect(UserRole.values.length, 2);
    });
  });

  group('ActivityAction', () {
    test('all actions have labels', () {
      for (final action in ActivityAction.values) {
        expect(action.label, isNotEmpty);
      }
    });

    test('has expected action types', () {
      final names = ActivityAction.values.map((a) => a.name).toList();
      expect(names, contains('created'));
      expect(names, contains('donated'));
      expect(names, contains('joined'));
    });
  });
}
