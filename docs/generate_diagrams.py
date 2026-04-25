import base64
import zlib
import urllib.request
import os

def generate_kroki_url(mermaid_code):
    compressed = zlib.compress(mermaid_code.encode('utf-8'), 9)
    encoded = base64.urlsafe_b64encode(compressed).decode('ascii')
    return f"https://kroki.io/mermaid/png/{encoded}"

def download_diagram(mermaid_code, filename):
    url = generate_kroki_url(mermaid_code)
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response, open(filename, 'wb') as out_file:
            out_file.write(response.read())
        print(f"Downloaded {filename}")
    except Exception as e:
        print(f"Failed to download {filename}: {e}")

diagrams = {}

diagrams['unified_system_architecture.png'] = """
graph TD
    subgraph Frontend Ecosystem
        M[Mobile App<br/>Flutter]
        W[Web Dashboard<br/>Flutter Web]
        L[Public Website<br/>Next.js]
    end

    subgraph Firebase Backend
        FA[Firebase Auth]
        FS[Firestore DB]
        FST[Firebase Storage]
        FH[Firebase Hosting]
    end
    
    M -->|REST / WebSockets| FA
    M -->|CRUD Streams| FS
    M -->|Upload/Download| FST
    
    W -->|REST / WebSockets| FA
    W -->|CRUD Streams| FS
    W -->|Upload/Download| FST
    
    L -->|REST| FS
    L -->|Hosted On| FH
    W -->|Hosted On| FH
"""

diagrams['deployment_architecture.png'] = """
flowchart LR
    A[Volunteer Device<br/>Android/iOS] <--> B{Internet}
    C[Admin Browser<br/>Chrome/Safari] <--> B
    D[Public Visitor<br/>Web Browser] <--> B
    
    B <--> E((Firebase<br/>Cloud))
    
    subgraph Firebase Infrastructure
        E --> F(Firebase Auth)
        E --> G[(Firestore)]
        E --> H[Firebase Storage]
        E --> I[Firebase Hosting]
    end
    
    I -->|Serves| C
    I -->|Serves| D
"""

diagrams['dfd_level2_flow.png'] = """
graph TD
    A[Admin] -->|1. Enter Donation Details| B(Record Donation)
    B -->|2. Verify Campaign| C[(Campaigns DB)]
    C -->|3. Return Campaign Info| B
    B -->|4. Save Donation Record| D[(Donations DB)]
    D -->|5. Update Total| C
    B -->|6. Generate Receipt| E[PDF Service]
    E -->|7. Provide PDF| A
"""

diagrams['rbac_admin_diagram.png'] = """
graph TD
    U[User Client] -->|Request Data| F(Firestore Rules)
    
    F -->|Check Auth| A{Is Authenticated?}
    A -->|No| D1[Deny Access]
    A -->|Yes| B{Is Admin Role?}
    
    B -->|Yes| P1[Allow All Read/Write]
    B -->|No| C{Is Owner of Record?}
    
    C -->|Yes| P2[Allow Own Profile/Data Read/Write]
    C -->|No| P3[Allow Read Only for Public Data]
    
    P1 --> G[(Database)]
    P2 --> G
    P3 --> G
"""

diagrams['sequence_donation.png'] = """
sequenceDiagram
    actor Admin
    participant UI as Flutter Web UI
    participant Service as DonationService
    participant DB as Firestore
    participant PDF as PDFGenerator
    
    Admin->>UI: Enters Donation Data
    UI->>Service: addDonation(data)
    Service->>DB: runTransaction()
    DB-->>Service: read campaign totals
    Service->>DB: write donation record
    Service->>DB: update campaign total
    DB-->>Service: transaction complete
    Service-->>UI: success
    UI->>PDF: requestReceipt()
    PDF-->>UI: receipt.pdf
    UI-->>Admin: Show Receipt
"""

diagrams['sequence_volunteer.png'] = """
sequenceDiagram
    actor Volunteer
    participant App as Mobile App
    participant Auth as FirebaseAuth
    participant DB as Firestore
    
    Volunteer->>App: Submits Registration Form
    App->>Auth: createUserWithEmailAndPassword()
    Auth-->>App: Return UserCredential (UID)
    App->>DB: create user document (role: volunteer)
    DB-->>App: Document Created
    App-->>Volunteer: Show Home Screen
"""

diagrams['class_entities.png'] = """
classDiagram
    class User {
        +String uid
        +String name
        +String email
        +String role
    }
    class Campaign {
        +String id
        +String title
        +double goalAmount
        +double raisedAmount
        +String status
    }
    class Donation {
        +String id
        +String campaignId
        +double amount
        +DateTime date
    }
    class VolunteerProfile {
        +String userId
        +List~String~ joinedCampaigns
        +int totalHours
    }
    User "1" -- "1" VolunteerProfile : has
    Campaign "1" -- "*" Donation : receives
    User "1" -- "*" Donation : makes (optional)
    User "*" -- "*" Campaign : volunteers for
"""

diagrams['activity_campaign.png'] = """
stateDiagram-v2
    [*] --> Draft: Admin Creates
    Draft --> Active: Admin Approves/Publishes
    Active --> Suspended: Admin Pauses
    Suspended --> Active: Admin Resumes
    Active --> Completed: Goal Reached / Time Ended
    Completed --> [*]
"""

diagrams['use_case_final.png'] = """
flowchart LR
    A((Public))
    B((Volunteer))
    C((Admin))
    
    U1(View Website Info)
    U2(View Public Campaigns)
    U3(Register / Login)
    U4(View Campaigns)
    U5(Join Campaign)
    U6(Manage Profile)
    U7(Create/Edit Campaigns)
    U8(Record Donations)
    U9(Generate Reports)
    U10(Manage Users)
    
    A --> U1
    A --> U2
    
    B --> U3
    B --> U4
    B --> U5
    B --> U6
    
    C --> U3
    C --> U7
    C --> U8
    C --> U9
    C --> U10
"""

diagrams['er_final.png'] = """
erDiagram
    USERS ||--o{ DONATIONS : records
    USERS ||--o| VOLUNTEER_PROFILE : has
    CAMPAIGNS ||--o{ DONATIONS : receives
    CAMPAIGNS ||--o{ EXPENSES : incurs
    USERS }o--o{ CAMPAIGNS : participates
    
    USERS {
        string uid PK
        string role
        string email
        string name
    }
    CAMPAIGNS {
        string id PK
        string title
        number target
        string status
    }
    DONATIONS {
        string id PK
        string campaignId FK
        string adminUid FK
        number amount
    }
"""

os.makedirs("E:/Fyp/ngo_volunteer_app/docs/diagrams", exist_ok=True)
for filename, code in diagrams.items():
    filepath = os.path.join("E:/Fyp/ngo_volunteer_app/docs/diagrams", filename)
    download_diagram(code, filepath)
