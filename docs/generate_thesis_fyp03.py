"""Generate FYP-03 Thesis DOCX (Chapters 7–8) — Air University Multan Campus."""
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

# =================== TITLE PAGE ===================
for _ in range(4): doc.add_paragraph()
h1(UNIVERSITY); h1(DEPARTMENT); doc.add_paragraph()
h1("NGO Operation and Volunteer Management System")
h1("(HRAS)")
doc.add_paragraph()
h1("FYP-03 Report: Chapters 7–8")
body(f"Submitted by: {STUDENT} ({REG})").alignment = WD_ALIGN_PARAGRAPH.CENTER
body(f"Supervised by: {SUPERVISOR}").alignment = WD_ALIGN_PARAGRAPH.CENTER
doc.add_page_break()

# =================== CHAPTER 7 ===================
for _ in range(6): doc.add_paragraph()
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run('Chapter 7'); r.bold = True; r.font.size = Pt(22)
p2 = doc.add_paragraph(); p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
r2 = p2.add_run('Software Testing'); r2.bold = True; r2.font.size = Pt(20)
doc.add_page_break()

h1("Chapter 7: Software Testing")
body("Testing is a very important part of software development. If the app crashes when a volunteer is trying to register, they might not come back. To prevent this, I performed extensive testing on the HRAS system.")

h2("7.1 Testing Strategy")
body("I used two main types of testing:")
body("1. Unit Testing: Writing automated scripts to test small parts of the code (like checking if an email is valid).")
body("2. Black Box Testing: Manually clicking through the app to make sure the features work exactly as required.")

h2("7.2 Unit Test Results")
body("I wrote a total of 62 unit tests in Flutter.")
table_caption("Unit Test Summary")
add_table(["Test Category", "Total Tests", "Status"],
    [["Form Validators", "26", "Passed"],
     ["Data Models", "15", "Passed"],
     ["Logic & Enums", "21", "Passed"],
     ["Overall", "62", "100% Pass"]])

h2("7.3 Black Box Test Cases")
body("Here are the manual test cases I performed to verify the functional requirements.")

table_caption("Login Functionality Test")
add_table(["Action Taken", "Expected Result", "Actual Result", "Status"],
    [["Enter correct email and password", "App goes to Dashboard", "Went to Dashboard", "Pass"],
     ["Leave email empty", "Show error message", "Showed error", "Pass"],
     ["Enter wrong password", "Show 'Invalid credentials'", "Showed error", "Pass"]])
doc.add_paragraph()

table_caption("Campaign Management Test")
add_table(["Action Taken", "Expected Result", "Actual Result", "Status"],
    [["Click Create Campaign, fill details", "Campaign appears in list", "Campaign created", "Pass"],
     ["Edit campaign title", "Title changes immediately", "Title changed", "Pass"],
     ["Delete a campaign", "Campaign is removed completely", "Removed", "Pass"]])
doc.add_paragraph()

table_caption("Smart Matching Test (FYP-02 Feature)")
add_table(["Action Taken", "Expected Result", "Actual Result", "Status"],
    [["User with 'Medical' skill checks app", "Medical campaigns show at the top", "Ranked at top", "Pass"],
     ["User from 'Lahore' checks app", "Lahore campaigns get extra score", "Scored higher", "Pass"]])
doc.add_page_break()

# =================== CHAPTER 8 ===================
for _ in range(6): doc.add_paragraph()
p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p.add_run('Chapter 8'); r.bold = True; r.font.size = Pt(22)
p2 = doc.add_paragraph(); p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
r2 = p2.add_run('Conclusion'); r2.bold = True; r2.font.size = Pt(20)
doc.add_page_break()

h1("Chapter 8: Conclusion")

h2("8.1 Project Achievements")
body("Over the past three semesters, I have successfully developed the NGO Operation and Volunteer Management System. By looking at the requirements we gathered from HRAS, we achieved the following goals:")
for a in [
    "A working mobile app for Android and iOS, built with a single Flutter codebase.",
    "A clean web dashboard for the admin to see everything.",
    "A database that updates instantly using Firebase.",
    "A smart algorithm that automatically suggests campaigns to volunteers.",
    "A QR-code attendance system that saves time during actual events."
]:
    body(f"• {a}")

h2("8.2 Limitations")
body("While the system works well, there are a few limitations right now:")
body("• The app requires an active internet connection to work. There is no offline mode yet.")
body("• We have not integrated JazzCash or Easypaisa directly inside the app due to API cost issues.")
body("• Location matching is currently based on city names, not exact GPS coordinates.")

h2("8.3 Future Work")
body("If I continue working on this project after graduation, I would like to add:")
body("• Direct payment gateways so donors can transfer money inside the app.")
body("• Urdu language support, because many volunteers in Pakistan prefer reading Urdu.")
body("• GPS integration so volunteers get push notifications when they are physically near a campaign.")

h2("8.4 Final Conclusion")
body("In conclusion, the HRAS system proves that even small, local NGOs in Pakistan can benefit greatly from digital transformation. Instead of spending hours managing WhatsApp messages and paper notebooks, the NGO team can now use this system to organize everything efficiently. This allows them to focus on what really matters: helping the community.")
doc.add_page_break()

# =================== USER GUIDE & GLOSSARY ===================
h1("User Guide")
h2("For Volunteers")
body("1. Download and open the app.")
body("2. Tap 'Sign Up', enter your details, and verify your email.")
body("3. Login and go to the Home screen to see recommended campaigns.")
body("4. Tap on any campaign to see details, then press 'Join Campaign'.")
body("5. On the day of the campaign, open the app and tap 'Scan QR' to mark your attendance.")

h2("For Admins")
body("1. Login using your admin email.")
body("2. Use the bottom navigation bar to switch between Campaigns, Donations, and Users.")
body("3. To create a new campaign, go to the Campaigns tab and press the floating '+' button.")
body("4. To generate an attendance QR code, open a specific campaign and tap 'Generate QR'.")
doc.add_page_break()

h1("Glossary")
for term, defn in [
    ("Firebase", "A Google service used to store database records securely in the cloud."),
    ("Flutter", "A framework by Google used to build mobile and web apps from one codebase."),
    ("CRUD", "Create, Read, Update, Delete — the four basic functions of database storage."),
    ("UAT", "User Acceptance Testing — testing the app with real people."),
]:
    body(f"{term}: {defn}")

out = os.path.join(os.path.dirname(__file__), 'Thesis-FYP03', 'FYP_03_Thesis.docx')
os.makedirs(os.path.dirname(out), exist_ok=True)
doc.save(out)
inject_update_fields(out)
print(f"FYP-03 Thesis saved: {out}")
