"""Generate FYP-02 Thesis DOCX (Chapters 3–6) — Air University Multan Campus.

Follows supervisor's FYP Document Template exactly:
  Chapter 3: Planning and Methodology
  Chapter 4: System Specification
  Chapter 5: System Design
  Chapter 6: Coding
"""
import os
import docx
from docx import Document
from docx.shared import Pt, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement, ns

# === STUDENT DATA ===
STUDENT = "Muhammad Maauz Mansoor"
REG = "233599"
SESSION = "2023–2027"
SEMESTER = "7th"
UNIVERSITY = "Air University Multan Campus"
DEPARTMENT = "Department of Computer Science"
SUPERVISOR = "Miss Fatima Yousuf"

doc = Document()

# --- Helpers ---
def add_page_number(run):
    for tag, attr in [('begin',None),('instrText','PAGE'),('separate',None),('end',None)]:
        el = OxmlElement('w:fldChar' if tag != 'instrText' else 'w:instrText')
        if tag == 'instrText':
            el.set(ns.qn('xml:space'), 'preserve'); el.text = attr
        else:
            el.set(ns.qn('w:fldCharType'), tag)
        run._r.append(el)

# Page setup
for s in doc.sections:
    s.top_margin = Inches(1.1); s.left_margin = Inches(1.3)
    s.right_margin = Inches(0.8); s.bottom_margin = Inches(0.8)
    s.footer_distance = Inches(0.2)
    footer = s.footer
    p = footer.paragraphs[0] if footer.paragraphs else footer.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_page_number(p.add_run())

# Styles
style = doc.styles['Normal']
style.font.name = 'Times New Roman'; style.font.size = Pt(12)
style.paragraph_format.line_spacing = 1.5
for level, sz in [('Heading 1', 16), ('Heading 2', 14), ('Heading 3', 13)]:
    hs = doc.styles[level]
    hs.font.name = 'Times New Roman'; hs.font.size = Pt(sz)
    hs.font.bold = True; hs.font.color.rgb = None
    hs.paragraph_format.line_spacing = 1.5

def h1(text): p = doc.add_heading(text, level=1); p.alignment = WD_ALIGN_PARAGRAPH.CENTER; return p
def h2(text): return doc.add_heading(text, level=2)
def h3(text): return doc.add_heading(text, level=3)
def body(text):
    p = doc.add_paragraph(text); p.style = doc.styles['Normal']; return p
def caption(text):
    p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(text); r.font.size = Pt(10); r.italic = True; return p
def add_table(headers, rows):
    t = doc.add_table(rows=len(rows)+1, cols=len(headers)); t.style = 'Table Grid'
    for i, h in enumerate(headers):
        c = t.rows[0].cells[i]; c.text = h
        for r in c.paragraphs[0].runs: r.bold = True
    for ri, row in enumerate(rows):
        for ci, val in enumerate(row):
            t.rows[ri+1].cells[ci].text = str(val)
    return t
def img(path, cap, width=Inches(5.2)):
    if os.path.exists(path):
        doc.add_picture(path, width=width)
        doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
        caption(cap); return True
    else:
        body(f"[DIAGRAM PLACEHOLDER: {cap}]"); return False

diagram_dir = os.path.join(os.path.dirname(__file__), 'diagrams')

# =================== TITLE PAGE ===================
for _ in range(4): doc.add_paragraph()
h1(UNIVERSITY); h1(DEPARTMENT); doc.add_paragraph()
h1("NGO Operation and Volunteer Management System")
h1("(HRAS — Hamesha Rahein Apke Saath)")
doc.add_paragraph()
h1("FYP-02 Report: Chapters 3–6")
doc.add_paragraph()
body(f"Submitted by: {STUDENT}").alignment = WD_ALIGN_PARAGRAPH.CENTER
body(f"Registration No: {REG}").alignment = WD_ALIGN_PARAGRAPH.CENTER
body(f"Session: {SESSION} | Semester: {SEMESTER}").alignment = WD_ALIGN_PARAGRAPH.CENTER
body(f"Supervised by: {SUPERVISOR}").alignment = WD_ALIGN_PARAGRAPH.CENTER
doc.add_page_break()

# =================== CHAPTER 3: PLANNING AND METHODOLOGY ===================
h1("Chapter 3: Planning and Methodology")
body("This chapter describes the project planning, deliverables, scheduling, and the development methodology adopted for the HRAS NGO Volunteer Management System.")

