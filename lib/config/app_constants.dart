/// App-wide string constants and configuration values.
class AppConstants {
  AppConstants._();

  // ─── App Info ───
  static const String appName = 'NGO Volunteer App';
  static const String appTagline = 'Empowering Communities Together';
  static const String appVersion = '1.0.0';
  static const String orgName = 'Aasra Foundation';

  // ─── Firebase Collections ───
  static const String usersCollection = 'users';
  static const String campaignsCollection = 'campaigns';
  static const String volunteersCollection = 'volunteers';
  static const String donationsCollection = 'donations';
  static const String announcementsCollection = 'announcements';
  static const String campaignPhotosCollection = 'campaign_photos';
  static const String beneficiariesCollection = 'beneficiaries';
  static const String distributionsCollection = 'distributions';
  static const String feedbackCollection = 'feedback';
  static const String activityLogCollection = 'activity_log';

  // ─── Firebase Storage Paths ───
  static const String profilePhotosPath = 'profile_photos';
  static const String campaignCoversPath = 'campaign_covers';
  static const String campaignPhotosPath = 'campaign_photos';

  // ─── Sizes ───
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonHeight = 52.0;
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 16.0;

  // ─── Image ───
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const int compressedImageQuality = 70; // 70% quality
  static const double profileImageSize = 120.0;

  // ─── Pagination ───
  static const int pageSize = 15; // Items per page

  // ─── Validation ───
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 1000;
  static const int phoneLength = 11; // Pakistani phone number

  // ─── Shared Preferences Keys ───
  static const String keyOnboardingSeen = 'onboarding_seen';
  static const String keyDarkMode = 'dark_mode';
  static const String keyUserId = 'user_id';
}
