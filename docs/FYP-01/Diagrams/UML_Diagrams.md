# UML Diagrams — HRAS NGO Management System
# Render these at https://mermaid.live or in VS Code with Mermaid plugin
# Export as PNG/SVG for Word thesis insertion

---

## 1. USE CASE DIAGRAM

```mermaid
graph TB
    subgraph "HRAS NGO System"
        UC1["Register Account"]
        UC2["Login / Logout"]
        UC3["View Campaigns"]
        UC4["Join Campaign"]
        UC5["Leave Campaign"]
        UC6["View Announcements"]
        UC7["Edit Profile"]
        UC8["Toggle Dark Mode"]
        UC9["Create Campaign"]
        UC10["Edit Campaign"]
        UC11["Delete Campaign"]
        UC12["Record Donation"]
        UC13["Manage Volunteers"]
        UC14["Manage Users"]
        UC15["View Analytics"]
        UC16["Generate PDF Report"]
        UC17["Record Expense"]
        UC18["Manage Beneficiaries"]
        UC19["Upload Photos"]
        UC20["Create Announcement"]
        UC21["Download Donation Receipt"]
        UC22["Change User Role"]
        UC23["Activate/Deactivate User"]
    end

    Volunteer((Volunteer))
    Admin((Admin))

    Volunteer --> UC1
    Volunteer --> UC2
    Volunteer --> UC3
    Volunteer --> UC4
    Volunteer --> UC5
    Volunteer --> UC6
    Volunteer --> UC7
    Volunteer --> UC8

    Admin --> UC2
    Admin --> UC3
    Admin --> UC9
    Admin --> UC10
    Admin --> UC11
    Admin --> UC12
    Admin --> UC13
    Admin --> UC14
    Admin --> UC15
    Admin --> UC16
    Admin --> UC17
    Admin --> UC18
    Admin --> UC19
    Admin --> UC20
    Admin --> UC21
    Admin --> UC22
    Admin --> UC23
```

---

## 2. ER DIAGRAM (Database Design — 9 Entities)

```mermaid
erDiagram
    USERS {
        string uid PK
        string name
        string email
        string phone
        string role
        string profileImageUrl
        string bio
        string address
        boolean isActive
        boolean emailVerified
        int campaignsJoined
        timestamp joinedAt
        timestamp lastActiveAt
    }

    CAMPAIGNS {
        string id PK
        string title
        string description
        string type
        string status
        string location
        string coverImageUrl
        string targetGoal
        string achievedGoal
        int totalVolunteers
        int volunteerLimit
        double totalDonationsAmount
        int totalDonationsCount
        int beneficiaryCount
        double totalExpenses
        int progressPercent
        string createdBy FK
        string createdByName
        timestamp startDate
        timestamp endDate
        timestamp createdAt
    }

    DONATIONS {
        string id PK
        string campaignId FK
        string campaignTitle
        string donorName
        string donorPhone
        string category
        boolean isMoney
        double amount
        string quantity
        string paymentMethod
        string receivedBy FK
        string receivedByName
        timestamp receivedAt
    }

    VOLUNTEERS {
        string id PK
        string campaignId FK
        string campaignTitle
        string userId FK
        string userName
        string userPhone
        string status
        timestamp joinedAt
        timestamp confirmedAt
    }

    BENEFICIARIES {
        string id PK
        string campaignId FK
        string name
        string phone
        string cnic
        string address
        int familySize
        string helpType
        string notes
        timestamp addedAt
    }

    EXPENSES {
        string id PK
        string campaignId FK
        string itemName
        string category
        int quantity
        double unitPrice
        double totalCost
        string vendor
        string notes
        string recordedBy FK
        timestamp recordedAt
    }

    DISTRIBUTIONS {
        string id PK
        string campaignId FK
        string beneficiaryId FK
        string itemName
        int quantity
        string distributedBy FK
        timestamp distributedAt
    }

    ANNOUNCEMENTS {
        string id PK
        string title
        string body
        string createdBy FK
        string createdByName
        timestamp createdAt
    }

    ACTIVITY_LOG {
        string id PK
        string userId FK
        string userName
        string action
        string targetType
        string targetId
        string details
        timestamp timestamp
    }

    USERS ||--o{ CAMPAIGNS : "creates"
    USERS ||--o{ VOLUNTEERS : "registers as"
    USERS ||--o{ DONATIONS : "records"
    USERS ||--o{ ACTIVITY_LOG : "generates"
    CAMPAIGNS ||--o{ DONATIONS : "receives"
    CAMPAIGNS ||--o{ VOLUNTEERS : "has"
    CAMPAIGNS ||--o{ BENEFICIARIES : "serves"
    CAMPAIGNS ||--o{ EXPENSES : "incurs"
    CAMPAIGNS ||--o{ DISTRIBUTIONS : "distributes"
    BENEFICIARIES ||--o{ DISTRIBUTIONS : "receives"
```

