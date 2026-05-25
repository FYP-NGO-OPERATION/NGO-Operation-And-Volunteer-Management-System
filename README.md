# HRAS: NGO Operations & Volunteer Management System

An AI-Integrated Operations and Volunteer Coordination Platform designed specifically for small-to-medium Charitable NGOs (like Hamesha Rahein Apke Saath). 

This project shifts NGOs away from messy WhatsApp groups and paper-based ledgers into a structured, digital ecosystem.

## 🌟 System Overview (Simple Explanation)
This app is **NOT** a public donation app (like Edhi/Alkhidmat B2C apps). 
This is a **B2B Internal Operations System**. 

- **For the Admin:** A dashboard to create campaigns, manage volunteer attendance, and log incoming cash/bank donations for transparent accounting.
- **For the Volunteer:** A mobile app to browse upcoming campaigns, register for duties, and track their own attendance via QR codes.

## 🏗️ Architecture
We use a **Modern Monorepo Architecture**:
- **Frontend:** Flutter (Single codebase for Web Dashboard and Mobile App).
- **Backend:** Firebase (Firestore NoSQL for real-time data sync, Firebase Auth for secure logins).
- **Innovation:** Rule-based AI algorithms for smart volunteer matching.

## 🚀 How to Run the App (Phase Commands)

This application was developed in distinct phases. We use **Feature Flags** (`APP_PHASE`) to safely turn features on or off depending on which phase of the FYP defense we are in.

### 1. FYP-01 Defense Mode (Safe Mode)
Runs the foundational MVP (Authentication, Campaign Creation, basic UI). Advanced features are hidden to ensure stability during the first defense.
```bash
flutter run --dart-define=APP_PHASE=FYP1
```

### 2. FYP-02 Development Mode
Unlocks advanced features developed in Phase 2, including the Smart Matching Algorithm, QR Code Attendance, and Push Notifications.
```bash
flutter run --dart-define=APP_PHASE=FYP2
```

### 3. Full Production Mode
Unlocks the entire ecosystem, including AI Analytics Dashboards and PDF Reporting.
```bash
flutter run --dart-define=APP_PHASE=FULL
```

---
*Developed by Muhammad Maauz Mansoor (233599) for Air University FYP.*
