# HRAS NGO FYP — Master Academic Roadmap
# Project: NGO Operation & Volunteer Management System
# Duration: 1.5 Years (FYP-01 → FYP-02 → FYP-03)
# Student: Muhammad Maauz Mansoor | Reg: 233599
# Supervisor: Miss Fatima Yousuf | Air University Multan Campus

---

## CHAPTER-TO-PHASE MAPPING (SUPERVISOR APPROVED)

| Chapter | Title | FYP Phase | Status |
|---------|-------|-----------|--------|
| 1 | Introduction | FYP-01 | ✅ Completed |
| 2 | Literature Review | FYP-01 | ✅ Completed |
| 3 | Planning and Methodology | FYP-02 | 🔲 Planned |
| 4 | System Specification | FYP-02 | 🔲 Planned |
| 5 | System Design | FYP-02 | 🔲 Planned |
| 6 | Coding | FYP-03 | 🔲 Planned |
| 7 | Testing | FYP-03 | 🔲 Planned |
| 8 | Conclusion | FYP-03 | 🔲 Planned |
| — | User Guide | FYP-03 | 🔲 Planned |
| — | References | All Phases | 🔄 Ongoing |
| — | Glossary | FYP-03 | 🔲 Planned |

---

## CURRENT PROJECT STATUS (As of May 2026)

### FYP-01 Deliverables (COMPLETED)

| # | Deliverable | Status |
|---|------------|--------|
| 1 | Chapter 1 — Introduction (10 sections) | ✅ Done |
| 2 | Chapter 2 — Literature Review (15 IEEE refs) | ✅ Done |
| 3 | Project Proposal Document | ✅ Done |
| 4 | FYP-01 Presentation (10 slides) | ✅ Done |
| 5 | Progress Report | ✅ Done |
| 6 | UML & System Diagrams (28 PNGs) | ✅ Done |
| 7 | Thesis DOCX (Chapters 1-2 + Appendix) | ✅ Done |
| 8 | Core Flutter App (Mobile + Web) | ✅ Done |
| 9 | Firebase Backend (Auth + Firestore + Rules) | ✅ Done |
| 10 | Feature Flag System (FYP1/FYP2/FULL modes) | ✅ Done |

### Codebase Metrics (Verified)

| Metric | Value |
|--------|-------|
| Dart source files | 80 |
| Lines of code | 14,159 |
| Data models | 9 |
| Firestore collections | 11 |
| Service classes | 10 |
| Unit tests | 62 (all passing) |
| Static analysis issues | 0 |
| Platforms | 3 (Android, iOS, Web) |

### Architecture

The project follows a **Unified Monorepo Architecture**:

```
ngo_volunteer_app/
├── app/              # Flutter (Mobile + Admin Web Dashboard)
│   ├── lib/          # Shared Dart codebase
│   ├── test/         # Unit tests
│   └── pubspec.yaml  # Flutter dependencies
├── website/          # Next.js (Public SEO Landing Page)
├── backend/          # Firebase Config (Rules, Indexes)
├── docs/             # Academic Documentation
│   ├── FYP-01/       # Chapters 1-2, Proposal, Presentation
│   ├── FYP-02/       # Chapters 3-5 (Planned)
│   ├── FYP-03/       # Chapters 6-8 (Planned)
│   ├── diagrams/     # 28 PNG diagrams
│   └── Thesis-FYP01/ # Generated DOCX thesis
└── README.md         # Architecture documentation
```

---

## SEMESTER ROADMAP

### FYP-01 (Apr–Jun 2026) — ✅ COMPLETED

| Week | Deliverable | Status |
|------|------------|--------|
| 1-2 | Chapter 1 (Introduction) + Architecture Diagrams | ✅ Done |
| 2-3 | Chapter 2 (Literature Review) + 15 IEEE References | ✅ Done |
| 3-4 | Progress Report + All UML Diagrams | ✅ Done |
| 4 | FYP-01 Presentation + Defense Preparation | ✅ Done |

### FYP-02 (Sep–Dec 2026) — PLANNED

| Month | Deliverable |
|-------|------------|
| Sep | Chapter 3 (Planning and Methodology) |
| Sep | Push Notifications (FCM) integration |
| Oct | Chapter 4 (System Specification) + Requirements Traceability |
| Oct | QR Volunteer Attendance feature |
| Nov | Chapter 5 (System Design) + All diagrams finalized |
| Nov | Innovation: Volunteer-Campaign Matching Algorithm |
| Nov | User study with 10-15 real HRAS members |
| Dec | Mid-defense presentation + Chapters 3-5 submission |

