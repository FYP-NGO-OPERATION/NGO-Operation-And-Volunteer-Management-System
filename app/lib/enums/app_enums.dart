// All app-wide enums with display labels.

// ─── User Roles ───
enum UserRole {
  admin('Admin'),
  volunteer('Volunteer');

  final String label;
  const UserRole(this.label);
}

// ─── Campaign Types ───
enum CampaignType {
  winterDrive('Winter Drive', '❄️'),
  ramadan('Ramadan', '🌙'),
  eid('Eid', '🎉'),
  orphanage('Orphanage Visit', '🏠'),
  medical('Medical Aid', '🏥'),
  education('Education', '📚'),
  ration('Ration Distribution', '🍚'),
  plantation('Tree Plantation', '🌳'),
  marriage('Marriage Support', '💒'),
  waterBirds('Water for Birds', '🐦'),
  custom('Custom Project', '📋');

  final String label;
  final String icon;
  const CampaignType(this.label, this.icon);

  static CampaignType fromString(String value) {
    return CampaignType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CampaignType.custom,
    );
  }
}

// ─── Campaign Status ───
enum CampaignStatus {
  upcoming('Upcoming', '🔵'),
  active('Active', '🟢'),
  completed('Completed', '✅');

  final String label;
  final String icon;
  const CampaignStatus(this.label, this.icon);

  static CampaignStatus fromString(String value) {
    return CampaignStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CampaignStatus.upcoming,
    );
  }
}

// ─── Volunteer Status ───
enum VolunteerStatus {
  registered('Registered'),
  confirmed('Confirmed'),
  attended('Attended'),
  absent('Absent');

  final String label;
  const VolunteerStatus(this.label);
}

// ─── Donation Categories ───
enum DonationCategory {
  money('Money', '💰'),
  clothes('Clothes', '👕'),
  food('Food / Ration', '🍚'),
  medicine('Medicine', '💊'),
  blankets('Blankets', '🛏️'),
  stationery('Stationery', '📝'),
  other('Other', '📦');

  final String label;
  final String icon;
  const DonationCategory(this.label, this.icon);

  static DonationCategory fromString(String value) {
    return DonationCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DonationCategory.other,
    );
  }
}

// ─── Payment Methods (from NGO leader transcript) ───
enum PaymentMethod {
  cash('Cash / By Hand', '💵'),
  jazzCash('JazzCash', '📱'),
  easyPaisa('EasyPaisa', '📱'),
  meezanBank('Meezan Bank', '🏦'),
  hblBank('HBL Bank', '🏦'),
  ubLBank('UBL Bank', '🏦'),
  otherBank('Other Bank', '🏦'),
  online('Online Transfer', '💳');

  final String label;
  final String icon;
  const PaymentMethod(this.label, this.icon);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

// ─── Expense Categories (from NGO leader transcript) ───
enum ExpenseCategory {
  purchase('Item Purchase', '🛒'),
  transport('Transportation', '🚗'),
  venue('Venue / Setup', '🏗️'),
  printing('Printing / Poster', '🖨️'),
  food('Food / Catering', '🍽️'),
  utility('Utility Bills', '💡'),
  medical('Medical', '🏥'),
  other('Other Expense', '📋');

  final String label;
  final String icon;
  const ExpenseCategory(this.label, this.icon);

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}

// ─── Beneficiary Help Types (from NGO leader transcript) ───
enum HelpType {
  ration('Ration Distribution', '🍚'),
  marriage('Marriage Support', '💒'),
  medical('Medical / Operation', '🏥'),
  education('Education Support', '📚'),
  plantation('Plantation / Environment', '🌳'),
  waterBirds('Bird Water Pots', '🐦'),
  winterDrive('Winter Drive Items', '❄️'),
  billPayment('Utility Bill Payment', '💡'),
  custom('Other Help', '📋');

  final String label;
  final String icon;
  const HelpType(this.label, this.icon);

  static HelpType fromString(String value) {
    return HelpType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HelpType.custom,
    );
  }
}

// ─── Activity Log Actions ───
enum ActivityAction {
  created('Created'),
  updated('Updated'),
  deleted('Deleted'),
  joined('Joined'),
  left('Left'),
  donated('Donated'),
  attended('Attended');

  final String label;
  const ActivityAction(this.label);
}
