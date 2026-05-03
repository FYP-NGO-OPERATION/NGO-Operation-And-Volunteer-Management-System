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
SEMESTER = "7th"
UNIVERSITY = "Air University Multan Campus"
DEPARTMENT = "Department of Computer Science"
SUPERVISOR = "Miss Fatima Yousuf"

doc = Document()

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

for s in doc.sections:
    s.top_margin = Inches(1.1); s.left_margin = Inches(1.3)
    s.right_margin = Inches(0.8); s.bottom_margin = Inches(0.8)
    s.footer_distance = Inches(0.2)
    p = s.footer.paragraphs[0] if s.footer.paragraphs else s.footer.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER; add_page_number(p.add_run())

style = doc.styles['Normal']
style.font.name = 'Times New Roman'; style.font.size = Pt(12)
style.paragraph_format.line_spacing = 1.5

for level, sz in [('Heading 1', 16), ('Heading 2', 14), ('Heading 3', 13)]:
    hs = doc.styles[level]; hs.font.name = 'Times New Roman'; hs.font.size = Pt(sz)
    hs.font.bold = True; hs.font.color.rgb = None; hs.paragraph_format.line_spacing = 1.5

def h1(t): p = doc.add_heading(t, level=1); p.alignment = WD_ALIGN_PARAGRAPH.CENTER; return p
def h2(t): return doc.add_heading(t, level=2)
def h3(t): return doc.add_heading(t, level=3)
def body(t): p = doc.add_paragraph(t); p.style = doc.styles['Normal']; return p

def table_caption(t):
    p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    add_seq_field(p, "Table", "Table ", f": {t}")
    return p

def figure_caption(t):
    p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_seq_field(p, "Figure", "Figure ", f": {t}")
    return p

def add_table(headers, rows):
    t = doc.add_table(rows=len(rows)+1, cols=len(headers)); t.style = 'Table Grid'
    for i, h in enumerate(headers):
        c = t.rows[0].cells[i]; c.text = h
        for r in c.paragraphs[0].runs: r.bold = True
    for ri, row in enumerate(rows):
        for ci, val in enumerate(row): t.rows[ri+1].cells[ci].text = str(val)
    return t

def img(path, cap, width=Inches(5.2)):
    if os.path.exists(path):
        doc.add_picture(path, width=width)
        doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
        figure_caption(cap); return True
    else:
        body(f"[DIAGRAM PLACEHOLDER: {cap}]"); return False

diagram_dir = os.path.join(os.path.dirname(__file__), 'diagrams')

# =================== TITLE PAGE ===================
for _ in range(4): doc.add_paragraph()
h1(UNIVERSITY); h1(DEPARTMENT); doc.add_paragraph()
h1("NGO Operation and Volunteer Management System")
h1("(HRAS)")
doc.add_paragraph()
h1("FYP-02 Report: Chapters 3–6")
doc.add_paragraph()
body(f"Submitted by: {STUDENT}").alignment = WD_ALIGN_PARAGRAPH.CENTER
body(f"Registration No: {REG}").alignment = WD_ALIGN_PARAGRAPH.CENTER
body(f"Session: {SESSION} | Semester: {SEMESTER}").alignment = WD_ALIGN_PARAGRAPH.CENTER
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
body("In this chapter, I will explain how I planned the project and the method I used to develop it over the three semesters.")

h2("3.1 Project Deliverables")
body("Here is the list of the main things I have to deliver for this project:")
for d in ["Project Plan and SRS", "System Design Documents", "A working Mobile App", "A working Web Dashboard", "Final Thesis Document"]:
    body(f"• {d}")

h2("3.2 Work Breakdown Structure")
body("I divided the whole project into smaller, manageable tasks. This is called a Work Breakdown Structure (WBS).")
table_caption("Work Breakdown Structure")
add_table(["Task", "Phase", "Time"],
    [["Requirements Gathering", "FYP-01", "4 weeks"],
     ["Basic App & Database", "FYP-01", "8 weeks"],
     ["Advanced Features (Matching, QR)", "FYP-02", "6 weeks"],
     ["Testing & Thesis", "FYP-03", "4 weeks"]])
doc.add_paragraph()
img(os.path.join(diagram_dir, 'wbs_chart_1777123248717.png'), 'Work Breakdown Structure Chart')

h2("3.3 Project Timeline")
body("I also created a Gantt chart to show the timeline of the project.")
img(os.path.join(diagram_dir, 'gantt_chart_1777123236084.png'), 'Gantt Chart')

