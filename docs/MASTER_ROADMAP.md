# HRAS NGO FYP — Master Academic Roadmap
# Project: NGO Operation & Volunteer Management System
# Duration: 1.5 Years (FYP-01 → FYP-02 → FYP-03)

---

## CURRENT PROJECT AUDIT (As of April 2026)

### STRONG (Keep)
- 80 Dart files, 14,159 lines, zero analyzer issues
- 3-platform delivery (Android, iOS, Web) from single codebase
- Premium design system (12 typography levels, dark/light modes)
- Firestore RBAC security rules (11 collections protected)
- PDF generation (analytics reports + donation receipts)
- 62 unit tests passing (validators, enums, config)
- Responsive web dashboard with sidebar + data tables
- Professional README with architecture documentation

### WEAK (Fix Now)
- No SRS document
- No system design diagrams (ER, Use Case, Sequence, etc.)
- No thesis chapters started
- No literature review or academic references
- No Firebase Hosting deployment (free, takes 5 minutes)
- No APK release build for demo device
- No user feedback data collected

### VERDICT
Implementation = ~120% of FYP-01 scope (ahead)
Academic depth = ~30% of FYP-01 scope (behind)
ACTION: Stop features. Start documentation immediately.

---

## SEMESTER ROADMAP

### FYP-01 (Current — Apr-Jun 2026)

| Week | Deliverable | Priority |
|------|------------|----------|
| 1 | Chapter 1 draft (Introduction) | 🔴 |
| 1 | Architecture diagram + ER diagram | 🔴 |
| 2 | Chapter 2 draft (Literature Review, 10 references) | 🔴 |
| 2 | Use Case diagram + DFD Level 0 | 🔴 |
| 3 | Progress Report compilation | 🔴 |
| 3 | Deploy web to Firebase Hosting | 🟡 |
| 3 | Build release APK | 🟡 |
| 4 | FYP-01 Presentation deck (10-12 slides) | 🔴 |
| 4 | Demo rehearsal | 🟡 |

### FYP-02 (Sep-Dec 2026)

| Month | Deliverable |
|-------|------------|
| Sep | Chapter 3 (Requirements Analysis) + Traceability Matrix |
| Sep | Push Notifications (FCM) + QR Attendance feature |
| Oct | Chapter 4 (System Design) + ALL diagrams finalized |
| Oct | Innovation: Volunteer-Campaign Matching Algorithm |
| Nov | Comparative analysis (5 existing NGO platforms) |
| Nov | User study with 10-15 real HRAS members |
| Dec | Mid-defense presentation + Chapter 3-4 submission |

### FYP-03 (Jan-Apr 2027)

| Month | Deliverable |
|-------|------------|
| Jan | Chapter 5 (Implementation) with screenshots |
| Jan | Chapter 6 (Testing) — expand to 80+ tests |
| Feb | Chapter 7 (Results & Discussion) with metrics |
| Feb | CSV export + Urdu language support |
| Mar | Chapter 8 (Conclusion & Future Work) |
| Mar | Final thesis compilation + formatting |
| Apr | Final defense deck + viva preparation |
| Apr | Deployment (Play Store internal track + Firebase Hosting) |

---

## THESIS CHAPTER OUTLINE

### Chapter 1: Introduction (~12-15 pages)
1.1 Background and Context
1.2 Problem Domain
1.3 Motivation
1.4 Problem Statement
1.5 Project Objectives
1.6 Scope of the Project
1.7 Limitations
1.8 Methodology Overview
1.9 Report Organization
1.10 Chapter Summary

### Chapter 2: Literature Review (~15-20 pages)
2.1 Theoretical Background
2.2 NGO Digital Transformation
2.3 Existing NGO Management Systems
2.4 Volunteer Management Platforms
2.5 Donation and Transparency Systems
2.6 Mobile vs Web Approaches
2.7 Cross-Platform Frameworks
2.8 Emerging Technologies (AI, GIS, Blockchain)
2.9 Comparative Analysis Table
2.10 Research Gap Identification
2.11 Chapter Summary