h2("3.1 Project Deliverables")
body("The list of project deliverables is:")
for d in ["Project Management Plan", "Software Requirements Specification (SRS)",
           "Software Design Description (SDD)", "Software Quality Assurance Plan",
           "Working System with Firestore Database", "Cross-Platform Mobile Application (Android, iOS, Web)",
           "Public Website (Next.js)", "Final Thesis Document"]:
    body(f"• {d}")

h2("3.2 Work Breakdown Structure")
body("The project is divided into seven major work packages spanning three FYP semesters.")
caption("Table 3.1: Work Breakdown Structure")
add_table(["WP#", "Work Package", "FYP Phase", "Duration"],
    [["WP1", "Requirements & Literature Review", "FYP-01", "4 weeks"],
     ["WP2", "Core System Development (Flutter + Firebase)", "FYP-01", "8 weeks"],
     ["WP3", "Website Development (Next.js)", "FYP-01", "3 weeks"],
     ["WP4", "Advanced Features (Matching, QR, FCM)", "FYP-02", "6 weeks"],
     ["WP5", "System Design & Documentation", "FYP-02", "4 weeks"],
     ["WP6", "Testing & User Study", "FYP-03", "4 weeks"],
     ["WP7", "Deployment & Final Thesis", "FYP-03", "4 weeks"]])
doc.add_paragraph()
img(os.path.join(diagram_dir, 'wbs_chart_1777123248717.png'), 'Figure 3.1: Work Breakdown Structure')

h2("3.3 Project Timeline (Gantt Chart)")
body("The project follows a phased timeline across 1.5 years (3 semesters).")
img(os.path.join(diagram_dir, 'gantt_chart_1777123236084.png'), 'Figure 3.2: Project Timeline — Gantt Chart')

h2("3.4 Process Model")
body("The HRAS system is developed using the Agile Iterative Model. This model was selected because:")
for r in ["Requirements evolved incrementally across FYP phases",
           "Each iteration produces a working prototype for supervisor review",
           "Feature flags enable parallel development without breaking stable releases",
           "Continuous integration ensures regression-free development"]:
    body(f"• {r}")
img(os.path.join(diagram_dir, 'sdlc_model_1777123350385.png'), 'Figure 3.3: Agile Iterative SDLC Model')

h2("3.5 FYP Phase Structure")
caption("Table 3.2: FYP Phase Structure")
add_table(["Phase", "Semester", "Focus", "Deliverables"],
    [["FYP-01", "6th", "Core Development", "Mobile App, Website, Firebase Backend"],
     ["FYP-02", "7th", "Advanced Features", "Smart Matching, QR Attendance, FCM, Documentation"],
     ["FYP-03", "8th", "Testing & Deployment", "UAT, Performance Testing, Final Thesis"]])

h2("3.6 Feature Flag Architecture")
body("A compile-time feature gating system ensures backward compatibility across FYP phases:")
body("• FYP-01 Mode (Default): flutter run — Only basic features visible")
body("• FYP-02 Mode: flutter run --dart-define=APP_PHASE=FYP2 — Advanced features enabled")
body("• Full Mode: flutter run --dart-define=APP_PHASE=FULL — Everything enabled")
body("This architecture allows simultaneous development of FYP-02 features without breaking the stable FYP-01 codebase that was already defended.")

h2("3.7 Summary")
body("This chapter established the Agile Iterative methodology, described the Work Breakdown Structure spanning three FYP semesters, and presented the feature flag architecture ensuring backward compatibility. The phased approach ensures each FYP defense demonstrates only the features relevant to that phase.")
doc.add_page_break()

# =================== CHAPTER 4: SYSTEM SPECIFICATION ===================
h1("Chapter 4: System Specification")
body("This chapter specifies the software requirements including business requirements, functional and non-functional requirements, use cases, and the traceability matrix.")

h2("4.1 Business Requirements")
body("The HRAS NGO requires a digital platform that:")
for b in ["Centralizes campaign management across multiple campaign types (Ration, Medical, Education, Winter Drive, etc.)",
           "Tracks monetary and in-kind donations with verifiable records",
           "Coordinates volunteer recruitment, registration, and attendance",
           "Provides real-time analytics and PDF reports for transparency",
           "Operates on mobile (Android/iOS) and web from a single codebase"]:
    body(f"• {b}")