h2("3.4 Methodology Used")
body("I chose the Agile Iterative model. This is because in software development, especially for NGOs, requirements can change. By using Agile, I could build the basic app first in FYP-01, show it to my supervisor, and then add the advanced features in FYP-02.")
img(os.path.join(diagram_dir, 'sdlc_model_1777123350385.png'), 'Agile Iterative SDLC Model')
doc.add_page_break()

# =================== CHAPTER 4 ===================
for _ in range(6): doc.add_paragraph()
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run('Chapter 4'); r.bold = True; r.font.size = Pt(22)
p2 = doc.add_paragraph(); p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
r2 = p2.add_run('System Specification'); r2.bold = True; r2.font.size = Pt(20)
doc.add_page_break()

h1("Chapter 4: System Specification")
body("This chapter lists all the requirements that the system must fulfill. These requirements were gathered by talking to the HRAS NGO members.")

h2("4.1 Functional Requirements")
body("These are the main features the system must have to work properly.")
table_caption("Functional Requirements")
add_table(["ID", "Requirement", "Phase"],
    [["FR01", "Admin login and Volunteer Registration", "FYP-01"],
     ["FR02", "Admin can create, edit, and delete campaigns", "FYP-01"],
     ["FR03", "System records donations and generates PDF receipts", "FYP-01"],
     ["FR04", "Volunteers can join campaigns", "FYP-01"],
     ["FR05", "Smart algorithm matches volunteers to campaigns based on skills", "FYP-02"],
     ["FR06", "Admin can generate QR codes for campaigns", "FYP-02"],
     ["FR07", "Volunteers scan QR to mark their attendance", "FYP-02"]])

h2("4.2 Non-Functional Requirements")
body("These requirements define how well the system should perform.")
table_caption("Non-Functional Requirements")
add_table(["ID", "Requirement", "Details"],
    [["NFR01", "Speed", "The app should load data quickly from Firebase."],
     ["NFR02", "Security", "Passwords should be hidden and database secured."],
     ["NFR03", "Ease of Use", "The UI should be very simple for normal people to use."]])

h2("4.3 Tools Used")
table_caption("Development Tools and Technologies")
add_table(["Tool", "Purpose"],
    [["Flutter", "To build the mobile app and web dashboard"],
     ["Dart", "The programming language used"],
     ["Firebase", "For database (Firestore) and authentication"],
     ["VS Code", "The IDE used for writing code"]])

h2("4.4 Actors")
table_caption("System Actors")
add_table(["Actor", "Role"],
    [["Admin", "Controls everything. Creates campaigns and records donations."],
     ["Volunteer", "Normal user who joins campaigns and scans QR for attendance."]])

h2("4.5 Use Cases")
body("The use case diagram shows what each actor can do in the system.")
img(os.path.join(diagram_dir, 'use_case_final.png'), 'Use Case Diagram')

table_caption("Campaign Management Use Case")
add_table(["Field", "Detail"],
    [["Actor", "Admin"],
     ["Action", "Admin clicks create campaign, fills details, and saves it to the database."]])

h2("4.6 Traceability Matrix")
body("This matrix ensures that every requirement is tested later.")
table_caption("Requirements Traceability Matrix")
add_table(["Req ID", "Use Case", "Test Case"],
    [["FR01", "UC01", "TC01"],
     ["FR02", "UC02", "TC02"],
     ["FR05", "UC03", "TC03"]])
doc.add_page_break()

# =================== CHAPTER 5 ===================
for _ in range(6): doc.add_paragraph()
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run('Chapter 5'); r.bold = True; r.font.size = Pt(22)
p2 = doc.add_paragraph(); p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
r2 = p2.add_run('System Design'); r2.bold = True; r2.font.size = Pt(20)
doc.add_page_break()

h1("Chapter 5: System Design")
body("This chapter contains all the diagrams that show the internal architecture and database design of the HRAS system.")

h2("5.1 Architecture")
body("The system uses Flutter for the frontend and Firebase for the backend.")
img(os.path.join(diagram_dir, 'unified_system_architecture.png'), 'System Architecture Diagram')

h2("5.2 Database Design (ER Diagram)")
body("Because Firebase is a NoSQL database, we use collections instead of tables. Here is the Entity Relationship diagram.")
img(os.path.join(diagram_dir, 'er_final.png'), 'Entity Relationship Diagram')