### Chapter 3: Requirement Analysis (~12-15 pages)
3.1 Stakeholder Identification
3.2 Functional Requirements
3.3 Non-Functional Requirements
3.4 Use Case Specifications
3.5 Requirements Traceability Matrix
3.6 SDLC Model Selection (Agile Iterative)
3.7 Project Constraints
3.8 Risk Analysis
3.9 Chapter Summary

### Chapter 4: System Design (~15-20 pages)
4.1 System Architecture
4.2 Work Breakdown Structure
4.3 Use Case Diagrams
4.4 Activity Diagrams
4.5 Sequence Diagrams
4.6 Class Diagram
4.7 Data Flow Diagrams (Level 0, Level 1)
4.8 Entity Relationship Diagram
4.9 State Diagrams
4.10 Deployment Diagram
4.11 UI/UX Design Decisions
4.12 Chapter Summary

### Chapter 5: Implementation (~15-20 pages)
5.1 Development Environment Setup
5.2 Flutter Architecture & Project Structure
5.3 Firebase Backend Configuration
5.4 Authentication Module
5.5 Campaign Management Module
5.6 Donation Tracking Module
5.7 Volunteer Management Module
5.8 Admin Dashboard Implementation
5.9 Web Platform Implementation
5.10 Design System Implementation
5.11 Security Implementation
5.12 Key Code Segments
5.13 Chapter Summary

### Chapter 6: Testing (~10-12 pages)
6.1 Testing Strategy
6.2 Unit Testing
6.3 Widget Testing
6.4 Integration Testing
6.5 System Testing
6.6 Security Testing
6.7 Performance Testing
6.8 Test Case Tables
6.9 Bug Log and Resolution
6.10 Chapter Summary

### Chapter 7: Results & Discussion (~10-12 pages)
7.1 Experimental Setup
7.2 Application Screenshots
7.3 User Feedback Analysis
7.4 Performance Benchmarks
7.5 Comparison with Existing Systems
7.6 Achievement vs Objectives Mapping
7.7 Discussion
7.8 Chapter Summary

### Chapter 8: Conclusion & Future Work (~5-8 pages)
8.1 Project Summary
8.2 Key Achievements
8.3 Key Findings
8.4 Limitations Encountered
8.5 Future Enhancements
8.6 Final Conclusion

---

## REQUIRED DIAGRAMS CHECKLIST

| # | Diagram | Tool | Chapter | Status |
|---|---------|------|---------|--------|
| 1 | System Architecture | draw.io | Ch 4 | ❌ |
| 2 | ER Diagram (9 entities) | draw.io | Ch 4 | ❌ |
| 3 | Use Case Diagram (Admin + Volunteer) | draw.io | Ch 3/4 | ❌ |
| 4 | DFD Level 0 | draw.io | Ch 4 | ❌ |
| 5 | DFD Level 1 | draw.io | Ch 4 | ❌ |
| 6 | Sequence Diagram (Login flow) | draw.io | Ch 4 | ❌ |
| 7 | Sequence Diagram (Donation flow) | draw.io | Ch 4 | ❌ |
| 8 | Activity Diagram (Campaign lifecycle) | draw.io | Ch 4 | ❌ |
| 9 | Class Diagram | draw.io | Ch 4 | ❌ |
| 10 | State Diagram (Campaign status) | draw.io | Ch 4 | ❌ |
| 11 | Deployment Diagram | draw.io | Ch 4 | ❌ |
| 12 | WBS Chart | draw.io | Ch 4 | ❌ |
| 13 | Gantt Chart (timeline) | Excel/PPT | Ch 3 | ❌ |
| 14 | Comparative Analysis Table | Word | Ch 2 | ❌ |
| 15 | Mobile Screenshots (10+) | Device | Ch 5/7 | ❌ |
| 16 | Web Screenshots (8+) | Browser | Ch 5/7 | ❌ |

---

