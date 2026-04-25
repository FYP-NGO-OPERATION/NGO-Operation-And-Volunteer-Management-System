# THESIS FRONT MATTER — HRAS NGO Management System
# Copy each section into your Word document in order
# Use Roman numeral page numbers (i, ii, iii...) for these pages

---

# TITLE PAGE

---

## Air University Multan Campus
### Department of Computer Science

---

# NGO Operation and Volunteer Management System
## (HRAS — Hamesha Rahein Apke Saath)

---

**A Project Report Submitted in Partial Fulfillment of the Requirements for the Degree of**

### Bachelor of Science in Computer Science (BSCS)

---

**Submitted by:**

| | |
|---|---|
| **Student Name** | Muhammad Maauz Mansoor |
| **Registration No.** | 233599 |
| **Session** | [2022–2026] |

---

**Supervised by:**

| | |
|---|---|
| **Supervisor** | Miss Fatima Yousuf |
| **Designation** | Lecturer |

---

**June 2026**

**Multan, Pakistan**

---
---

# CERTIFICATE / APPROVAL PAGE

---

## CERTIFICATE OF APPROVAL

This is to certify that the project titled **"NGO Operation and Volunteer Management System (HRAS)"** submitted by **Muhammad Maauz Mansoor** bearing Registration No. **233599** is accepted in partial fulfillment of the requirements for the degree of **Bachelor of Science in Computer Science**.

---

| Role | Name | Signature | Date |
|------|------|-----------|------|
| **Supervisor** | [Name] | _________________ | ____________ |
| **Internal Examiner** | [Name] | _________________ | ____________ |
| **External Examiner** | [Name] | _________________ | ____________ |
| **Head of Department** | [Name] | _________________ | ____________ |

---
---

# DEDICATION

---

*This project is dedicated to*

*my parents, whose unwavering support and sacrifices made this journey possible,*

*to the volunteers and donors of HRAS who inspired this work,*

*and to every individual who believes that technology can amplify humanitarian impact.*

---
---

# ACKNOWLEDGEMENTS

---

First and foremost, I am grateful to **Almighty Allah** for giving me the strength, knowledge, and perseverance to complete this project.

I extend my sincere gratitude to my supervisor, **Miss Fatima Yousuf**, whose expert guidance, constructive feedback, and continuous encouragement were instrumental throughout this project. Their mentorship helped shape not only this system but also my growth as a software engineer.

I am deeply thankful to the **HRAS NGO leadership and volunteers** who provided valuable domain insights, real operational challenges, and feedback that grounded this project in practical reality.

I would also like to thank my **family and friends** for their patience, moral support, and understanding during the demanding phases of development and documentation.

Finally, I acknowledge the **open-source community** — the Flutter team, Firebase team, and countless contributors whose tools and frameworks made this project technically possible.

---
---

# ABSTRACT

---

Non-Governmental Organizations (NGOs) in Pakistan play a vital role in addressing social challenges including poverty, healthcare, and education. However, most grassroots NGOs operate with informal coordination methods — WhatsApp groups, paper registers, and manual spreadsheets — resulting in operational inefficiency, reduced donor trust, and limited scalability.

This project presents the design, development, and evaluation of **HRAS (Hamesha Rahein Apke Saath)**, a comprehensive cross-platform NGO management ecosystem built using **Flutter** and **Firebase**. The system delivers native experiences across **Android, iOS, and Web** from a single codebase, addressing the operational needs of campaign management, donation tracking, volunteer coordination, and real-time analytics.

Key contributions include: (1) a unified design system ensuring visual consistency across all platforms, (2) role-based access control enforced through server-side Firestore security rules, (3) PDF generation for donation receipts and analytics reports enhancing transparency, and (4) a responsive admin dashboard providing real-time operational insights.

The system was developed following an **Agile Iterative methodology** across three iterations corresponding to FYP-01 (core development), FYP-02 (advanced features and evaluation), and FYP-03 (deployment and finalization). The implementation comprises **80 Dart source files** totaling over **14,000 lines of code**, with **62 automated unit tests** passing with zero static analysis issues.

A comparative analysis with six existing platforms (CiviCRM, Salesforce Nonprofit Cloud, GoFundMe, VolunteerHub, Galaxy Digital, Odoo) demonstrates that HRAS uniquely combines mobile-first design, real-time data synchronization, and cultural relevance for the Pakistani NGO context in an affordable, open-source solution.

**Keywords:** NGO Management System, Flutter, Firebase, Cross-Platform Development, Volunteer Management, Donation Tracking, RBAC, Mobile Application

---
---

# TABLE OF CONTENTS

---