h2("5.3 Data Flow Diagrams")
body("These diagrams show how data moves in the system.")
img(os.path.join(diagram_dir, 'dfd_level0_1777123112830.png'), 'DFD Level 0')
img(os.path.join(diagram_dir, 'dfd_level1_1777123318617.png'), 'DFD Level 1')
img(os.path.join(diagram_dir, 'dfd_level2_flow.png'), 'DFD Level 2')

h2("5.4 Sequence Diagrams")
img(os.path.join(diagram_dir, 'sequence_donation.png'), 'Donation Sequence Diagram')
img(os.path.join(diagram_dir, 'sequence_volunteer.png'), 'Volunteer Sequence Diagram')

h2("5.5 Other UML Diagrams")
img(os.path.join(diagram_dir, 'class_entities.png'), 'Class Diagram')
img(os.path.join(diagram_dir, 'component_diagram_1777123363771.png'), 'Component Diagram')
img(os.path.join(diagram_dir, 'deployment_architecture.png'), 'Deployment Diagram')

h2("5.6 Data Dictionary")
body("These tables describe the structure of the data saved in Firebase.")
table_caption("Users Collection Dictionary")
add_table(["Field Name", "Data Type", "Description"],
    [["uid", "String", "Unique ID from Firebase Auth"],
     ["name", "String", "User's full name"],
     ["role", "String", "Either admin or volunteer"],
     ["skills", "Array", "List of skills for matching algorithm"]])

table_caption("Campaigns Collection Dictionary")
add_table(["Field Name", "Data Type", "Description"],
    [["title", "String", "Name of the campaign"],
     ["type", "String", "Medical, Ration, Education, etc."],
     ["status", "String", "Upcoming, Active, or Completed"]])

h2("5.7 Algorithm Logic (FYP-02)")
body("For the FYP-02 phase, I designed a smart matching algorithm. Instead of using a complex black-box AI, I created a rule-based formula that is easy to explain and works very well.")
body("The algorithm gives a score out of 100% based on three things:")
for rule in [
    "Skills (50%): If a user's skill matches the campaign type, they get a high score.",
    "Location (30%): If the user lives in the same city as the campaign, they get extra points.",
    "Availability (20%): If they haven't registered yet, they get full points here."
]:
    body(f"• {rule}")
doc.add_page_break()

# =================== CHAPTER 6 ===================
for _ in range(6): doc.add_paragraph()
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run('Chapter 6'); r.bold = True; r.font.size = Pt(22)
p2 = doc.add_paragraph(); p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
r2 = p2.add_run('Coding'); r2.bold = True; r2.font.size = Pt(20)
doc.add_page_break()

h1("Chapter 6: Coding")
body("This chapter highlights some of the important code written for this project. The entire code is written in Dart using the Flutter framework.")

h2("6.1 Smart Matching Code")
body("Here is the logic I wrote to calculate the matching score between a volunteer and a campaign.")
code1 = '''static List<MatchResult> getRecommendations(UserModel user, List<CampaignModel> campaigns) {
  List<MatchResult> results = [];
  for (var campaign in campaigns) {
    double skillScore = calculateSkillMatch(user.skills, campaign.type);
    double locationScore = calculateLocationMatch(user.address, campaign.location);
    
    // Formula
    double total = (skillScore * 0.5) + (locationScore * 0.3) + (0.2);
    results.add(MatchResult(campaign: campaign, score: total));
  }
  // Sort from highest to lowest
  results.sort((a, b) => b.score.compareTo(a.score));
  return results;
}'''
body(code1)

h2("6.2 QR Attendance Code")
body("To mark attendance, the admin generates a QR code, and the volunteer scans it. Here is the code that runs when the QR is scanned.")
code2 = '''Future<void> scanQRAndMarkAttendance(String qrData, String userId) async {
  var data = jsonDecode(qrData);
  String campaignId = data['campaignId'];
  
  // Update Firestore database
  await FirebaseFirestore.instance
      .collection('volunteers')
      .where('campaignId', isEqualTo: campaignId)
      .where('userId', isEqualTo: userId)
      .get()
      .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.first.reference.update({'status': 'attended'});
        }
      });
}'''
body(code2)

h2("6.3 Summary")
body("The code for this project is modular. I have separated UI screens from business logic services. This makes the code very easy to manage and update.")

# Save
out = os.path.join(os.path.dirname(__file__), 'Thesis-FYP02', 'FYP_02_Thesis.docx')
os.makedirs(os.path.dirname(out), exist_ok=True)
doc.save(out)
inject_update_fields(out)
print(f"FYP-02 Thesis saved: {out}")
