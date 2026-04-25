# Architecture + Planning Diagrams — HRAS NGO System
# Render at https://mermaid.live — Export as PNG for Word thesis

---

## 20. THREE-TIER SYSTEM ARCHITECTURE

```mermaid
graph TB
    subgraph "PRESENTATION TIER"
        direction LR
        MOB["📱 Mobile App<br/>(Android / iOS)<br/>Flutter + Dart"]
        WEB["🌐 Web Platform<br/>(Browser)<br/>Flutter Web"]
        ADMIN["🖥️ Admin Dashboard<br/>(Desktop Browser)<br/>Responsive Sidebar"]
    end

    subgraph "BUSINESS LOGIC TIER"
        direction LR
        AP["AuthProvider<br/>(User State)"]
        CP["CampaignProvider<br/>(Campaign State)"]
        TP["ThemeProvider<br/>(UI State)"]
        SVC["Service Layer<br/>(AuthService, CampaignService,<br/>UserService, PdfService)"]
    end

    subgraph "DATA TIER (Firebase Cloud)"
        direction LR
        FA["Firebase Auth<br/>(JWT Authentication)"]
        FS["Cloud Firestore<br/>(11 Collections)"]
        ST["Firebase Storage<br/>(Images/Media)"]
        FH["Firebase Hosting<br/>(Web Deploy)"]
        SR["Security Rules<br/>(RBAC)"]
    end

    MOB --> AP
    WEB --> AP
    ADMIN --> AP
    MOB --> CP
    WEB --> CP
    AP --> SVC
    CP --> SVC
    SVC --> FA
    SVC --> FS
    SVC --> ST
    FS --- SR
    WEB -.-> FH
```

---

## 21. FIREBASE BACKEND ARCHITECTURE

```mermaid
graph TB
    subgraph "Firebase Services"
        AUTH["🔐 Firebase Auth<br/>Email/Password Provider<br/>JWT Token Management<br/>Password Reset"]

        subgraph "Cloud Firestore (11 Collections)"
            C1["users"]
            C2["campaigns"]
            C3["donations"]
            C4["volunteers"]
            C5["beneficiaries"]
            C6["expenses"]
            C7["distributions"]
            C8["announcements"]
            C9["campaign_photos"]
            C10["feedback"]
            C11["activity_log"]
        end

        RULES["🛡️ Security Rules<br/>isAdmin() helper<br/>isOwner() helper<br/>isValidString() helper<br/>RBAC enforcement"]

        STORAGE["📁 Firebase Storage<br/>profile_photos/<br/>campaign_covers/<br/>campaign_photos/"]
    end

    CLIENT["Flutter Client"] --> AUTH
    CLIENT --> C1
    CLIENT --> C2
    CLIENT --> C3
    CLIENT --> STORAGE
    C1 --- RULES
    C2 --- RULES
    C3 --- RULES
    C11 --- RULES
```

---

## 22. SECURITY / RBAC ARCHITECTURE

```mermaid
graph TB
    subgraph "Layer 1: Authentication"
        REQ["Client Request"] --> FA["Firebase Auth"]
        FA --> TOKEN["JWT Token<br/>(uid, email)"]
    end

    subgraph "Layer 2: Server-Side Rules"
        TOKEN --> RULES["Firestore Security Rules"]
        RULES --> CHECK1{"request.auth != null?"}
        CHECK1 -->|No| DENY1["❌ DENY: Unauthenticated"]
        CHECK1 -->|Yes| CHECK2{"isAdmin()?"}
        CHECK2 -->|Yes| ADMIN_OPS["✅ ALLOW: Full CRUD on<br/>campaigns, donations,<br/>users, expenses"]
        CHECK2 -->|No| CHECK3{"isOwner()?"}
        CHECK3 -->|Yes| OWN_OPS["✅ ALLOW: Read own data,<br/>update own profile,<br/>join/leave campaigns"]
        CHECK3 -->|No| DENY2["❌ DENY: Unauthorized"]
    end

    subgraph "Layer 3: Client-Side Guards"
        ROUTE["Route Guard"] --> ROLE{"user.role?"}
        ROLE -->|admin| SHOW_ADMIN["Show AdminLayout<br/>(sidebar + admin screens)"]
        ROLE -->|volunteer| SHOW_HOME["Show HomeScreen<br/>(bottom nav + volunteer screens)"]
    end

    subgraph "Immutable Logs"
        LOG["activity_log collection"]
        LOG_RULE["allow create: if authenticated<br/>allow update, delete: if false"]
    end
```

