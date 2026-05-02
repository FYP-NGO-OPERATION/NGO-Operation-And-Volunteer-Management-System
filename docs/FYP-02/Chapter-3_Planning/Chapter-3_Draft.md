# Chapter 3: System Planning & Methodology

## 3.1 Introduction

This chapter describes the planning methodology adopted for the HRAS NGO Volunteer Management System during the FYP-02 phase. Building upon the foundational work of FYP-01 (requirements gathering and core implementation), this phase focuses on advanced feature development, including a smart matching algorithm, QR-based attendance tracking, and push notification integration.

## 3.2 Development Methodology

### 3.2.1 Agile Iterative Approach

The project follows an Agile Iterative methodology spanning three FYP semesters:

| Phase | Semester | Focus |
|-------|----------|-------|
| FYP-01 | 6th Semester | Requirements, Core Mobile & Web Development |
| FYP-02 | 7th Semester | Advanced Features, Matching Algorithm, User Study |
| FYP-03 | 8th Semester | Deployment, Final Testing, Thesis Compilation |

### 3.2.2 Sprint Planning (FYP-02)

FYP-02 is organized into four two-week sprints:

1. **Sprint 1**: Smart Matching Algorithm implementation
2. **Sprint 2**: QR Attendance System development
3. **Sprint 3**: Push Notification integration (FCM)
4. **Sprint 4**: User study, bug fixes, documentation

## 3.3 Feature Flag Architecture

A compile-time feature gating system ensures backward compatibility:

```dart
// Default mode (FYP-01 safe):
flutter run

// FYP-02 features enabled:
flutter run --dart-define=APP_PHASE=FYP2

// All features enabled:
flutter run --dart-define=APP_PHASE=FULL
```

This architecture allows simultaneous development without breaking the stable FYP-01 codebase.

## 3.4 Tools and Technologies

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter | 3.x | Cross-platform UI framework |
| Firebase Core | 4.7.0 | Backend services |
| Firebase Messaging | 16.2.0 | Push notifications (FCM) |
| qr_flutter | 4.1.0 | QR code generation |
| mobile_scanner | 6.0.x | QR code scanning (camera) |

## 3.5 Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| FYP-02 features breaking FYP-01 | High | Feature flag isolation |
| FCM requires server configuration | Medium | Client-side token registration first |
| QR scanner not available on Web | Low | Graceful fallback message shown |
| Matching algorithm accuracy | Medium | Weighted scoring with explainable output |

## 3.6 Chapter Summary

This chapter established the Agile Iterative methodology for FYP-02, described the feature flag architecture ensuring backward compatibility, and identified the tools, technologies, and risk mitigation strategies for the advanced feature development phase.
