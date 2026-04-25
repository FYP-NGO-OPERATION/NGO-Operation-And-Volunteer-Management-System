# FYP-01 Presentation — Slide Content

## Slide Deck: NGO Operation & Volunteer Management System (HRAS)
### FYP-01 Progress Presentation | BS Computer Science

---

### SLIDE 1 — TITLE

**NGO Operation & Volunteer Management System**

HRAS — Hamesha Rahein Apke Saath

*One Society, One Heartbeat*

- Student: Muhammad Maauz Mansoor | Reg: [Number]
- Supervisor: [Name]
- BS Computer Science — 6th Semester
- Date: June 2026

---

### SLIDE 2 — PROBLEM STATEMENT

**The Challenge**

- 45,000+ NGOs in Pakistan operate with informal tools
- Donations tracked on paper or WhatsApp — no transparency
- Volunteer coordination through word-of-mouth — no tracking
- No integrated system connecting campaigns, donors, and volunteers

**Problem**: Small NGOs lack affordable, integrated digital platforms for operations management.

*Speaker Note: Mention HRAS specifically — real NGO, real problems observed through interviews.*

---

### SLIDE 3 — OBJECTIVES

1. Cross-platform app (Android, iOS, Web) — single codebase
2. Campaign lifecycle management
3. Donation tracking with PDF receipts
4. Volunteer self-registration and tracking
5. Role-based access control (server-side)
6. Admin analytics dashboard
7. Unified design system
8. Evaluation through testing and comparison

*Speaker Note: Emphasize "one codebase, three platforms" — this is the technical differentiator.*

---

### SLIDE 4 — SOLUTION OVERVIEW

**Architecture: 3-Tier System**

```
Presentation: Flutter (Mobile + Web)
        ↕
Business Logic: Provider + Service Layer
        ↕
Data: Firebase (Auth + Firestore + Storage)
```

**Key Stats:**
- 80 Dart source files
- 14,159 lines of code
- 9 data models, 11 Firestore collections
- 62 unit tests passing
- Zero static analysis issues

*Speaker Note: Show the architecture diagram from your docs folder.*

---

### SLIDE 5 — DEMO: MOBILE APP

**Live Demo Points:**
1. Splash screen → Onboarding
2. Login (admin credentials)
3. Dashboard with campaign cards
4. Campaign detail → Tabs (Info, Record, Highlights)
5. Dark mode toggle
6. Profile screen

*Speaker Note: Have emulator ready. If it fails, switch to screenshots.*

---

### SLIDE 6 — DEMO: WEB PLATFORM

**Live Demo Points:**
1. Landing page (hero + footer)
2. Login → Admin Dashboard with sidebar
3. Campaign grid (3-column responsive)
4. PremiumDataTable with search/pagination
5. Analytics with charts
6. PDF report download

*Speaker Note: Resize browser to show responsive design transitioning from desktop to mobile.*

---

### SLIDE 7 — SECURITY MODEL

**Three-Layer Security:**

| Layer | Mechanism |
|-------|-----------|
| Authentication | Firebase Auth (JWT tokens) |
| Authorization | Firestore Security Rules (RBAC) |
| UI Guards | Conditional admin route rendering |

- Volunteers cannot access admin functions even if app is decompiled
- Activity logs are immutable (cannot edit/delete)
- Inactive users automatically blocked

*Speaker Note: Show the firestore.rules file briefly — examiners appreciate seeing actual security code.*

---

### SLIDE 8 — DESIGN SYSTEM

**Unified Across All Platforms:**

- 12 typography levels (Display → Caption)
- 8 spacing tokens (4px → 48px)
- Semantic color palette (light + dark)
- Reusable components (CustomButton, CustomTextField, PremiumDataTable)
- Consistent border radii, shadows, animations

*Speaker Note: Toggle dark mode live during this slide.*

---

### SLIDE 9 — PROGRESS STATUS

| Milestone | Status |
|-----------|--------|
| Mobile App (Android/iOS) | ✅ Complete |
| Web Platform | ✅ Complete |
| Admin Dashboard | ✅ Complete |
| Firebase Backend | ✅ Complete |
| Security Rules | ✅ Complete |
| Design System | ✅ Complete |
| Unit Tests (62) | ✅ Complete |
| Chapter 1 (Introduction) | ✅ Draft |
| Chapter 2 (Literature Review) | ✅ Draft |
| UML Diagrams | ✅ Created |
| Chapters 3-8 | 📋 FYP-02/03 |

*Speaker Note: Highlight that implementation is ahead of schedule.*

---

### SLIDE 10 — FUTURE WORK & TIMELINE

**FYP-02 (7th Semester):**
- Push notifications (FCM)
- QR-based volunteer attendance
- Volunteer-campaign matching algorithm
- User study with real HRAS members
- Chapters 3-4

**FYP-03 (8th Semester):**
- CSV export + Urdu language support
- Deployment (Firebase Hosting + Play Store)
- Chapters 5-8 + final thesis
- Research paper submission

**Thank you. Questions welcome.**

*Speaker Note: End confidently. Make eye contact. Don't rush.*

---

## FORMATTING FOR POWERPOINT

- Background: White or very light gray
- Title font: 28-32pt Bold
- Body font: 18-22pt
- Use bullet points, not paragraphs
- One key visual per slide (screenshot, diagram, or table)
- HRAS logo on every slide (top-right corner)
- Slide numbers on bottom-right
- Maximum 6-7 bullet points per slide