---

## 3. CLASS DIAGRAM

```mermaid
classDiagram
    class UserModel {
        +String uid
        +String name
        +String email
        +String phone
        +String role
        +bool isActive
        +bool isAdmin()
        +bool isVolunteer()
        +UserModel copyWith()
        +Map toMap()
        +UserModel fromMap()
    }

    class CampaignModel {
        +String id
        +String title
        +String description
        +CampaignType type
        +CampaignStatus status
        +DateTime startDate
        +int totalVolunteers
        +double totalDonationsAmount
        +double totalExpenses
        +bool isActive()
        +bool isFull()
        +double remainingBudget()
        +CampaignModel copyWith()
        +Map toMap()
    }

    class DonationModel {
        +String id
        +String campaignId
        +String donorName
        +double amount
        +String category
        +String paymentMethod
        +bool isMoney
        +Map toMap()
    }

    class VolunteerModel {
        +String id
        +String campaignId
        +String userId
        +String status
        +DateTime joinedAt
        +Map toMap()
    }

    class AuthProvider {
        -AuthService _authService
        -UserService _userService
        -UserModel _user
        -bool _isLoading
        +login()
        +register()
        +logout()
        +checkAuthState()
    }

    class CampaignProvider {
        -CampaignService _service
        -List~CampaignModel~ _campaigns
        +init()
        +getCampaigns()
        +refreshCampaigns()
    }

    class AuthService {
        +login()
        +register()
        +logout()
        +resetPassword()
    }

    class CampaignService {
        +createCampaign()
        +updateCampaign()
        +deleteCampaign()
        +joinCampaign()
        +leaveCampaign()
        +addDonation()
        +addExpense()
    }

    class PdfReportService {
        +generateCampaignReport()
        +generateDonationReceipt()
    }

    AuthProvider --> AuthService
    AuthProvider --> UserModel
    CampaignProvider --> CampaignService
    CampaignProvider --> CampaignModel
    CampaignService --> DonationModel
    CampaignService --> VolunteerModel
    CampaignService --> CampaignModel
```

---

## 4. SEQUENCE DIAGRAM — User Login Flow

```mermaid
sequenceDiagram
    participant U as User
    participant App as Flutter App
    participant AP as AuthProvider
    participant AS as AuthService
    participant FA as Firebase Auth
    participant FS as Firestore

    U->>App: Enter email + password
    App->>AP: login(email, password)
    AP->>AS: login(email, password)
    AS->>FA: signInWithEmailAndPassword()
    FA-->>AS: UserCredential (uid, token)
    AS-->>AP: Success + uid
    AP->>FS: getDoc('users/{uid}')
    FS-->>AP: UserModel data
    AP->>AP: Check isActive == true
    alt User is Active
        AP-->>App: Success + UserModel
        App->>App: Check role == 'admin'?
        alt Admin
            App->>U: Navigate to AdminLayout
        else Volunteer
            App->>U: Navigate to HomeScreen
        end
    else User is Deactivated
        AP->>AS: logout()
        AP-->>App: Failure (account deactivated)
        App->>U: Show error snackbar
    end
```

---

## 5. SEQUENCE DIAGRAM — Donation Recording

```mermaid
sequenceDiagram
    participant A as Admin
    participant App as Flutter App
    participant CS as CampaignService
    participant FS as Firestore
    participant PDF as PdfReportService

    A->>App: Fill donation form
    App->>App: Validate form fields
    App->>CS: addDonation(donationData)
    CS->>FS: collection('donations').add(data)
    FS-->>CS: Document ID
    CS->>FS: Update campaign totalDonationsAmount
    CS->>FS: Log activity to activity_log
    FS-->>CS: Success
    CS-->>App: Donation recorded
    App->>A: Show success snackbar
    A->>App: Request receipt
    App->>PDF: generateDonationReceipt()
    PDF-->>App: PDF document
    App->>A: Print/share PDF receipt
```

---

## 6. ACTIVITY DIAGRAM — Campaign Lifecycle

