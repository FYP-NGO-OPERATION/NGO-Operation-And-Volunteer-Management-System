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
    section.top_margin = Inches(1.1)
    section.left_margin = Inches(1.3)
    section.right_margin = Inches(0.8)
    section.bottom_margin = Inches(0.8)
    section.footer_distance = Inches(0.2)
    p = section.footer.paragraphs[0] if section.footer.paragraphs else section.footer.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_page_number(p.add_run())

style = doc.styles['Normal']
style.font.name = 'Times New Roman'
style.font.size = Pt(12)
style.paragraph_format.line_spacing = 1.5

for level, sz in [('Heading 1', 16), ('Heading 2', 14), ('Heading 3', 13)]:
    hs = doc.styles[level]
    hs.font.name = 'Times New Roman'
    hs.font.size = Pt(sz)
    hs.font.bold = True
    hs.font.color.rgb = None
    hs.paragraph_format.line_spacing = 1.5

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

h2("3.1 Project Planning")
body("Good planning was necessary to make sure the HRAS system was completed on time within the final year of my degree. Because there were many moving parts, like a mobile app for volunteers, a web dashboard for admins, and a real-time database, I had to break the project down into smaller, manageable pieces.")

h2("3.2 Work Breakdown Structure (WBS)")
body("A Work Breakdown Structure helps in dividing a large project into smaller tasks. For this system, I divided the work into four main phases: Requirements gathering, System Design, Coding (Implementation), and Testing.")
img(os.path.join(diagram_dir, 'wbs_chart_1777123248717.png'), 'Work Breakdown Structure Chart')

table_caption("Work Breakdown Structure Details")
add_table(["Phase", "Tasks Included"],
    [["1. Requirements", "Meeting with HRAS NGO, gathering requirements, writing proposal."],
     ["2. System Design", "Creating UI screens in Figma, making ER and Class diagrams."],
     ["3. Implementation", "Writing Flutter code, setting up Firebase, building the Admin web panel."],
     ["4. Testing", "Unit testing, manual user testing with real volunteers."]])

h2("3.3 Project Timeline (Gantt Chart)")
body("To keep track of deadlines, I created a Gantt Chart. It visually shows when each phase started and when it was completed across the two semesters.")
img(os.path.join(diagram_dir, 'gantt_chart_1777123236084.png'), 'Project Gantt Chart')

h2("3.4 Process Model")
body("I chose the Agile Iterative software development model for this project. Unlike the traditional Waterfall model where you finish everything before testing, the Agile model allowed me to build the app piece by piece. After I built the donation module, I showed it to the NGO team. They gave their feedback, and I adjusted it before moving on to the volunteer module. This iterative loop made sure the final product was exactly what they wanted.")
img(os.path.join(diagram_dir, 'sdlc_model_1777123350385.png'), 'Agile Iterative Process Model')

h2("3.5 FYP Phase Structure")
body("The university divides the final year project into three major submissions. Here is how I aligned my work:")
table_caption("FYP Phase Submissions")
add_table(["Phase", "Deliverables"],
    [["FYP-01", "Proposal, Chapters 1-2, basic UI screens, and core Firebase login."],
     ["FYP-02", "Chapters 3-6, advanced features (Smart Matching, QR Attendance)."],
     ["FYP-03", "Chapters 7-8, final testing, bug fixing, and complete deployment."]])

h2("3.6 Summary")
body("This chapter laid out the entire roadmap for developing the system. By using an Agile model and a clear Work Breakdown Structure, I was able to manage my time effectively and ensure all requirements were met systematically.")
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
body("System specifications list down exactly what the software must do. These are derived from the problem statement discussed in Chapter 1. The specifications are divided into functional requirements (what the app does) and non-functional requirements (how well the app performs).")

h2("4.2 Functional Requirements")
body("Functional requirements define the core behavior of the system. I gathered these after interviewing the HRAS NGO management. Below is the list of 15 key functional requirements implemented in the system.")

