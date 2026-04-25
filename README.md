# 🌍 HRAS — NGO Operation & Volunteer Management System

> **Hamesha Rahein Apke Saath | One Society, One Heartbeat**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-4CAF50)]()
[![Tests](https://img.shields.io/badge/Tests-62%20Passing-brightgreen)]()
[![Analyze](https://img.shields.io/badge/Flutter%20Analyze-0%20Issues-brightgreen)]()
[![License](https://img.shields.io/badge/License-Academic-blue)]()

---

## 🏗️ Single Ecosystem Architecture

This is a **unified full-stack ecosystem** — NOT separate projects. One codebase powers all platforms:

```
┌─────────────────────────────────────────────────────┐
│              HRAS NGO ECOSYSTEM                      │
│                                                      │
│   ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│   │ Android  │  │   iOS    │  │    Web Browser    │  │
│   │   App    │  │   App    │  │  (Public + Admin) │  │
│   └────┬─────┘  └────┬─────┘  └────────┬─────────┘  │
│        │              │                 │            │
│   ┌────┴──────────────┴─────────────────┴──────┐     │
│   │         SHARED FLUTTER CODEBASE            │     │
│   │    lib/ (Models, Providers, Services,      │     │
│   │         Screens, Widgets, Theme)           │     │
│   └────────────────────┬───────────────────────┘     │
│                        │                             │
│   ┌────────────────────┴───────────────────────┐     │
│   │           FIREBASE CLOUD BACKEND           │     │
│   │  Auth │ Firestore │ Storage │ Hosting      │     │
│   │        Firestore Security Rules (RBAC)     │     │
│   └────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────┘
```

> **Why this matters for examiners:** Unlike typical FYPs that build separate mobile and web apps, this project achieves true code reuse — one `lib/` codebase serves all three platforms through Flutter's cross-compilation. Admin, volunteer, and public interfaces are role-gated within the same application.

---

## ✨ Features

### 📱 Mobile App (Android + iOS)
- Animated splash screen with brand onboarding
- Campaign browsing with detail views
- Join/leave campaigns as volunteer
- Profile management with contribution history
- Dark/light mode with design system
- Push-ready architecture

### 🌐 Web Platform (Public + Admin Dashboard)
- SEO-optimized public landing page
- Responsive admin sidebar navigation
- PremiumDataTable with search, sort, pagination
- Analytics dashboard with bar + pie charts
- Full campaign lifecycle management

### 🔐 Admin Panel (Role-Gated)
- Campaign CRUD (create, edit, activate, complete)
- Donation recording with PDF receipt generation
- Volunteer management and approval
- User administration (role changes, activation)
- Expense tracking and beneficiary management
- PDF analytics report export
- Immutable activity audit logs

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter 3.x (Dart) | Cross-platform UI |
| **State** | Provider (ChangeNotifier) | Reactive state management |
| **Backend** | Firebase | Serverless cloud backend |
| **Database** | Cloud Firestore | Real-time NoSQL (11 collections) |
| **Auth** | Firebase Authentication | JWT-based email/password |
| **Storage** | Firebase Storage | Profile photos, campaign images |
| **Hosting** | Firebase Hosting | Web deployment |
| **Security** | Firestore Security Rules | Server-side RBAC enforcement |
| **PDF** | pdf + printing packages | Receipts and reports |
| **Charts** | fl_chart | Analytics visualizations |
| **Design** | Custom token-based system | 12 typography, 8 spacing tokens |

---

## 📁 Unified Monorepo Structure

```
ngo_fyp_system/
│
├── app/                          # 🔥 FLUTTER (Mobile App + Admin Dashboard)
│   ├── lib/                      #    Shared Dart codebase (Android/iOS/Web)
│   ├── android/                  #    Android build configuration
│   ├── ios/                      #    iOS build configuration
│   └── web/                      #    Web build configuration
│
├── website/                      # 🌐 NEXT.JS (Public Marketing & SEO Landing)
│   ├── app/                      #    Next.js app router
│   ├── components/               #    React components
│   └── public/                   #    Static assets
│
├── backend/                      # ☁️ FIREBASE (Backend Logic)
│   ├── firestore.rules           #    🔒 Server-side RBAC security rules
│   ├── firestore.indexes.json    #    Database indexes
│   └── firebase.json             #    Firebase project configuration
│
├── docs/                         # 📄 ACADEMIC DOCUMENTATION
│   ├── FYP-01/                   #    Semester 1: Chapters 1-2, proposal
│   ├── FYP-02/                   #    Semester 2: Chapters 3-4, research
│   ├── FYP-03/                   #    Semester 3: Chapters 5-8, defense
│   ├── diagrams/                 #    20+ PNG diagrams (Mermaid generated)
│   ├── Thesis-FYP01/             #    DOCX thesis with embedded diagrams
│   └── MASTER_ROADMAP.md         #    1.5-year academic timeline
│
└── README.md                     # 📖 This architecture documentation
```

### Why Monorepo Architecture?

| ❌ Wrong Approach | ✅ Our Approach (Industry Standard) |
|-------------------|--------------------------------------|
| Separate unlinked folders | One parent directory (`ngo_fyp_system`) |
| Duplicate Firebase configs | Centralized `backend/` config |
| Confusing for examiners | Examiner opens one repo, sees entire ecosystem |

---

## 📊 Project Metrics

| Metric | Value |
|--------|-------|
| Dart source files | 80 |
| Lines of code | 14,159 |
| Data models | 9 |
| Firestore collections | 11 |
| Service classes | 10 |
| State providers | 3 |
| UI screens | 25+ |
| Reusable widgets | 15+ |
| Unit tests | 62 (all passing) |
| Static analysis issues | 0 |
| Platforms | 3 (Android, iOS, Web) |

---

## 🔒 Security Architecture

```
Layer 1: Authentication     → Firebase Auth (JWT tokens)
Layer 2: Authorization      → Firestore Security Rules (server-side RBAC)
Layer 3: UI Guards          → Conditional admin/volunteer route rendering
Layer 4: Audit Trail        → Immutable activity_log (no update/delete)
```

Key security rules:
- `isAdmin()` — checks `resource.data.role == 'admin'` in Firestore
- `isOwner()` — verifies `request.auth.uid == resource.data.uid`
- Activity logs are **create-only** — no one can edit or delete them

---

## 📅 FYP Timeline (1.5 Years / 3 Semesters)

| Phase | Semester | Duration | Focus | Status |
|-------|----------|----------|-------|--------|
| **FYP-1** | 6th | Feb–Jun 2026 | Core ecosystem + Ch 1-2 | ✅ Complete |
| **FYP-2** | 7th | Sep–Dec 2026 | Advanced features + Ch 3-4 | 📋 Planned |
| **FYP-3** | 8th | Jan–Apr 2027 | Deployment + final thesis | 📋 Planned |

### FYP-1 Completed ✅
- Full mobile app (25+ screens, premium design)
- Web platform (landing + admin dashboard)
- Firebase backend (11 collections, RBAC)
- 62 unit tests, 0 analyzer issues
- Chapter 1 (Introduction) + Chapter 2 (Literature Review)
- 17 professional diagrams, thesis DOCX

### FYP-2 Planned 📋
- Push Notifications (FCM)
- QR-Based Volunteer Attendance
- Volunteer-Campaign Matching Algorithm
- User Study (10-15 real HRAS members)
- Chapter 3 (Requirements) + Chapter 4 (Design)

### FYP-3 Planned 📋
- CSV Export + Urdu Language Support
- Production Deployment (Firebase Hosting + Play Store)
- Chapter 5-8 + Complete Thesis (100+ pages)
- Final Defense + Viva Preparation

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x+ ([install guide](https://docs.flutter.dev/get-started/install))
- Firebase CLI (`npm install -g firebase-tools`)
- Android Studio / VS Code
- Chrome (for web testing)

### Quick Start
```bash
# Clone repository
git clone https://github.com/FYP-NGO-OPERATION/NGO-Operation-And-Volunteer-Management-System.git
cd NGO-Operation-And-Volunteer-Management-System

# Install dependencies
flutter pub get

# Run on different platforms
flutter run                # Mobile (connected device/emulator)
flutter run -d chrome      # Web browser
flutter test               # Run all 62 unit tests
flutter analyze            # Static analysis (should show 0 issues)
```

### Firebase Configuration
```bash
# 1. Create Firebase project at console.firebase.google.com
# 2. Enable Email/Password Authentication
# 3. Create Cloud Firestore database
# 4. Configure Flutter
flutterfire configure

# 5. Deploy security rules
firebase deploy --only firestore:rules

# 6. Deploy web app
flutter build web
firebase deploy --only hosting
```

---

## 👤 Author

| | |
|---|---|
| **Student** | Muhammad Maauz Mansoor |
| **Registration** | 233599 |
| **Program** | BS Computer Science |
| **Supervisor** | Miss Fatima Yousuf |
| **University** | Air University Multan Campus |

---

*Built with ❤️ for HRAS NGO — Hamesha Rahein Apke Saath*