h2("4.2 User Requirements")
h3("4.2.1 Admin Requirements")
for r in ["Login with email/password authentication",
           "Create, edit, and delete campaigns with full lifecycle management",
           "Record donations (cash, online, in-kind) with receipt generation",
           "Manage volunteers and track attendance",
           "View analytics dashboard with real-time statistics",
           "Generate QR codes for campaign attendance (FYP-02)",
           "Manage all users (activate/deactivate accounts)"]:
    body(f"• {r}")
h3("4.2.2 Volunteer Requirements")
for r in ["Register and login with email verification",
           "Browse available campaigns and join/leave campaigns",
           "View personal contribution history",
           "Receive campaign recommendations based on skills (FYP-02)",
           "Scan QR codes for attendance verification (FYP-02)",
           "Update profile with skills, address, and bio"]:
    body(f"• {r}")

h2("4.3 Process Flow")
body("The system follows a three-tier process flow: User Interface (Flutter) → Business Logic (Dart Services) → Backend (Firebase Firestore).")
img(os.path.join(diagram_dir, 'system_flowchart_1777123184888.png'), 'Figure 4.1: Complete System Process Flow')

h2("4.4 Functional Requirements")
caption("Table 4.1: Functional Requirements")
add_table(["ID", "Requirement", "Priority", "FYP Phase"],
    [["FR01", "User Login with email/password authentication", "High", "FYP-01"],
     ["FR02", "User Registration with email verification", "High", "FYP-01"],
     ["FR03", "Campaign CRUD (Create, Read, Update, Delete)", "High", "FYP-01"],
     ["FR04", "Campaign status lifecycle (Upcoming → Active → Completed)", "High", "FYP-01"],
     ["FR05", "Donation recording (Cash, Online, In-kind categories)", "High", "FYP-01"],
     ["FR06", "PDF donation receipt generation", "Medium", "FYP-01"],
     ["FR07", "Volunteer self-registration for campaigns", "High", "FYP-01"],
     ["FR08", "Volunteer attendance tracking", "Medium", "FYP-01"],
     ["FR09", "Expense recording per campaign", "High", "FYP-01"],
     ["FR10", "Admin dashboard with real-time analytics", "Medium", "FYP-01"],
     ["FR11", "Role-based access control (Admin/Volunteer)", "High", "FYP-01"],
     ["FR12", "Smart volunteer-campaign matching algorithm", "Medium", "FYP-02"],
     ["FR13", "QR code generation for campaign attendance", "Medium", "FYP-02"],
     ["FR14", "QR code scanning for volunteer check-in", "Medium", "FYP-02"],
     ["FR15", "Push notifications via FCM", "Low", "FYP-02"]])

h2("4.5 Non-Functional Requirements")
caption("Table 4.2: Non-Functional Requirements")
add_table(["ID", "Requirement", "Description"],
    [["NFR01", "Performance", "System must respond within 2 seconds for CRUD operations"],
     ["NFR02", "Usability", "Interface must be intuitive for users with basic smartphone literacy"],
     ["NFR03", "Availability", "System must be available 99% uptime via Firebase infrastructure"],
     ["NFR04", "Scalability", "Must handle 500+ concurrent users without performance degradation"],
     ["NFR05", "Security", "RBAC enforced via Firestore security rules; passwords hashed by Firebase Auth"],
     ["NFR06", "Maintainability", "Modular architecture with feature flags for phase-based development"]])

h2("4.6 Assumptions and Constraints")
h3("4.6.1 Development Languages and Tools")
caption("Table 4.3: Development Tools and Technologies")
add_table(["Tool/Technology", "Version", "Purpose"],
    [["Flutter", "3.x", "Cross-platform UI framework (Android, iOS, Web)"],
     ["Dart", "3.x", "Programming language"],
     ["Firebase Core", "4.7.0", "Backend-as-a-Service"],
     ["Cloud Firestore", "6.3.0", "NoSQL database"],
     ["Firebase Auth", "5.5.1", "Authentication"],
     ["Firebase Storage", "12.4.4", "File/image storage"],
     ["Firebase Messaging", "16.2.0", "Push notifications (FCM)"],
     ["Next.js", "16.x", "Public website framework"],
     ["qr_flutter", "4.1.0", "QR code generation"],
     ["mobile_scanner", "6.0.x", "QR code scanning (camera)"],
     ["VS Code", "Latest", "Primary IDE"]])