table_caption("Functional Requirements (FR)")
add_table(["ID", "Requirement Description", "Priority"],
    [["FR-01", "The system shall allow users to register using email and password.", "High"],
     ["FR-02", "The system shall differentiate between 'Admin' and 'Volunteer' roles.", "High"],
     ["FR-03", "The Admin shall be able to create, update, and delete campaigns.", "High"],
     ["FR-04", "Volunteers shall be able to view a list of all active campaigns.", "High"],
     ["FR-05", "Volunteers shall be able to register/join a specific campaign.", "High"],
     ["FR-06", "The Admin shall be able to manually record donations received.", "High"],
     ["FR-07", "The system shall generate a PDF receipt for donations.", "Medium"],
     ["FR-08", "The Admin dashboard shall display total funds collected in real-time.", "High"],
     ["FR-09", "The system shall automatically recommend campaigns to volunteers based on their skills (Smart Matching).", "Medium"],
     ["FR-10", "The system shall generate a unique QR code for each campaign.", "Medium"],
     ["FR-11", "Volunteers shall be able to scan the QR code to mark their attendance.", "Medium"],
     ["FR-12", "The Admin shall be able to view a list of all registered volunteers.", "High"],
     ["FR-13", "The system shall send push notifications when a new campaign is created.", "Low"],
     ["FR-14", "Volunteers shall be able to update their profile and skills.", "Medium"],
     ["FR-15", "The Admin shall be able to download a summary report of campaigns.", "Low"]])

h2("4.3 Non-Functional Requirements")
body("Non-functional requirements dictate the performance, usability, and security of the system.")

table_caption("Non-Functional Requirements (NFR)")
add_table(["ID", "Requirement Description", "Category"],
    [["NFR-01", "The app screens should load within 3 seconds on a standard 4G connection.", "Performance"],
     ["NFR-02", "The system database must update in real-time without needing a manual refresh.", "Performance"],
     ["NFR-03", "The app must be usable on both Android and iOS devices.", "Portability"],
     ["NFR-04", "User passwords must be securely hashed and not stored in plain text.", "Security"],
     ["NFR-05", "Only users with the 'Admin' role can access the web dashboard.", "Security"],
     ["NFR-06", "The UI must be simple enough that a volunteer can join a campaign in under 3 clicks.", "Usability"]])

h2("4.4 Development Tools and Technologies")
table_caption("Tools Used")
add_table(["Tool / Language", "Purpose"],
    [["Flutter (Dart)", "To build the cross-platform mobile app and web frontend."],
     ["Firebase Firestore", "NoSQL cloud database to store all text data instantly."],
     ["Firebase Auth", "To securely handle user login and sign up."],
     ["Figma", "To design the user interface before writing any code."],
     ["VS Code", "The main code editor used to write the project."],
     ["GitHub", "For version control and keeping backups of the code."]])

h2("4.5 System Actors")
body("There are two main actors who will interact with this system:")
table_caption("Actors")
add_table(["Actor", "Description"],
    [["Admin", "The NGO management team. They use the web dashboard to manage campaigns and track donations."],
     ["Volunteer", "Normal users who download the mobile app to find charity events and participate."]])

h2("4.6 Use Case Diagrams and Scenarios")
body("Use cases explain how different actors interact with the system. Below is the main use case diagram showing both Admin and Volunteer interactions.")
img(os.path.join(diagram_dir, 'use_case_diagram_1777123080620.png'), 'Main Use Case Diagram')

table_caption("Use Case: Manage Campaign")
add_table(["Field", "Description"],
    [["Use Case Name", "Manage Campaign"],
     ["Primary Actor", "Admin"],
     ["Pre-condition", "Admin is logged into the system."],
     ["Main Flow", "1. Admin clicks 'Create Campaign'. 2. Fills details. 3. Saves. System updates database."],
     ["Post-condition", "Campaign is visible to all volunteers on their mobile apps."]])

table_caption("Use Case: Mark Attendance")
add_table(["Field", "Description"],
    [["Use Case Name", "Mark QR Attendance"],
     ["Primary Actor", "Volunteer"],
     ["Pre-condition", "Volunteer is at the campaign location with their smartphone."],
     ["Main Flow", "1. Volunteer opens app. 2. Taps 'Scan QR'. 3. Scans Admin's screen. 4. System records presence."],
     ["Post-condition", "Volunteer's status changes to 'Present' in the Admin dashboard."]])

