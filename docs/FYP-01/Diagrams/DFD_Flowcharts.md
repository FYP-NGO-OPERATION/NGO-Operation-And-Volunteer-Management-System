# Data Flow Diagrams + System Flowcharts — HRAS NGO System
# Render at https://mermaid.live — Export as PNG for Word thesis

---

## 11. DFD LEVEL 0 (Context Diagram)

```mermaid
graph LR
    Admin((Admin))
    Volunteer((Volunteer))

    Admin -->|"Campaign data,<br/>Donation records,<br/>User management"| SYS["HRAS NGO<br/>Management System"]
    SYS -->|"Analytics reports,<br/>PDF receipts,<br/>Campaign status"| Admin

    Volunteer -->|"Registration,<br/>Campaign join/leave,<br/>Profile updates"| SYS
    SYS -->|"Campaign list,<br/>Announcements,<br/>Contribution history"| Volunteer

    SYS -->|"Read/Write data"| DB[("Firebase<br/>Cloud Firestore")]
    DB -->|"Real-time streams"| SYS

    SYS -->|"Auth requests"| AUTH["Firebase<br/>Authentication"]
    AUTH -->|"JWT tokens"| SYS
```

---

## 12. DFD LEVEL 1

```mermaid
graph TB
    Admin((Admin))
    Volunteer((Volunteer))

    subgraph "HRAS NGO System"
        P1["1.0<br/>Authentication<br/>Module"]
        P2["2.0<br/>Campaign<br/>Management"]
        P3["3.0<br/>Donation<br/>Tracking"]
        P4["4.0<br/>Volunteer<br/>Management"]
        P5["5.0<br/>Analytics &<br/>Reporting"]
        P6["6.0<br/>User<br/>Administration"]
    end

    DB[("Firestore<br/>Database")]

    Admin -->|"Credentials"| P1
    Volunteer -->|"Credentials"| P1
    P1 -->|"User session"| P2
    P1 -->|"User session"| P4
    P1 <-->|"User records"| DB

    Admin -->|"Campaign details"| P2
    P2 <-->|"Campaign records"| DB
    P2 -->|"Campaign list"| Volunteer

    Admin -->|"Donation data"| P3
    P3 <-->|"Donation records"| DB
    P3 -->|"PDF receipt"| Admin

    Volunteer -->|"Join/Leave"| P4
    P4 <-->|"Volunteer records"| DB

    P5 -->|"Reports, charts"| Admin
    P5 <-->|"All records"| DB

    Admin -->|"Role changes"| P6
    P6 <-->|"User records"| DB
```

---

## 13. DFD LEVEL 2 — Campaign Management (Process 2.0)

```mermaid
graph TB
    Admin((Admin))
    Volunteer((Volunteer))

    subgraph "2.0 Campaign Management"
        P21["2.1<br/>Create<br/>Campaign"]
        P22["2.2<br/>Update<br/>Campaign"]
        P23["2.3<br/>Manage<br/>Beneficiaries"]
        P24["2.4<br/>Record<br/>Expenses"]
        P25["2.5<br/>Upload<br/>Photos"]
        P26["2.6<br/>Change<br/>Status"]
    end

    CDB[("campaigns<br/>collection")]
    BDB[("beneficiaries<br/>collection")]
    EDB[("expenses<br/>collection")]
    PDB[("photos<br/>collection")]
    STOR["Firebase<br/>Storage"]

    Admin -->|"Title, type,<br/>dates, goal"| P21
    P21 -->|"New campaign"| CDB

    Admin -->|"Updated fields"| P22
    P22 <-->|"Campaign doc"| CDB

    Admin -->|"Beneficiary data"| P23
    P23 -->|"Beneficiary record"| BDB

    Admin -->|"Expense details"| P24
    P24 -->|"Expense record"| EDB
    P24 -->|"Update totals"| CDB

    Admin -->|"Photo file"| P25
    P25 -->|"Upload image"| STOR
    P25 -->|"Photo metadata"| PDB

    Admin -->|"New status"| P26
    P26 -->|"Status update"| CDB
    CDB -->|"Campaign list"| Volunteer
```

---

## 14. SYSTEM FLOWCHART (Complete System)

```mermaid
flowchart TD
    START([App Launch]) --> SPLASH[Splash Screen]
    SPLASH --> CHECK{User logged in?}
    CHECK -->|No| ONBOARD[Onboarding Screens]
    ONBOARD --> LOGIN[Login Screen]
    CHECK -->|Yes| ROLE{Check user role}

    LOGIN --> AUTH{Authenticate}
    AUTH -->|Fail| ERROR[Show error message]
    ERROR --> LOGIN
    AUTH -->|Success| ACTIVE{Is user active?}
    ACTIVE -->|No| DEACT[Force logout + message]
    DEACT --> LOGIN
    ACTIVE -->|Yes| ROLE

    ROLE -->|Admin| ADMIN[Admin Dashboard + Sidebar]
    ROLE -->|Volunteer| HOME[Home Screen + Bottom Nav]

    ADMIN --> A1[Campaign Management]
    ADMIN --> A2[Donation Tracking]
    ADMIN --> A3[User Management]
    ADMIN --> A4[Analytics + Reports]
    ADMIN --> A5[Announcements]

    HOME --> V1[Browse Campaigns]
    HOME --> V2[View Announcements]
    HOME --> V3[My Profile]
    HOME --> V4[Settings]

    V1 --> JOIN{Join campaign?}
    JOIN -->|Yes| JOINED[Volunteer record created]
    JOIN -->|No| V1

    A4 --> PDF[Generate PDF Report]
    A2 --> RECEIPT[Generate Donation Receipt]
```