h3("4.6.2 Operating Environment")
body("The system runs on: Android 5.0+, iOS 12+, and modern web browsers (Chrome, Safari, Firefox). The backend runs on Google Cloud infrastructure via Firebase.")

h2("4.7 Actors")
caption("Table 4.4: System Actors")
add_table(["Actor", "Description", "Key Actions"],
    [["Admin", "NGO administrator with full system access", "Campaign CRUD, Donation recording, User management, QR generation, Analytics"],
     ["Volunteer", "Registered user who participates in campaigns", "Browse campaigns, Join/Leave, Scan QR, View recommendations, Update profile"],
     ["Public User", "Unregistered visitor on the website", "View public campaigns, Read about HRAS, Contact NGO"]])

h2("4.8 Use Cases")
body("The following use case diagram shows the interactions between actors and the system.")
img(os.path.join(diagram_dir, 'use_case_final.png'), 'Figure 4.2: Use Case Diagram')

h3("4.8.1 Use Case: User Login")
caption("Table 4.5: Login Use Case")
add_table(["Field", "Description"],
    [["Use Case ID", "UC01"], ["Actor", "Admin / Volunteer"],
     ["Precondition", "User has a registered account"],
     ["Main Flow", "1. User enters email and password\n2. System validates credentials via Firebase Auth\n3. System loads user profile from Firestore\n4. System redirects to Dashboard (Volunteer) or Admin Panel (Admin)"],
     ["Postcondition", "User is authenticated and dashboard is displayed"],
     ["Exception", "Invalid credentials → error message shown"]])

h3("4.8.2 Use Case: Campaign Management")
caption("Table 4.6: Campaign Management Use Case")
add_table(["Field", "Description"],
    [["Use Case ID", "UC02"], ["Actor", "Admin"],
     ["Precondition", "Admin is logged in"],
     ["Main Flow", "1. Admin clicks 'Create Campaign'\n2. Fills title, description, type, location, dates\n3. System creates campaign in Firestore\n4. Campaign appears in campaign list"],
     ["Postcondition", "New campaign is created and visible to all users"],
     ["Exception", "Validation errors → form shows inline errors"]])

h2("4.9 Traceability Matrix")
caption("Table 4.7: Requirements Traceability Matrix")
add_table(["FR ID", "Use Case", "Test Case", "Module"],
    [["FR01", "UC01", "TC01", "Authentication"],
     ["FR02", "UC01", "TC02", "Registration"],
     ["FR03", "UC02", "TC03", "Campaign Management"],
     ["FR05", "UC03", "TC04", "Donation Recording"],
     ["FR07", "UC04", "TC05", "Volunteer Management"],
     ["FR12", "UC05", "TC06", "Smart Matching (FYP-02)"],
     ["FR13", "UC06", "TC07", "QR Attendance (FYP-02)"]])

h2("4.10 Summary")
body("This chapter specified 15 functional requirements and 6 non-functional requirements across FYP-01 and FYP-02 phases. Use cases were defined for core system interactions, and a traceability matrix links requirements to test cases for verification in Chapter 7.")
doc.add_page_break()

# =================== CHAPTER 5: SYSTEM DESIGN ===================
h1("Chapter 5: System Design")
body("This chapter presents the architectural design of the HRAS system including system architecture, data models, flow diagrams, and the design of advanced FYP-02 features.")

h2("5.1 System Architecture")
body("The HRAS system follows a four-layer architecture: Presentation Layer (Flutter UI), Business Logic Layer (Dart Services), Data Access Layer (Firebase SDK), and Infrastructure Layer (Google Cloud).")
img(os.path.join(diagram_dir, 'unified_system_architecture.png'), 'Figure 5.1: Unified System Architecture')

h2("5.2 Entity Relationship Diagram")
body("The Firestore database uses a NoSQL document model with the following collections:")
img(os.path.join(diagram_dir, 'er_final.png'), 'Figure 5.2: Entity Relationship Diagram')

h2("5.3 Data Flow Diagrams")
h3("5.3.1 Context Level (Level 0)")
img(os.path.join(diagram_dir, 'dfd_level0_1777123112830.png'), 'Figure 5.3: DFD Level 0 — System Context')
h3("5.3.2 Level 1 DFD")
img(os.path.join(diagram_dir, 'dfd_level1_1777123318617.png'), 'Figure 5.4: DFD Level 1 — Process Decomposition')
h3("5.3.3 Level 2 DFD")
img(os.path.join(diagram_dir, 'dfd_level2_flow.png'), 'Figure 5.5: DFD Level 2 — Donation & Volunteer Flow')