h2("4.7 Requirements Traceability Matrix")
body("A traceability matrix ensures that every requirement we gathered is actually tested and built.")
table_caption("Traceability Matrix")
add_table(["Req ID", "Description", "Test Case ID", "Status"],
    [["FR-01", "User Login", "TC-01", "Tested & Passed"],
     ["FR-03", "Manage Campaigns", "TC-02", "Tested & Passed"],
     ["FR-06", "Record Donations", "TC-03", "Tested & Passed"],
     ["FR-10", "QR Attendance", "TC-04", "Tested & Passed"]])

h2("4.8 Summary")
body("This chapter detailed exactly what the NGO system must do. By clearly defining 15 functional requirements and assigning them priorities, I was able to write the code efficiently without guessing what features to build next.")
doc.add_page_break()

# =================== CHAPTER 5 ===================
for _ in range(6): doc.add_paragraph()
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run('Chapter 5'); r.bold = True; r.font.size = Pt(22)
p2 = doc.add_paragraph(); p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
r2 = p2.add_run('System Design'); r2.bold = True; r2.font.size = Pt(20)
doc.add_page_break()

h1("Chapter 5: System Design")

h2("5.1 Introduction")
body("System design is where the requirements from Chapter 4 are turned into technical blueprints. This chapter covers the architecture of the system, database design (ER diagrams), and how data flows through the application.")

h2("5.2 System Architecture")
body("The HRAS system uses a Client-Server architecture. The clients are the Flutter Mobile App and the Web Dashboard. They do not talk to each other directly. Instead, they both connect to the Firebase Cloud Server, which handles authentication and database storage.")
img(os.path.join(diagram_dir, 'system_architecture_1777123050441.png'), 'System Architecture Diagram')

h2("5.3 Database Design (ER Diagram)")
body("Since Firebase is a NoSQL database, it uses 'Collections' and 'Documents' instead of traditional SQL tables. However, an Entity-Relationship (ER) diagram is still useful to understand how the data connects. The main entities are Users, Campaigns, and Donations.")
img(os.path.join(diagram_dir, 'er_diagram_1777123063920.png'), 'Entity Relationship Diagram')

h2("5.4 Data Dictionary")
body("Below is the structure of the main database collections used in Firebase Firestore.")

table_caption("Data Dictionary: Users Collection")
add_table(["Field Name", "Data Type", "Description"],
    [["uid", "String", "Unique Firebase identifier"],
     ["name", "String", "Full name of the user"],
     ["role", "String", "'admin' or 'volunteer'"],
     ["skills", "Array", "List of skills the volunteer has"]])

table_caption("Data Dictionary: Campaigns Collection")
add_table(["Field Name", "Data Type", "Description"],
    [["campaignId", "String", "Unique auto-generated ID"],
     ["title", "String", "Name of the campaign"],
     ["date", "Timestamp", "When the campaign takes place"],
     ["status", "String", "'active', 'completed', or 'cancelled'"]])

h2("5.5 Data Flow Diagrams (DFD)")
body("Data Flow Diagrams show how information moves through the system from the user's screen into the database and back.")
img(os.path.join(diagram_dir, 'dfd_level0_1777123112830.png'), 'DFD Level 0 (Context Diagram)')
body("The Level 0 Context Diagram above shows the basic input/output between the Admin, the Volunteer, and the central system.")
img(os.path.join(diagram_dir, 'dfd_level1_1777123318617.png'), 'DFD Level 1')

h2("5.6 Sequence Diagrams")
body("Sequence diagrams show the step-by-step order of operations over time. For example, when a user logs in, the app first talks to Firebase Auth, waits for a token, and then requests user data from Firestore.")
img(os.path.join(diagram_dir, 'sequence_login_1777123126133.png'), 'Login Sequence Diagram')