---

## 23. MOBILE APP ARCHITECTURE

```mermaid
graph TB
    subgraph "Flutter Mobile App"
        MAIN["main.dart<br/>App Entry Point<br/>+ Global Error Handlers"]
        MAIN --> MULTI["MultiProvider<br/>AuthProvider + CampaignProvider + ThemeProvider"]
        MULTI --> MAPP["MaterialApp<br/>Theme: Light/Dark<br/>Home: SplashScreen"]

        subgraph "Screen Layer (12 modules)"
            S1["splash/"]
            S2["auth/ (login, register, forgot)"]
            S3["home/"]
            S4["campaigns/ (list, detail, create)"]
            S5["donations/"]
            S6["volunteers/"]
            S7["profile/ (edit, about, password)"]
            S8["admin/ (analytics, donations)"]
            S9["expenses/"]
            S10["announcements/"]
            S11["beneficiaries/"]
            S12["landing/"]
        end

        subgraph "Widget Library"
            W1["CustomButton"]
            W2["CustomTextField"]
            W3["PremiumDataTable"]
            W4["SkeletonLoader"]
            W5["NoInternetBanner"]
        end

        subgraph "Design System"
            D1["AppColors (light + dark)"]
            D2["AppTextStyles (12 levels)"]
            D3["AppSpacing (8 tokens)"]
            D4["AppTokens (radii, shadows)"]
            D5["AppAnimations (durations, curves)"]
        end
    end
```

---

## 24. WBS (Work Breakdown Structure)

```mermaid
graph TB
    ROOT["HRAS NGO<br/>Management System"]

    ROOT --> WP1["WP1: Project<br/>Management"]
    ROOT --> WP2["WP2: Requirements<br/>& Design"]
    ROOT --> WP3["WP3: Mobile App<br/>Development"]
    ROOT --> WP4["WP4: Web Platform<br/>Development"]
    ROOT --> WP5["WP5: Backend &<br/>Security"]
    ROOT --> WP6["WP6: Testing &<br/>Quality"]
    ROOT --> WP7["WP7: Documentation<br/>& Thesis"]

    WP1 --> W11["Proposal"]
    WP1 --> W12["Timeline planning"]
    WP1 --> W13["Progress reports"]

    WP2 --> W21["Stakeholder analysis"]
    WP2 --> W22["Requirements doc"]
    WP2 --> W23["UML diagrams"]
    WP2 --> W24["UI/UX wireframes"]

    WP3 --> W31["Auth module"]
    WP3 --> W32["Campaign module"]
    WP3 --> W33["Donation module"]
    WP3 --> W34["Volunteer module"]
    WP3 --> W35["Profile module"]
    WP3 --> W36["Design system"]

    WP4 --> W41["Landing page"]
    WP4 --> W42["Admin dashboard"]
    WP4 --> W43["Responsive layout"]
    WP4 --> W44["Web-specific widgets"]

    WP5 --> W51["Firebase setup"]
    WP5 --> W52["Firestore rules"]
    WP5 --> W53["Authentication"]
    WP5 --> W54["Storage config"]

    WP6 --> W61["Unit tests"]
    WP6 --> W62["Integration tests"]
    WP6 --> W63["Security audit"]
    WP6 --> W64["Performance review"]

    WP7 --> W71["Ch 1-2 (FYP-01)"]
    WP7 --> W72["Ch 3-4 (FYP-02)"]
    WP7 --> W73["Ch 5-8 (FYP-03)"]
    WP7 --> W74["Final thesis"]
```

