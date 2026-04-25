# NGO Operation & Volunteer Management System

> **HRAS — Hamesha Rahein Apke Saath | One Society, One Heartbeat**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-green)]()
[![Tests](https://img.shields.io/badge/Tests-62%20Passed-brightgreen)]()
[![Analyze](https://img.shields.io/badge/flutter%20analyze-0%20issues-brightgreen)]()

A complete cross-platform NGO management ecosystem that digitizes campaign management, donation tracking, volunteer coordination, and real-time analytics — built with Flutter and Firebase.

---

## 📱 Platforms

| Platform | Technology | Status |
|----------|-----------|--------|
| Android | Flutter APK | ✅ Complete |
| iOS | Flutter IPA | ✅ Complete |
| Web (Public + Admin) | Flutter Web | ✅ Complete |

## 🏗️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x (Dart) |
| Backend | Firebase (Firestore, Auth, Storage) |
| State Management | Provider (ChangeNotifier) |
| Charts | fl_chart |
| PDF Generation | pdf + printing |
| Security | Firestore Security Rules (RBAC) |
| Design System | Custom semantic tokens |

## ✨ Features

### Mobile App (Android / iOS)
- Campaign browsing, joining, and tracking
- Donation history and contribution tracking
- Profile management with dark/light mode
- Announcements and campaign highlights

### Web Platform
- Public landing page with SEO
- Responsive admin dashboard with sidebar navigation
- PremiumDataTable with search and pagination
- Analytics charts (bar + pie)

### Admin Panel
- Campaign CRUD with full lifecycle management
- Donation recording with PDF receipt generation
- Volunteer and user management (role changes, activation)
- Expense tracking and beneficiary management
- PDF analytics report export

### Security
- Firebase Authentication (JWT)
- Server-side Firestore Security Rules (RBAC)
- Immutable activity audit logs
- Client-side admin route guards

## 📊 Project Stats

| Metric | Value |
|--------|-------|
| Dart Source Files | 80 |
| Lines of Code | 14,159 |
| Data Models | 9 |
| Firestore Collections | 11 |
| Unit Tests | 62 (all passing) |
| Static Analysis Issues | 0 |

## 📁 Repository Structure

```
ngo_volunteer_app/
├── lib/                    # Flutter source code (all platforms)
│   ├── config/             # Colors, constants, theme
│   ├── enums/              # 8 type-safe enums
│   ├── models/             # 9 data models
│   ├── providers/          # State management (Auth, Campaign, Theme)
│   ├── screens/            # 25+ screens across 12 modules
│   ├── services/           # 10 Firebase service classes
│   ├── theme/              # Design tokens (typography, spacing)
│   ├── utils/              # Validators, responsive helpers
│   └── widgets/            # Reusable UI components
├── test/                   # Unit tests (62 tests, 3 suites)
├── web/                    # Web assets (index.html, manifest)
├── android/                # Android configuration
├── ios/                    # iOS configuration
├── firestore.rules         # Server-side security rules
│
├── FYP-1/                  # 6th Semester deliverables
│   ├── documentation/      # Thesis chapters, proposal, progress report
│   ├── diagrams/           # 17 PNG + Mermaid source diagrams
│   └── MASTER_ROADMAP.md   # 1.5-year project timeline
│
├── FYP-2/                  # 7th Semester (planned)
│   ├── planned-features/   # Push notifications, QR attendance
│   ├── research/           # Literature, user study
│   └── advanced-modules/   # Volunteer matching algorithm
│
├── FYP-3/                  # 8th Semester (planned)
│   ├── final-documentation/# Chapters 5-8, complete thesis
│   ├── deployment/         # Firebase Hosting, Play Store
│   └── defense/            # Final presentation, viva prep
│
└── README.md               # This file
```

## 📅 FYP Timeline (1.5 Years)

| Phase | Semester | Focus | Status |
|-------|----------|-------|--------|
| **FYP-1** | 6th (Feb-Jun 2026) | Core development + Ch 1-2 | ✅ Complete |
| **FYP-2** | 7th (Sep-Dec 2026) | Advanced features + Ch 3-4 | 📋 Planned |
| **FYP-3** | 8th (Jan-Apr 2027) | Final thesis + deployment | 📋 Planned |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x+
- Firebase project configured
- Android Studio / VS Code

### Installation
```bash
git clone https://github.com/FYP-NGO-OPERATION/NGO-Operation-And-Volunteer-Management-System.git
cd NGO-Operation-And-Volunteer-Management-System
flutter pub get
flutter run           # Mobile
flutter run -d chrome # Web
flutter test          # Run tests
flutter analyze       # Static analysis
```

### Firebase Setup
1. Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication (Email/Password)
3. Create Firestore database
4. Run `flutterfire configure`
5. Deploy rules: `firebase deploy --only firestore:rules`

## 🔒 Security Model

| Layer | Mechanism |
|-------|-----------|
| Authentication | Firebase Auth (JWT tokens) |
| Authorization | Firestore Rules (RBAC) |
| UI Guards | Conditional admin route rendering |
| Audit Trail | Immutable activity_log collection |

## 👤 Author

**[Your Name]** — BS Computer Science
**Supervisor:** [Supervisor Name]
**University:** [University Name]

---

*HRAS — Hamesha Rahein Apke Saath | One Society, One Heartbeat*