### FYP-03 (Jan–Apr 2027) — PLANNED

| Month | Deliverable |
|-------|------------|
| Jan | Chapter 6 (Coding) with code walkthrough + screenshots |
| Jan | Expand to 80+ unit tests |
| Feb | Chapter 7 (Testing) with test results and metrics |
| Feb | CSV export + Urdu language support |
| Mar | Chapter 8 (Conclusion & Future Work) |
| Mar | Final thesis compilation + User Guide |
| Apr | Deployment (Play Store internal + Firebase Hosting) |
| Apr | Final defense + viva preparation |

---

## DIAGRAMS STATUS

| # | Diagram | File Exists | Thesis Referenced |
|---|---------|-------------|-------------------|
| 1 | Unified System Architecture | ✅ unified_system_architecture.png | ✅ Fig 4.1 |
| 2 | Use Case Diagram | ✅ use_case_final.png | ✅ Fig 4.2 |
| 3 | ER Diagram | ✅ er_final.png | ✅ Fig 4.3 |
| 4 | Sequence — Donation Flow | ✅ sequence_donation.png | ✅ Fig 4.4 |
| 5 | Sequence — Volunteer Flow | ✅ sequence_volunteer.png | ✅ Fig 4.5 |
| 6 | Activity — Campaign Lifecycle | ✅ activity_campaign.png | ✅ Fig 4.6 |
| 7 | Class Diagram | ✅ class_entities.png | ✅ Fig 4.7 |
| 8 | DFD Level 0 | ✅ dfd_level0_*.png | ✅ Fig 4.8 |
| 9 | DFD Level 1 | ✅ dfd_level1_*.png | ✅ Fig 4.9 |
| 10 | DFD Level 2 | ✅ dfd_level2_flow.png | ✅ Fig 4.10 |
| 11 | Deployment Diagram | ✅ deployment_architecture.png | ✅ Fig 4.11 |
| 12 | Component Diagram | ✅ component_diagram_*.png | ✅ Fig 4.12 |
| 13 | RBAC Diagram | ✅ rbac_admin_diagram.png | ✅ Fig 4.13 |
| 14 | System Flowchart | ✅ system_flowchart_*.png | ✅ Fig 3.1 |
| 15 | Gantt Chart | ✅ gantt_chart_*.png | ✅ Fig 3.2 |
| 16 | WBS Chart | ✅ wbs_chart_*.png | ✅ Fig 3.3 |
| 17 | Donation Flowchart | ✅ donation_flowchart_*.png | ✅ Fig 3.4 |
| 18 | SDLC Model | ✅ sdlc_model_*.png | ✅ Fig 3.5 |

> **Note:** Diagrams are labeled with Chapter 3/4 figure numbers but are included in the thesis Appendix for FYP-01. They will be moved inline into their respective chapters during FYP-02 and FYP-03 writing.

---

## INNOVATION FEATURES — PHASE ALLOCATION

| Feature | Phase | Status |
|---------|-------|--------|
| Push Notifications (FCM) | FYP-02 | 🔲 Planned |
| QR Volunteer Attendance | FYP-02 | 🔲 Planned |
| Volunteer-Campaign Matching Algorithm | FYP-02 | 🔲 Planned |
| CSV/Excel Export | FYP-03 | 🔲 Planned |
| Urdu Language Support | FYP-03 | 🔲 Planned |
| GIS Campaign Map | FYP-03 | 🟡 Optional |

---

## FEATURE FLAG SYSTEM (EXAMINER SAFETY)

The Flutter app uses compile-time feature flags to control feature visibility per FYP phase:

```bash
# FYP-01 Defense (DEFAULT — examiner-safe):
flutter run

# FYP-02 Development:
flutter run --dart-define=APP_PHASE=FYP2

# Full System:
flutter run --dart-define=APP_PHASE=FULL
```

| Feature | FYP1 (Default) | FYP2 | FULL |
|---------|:-:|:-:|:-:|
| Dashboard + Stats | ✅ | ✅ | ✅ |
| Campaign CRUD | ✅ | ✅ | ✅ |
| Donation Recording | ✅ | ✅ | ✅ |
| Volunteer Management | ✅ | ✅ | ✅ |
| User Management | ✅ | ✅ | ✅ |
| Analytics Dashboard | ❌ | ✅ | ✅ |
| PDF Report Export | ❌ | ✅ | ✅ |
| Push Notifications | ❌ | ❌ | ✅ |
| Smart Matching | ❌ | ❌ | ✅ |