---

## 25. GANTT CHART (Text Representation)

```mermaid
gantt
    title HRAS FYP Timeline (1.5 Years)
    dateFormat YYYY-MM
    axisFormat %b %Y

    section FYP-01 (6th Sem)
    Requirements & Proposal       :done, 2026-02, 2026-03
    Mobile App Core Development   :done, 2026-03, 2026-04
    Design System + UI Overhaul   :done, 2026-04, 2026-04
    Web Platform Development      :done, 2026-04, 2026-04
    Testing + Documentation       :active, 2026-04, 2026-06
    Chapter 1 + 2 Writing         :active, 2026-04, 2026-06
    Diagrams + FYP-01 Defense     :2026-05, 2026-06

    section FYP-02 (7th Sem)
    Push Notifications + QR       :2026-09, 2026-10
    Innovation: Volunteer Matching :2026-10, 2026-11
    Chapter 3 + 4 Writing         :2026-09, 2026-11
    User Study (10-15 users)      :2026-11, 2026-12
    Mid-Defense Presentation      :2026-12, 2026-12

    section FYP-03 (8th Sem)
    CSV Export + Urdu Support     :2027-01, 2027-02
    Chapter 5-8 Writing           :2027-01, 2027-03
    Final Testing (80+ tests)     :2027-02, 2027-03
    Deployment (Hosting + Store)  :2027-03, 2027-03
    Thesis Compilation            :2027-03, 2027-04
    Final Defense                 :2027-04, 2027-04
```

---

## 26. SDLC MODEL — Agile Iterative

```mermaid
graph LR
    subgraph "Iteration 1 (FYP-01)"
        R1["Requirements<br/>Gathering"] --> D1["Design<br/>(Architecture)"]
        D1 --> I1["Implementation<br/>(Core App)"]
        I1 --> T1["Testing<br/>(Unit Tests)"]
        T1 --> E1["Evaluation<br/>(Supervisor Review)"]
    end

    subgraph "Iteration 2 (FYP-02)"
        R2["Enhanced<br/>Requirements"] --> D2["Detailed<br/>Design"]
        D2 --> I2["Advanced<br/>Features"]
        I2 --> T2["Integration<br/>Testing"]
        T2 --> E2["User Study<br/>Evaluation"]
    end

    subgraph "Iteration 3 (FYP-03)"
        R3["Final<br/>Scope"] --> D3["Deployment<br/>Design"]
        D3 --> I3["Polish +<br/>Deploy"]
        I3 --> T3["System<br/>Testing"]
        T3 --> E3["Final<br/>Defense"]
    end

    E1 -->|"Feedback"| R2
    E2 -->|"Feedback"| R3
```

---

## 27. RISK MANAGEMENT MATRIX

| # | Risk | Probability | Impact | Mitigation |
|---|------|-------------|--------|------------|
| 1 | Firebase free tier exceeded | Low | High | Monitor usage; upgrade plan if needed |
| 2 | Data loss during development | Medium | Critical | Firestore auto-backups; Git version control |
| 3 | Scope creep (too many features) | High | Medium | Fixed scope per semester; say no to extras |
| 4 | Internet unavailable during demo | Medium | High | Mobile hotspot backup; pre-recorded video |
| 5 | Flutter web performance issues | Medium | Medium | Lazy loading; image optimization; tree-shaking |
| 6 | Security vulnerability discovered | Low | Critical | Firestore rules; regular security audit |
| 7 | Team member unavailability | Low | Medium | Solo project; documented for handoff |
| 8 | Examiner questions on testing | High | High | Expand test suite to 80+; document results |