## INNOVATION FEATURES — FINAL DECISION

| Feature | Verdict | Semester | Reason |
|---------|---------|----------|--------|
| Push Notifications (FCM) | ✅ DO | FYP-02 | Expected feature, easy to implement |
| QR Volunteer Attendance | ✅ DO | FYP-02 | High demo impact, low effort |
| Volunteer-Campaign Matching | ✅ DO | FYP-02 | Research paper material, algorithmic depth |
| CSV/Excel Export | ✅ DO | FYP-03 | Practical, NGOs need this |
| Urdu Language Support | ✅ DO | FYP-03 | Cultural relevance for Pakistani NGO |
| GIS Campaign Map | 🟡 MAYBE | FYP-03 | Good visual but not core |
| AI Chatbot | ❌ SKIP | — | Fake without real training data |
| Blockchain | ❌ SKIP | — | Buzzword, examiners see through it |
| Fraud Detection | ❌ SKIP | — | Needs data volume you don't have |
| Payment Gateway | 🟡 MAYBE | FYP-03 | Sandbox mode only, complex |

---

## ACADEMIC REFERENCES TO FIND (Literature Review Starters)

Search these on Google Scholar, IEEE Xplore, ACM Digital Library:

1. "NGO management information systems" — survey papers
2. "Volunteer management software" — comparative studies
3. "Donation transparency technology" — blockchain/digital solutions
4. "Cross-platform mobile development Flutter" — framework comparisons
5. "Firebase real-time applications" — architecture studies
6. "Role-based access control mobile apps" — security patterns
7. "Design systems component libraries" — UI engineering
8. "Digital transformation nonprofit organizations" — impact studies
9. "Mobile applications social impact developing countries" — Pakistan context
10. "Software requirements engineering NGO" — methodology papers

Target: 15-20 IEEE references for Chapter 2.

---

## REPOSITORY STRUCTURE (Final)

```
ngo_volunteer_app/
├── lib/                          # Source code (Flutter)
├── test/                         # Unit + widget tests
├── web/                          # Web assets (index.html, manifest)
├── android/                      # Android config
├── ios/                          # iOS config
├── firestore.rules               # Security rules
├── README.md                     # Professional project README
│
├── docs/                         # ALL academic documentation
│   ├── FYP-01/
│   │   ├── Chapter-1_Introduction/
│   │   ├── Chapter-2_Literature-Review/
│   │   ├── Proposal/
│   │   ├── Diagrams/
│   │   ├── Presentation/
│   │   └── Progress-Report/
│   │
│   ├── FYP-02/
│   │   ├── Chapter-3_Requirements/
│   │   ├── Chapter-4_System-Design/
│   │   ├── Research/
│   │   ├── Testing/
│   │   ├── Innovation-Module/
│   │   └── Mid-Presentation/
│   │
│   ├── FYP-03/
│   │   ├── Chapter-5_Implementation/
│   │   ├── Chapter-6_Testing/
│   │   ├── Chapter-7_Results/
│   │   ├── Chapter-8_Conclusion/
│   │   ├── Final-Thesis/
│   │   ├── Defense/
│   │   ├── Deployment/
│   │   └── User-Manual/
│   │
│   ├── diagrams/                 # All UML/system diagrams
│   ├── screenshots/
│   │   ├── mobile/
│   │   ├── web/
│   │   └── admin/
│   └── references/               # Research papers / bibliography
```

---

## WHAT GOLD MEDAL STUDENTS DO DIFFERENTLY

1. They start documentation in Week 1, not after coding is done
2. They have a published/submitted research paper by FYP-03
3. They collect real user feedback (even 10 users) and quantify it
4. They deploy to a live URL and Play Store (internal track)
5. They have 80+ tests with coverage reports
6. They present with confidence because they rehearsed 5+ times
7. They have ONE novel algorithm/technique (not just CRUD)
8. They maintain a clean GitHub with tagged releases
9. They create a 2-minute video demo for their portfolio
10. They write a comparative analysis showing their system is better