h2("5.4 Sequence Diagrams")
h3("5.4.1 Donation Transaction Flow")
img(os.path.join(diagram_dir, 'sequence_donation.png'), 'Figure 5.6: Sequence Diagram — Donation Flow')
h3("5.4.2 Volunteer Registration Flow")
img(os.path.join(diagram_dir, 'sequence_volunteer.png'), 'Figure 5.7: Sequence Diagram — Volunteer Registration')

h2("5.5 Class Diagram")
img(os.path.join(diagram_dir, 'class_entities.png'), 'Figure 5.8: Class Diagram — Core Entities')

h2("5.6 Component Diagram")
img(os.path.join(diagram_dir, 'component_diagram_1777123363771.png'), 'Figure 5.9: Component Diagram — Four-Layer Architecture')

h2("5.7 Deployment Diagram")
img(os.path.join(diagram_dir, 'deployment_architecture.png'), 'Figure 5.10: Deployment Diagram')

h2("5.8 Data Dictionary")
caption("Table 5.1: Users Collection")
add_table(["Field", "Type", "Description"],
    [["uid", "String", "Unique user identifier (Firebase Auth UID)"],
     ["name", "String", "Full name of the user"],
     ["email", "String", "Email address (unique)"],
     ["phone", "String", "Phone number"],
     ["role", "String", "User role: 'admin' or 'volunteer'"],
     ["skills", "Array<String>", "List of user skills (for matching)"],
     ["address", "String", "User address (for location matching)"],
     ["isActive", "Boolean", "Account active status"],
     ["campaignsJoined", "Integer", "Count of campaigns joined"],
     ["fcmToken", "String", "FCM push notification token (FYP-02)"]])
doc.add_paragraph()
caption("Table 5.2: Campaigns Collection")
add_table(["Field", "Type", "Description"],
    [["id", "String", "Unique campaign identifier"],
     ["title", "String", "Campaign title"],
     ["type", "Enum", "Campaign type (ration, medical, education, etc.)"],
     ["status", "Enum", "Status: upcoming, active, completed"],
     ["location", "String", "Campaign location"],
     ["startDate", "Timestamp", "Campaign start date"],
     ["totalVolunteers", "Integer", "Count of registered volunteers"],
     ["totalDonationsAmount", "Double", "Total donation amount (PKR)"],
     ["totalExpenses", "Double", "Total expenses recorded"],
     ["progressPercent", "Integer", "Campaign completion percentage"]])
doc.add_paragraph()
caption("Table 5.3: Volunteers Collection")
add_table(["Field", "Type", "Description"],
    [["id", "String", "Unique volunteer record ID"],
     ["campaignId", "String", "Reference to campaign"],
     ["userId", "String", "Reference to user"],
     ["status", "Enum", "Status: registered, confirmed, attended, absent"],
     ["registeredAt", "Timestamp", "Registration timestamp"],
     ["attendedAt", "Timestamp", "Attendance timestamp (set by QR scan)"]])

h2("5.9 Smart Matching Algorithm Design (FYP-02)")
body("The Smart Matching Algorithm uses a weighted scoring model to recommend campaigns to volunteers:")
body("Score = (Skill Match × 0.50) + (Location Match × 0.30) + (Availability × 0.20)")
caption("Table 5.4: Matching Algorithm Weights")
add_table(["Factor", "Weight", "Score Range", "Logic"],
    [["Skills Match", "50%", "0.0–1.0", "Maps user skill keywords to campaign type compatibility"],
     ["Location Match", "30%", "0.0–1.0", "String-based city comparison (15 Pakistani cities)"],
     ["Availability", "20%", "0.0–1.0", "1.0 if not registered, 0.0 if already registered"]])
body("Quality Labels: Excellent (≥80%), Good (≥60%), Fair (≥40%), Low (<40%)")

h2("5.10 QR Attendance System Design (FYP-02)")
body("The QR Attendance system follows a generate-scan-verify flow:")
body("1. Admin opens a campaign and selects 'Generate QR Code'")
body("2. System encodes campaign ID and title into a JSON payload")
body("3. QR code is displayed using the qr_flutter package")
body("4. Volunteer opens the app and taps 'Scan QR Attendance'")
body("5. Camera scans the QR code using mobile_scanner package")
body("6. System parses the JSON, verifies registration, and marks attendance in Firestore")