```mermaid
flowchart TD
    A([Admin creates campaign]) --> B{Status: Upcoming}
    B --> C[Set details: title, type, location, dates]
    C --> D[Upload cover image]
    D --> E[Campaign visible to volunteers]
    E --> F{Volunteers join?}
    F -->|Yes| G[Volunteer record created]
    F -->|No| H[Wait for interest]
    G --> I{Admin activates?}
    I -->|Yes| J[Status: Active]
    J --> K[Record donations]
    J --> L[Record expenses]
    J --> M[Add beneficiaries]
    J --> N[Upload photos]
    K --> O{Campaign goal met?}
    L --> O
    M --> O
    O -->|Yes| P[Admin marks complete]
    O -->|No| J
    P --> Q[Status: Completed]
    Q --> R[Generate analytics report]
    R --> S([Campaign archived])
```

---

## 7. STATE DIAGRAM — Campaign Status

```mermaid
stateDiagram-v2
    [*] --> Upcoming : Admin creates campaign
    Upcoming --> Active : Admin activates
    Active --> Completed : Admin marks done
    Upcoming --> Upcoming : Edit details
    Active --> Active : Record donations/expenses
    Completed --> [*] : Campaign archived

    state Active {
        [*] --> AcceptingVolunteers
        AcceptingVolunteers --> Full : Volunteer limit reached
        Full --> AcceptingVolunteers : Volunteer leaves
    }
```

---

## 8. DEPLOYMENT DIAGRAM

```mermaid
graph TB
    subgraph "Client Devices"
        Android["Android Phone<br/>(Flutter APK)"]
        iOS["iPhone<br/>(Flutter IPA)"]
        Browser["Web Browser<br/>(Flutter Web)"]
    end

    subgraph "Firebase Cloud (Google)"
        Auth["Firebase Authentication<br/>(JWT Tokens)"]
        Firestore["Cloud Firestore<br/>(NoSQL Database)"]
        Storage["Firebase Storage<br/>(Images/Media)"]
        Hosting["Firebase Hosting<br/>(Web Deployment)"]
        Rules["Firestore Security Rules<br/>(RBAC Enforcement)"]
    end

    Android -->|HTTPS| Auth
    iOS -->|HTTPS| Auth
    Browser -->|HTTPS| Auth
    Browser -->|HTTPS| Hosting

    Auth --> Firestore
    Firestore --> Rules
    Android -->|Real-time Streams| Firestore
    iOS -->|Real-time Streams| Firestore
    Browser -->|Real-time Streams| Firestore
    Android -->|Upload/Download| Storage
    iOS -->|Upload/Download| Storage
```

---

## 9. COMPONENT DIAGRAM

```mermaid
graph TB
    subgraph "Presentation Layer"
        Screens["Screens<br/>(25+ screens)"]
        Widgets["Reusable Widgets<br/>(CustomButton, DataTable)"]
        Theme["Design System<br/>(Colors, Typography, Spacing)"]
    end

    subgraph "Business Logic Layer"
        AuthProv["AuthProvider"]
        CampProv["CampaignProvider"]
        ThemeProv["ThemeProvider"]
    end

    subgraph "Service Layer"
        AuthSvc["AuthService"]
        CampSvc["CampaignService"]
        UserSvc["UserService"]
        PdfSvc["PdfReportService"]
    end

    subgraph "Data Layer (Firebase)"
        FBAuth["Firebase Auth"]
        FBStore["Cloud Firestore"]
        FBStorage["Firebase Storage"]
    end

    Screens --> Widgets
    Screens --> Theme
    Screens --> AuthProv
    Screens --> CampProv
    Screens --> ThemeProv
    AuthProv --> AuthSvc
    AuthProv --> UserSvc
    CampProv --> CampSvc
    AuthSvc --> FBAuth
    CampSvc --> FBStore
    UserSvc --> FBStore
    CampSvc --> FBStorage
    PdfSvc --> CampSvc
```

---

## 10. PACKAGE DIAGRAM

```mermaid
graph TB
    subgraph "lib/"
        config["config/<br/>AppColors, AppConstants, AppTheme"]
        enums["enums/<br/>8 type-safe enums"]
        models["models/<br/>9 data models"]
        providers["providers/<br/>3 state providers"]
        screens["screens/<br/>12 feature directories"]
        services["services/<br/>10 Firebase services"]
        theme["theme/<br/>Design tokens"]
        utils["utils/<br/>Responsive, Validators"]
        widgets["widgets/<br/>Common + Web + Admin"]
    end

    screens --> providers
    screens --> widgets
    screens --> theme
    screens --> config
    providers --> services
    providers --> models
    services --> models
    services --> enums
    widgets --> config
    widgets --> theme
    models --> enums
```
