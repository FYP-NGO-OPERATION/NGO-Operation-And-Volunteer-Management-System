# Tech Stack

**Date:** 2026-04-24

## Core Technologies
- **Language:** Dart
- **Framework:** Flutter (Mobile and Web supported)
- **Backend/BaaS:** Firebase (Firestore, Firebase Auth)
- **State Management:** Provider pattern (`provider` package)

## Dependencies
- `firebase_core`, `firebase_auth`, `cloud_firestore`: Core backend integration.
- `provider`: For reactive state management.
- `flutter_staggered_grid_view`: For image galleries.
- `url_launcher`: For opening PDFs or links.
- `intl`: For date and currency formatting.
- `pdf`, `printing`: For report generation.
- `connectivity_plus`: For network status tracking.

## Configuration
- Flutter SDK configured for multi-platform (Android, iOS, Web).
- Firebase configs generated via `flutterfire_cli` (in `firebase_options.dart`).