---

## 15. ADMIN WORKFLOW FLOWCHART

```mermaid
flowchart TD
    A([Admin logs in]) --> DASH[Admin Dashboard]
    DASH --> CHOICE{Select action}

    CHOICE -->|Campaigns| C1[View campaign list]
    C1 --> C2{Action?}
    C2 -->|Create| C3[Fill campaign form]
    C3 --> C4[Save to Firestore]
    C2 -->|Edit| C5[Update campaign fields]
    C5 --> C4
    C2 -->|View| C6[Campaign detail tabs]
    C6 --> C7[Record donation]
    C6 --> C8[Add beneficiary]
    C6 --> C9[Record expense]
    C6 --> C10[Upload photos]

    CHOICE -->|Users| U1[View user list]
    U1 --> U2{Action?}
    U2 -->|Change role| U3[Set admin/volunteer]
    U2 -->|Activate| U4[Toggle isActive]

    CHOICE -->|Analytics| AN1[View charts]
    AN1 --> AN2[Download PDF report]

    CHOICE -->|Donations| D1[View all donations]
    D1 --> D2[Download receipt PDF]
```

---

## 16. DONATION PROCESS FLOWCHART

```mermaid
flowchart TD
    A([Admin opens campaign]) --> B[Navigate to Record tab]
    B --> C[Click Add Donation]
    C --> D[Fill donation form]
    D --> E{Donation type?}
    E -->|Money| F[Enter amount + payment method]
    E -->|In-Kind| G[Enter item name + quantity]
    F --> H[Enter donor name + phone]
    G --> H
    H --> I{Validate form?}
    I -->|Fail| J[Show validation errors]
    J --> D
    I -->|Pass| K[Save to Firestore]
    K --> L[Update campaign totals]
    L --> M[Log activity]
    M --> N[Show success message]
    N --> O{Generate receipt?}
    O -->|Yes| P[Create PDF receipt]
    P --> Q[Print / Share]
    O -->|No| R([Done])
    Q --> R
```

---

## 17. VOLUNTEER REGISTRATION FLOWCHART

```mermaid
flowchart TD
    A([User opens app]) --> B{Has account?}
    B -->|No| C[Registration Screen]
    C --> D[Enter name, email, phone, password]
    D --> E{Validate fields?}
    E -->|Fail| F[Show errors]
    F --> D
    E -->|Pass| G[Create Firebase Auth account]
    G --> H[Create Firestore user document]
    H --> I[Navigate to Home Screen]

    B -->|Yes| J[Login Screen]
    J --> K[Enter credentials]
    K --> L{Auth success?}
    L -->|No| M[Show error]
    M --> J
    L -->|Yes| I

    I --> N[Browse campaigns]
    N --> O[View campaign detail]
    O --> P{Join campaign?}
    P -->|Yes| Q{Campaign full?}
    Q -->|Yes| R[Show full message]
    Q -->|No| S[Create volunteer record]
    S --> T[Update campaign volunteer count]
    T --> U[Show success + confetti]
    P -->|No| N
```

---

## 18. AUTHENTICATION FLOWCHART

```mermaid
flowchart TD
    A([App starts]) --> B[Check Firebase Auth state]
    B --> C{Token exists?}
    C -->|No| D[Show Login screen]
    C -->|Yes| E[Fetch user doc from Firestore]
    E --> F{User exists in DB?}
    F -->|No| G[Force logout]
    G --> D
    F -->|Yes| H{isActive == true?}
    H -->|No| I[Force logout + show deactivated msg]
    I --> D
    H -->|Yes| J{role == admin?}
    J -->|Yes| K[Navigate to AdminLayout]
    J -->|No| L[Navigate to HomeScreen]

    D --> M[User enters credentials]
    M --> N[Firebase Auth validate]
    N --> O{Success?}
    O -->|No| P[Show error snackbar]
    P --> D
    O -->|Yes| E
```

---

## 19. REPORT GENERATION FLOWCHART

```mermaid
flowchart TD
    A([Admin opens Analytics]) --> B[Load campaign data from Firestore]
    B --> C[Calculate KPIs]
    C --> D[Render charts: Bar + Pie]
    D --> E{Generate PDF?}
    E -->|Yes| F[Collect all campaign stats]
    F --> G[Build PDF document]
    G --> H[Add header: HRAS NGO branding]
    H --> I[Add summary table: totals]
    I --> J[Add campaign breakdown table]
    J --> K[Add footer + timestamp]
    K --> L[Open print/share dialog]
    L --> M([PDF delivered])
    E -->|No| N([View on screen only])
```