| Chapter | Title | Page |
|---------|-------|------|
| | Certificate of Approval | ii |
| | Dedication | iii |
| | Acknowledgements | iv |
| | Abstract | v |
| | Table of Contents | vi |
| | List of Figures | viii |
| | List of Tables | ix |
| **1** | **Introduction** | **1** |
| 1.1 | Background and Context | 1 |
| 1.2 | Problem Domain | 2 |
| 1.3 | Motivation | 3 |
| 1.4 | Problem Statement | 4 |
| 1.5 | Project Objectives | 4 |
| 1.6 | Scope of the Project | 5 |
| 1.7 | Limitations | 6 |
| 1.8 | Methodology Overview | 7 |
| 1.9 | Report Organization | 8 |
| 1.10 | Chapter Summary | 9 |
| **2** | **Literature Review** | **10** |
| 2.1 | Theoretical Background | 10 |
| 2.2 | NGO Digital Transformation | 11 |
| 2.3 | Existing NGO Management Systems | 12 |
| 2.4 | Volunteer Management Platforms | 14 |
| 2.5 | Donation and Transparency Systems | 15 |
| 2.6 | Mobile vs Web Approaches | 16 |
| 2.7 | Cross-Platform Frameworks | 17 |
| 2.8 | Emerging Technologies | 18 |
| 2.9 | Comparative Analysis | 19 |
| 2.10 | Research Gap Identification | 20 |
| 2.11 | Chapter Summary | 21 |
| **3** | **Requirement Analysis** | **22** |
| **4** | **System Design** | **35** |
| **5** | **Implementation** | **55** |
| **6** | **Testing** | **70** |
| **7** | **Results and Discussion** | **80** |
| **8** | **Conclusion and Future Work** | **90** |
| | **References** | **95** |
| | **Appendices** | **98** |

*Note: Page numbers are approximate. Update after final formatting in Word.*

---
---

# LIST OF FIGURES

---

| Figure | Title | Page |
|--------|-------|------|
| 3.1 | Complete System Flowchart | 23 |
| 3.2 | Project Timeline — Gantt Chart | 25 |
| 3.3 | Work Breakdown Structure | 26 |
| 3.4 | Donation Recording Process Flowchart | 28 |
| 3.5 | Agile Iterative SDLC Model | 30 |
| 3.6 | Authentication Flowchart | 32 |
| 4.1 | Three-Tier System Architecture | 36 |
| 4.2 | Use Case Diagram | 38 |
| 4.3 | Entity Relationship Diagram | 42 |
| 4.4 | Sequence Diagram — Login Flow | 44 |
| 4.5 | Activity Diagram — Campaign Lifecycle | 46 |
| 4.6 | State Diagram — Campaign Status | 48 |
| 4.7 | Class Diagram | 50 |
| 4.8 | DFD Level 0 (Context Diagram) | 52 |
| 4.9 | DFD Level 1 | 53 |
| 4.10 | Deployment Diagram | 55 |
| 4.11 | Component Diagram | 56 |
| 4.12 | Security Architecture — RBAC Model | 57 |
| 5.1 | Mobile App — Splash Screen | 60 |
| 5.2 | Mobile App — Login Screen | 61 |
| 5.3 | Mobile App — Dashboard | 62 |
| 5.4 | Web Platform — Admin Dashboard | 65 |
| 5.5 | Web Platform — Campaign Grid | 66 |

*Note: Add actual page numbers after Word formatting.*

---
---

# LIST OF TABLES

---

| Table | Title | Page |
|-------|-------|------|
| 2.1 | Comparative Analysis of Existing NGO Platforms | 19 |
| 3.1 | Functional Requirements | 24 |
| 3.2 | Non-Functional Requirements | 26 |
| 3.3 | Use Case UC-01: User Registration | 28 |
| 3.4 | Use Case UC-02: User Login | 29 |
| 3.5 | Use Case UC-03: Create Campaign | 30 |
| 3.6 | Use Case UC-04: Record Donation | 31 |
| 3.7 | Requirements Traceability Matrix | 33 |
| 3.8 | Risk Management Matrix | 34 |
| 4.1 | Firestore Collections Description | 40 |
| 5.1 | Technology Stack | 58 |
| 5.2 | Project File Structure | 59 |
| 6.1 | Unit Test Results Summary | 72 |
| 6.2 | Test Cases — Authentication Module | 73 |
| 6.3 | Test Cases — Campaign Module | 74 |
| 6.4 | Security Test Results | 76 |
| 7.1 | User Feedback Summary | 82 |
| 7.2 | Performance Benchmark Results | 84 |
| 7.3 | Objectives Achievement Mapping | 86 |

*Note: Update page numbers after final Word formatting.*

---

## FORMATTING CHECKLIST FOR WORD

- [ ] Font: Times New Roman throughout
- [ ] Chapter title: 16pt Bold, centered
- [ ] Heading 1 (1.1, 1.2): 14pt Bold
- [ ] Heading 2 (sub-sections): 13pt Bold
- [ ] Body text: 12pt
- [ ] Line spacing: 1.5
- [ ] Margins: 1 inch all sides (or per university template)
- [ ] Front matter pages: Roman numerals (i, ii, iii...)
- [ ] Chapter pages: Arabic numerals (1, 2, 3...)
- [ ] Figure captions: Below figure, 11pt, "Figure X.Y: Description"
- [ ] Table captions: Above table, 11pt, "Table X.Y: Description"
- [ ] References: IEEE numbered format [1], [2], ...
- [ ] Headers: Chapter name on even pages, section name on odd pages
- [ ] Page break before each new chapter