h2("5.11 Summary")
body("This chapter presented the four-layer system architecture, data models (ER diagram and data dictionary), behavioral models (sequence and activity diagrams), and the design of FYP-02 innovation features. All diagrams follow UML 2.0 notation standards.")
doc.add_page_break()

# =================== CHAPTER 6: CODING ===================
h1("Chapter 6: Coding")
body("This chapter contains code of the major functionalities of the project. Full code is available in the GitHub repository.")

h2("6.1 Flutter Mobile Development")
h3("6.1.1 Feature Flags System")
body("The feature flag system controls which features are visible in each FYP phase:")
code = '''class FeatureFlags {
  static const String phase = String.fromEnvironment(
    'APP_PHASE', defaultValue: 'FYP1');

  static bool get isFyp1 => phase == 'FYP1';
  static bool get isFyp2 => phase == 'FYP2';
  static bool get isFull => phase == 'FULL';

  // Feature gates
  static bool get isSmartMatchingEnabled => isFyp2 || isFull;
  static bool get isQrAttendanceEnabled => isFyp2 || isFull;
  static bool get isPushNotificationsEnabled => isFyp2 || isFull;
}'''
body(code)

h3("6.1.2 Campaign Service (Core CRUD)")
body("The CampaignService handles all Firestore CRUD operations for campaigns:")
code2 = '''class CampaignService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<CampaignModel> createCampaign(CampaignModel campaign) async {
    final docRef = _db.collection('campaigns').doc();
    final newCampaign = campaign.copyWith(id: docRef.id);
    await docRef.set(newCampaign.toMap());
    return newCampaign;
  }

  Stream<List<CampaignModel>> getCampaignsStream() {
    return _db.collection('campaigns')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => CampaignModel.fromMap(d.data())).toList());
  }
}'''
body(code2)

h2("6.2 Smart Matching Algorithm (FYP-02)")
body("The matching algorithm uses weighted scoring to recommend campaigns:")
code3 = '''static List<MatchResult> getRecommendations({
  required UserModel user,
  required List<CampaignModel> campaigns,
  List<VolunteerModel> existingRegistrations = const [],
}) {
  for (final campaign in campaigns) {
    final skillScore = _calculateSkillScore(user.skills, campaign.type);
    final locationScore = _calculateLocationScore(user.address, campaign.location);
    final availabilityScore = registeredIds.contains(campaign.id) ? 0.0 : 1.0;

    final totalScore = (skillScore * 0.50) + (locationScore * 0.30)
                     + (availabilityScore * 0.20);
    results.add(MatchResult(campaign: campaign, score: totalScore, ...));
  }
  results.sort((a, b) => b.score.compareTo(a.score));
  return results;
}'''
body(code3)

h2("6.3 QR Attendance System (FYP-02)")
body("QR code generation and scanning for volunteer attendance:")
code4 = '''// Generate QR payload
static String generateQrPayload({required String campaignId, required String campaignTitle}) {
  return jsonEncode({'type': 'hras_attendance', 'campaignId': campaignId,
                     'campaignTitle': campaignTitle, 'generatedAt': DateTime.now().toIso8601String()});
}

// Mark attendance from scanned QR
static Future<QrScanResult> markAttendance({required String qrRawData, required String userId}) {
  final payload = parseQrPayload(qrRawData);
  if (payload == null) return QrScanResult(success: false, message: 'Invalid QR');
  // Verify registration, check duplicate, mark as attended in Firestore
}'''
body(code4)

h2("6.4 Firebase Security Rules")
body("Firestore security rules enforce role-based access control:")
code5 = '''rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /campaigns/{campaignId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId
        || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}'''
body(code5)

h2("6.5 Summary")
body("This chapter presented code for the major system functionalities including the feature flag system, campaign management, smart matching algorithm, QR attendance system, and Firebase security rules. The complete source code with 80+ Dart files and 14,000+ lines is available in the GitHub repository.")

# =================== SAVE ===================
out = os.path.join(os.path.dirname(__file__), 'Thesis-FYP02', 'FYP_02_Thesis.docx')
os.makedirs(os.path.dirname(out), exist_ok=True)
doc.save(out)
print(f"FYP-02 Thesis saved: {out}")
print(f"Chapters: 3 (Planning), 4 (Specification), 5 (Design), 6 (Coding)")
print(f"Tables: 12+ academic tables included")
print(f"Diagrams: Embedded from docs/diagrams/")
