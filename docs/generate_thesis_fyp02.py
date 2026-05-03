"""Generate FYP-02 Thesis DOCX (Chapters 3–6) — Air University Multan Campus."""
import os, zipfile, tempfile, shutil
import docx
from docx import Document
from docx.shared import Pt, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement, ns

def inject_update_fields(docx_path):
    temp_dir = tempfile.mkdtemp()
    try:
        with zipfile.ZipFile(docx_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)
        settings_path = os.path.join(temp_dir, 'word', 'settings.xml')
        if os.path.exists(settings_path):
            with open(settings_path, 'r', encoding='utf-8') as f:
                content = f.read()
            if '<w:updateFields w:val="true"/>' not in content:
                import re
                content = re.sub(r'(<w:settings[^>]*>)', r'\1<w:updateFields w:val="true"/>', content, count=1)
                with open(settings_path, 'w', encoding='utf-8') as f:
                    f.write(content)
        with zipfile.ZipFile(docx_path, 'w', zipfile.ZIP_DEFLATED) as zip_out:
            for root, _, files in os.walk(temp_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    zip_out.write(file_path, os.path.relpath(file_path, temp_dir))
    finally:
        shutil.rmtree(temp_dir)

STUDENT = "Muhammad Maauz Mansoor"
REG = "233599"
SESSION = "2023–2027"
UNIVERSITY = "Air University Multan Campus"
DEPARTMENT = "Department of Computer Science"
SUPERVISOR = "Miss Fatima Yousuf"

doc = Document()

# ======= HELPERS =======
def add_page_number(run):
    for tag, attr in [('begin',None),('instrText','PAGE'),('separate',None),('end',None)]:
        el = OxmlElement('w:fldChar' if tag != 'instrText' else 'w:instrText')
        if tag == 'instrText':
            el.set(ns.qn('xml:space'), 'preserve'); el.text = attr
        else:
            el.set(ns.qn('w:fldCharType'), tag)
        run._r.append(el)

def add_seq_field(paragraph, seq_identifier, text_before, text_after):
    run_before = paragraph.add_run(text_before)
    run_before.font.size = Pt(10); run_before.italic = True
    
    fldChar1 = OxmlElement('w:fldChar'); fldChar1.set(ns.qn('w:fldCharType'), 'begin')
    r1 = paragraph.add_run(); r1._r.append(fldChar1)
    
    instrText = OxmlElement('w:instrText'); instrText.set(ns.qn('xml:space'), 'preserve')
    instrText.text = f' SEQ {seq_identifier} \\* ARABIC '
    r2 = paragraph.add_run(); r2._r.append(instrText)
    
    fldChar2 = OxmlElement('w:fldChar'); fldChar2.set(ns.qn('w:fldCharType'), 'separate')
    r3 = paragraph.add_run(); r3._r.append(fldChar2)
    
    r4 = paragraph.add_run('1') # Placeholder
    r4.font.size = Pt(10); r4.italic = True
    
    fldChar3 = OxmlElement('w:fldChar'); fldChar3.set(ns.qn('w:fldCharType'), 'end')
    r5 = paragraph.add_run(); r5._r.append(fldChar3)
    
    run_after = paragraph.add_run(text_after)
    run_after.font.size = Pt(10); run_after.italic = True

def add_table(headers, rows):
    t = doc.add_table(rows=len(rows)+1, cols=len(headers))
    t.style = 'Table Grid'
    for i, h in enumerate(headers):
        c = t.rows[0].cells[i]
        c.text = h
        for r in c.paragraphs[0].runs: r.bold = True
    for ri, row in enumerate(rows):
        for ci, val in enumerate(row):
            t.rows[ri+1].cells[ci].text = str(val)
    return t

def table_caption(t):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    add_seq_field(p, "Table", "Table ", f": {t}")
    return p

def figure_caption(t):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_seq_field(p, "Figure", "Figure ", f": {t}")
    return p

# Layout setup
for section in doc.sections:
    section.top_margin = Inches(1.1); section.left_margin = Inches(1.3)
    section.right_margin = Inches(0.8); section.bottom_margin = Inches(0.8)
    section.footer_distance = Inches(0.2)
    p = section.footer.paragraphs[0] if section.footer.paragraphs else section.footer.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_page_number(p.add_run())

style = doc.styles['Normal']
style.font.name = 'Times New Roman'; style.font.size = Pt(12); style.paragraph_format.line_spacing = 1.5

for level, sz in [('Heading 1', 16), ('Heading 2', 14), ('Heading 3', 13)]:
    hs = doc.styles[level]
    hs.font.name = 'Times New Roman'; hs.font.size = Pt(sz); hs.font.bold = True
    hs.font.color.rgb = None; hs.paragraph_format.line_spacing = 1.5

def h1(t): p = doc.add_heading(t, level=1); p.alignment = WD_ALIGN_PARAGRAPH.CENTER; return p
def h2(t): return doc.add_heading(t, level=2)
def h3(t): return doc.add_heading(t, level=3)
def body(t): p = doc.add_paragraph(t); p.style = doc.styles['Normal']; return p

diagram_dir = os.path.join(os.path.dirname(__file__), 'diagrams')
def img(path, cap, width=Inches(5.2)):
    if os.path.exists(path):
        doc.add_picture(path, width=width)
        doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
        figure_caption(cap)
        return True
    else:
        body(f"[DIAGRAM PLACEHOLDER: {cap}]")
        return False

# =================== TITLE PAGE ===================
for _ in range(4): doc.add_paragraph()
h1(UNIVERSITY)
h1(DEPARTMENT)
doc.add_paragraph()
h1("NGO Operation and Volunteer Management System")
h1("(HRAS)")
doc.add_paragraph()
h1("FYP-02 Report: Chapters 3–6")
doc.add_paragraph()
body(f"Submitted by: {STUDENT} ({REG})").alignment = WD_ALIGN_PARAGRAPH.CENTER
body(f"Supervised by: {SUPERVISOR}").alignment = WD_ALIGN_PARAGRAPH.CENTER
doc.add_page_break()

# =================== CHAPTER 3 ===================
for _ in range(6): doc.add_paragraph()
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run('Chapter 3'); r.bold = True; r.font.size = Pt(22)
p2 = doc.add_paragraph(); p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
r2 = p2.add_run('Planning and Methodology'); r2.bold = True; r2.font.size = Pt(20)
doc.add_page_break()

h1("Chapter 3: Planning and Methodology")

h2("3.1 Project Planning and Execution Strategy")
body("The successful engineering of a complex, cross-platform software ecosystem within the rigid academic timeframe of a final year project mandates aggressive and meticulous project management. Because the HRAS system features three highly interdependent nodes—a mobile application for volunteers, an administrative web dashboard, and a real-time cloud database—any mismanagement in the architectural sequence would result in catastrophic cascading delays. Therefore, the project was systematically partitioned using established Software Engineering metrics to ensure consistent velocity and risk mitigation.")

h2("3.2 Work Breakdown Structure (WBS)")
body("To manage the complexity, a strict Work Breakdown Structure (WBS) was developed. The WBS decomposes the macro-objective (the entire NGO ecosystem) into micro-deliverables that can be independently coded, tested, and validated. The structure was divided into four primary macro-phases: Requirements Engineering, Architectural Design, Code Implementation, and Quality Assurance Testing. This hierarchical decomposition ensured that critical backend services (like Firebase Authentication) were fully stable before frontend UI widgets were connected to them.")
img(os.path.join(diagram_dir, 'wbs_chart_1777123248717.png'), 'Hierarchical Work Breakdown Structure (WBS)')

table_caption("Detailed WBS Sub-Tasks")
add_table(["Macro-Phase", "Critical Micro-Tasks"],
    [["1. Requirements Engineering", "Elicitation meetings with HRAS NGO executives, functional requirement mapping, feasibility analysis."],
     ["2. Architectural Design", "Database schema normalization, UI/UX wireframing in Figma, UML diagram generation (ER, Sequence, Class)."],
     ["3. Code Implementation", "Dart/Flutter widget tree construction, Firebase NoSQL integration, State Management (Provider) setup, algorithmic coding."],
     ["4. Quality Assurance", "Automated unit test scripting, integration testing of API endpoints, User Acceptance Testing (UAT) with real volunteers."]])

h2("3.3 Project Timeline and Resource Allocation (Gantt Chart)")
body("Temporal constraints were managed via a rigorous Gantt Chart schedule. The timeline explicitly mapped task dependencies to prevent developer downtime. For example, the 'Campaign UI Development' task was strictly locked behind the 'Firestore Database Configuration' task. The Gantt chart spanned two academic semesters, allocating buffer weeks for unforeseen bug resolution and university evaluation preparations.")
img(os.path.join(diagram_dir, 'gantt_chart_1777123236084.png'), 'Project Timeline and Dependencies (Gantt Chart)')

h2("3.4 Software Development Life Cycle (SDLC) Model")
body("The architectural approach was governed by the Agile Iterative Software Development Life Cycle. In the context of NGO operations, stakeholder requirements are notoriously fluid. A traditional, monolithic Waterfall approach—where testing only occurs after full development—was deemed a critical risk. If the NGO management realized a feature did not fit their field workflow at the end of the year, pivoting would be impossible.")
body("By utilizing an Agile Iterative model, the software was developed in functional sprints. The first iteration delivered a Minimum Viable Product (MVP) containing just the authentication and basic campaign viewing modules. This was deployed to a test group of NGO administrators. Their feedback was immediately integrated into the second iteration, which introduced the complex QR attendance logic and the Smart Matching algorithm. This continuous feedback loop guaranteed that the final software architecture perfectly mirrored the real-world operational demands of the organization.")
img(os.path.join(diagram_dir, 'sdlc_model_1777123350385.png'), 'Agile Iterative SDLC Process Model')

h2("3.5 FYP Phase Submissions and Deliverables")
body("To align the Agile iterations with the university's evaluation matrix, the project was mapped to three distinct submission gateways. This structured the development velocity to meet specific academic milestones.")
table_caption("Academic Deliverable Mapping")
add_table(["Evaluation Phase", "Technical Deliverables"],
    [["FYP-01", "Comprehensive Project Proposal, Requirement Elicitation (Chapters 1-2), Baseline UI Scaffolding, Firebase Auth Setup."],
     ["FYP-02", "UML Architectural Design (Chapters 3-6), Implementation of Complex Business Logic (Smart Matching, QR Engine), NoSQL Schema Finalization."],
     ["FYP-03", "Exhaustive Quality Assurance (Chapters 7-8), PDF Generation Logic, Final Bug Resolution, Production Deployment."]])

h2("3.6 Chapter Summary")
body("This chapter presented the comprehensive project management framework driving the development of the HRAS ecosystem. By leveraging an Agile Iterative SDLC, supported by a meticulously structured WBS and timeline, the project was insulated against scope creep and delayed deliverables. This rigorous planning phase ensured that the subsequent translation of business requirements into actual code proceeded with maximum efficiency.")
doc.add_page_break()

# =================== CHAPTER 4 ===================
for _ in range(6): doc.add_paragraph()
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run('Chapter 4'); r.bold = True; r.font.size = Pt(22)
p2 = doc.add_paragraph(); p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
r2 = p2.add_run('System Specification'); r2.bold = True; r2.font.size = Pt(20)
doc.add_page_break()

h1("Chapter 4: System Specification")

h2("4.1 Introduction to Specifications")
body("The System Specification phase acts as the definitive contract between the problem domain identified in Chapter 1 and the technical architecture developed in Chapter 5. It strictly defines the functional boundaries of the software, translating abstract NGO problems into precise, testable engineering requirements.")

h2("4.2 Functional Requirements (FR)")
body("Functional requirements define the exact operational capabilities the software must possess to solve the administrative bottlenecks. Based on extensive requirements engineering with the HRAS executives, the following 15 critical functional requirements were formulated and implemented.")

table_caption("Comprehensive Functional Requirements")
add_table(["ID", "Requirement Specification", "Priority"],
    [["FR-01", "The system must authenticate users via an encrypted Email/Password protocol integrated with Firebase Auth.", "Critical"],
     ["FR-02", "The system must enforce strict Role-Based Access Control (RBAC), differentiating 'admin' from 'volunteer' privileges.", "Critical"],
     ["FR-03", "Administrators must possess full CRUD (Create, Read, Update, Delete) capabilities over NGO campaigns.", "Critical"],
     ["FR-04", "The mobile application must fetch and render a real-time list of active campaigns for volunteer viewing.", "High"],
     ["FR-05", "Volunteers must be able to securely register their participation for specific active campaigns.", "High"],
     ["FR-06", "The system must provide administrators an interface to log verified monetary and inventory donations.", "High"],
     ["FR-07", "The system must possess a rendering engine capable of generating localized PDF receipts for recorded donations.", "Medium"],
     ["FR-08", "The administrative web dashboard must calculate and display real-time financial aggregation metrics.", "High"],
     ["FR-09", "The backend must execute a Smart Matching algorithm that ranks campaigns based on a volunteer's predefined skill tags.", "High"],
     ["FR-10", "The system must utilize a cryptographic library to generate unique QR codes identifying specific campaigns.", "Medium"],
     ["FR-11", "The mobile client must access device camera hardware to scan QR codes and update attendance status to 'Present'.", "High"],
     ["FR-12", "Administrators must have visibility into a centralized database of all registered volunteers and their historical data.", "High"],
     ["FR-13", "The cloud infrastructure must trigger FCM (Firebase Cloud Messaging) push notifications upon new campaign creation.", "Low"],
     ["FR-14", "Volunteers must be able to mutate their profile data, specifically updating their array of specialized skills.", "Medium"],
     ["FR-15", "The web dashboard must support the compilation and download of comprehensive campaign summary reports.", "Low"]])

h2("4.3 Non-Functional Requirements (NFR)")
body("Non-functional requirements establish the quality attributes, performance thresholds, and security parameters under which the functional requirements must operate.")

table_caption("Non-Functional Quality Attributes")
add_table(["ID", "Technical Specification", "Attribute Category"],
    [["NFR-01", "The UI thread must maintain a 60 FPS rendering target to prevent sluggish navigation on low-end mobile hardware.", "Performance"],
     ["NFR-02", "Data mutations in Firestore must synchronize across all active client instances within a latency of < 500ms.", "Real-time Sync"],
     ["NFR-03", "The application logic must be decoupled from the UI to ensure identical execution on Android, iOS, and Web environments.", "Portability"],
     ["NFR-04", "All user authentication data must bypass local storage and be processed directly via Google's encrypted Auth APIs.", "Security"],
     ["NFR-05", "Firestore Security Rules must mathematically block unauthorized document writes, preventing privilege escalation.", "Security"],
     ["NFR-06", "The mobile UX must be optimized such that a volunteer can complete campaign registration in under three sequential taps.", "Usability"]])

h2("4.4 Development Stack and Technologies")
body("The technology stack was selected specifically to maximize deployment reach while minimizing maintenance overhead.")
table_caption("Core Technology Stack")
add_table(["Technology", "Architectural Purpose"],
    [["Flutter Framework (Dart)", "Provides a high-performance, single-codebase cross-platform UI engine."],
     ["Firebase Firestore", "A highly scalable NoSQL cloud database providing instant WebSocket data synchronization."],
     ["Firebase Authentication", "Handles secure token generation, session management, and password encryption."],
     ["Provider (State Mgmt)", "Efficiently manages application state and UI rebuilding without memory leaks."]])

h2("4.5 System Actors")
body("The ecosystem is designed to cater to two distinctly polarized user personas, each requiring vastly different interface philosophies and data access rights.")
table_caption("System Personas")
add_table(["Actor", "Access Level & Description"],
    [["Administrator", "Possesses global read/write access. Interacts primarily through the expansive Web Dashboard to execute complex logistical planning, verify finances, and generate macro-level analytical reports."],
     ["Volunteer", "Possesses restricted access isolated to their own profile. Interacts primarily through the Mobile Application to consume campaign data, scan QR codes, and register participation."]])

h2("4.6 Comprehensive Use Cases")
body("Use cases translate the requirements into concrete operational scenarios. The overarching architecture is visualized in the Use Case diagram below, detailing the interaction vectors between the actors and the system boundaries.")
img(os.path.join(diagram_dir, 'use_case_diagram_1777123080620.png'), 'Unified System Use Case Diagram')

table_caption("Scenario: Algorithmic Smart Matching")
add_table(["Parameter", "Scenario Definition"],
    [["Use Case Name", "Trigger Smart Campaign Matching"],
     ["Primary Actor", "System / Volunteer"],
     ["Pre-condition", "Volunteer has defined skills in profile; active campaigns exist."],
     ["Execution Flow", "1. Volunteer authenticates. 2. System retrieves user's skill array. 3. System iterates over active campaigns. 4. Algorithm calculates match score. 5. UI renders sorted list prioritizing highest matches."],
     ["Post-condition", "Volunteer is presented with a highly personalized campaign feed."]])

table_caption("Scenario: Cryptographic Attendance (QR)")
add_table(["Parameter", "Scenario Definition"],
    [["Use Case Name", "Process QR Attendance Verification"],
     ["Primary Actor", "Volunteer / Administrator"],
     ["Pre-condition", "Admin has generated QR for campaign; Volunteer is physically present."],
     ["Execution Flow", "1. Admin displays dynamic QR code. 2. Volunteer initiates camera scanner. 3. System decodes Campaign ID. 4. System verifies volunteer registration. 5. Firestore mutates attendance boolean to True."],
     ["Post-condition", "Real-time attendance metric increments on Admin dashboard."]])

h2("4.7 Requirements Traceability Matrix (RTM)")
body("To ensure absolute engineering rigor, an RTM was maintained throughout the SDLC. This matrix explicitly maps the functional specifications to the actual testing scenarios, guaranteeing that no requirement was abandoned during the coding phase.")
table_caption("Traceability Matrix Snapshot")
add_table(["Requirement ID", "Core Function", "Test Case Linkage", "Deployment Status"],
    [["FR-01", "Encrypted Authentication", "TC-01, TC-02, TC-03", "Verified & Deployed"],
     ["FR-03", "Campaign CRUD Operations", "TC-05, TC-06, TC-07", "Verified & Deployed"],
     ["FR-06", "Financial Donation Logging", "TC-15 (Integration)", "Verified & Deployed"],
     ["FR-09", "Smart Matching Algorithm", "TC-11", "Verified & Deployed"],
     ["FR-10, FR-11", "QR Generation & Scanning", "TC-12, TC-13", "Verified & Deployed"]])

h2("4.8 Chapter Summary")
body("This chapter systematically transformed the operational problems of the HRAS NGO into a rigorous, testable set of software engineering specifications. By defining explicit functional parameters, strict performance thresholds, and detailed execution scenarios, the foundation was laid for the architectural design phase. The comprehensive Traceability Matrix ensures that the final deployed code will perfectly align with these initial specifications.")
doc.add_page_break()

# =================== CHAPTER 5 ===================
for _ in range(6): doc.add_paragraph()
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run('Chapter 5'); r.bold = True; r.font.size = Pt(22)
p2 = doc.add_paragraph(); p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
r2 = p2.add_run('System Design'); r2.bold = True; r2.font.size = Pt(20)
doc.add_page_break()

h1("Chapter 5: System Design")

h2("5.1 Introduction to Architectural Design")
body("System design represents the critical bridge between abstract requirements and executable code. This chapter details the comprehensive structural blueprints of the HRAS ecosystem. It encompasses the macro-level network architecture, the micro-level object-oriented code structures, and the schema normalization strategies employed to optimize data retrieval in a NoSQL environment.")

h2("5.2 Macro System Architecture")
body("The platform is engineered upon a decoupled Client-Server architecture. The presentation layer consists of two distinct Flutter-compiled clients: the Mobile Application and the Web Dashboard. These clients do not communicate laterally. Instead, all data transactions are routed through the Firebase Cloud Backend. This centralized architecture ensures that business logic and security rules are executed server-side, preventing client manipulation and guaranteeing data consistency across all platforms.")
img(os.path.join(diagram_dir, 'system_architecture_1777123050441.png'), 'High-Level Client-Server Architecture')

h2("5.3 Database Schema and Entity Relationships")
body("While Firebase Firestore operates as a document-based NoSQL database, mapping the conceptual relationships between entities remains crucial for structuring the nested collections. The system fundamentally revolves around three primary entities: Users, Campaigns, and Donations. The ER diagram illustrates how a singular Campaign document contains sub-collections referencing multiple Volunteer documents (a one-to-many relationship) to track attendance states efficiently without duplicating heavy profile data.")
img(os.path.join(diagram_dir, 'er_diagram_1777123063920.png'), 'Conceptual Entity Relationship Schema')

h2("5.4 Comprehensive Data Dictionary")
body("To ensure consistent data typing across the Dart frontend and the Firestore backend, a rigid data dictionary was established. This prevents type-casting errors during network serialization.")

table_caption("Data Schema: 'users' Collection")
add_table(["Key", "Type", "Constraints", "Description"],
    [["uid", "String", "Primary, Unique", "Cryptographic ID generated by Firebase Auth."],
     ["name", "String", "Length > 2", "The full legal name of the stakeholder."],
     ["role", "String", "Enum (admin, vol)", "The master flag controlling RBAC permissions."],
     ["skills", "Array<String>", "Nullable", "Vector of skill tags utilized by the matching algorithm."]])

table_caption("Data Schema: 'campaigns' Collection")
add_table(["Key", "Type", "Constraints", "Description"],
    [["campaignId", "String", "Primary, Unique", "Auto-generated alphanumeric document ID."],
     ["title", "String", "Length > 5", "Public-facing title of the humanitarian event."],
     ["date", "Timestamp", "Future Date", "Temporal marker for the event execution."],
     ["tags", "Array<String>", "Required", "Skill prerequisites used for algorithmic matching."],
     ["status", "String", "Enum (active, done)", "State machine flag controlling visibility."]])

h2("5.5 Data Flow Modeling (DFD)")
body("Data Flow Diagrams graphically map the lifecycle of information as it enters the UI, traverses the network, mutates in the database, and returns as a response. The Level 0 Context Diagram establishes the absolute system boundary, demonstrating the macro inputs (e.g., Donation amounts) from external actors and the resulting outputs (e.g., PDF Receipts).")
img(os.path.join(diagram_dir, 'dfd_level0_1777123112830.png'), 'DFD Level 0: Macro Context Boundary')
body("The Level 1 DFD deconstructs the central system into discrete internal processes. It visualizes the exact pathways through which the Authentication module verifies credentials before allowing data to flow into the Campaign Management or Reporting modules.")
img(os.path.join(diagram_dir, 'dfd_level1_1777123318617.png'), 'DFD Level 1: Internal Sub-Process Flow')

h2("5.6 Temporal Execution (Sequence Diagrams)")
body("Sequence diagrams are vital for understanding asynchronous network operations over time. The Login Sequence below illustrates a highly complex temporal flow: The client dispatches credentials to Firebase Auth, awaits an encrypted token, utilizes that token to query the Firestore 'users' collection, validates the RBAC 'role' field, and finally commands the Flutter Router to render the appropriate dashboard.")
img(os.path.join(diagram_dir, 'sequence_login_1777123126133.png'), 'Asynchronous Authentication Sequence')

h2("5.7 Object-Oriented Class Structure")
body("The Flutter frontend was engineered using strict Object-Oriented Programming (OOP) principles. The Class Diagram visualizes the separation of concerns within the codebase. Data transfer objects (Models) are completely isolated from network request logic (Services). For instance, the `CampaignService` class handles all asynchronous API calls, returning clean `CampaignModel` objects that the UI components render. This modularity drastically reduces code duplication.")
img(os.path.join(diagram_dir, 'class_diagram_1777123296381.png'), 'Frontend Class Hierarchy and Associations')

h2("5.8 Component and Physical Deployment Architecture")
body("The Component Architecture reflects the implementation of the Provider State Management pattern. It shows how UI widgets listen to central Provider classes, ensuring that when data mutates in the database, only the specific widgets relying on that data rebuild, preventing UI frame drops.")
img(os.path.join(diagram_dir, 'component_diagram_1777123363771.png'), 'State Management Component Integration')
body("The Deployment Diagram maps the physical infrastructure. It illustrates the distribution of the compiled binary (.apk / .ipa) to the end-user's physical hardware, operating over HTTPS protocols to interface with Google's globally distributed Firebase server infrastructure.")
img(os.path.join(diagram_dir, 'deployment_diagram_1777123140325.png'), 'Physical Hardware and Cloud Deployment')

h2("5.9 Security Paradigm: Role-Based Access Control")
body("To protect sensitive NGO financial data, a mathematically robust RBAC logic was engineered. The security flow does not rely on hiding buttons in the UI. Instead, when an API request is initiated, Firestore Security Rules intercept the request, query the user's role token, and explicitly reject the read/write operation if the user lacks 'admin' clearance. This server-side validation renders client-side hacking attempts ineffective.")
img(os.path.join(diagram_dir, 'rbac_security_1777123197305.png'), 'Server-Side RBAC Enforcement Flow')

h2("5.10 Chapter Summary")
body("This chapter translated the abstract project requirements into an exhaustive technical blueprint. By establishing a normalized NoSQL schema, enforcing server-side security architectures, and mapping complex asynchronous data flows through sequence and class diagrams, a rigid framework was created. This meticulous design phase ensured that the subsequent coding phase was executed efficiently, with zero ambiguity regarding data structures or network protocols.")
doc.add_page_break()

# =================== CHAPTER 6 ===================
for _ in range(6): doc.add_paragraph()
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run('Chapter 6'); r.bold = True; r.font.size = Pt(22)
p2 = doc.add_paragraph(); p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
r2 = p2.add_run('Coding and Implementation'); r2.bold = True; r2.font.size = Pt(20)
doc.add_page_break()

h1("Chapter 6: Coding and Implementation")

h2("6.1 Implementation Ecosystem")
body("The translation of the architectural blueprints into executable software was conducted using the Dart programming language within the Flutter SDK. The development environment utilized Visual Studio Code, augmented with strict linting rules to enforce code quality. The application was structurally partitioned adhering to the MVC (Model-View-Controller) paradigm. The 'screens' directory contained stateless and stateful UI components, the 'models' directory housed JSON serialization logic, and the 'services' directory encapsulated all asynchronous HTTP and Firebase SDK communications.")

h2("6.2 Engineering the Smart Matching Algorithm")
body("A significant technical milestone achieved during the FYP-02 iteration was the development of the Smart Matching Engine. Historically, volunteers at HRAS manually scrolled through lists to find relevant campaigns, often missing events where their specialized skills (e.g., paramedical training) were desperately needed.")
body("The implemented algorithm executes a complex intersection sequence on the client side to minimize server database reads. Upon application launch, the system queries the user's document to retrieve their `skills` array. Simultaneously, it fetches the list of active campaigns, each possessing a `tags` array. The algorithm performs a highly optimized iterative comparison; for every intersection found between the user's skills and a campaign's tags, an internal weighting metric is incremented. The array of campaigns is subsequently dynamically sorted via the Dart `sort()` method based on this computed weight, ensuring the UI rendering engine instantly displays the most relevant humanitarian events at the apex of the volunteer's feed.")

h2("6.3 Cryptographic QR Code Attendance Engine")
body("To resolve the severe logistical latency of manual paper-based attendance during chaotic field campaigns, a cryptographic QR processing engine was engineered.")
body("The logic operates in a dual-phase execution: First, the Admin Dashboard utilizes a data-encoding package to convert a specific 20-character alphanumeric `campaignId` string into a high-density QR code visual matrix. Second, the volunteer application triggers the native mobile camera hardware, executing a real-time computer vision scan to decode the matrix. Upon successful decryption, the application payload transmits a secure mutation request to Firestore, updating the volunteer's boolean attendance flag from 'Registered' to 'Present' within milliseconds. This completely automates field logistics and provides the NGO leadership with instant attendance metrics.")

h2("6.4 Dynamic PDF Rendering and File System I/O")
body("Ensuring verifiable financial transparency required the ability to generate immutable documentation. I integrated the sophisticated `pdf` Dart package to construct a virtual rendering canvas. When an administrator commits a donation entry, the software dynamically paints the NGO's branding, the donor's alphanumeric credentials, the timestamp, and the financial quantum onto this digital canvas. The application then interfaces directly with the native operating system's file I/O channels (requiring explicit user permissions) to encode and write the document to local storage as a secure PDF file, ready for immediate dissemination to the donor.")

h2("6.5 Chapter Summary")
body("This chapter detailed the aggressive technical execution of the project's most complex modules. By writing highly optimized algorithmic code for smart matching, successfully bridging native camera hardware with cloud databases for QR attendance, and implementing dynamic file I/O operations for PDF generation, the conceptual blueprints of Chapter 5 were successfully transformed into a robust, high-performance software reality.")
doc.add_page_break()

out = os.path.join(os.path.dirname(__file__), 'Thesis-FYP02', 'FYP_02_Thesis.docx')
os.makedirs(os.path.dirname(out), exist_ok=True)
doc.save(out)
inject_update_fields(out)
print(f"FYP-02 Thesis (Extreme Edition) saved: {out}")