h2("5.7 Class Diagram")
body("The Class Diagram represents the object-oriented structure of the Flutter application code. It shows the Models (like UserModel, CampaignModel) and the Services (like AuthService, DatabaseService) that manipulate them.")
img(os.path.join(diagram_dir, 'class_diagram_1777123296381.png'), 'Class Diagram')

h2("5.8 Component and Deployment Diagrams")
body("The Component diagram shows how the UI files, State Management files, and Firebase connection files interact inside the Flutter project.")
img(os.path.join(diagram_dir, 'component_diagram_1777123363771.png'), 'Component Diagram')
body("The Deployment diagram shows where the software is physically hosted. The mobile app lives on the user's phone, while Firebase is hosted on Google's cloud servers.")
img(os.path.join(diagram_dir, 'deployment_diagram_1777123140325.png'), 'Deployment Diagram')

h2("5.9 Role Based Access Control (RBAC)")
body("Security is very important. I designed a Role-Based Access Control system. If a normal Volunteer tries to open the Admin Dashboard link, the system reads their 'role' from the database and immediately blocks them, showing an 'Access Denied' screen.")
img(os.path.join(diagram_dir, 'rbac_security_1777123197305.png'), 'RBAC Security Flow')

h2("5.10 Summary")
body("This chapter presented the complete technical blueprint of the HRAS system. By creating clear ER diagrams, Sequence diagrams, and defining the database dictionary beforehand, the actual coding process became much faster and less prone to errors.")
doc.add_page_break()

# =================== CHAPTER 6 ===================
for _ in range(6): doc.add_paragraph()
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run('Chapter 6'); r.bold = True; r.font.size = Pt(22)
p2 = doc.add_paragraph(); p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
r2 = p2.add_run('Coding and Implementation'); r2.bold = True; r2.font.size = Pt(20)
doc.add_page_break()

h1("Chapter 6: Coding and Implementation")

h2("6.1 Implementation Environment")
body("The coding phase involved writing Dart code inside the Flutter framework. I used Visual Studio Code as my IDE. The codebase was separated into standard folders: 'screens' for UI, 'models' for data structures, and 'services' for database calls.")

h2("6.2 Smart Matching Algorithm (FYP-02 Feature)")
body("One of the major features implemented during the FYP-02 phase was the Smart Matching Algorithm. The problem was that volunteers often missed campaigns that matched their specific skills (like medical volunteers missing medical camps).")
body("I wrote a custom algorithm that runs when the user opens the Home Screen. It fetches the user's 'skills' list from their profile, and then compares it against the tags of all active campaigns. If a campaign requires a 'Medical' skill and the user has it, that campaign is given a higher score and moved to the very top of their list.")
body("This makes the app feel personalized and increases volunteer participation rates.")

h2("6.3 QR Code Attendance Logic")
body("Another major feature was the QR Attendance system. Taking attendance manually on paper takes too much time during a busy NGO event.")
body("Here is how I coded it:")
body("1. The Admin opens a specific campaign on the dashboard and presses 'Generate QR'.")
body("2. The system generates a QR code image that contains the unique 'campaignId'.")
body("3. The volunteer uses the camera scanner inside their mobile app to scan this screen.")
body("4. The app extracts the ID and sends a quick update to Firebase, changing the volunteer's status from 'Registered' to 'Present'.")

h2("6.4 PDF Generation")
body("For donation transparency, I implemented a package called 'pdf' in Flutter. When an admin enters a donation amount, they can click a button to generate a receipt. The code draws text onto a digital canvas, formats it nicely with the NGO logo, and saves it as a PDF file to the phone's storage, which can then be shared directly on WhatsApp.")

h2("6.5 Summary")
body("This chapter covered the key programming logic behind the system's most important features. By keeping the code clean and separating UI from database logic, the app runs smoothly without lagging.")
doc.add_page_break()

out = os.path.join(os.path.dirname(__file__), 'Thesis-FYP02', 'FYP_02_Thesis.docx')
os.makedirs(os.path.dirname(out), exist_ok=True)
doc.save(out)
inject_update_fields(out)
print(f"FYP-02 Thesis saved: {out}")
