/// User roles in the application.
enum UserRole {
  admin('admin', 'Admin'),
  volunteer('volunteer', 'Volunteer');

  final String value;
  final String label;
  const UserRole(this.value, this.label);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.volunteer,
    );
  }
}

/// Campaign types supported by the NGO.
enum CampaignType {
  winterDrive('winter_drive', 'Winter Drive', '❄️'),
  ramadan('ramadan', 'Ramadan', '🌙'),
  eid('eid', 'Eid', '🎉'),
  orphanage('orphanage', 'Orphanage', '🏠'),
  custom('custom', 'Custom', '📋');

  final String value;
  final String label;
  final String emoji;
  const CampaignType(this.value, this.label, this.emoji);

  static CampaignType fromString(String value) {
    return CampaignType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CampaignType.custom,
    );
  }
}

/// Campaign lifecycle statuses.
enum CampaignStatus {
  upcoming('upcoming', 'Upcoming'),
  active('active', 'Active'),
  completed('completed', 'Completed');

  final String value;
  final String label;
  const CampaignStatus(this.value, this.label);

  static CampaignStatus fromString(String value) {
    return CampaignStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => CampaignStatus.upcoming,
    );
  }
}

/// Volunteer participation statuses.
enum VolunteerStatus {
  registered('registered', 'Registered'),
  confirmed('confirmed', 'Confirmed'),
  attended('attended', 'Attended'),
  absent('absent', 'Absent');

  final String value;
  final String label;
  const VolunteerStatus(this.value, this.label);

  static VolunteerStatus fromString(String value) {
    return VolunteerStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VolunteerStatus.registered,
    );
  }
}

/// Donation categories.
enum DonationCategory {
  clothes('clothes', 'Clothes', '👕'),
  money('money', 'Money', '💰'),
  food('food', 'Food', '🍚'),
  other('other', 'Other', '📦');

  final String value;
  final String label;
  final String emoji;
  const DonationCategory(this.value, this.label, this.emoji);

  static DonationCategory fromString(String value) {
    return DonationCategory.values.firstWhere(
      (cat) => cat.value == value,
      orElse: () => DonationCategory.other,
    );
  }
}

/// Activity log action types.
enum ActivityAction {
  created('created', 'Created'),
  updated('updated', 'Updated'),
  deleted('deleted', 'Deleted'),
  joined('joined', 'Joined'),
  left('left', 'Left');

  final String value;
  final String label;
  const ActivityAction(this.value, this.label);
}
