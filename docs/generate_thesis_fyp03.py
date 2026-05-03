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

# =================== TITLE PAGE ===================
for _ in range(4): doc.add_paragraph()
h1(UNIVERSITY)
h1(DEPARTMENT)
doc.add_paragraph()
h1("NGO Operation and Volunteer Management System")
h1("(HRAS)")
doc.add_paragraph()
h1("FYP-03 Report: Chapters 7–8")
doc.add_paragraph()
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

h2("7.1 Introduction to Testing")
body("Testing is a very critical part of software development. If the app crashes when a volunteer is trying to register, or if a donation record gets deleted by mistake, the NGO could lose trust. To prevent this, I performed extensive testing on the HRAS system before declaring it complete.")

h2("7.2 Testing Strategy")
body("I used three main types of testing for this project:")
body("1. Unit Testing: Writing automated scripts to test small parts of the code. For example, testing if the email field correctly blocks emails that do not have an '@' sign.")
body("2. Integration Testing: Checking if different parts of the app work together. For example, when an Admin creates a campaign, does it show up immediately on the Volunteer's phone?")
body("3. Black Box Testing (UAT): Manually clicking through the app like a normal user to make sure all buttons and features do exactly what they are supposed to do.")

h2("7.3 Unit Test Results")
body("I wrote a total of 62 automated unit tests using the Flutter Testing framework.")
table_caption("Unit Test Summary")
add_table(["Test Category", "Total Tests", "Passed", "Failed", "Status"],
    [["Form Validators", "26", "26", "0", "Pass"],
     ["Data Models (JSON Parsing)", "15", "15", "0", "Pass"],
     ["Role & Permission Logic", "21", "21", "0", "Pass"],
     ["Overall", "62", "62", "0", "100% Pass"]])

h2("7.4 Black Box Test Cases")
body("Here are the detailed manual test cases I performed to verify the core functional requirements of the system.")

table_caption("Test Case: User Authentication")
add_table(["Test ID", "Action Taken", "Expected Result", "Actual Result", "Status"],
    [["TC-01", "Enter correct email and password", "App routes to Dashboard", "Routed to Dashboard", "Pass"],
     ["TC-02", "Leave email empty and press Login", "Show 'Email required' error", "Showed error", "Pass"],
     ["TC-03", "Enter wrong password", "Show 'Invalid credentials' error", "Showed error", "Pass"],
     ["TC-04", "Volunteer tries to open Admin web link", "Show 'Access Denied' screen", "Blocked successfully", "Pass"]])
doc.add_paragraph()

table_caption("Test Case: Campaign Management")
add_table(["Test ID", "Action Taken", "Expected Result", "Actual Result", "Status"],
    [["TC-05", "Admin creates campaign with missing title", "Save button disabled / Error shown", "Error shown", "Pass"],
     ["TC-06", "Admin creates valid campaign", "Campaign appears in list instantly", "Appeared instantly", "Pass"],
     ["TC-07", "Admin edits campaign title", "Title changes across all devices", "Title changed", "Pass"],
     ["TC-08", "Admin deletes a campaign", "Campaign is removed from database", "Removed", "Pass"]])
doc.add_paragraph()

table_caption("Test Case: Volunteer Registration")
add_table(["Test ID", "Action Taken", "Expected Result", "Actual Result", "Status"],
    [["TC-09", "Volunteer taps 'Join' on a campaign", "Status changes to 'Registered'", "Status updated", "Pass"],
     ["TC-10", "Volunteer tries to join completed campaign", "Join button should be hidden", "Button hidden", "Pass"]])
doc.add_paragraph()

table_caption("Test Case: Smart Matching & QR (FYP-02 Features)")
add_table(["Test ID", "Action Taken", "Expected Result", "Actual Result", "Status"],
    [["TC-11", "User with 'Medical' skill opens app", "Medical campaigns rank at the top", "Ranked correctly", "Pass"],
     ["TC-12", "Admin taps 'Generate QR' on campaign", "QR image is displayed on screen", "QR displayed", "Pass"],
     ["TC-13", "Volunteer scans QR code", "Attendance marked 'Present'", "Attendance marked", "Pass"]])

h2("7.5 User Acceptance Testing (UAT)")
body("After testing the app myself, I gave the mobile app to three volunteers from the HRAS NGO to try out. I asked them to sign up, find a campaign, and join it without my help.")
body("Feedback: All three volunteers were able to join a campaign in less than 1 minute. They mentioned that the app was much easier to use than waiting for WhatsApp messages. They also appreciated the simple UI colors.")
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
body("Over the past three semesters, I have successfully designed, developed, and tested the complete NGO Operation and Volunteer Management System. By closely following the requirements gathered from the HRAS team, we achieved the following major goals:")
for a in [
    "Built a fully functioning cross-platform mobile app for Android and iOS using a single Flutter codebase.",
    "Created a responsive web dashboard for the Admin team to monitor all operations.",
    "Integrated Firebase Firestore for real-time data synchronization, completely removing the need for manual page refreshes.",
    "Implemented a secure Role-Based Access Control (RBAC) system so sensitive NGO data stays safe.",
    "Developed a Smart Matching algorithm that personalizes the campaign feed for every volunteer.",
    "Built a QR-code attendance system that saves the Admin team hours of paperwork during real-world charity events.",
    "Added a PDF receipt generator to improve trust and transparency with donors."
]:
    body(f"• {a}")

h2("8.2 System Limitations")
body("While the system meets all its initial functional requirements and works well, there are a few practical limitations that exist in this version:")
body("• The app relies entirely on the Firebase Cloud. It requires an active internet connection to work. There is no true offline mode, so using the app in remote village areas might be difficult.")
body("• We have not integrated direct payment gateways like JazzCash, Easypaisa, or Stripe inside the app due to business registration requirements and API costs. Currently, donations must be manually verified and entered by the Admin.")
body("• The location matching feature is currently based on text input (city names) rather than real GPS coordinates.")
body("• The system is heavily customized for HRAS. If another NGO wants to use it, they cannot just create an account; the source code would need to be modified and deployed separately.")

h2("8.3 Future Work")
body("If development continues on this project after graduation, I would highly recommend adding the following features to make it even better:")
body("• Direct Online Payments: Integrating a local payment gateway so donors can transfer money instantly within the app.")
body("• Multi-Language Support (Urdu): Since many volunteers and donors in Pakistan prefer reading in Urdu, adding a language toggle would increase user adoption.")
body("• GPS Integration: Adding Google Maps so volunteers can get turn-by-turn directions to the campaign location, and get push notifications when they are physically nearby.")
body("• Advanced Analytics: Adding beautiful charts and graphs to the Admin dashboard to show yearly donation trends and volunteer performance.")

h2("8.4 Final Conclusion")
body("In conclusion, the HRAS system proves that even small, grassroots NGOs in Pakistan can benefit massively from digital transformation. Instead of spending hours managing messy WhatsApp groups and paper notebooks, the NGO team can now use this automated, transparent system to organize everything perfectly.")
body("This project demonstrates the power of modern frameworks like Flutter and Firebase. It allowed a single developer to build a mobile app, a web app, and a real-time backend all at once. Ultimately, this software reduces the administrative burden on the NGO, allowing them to focus their energy and time on what really matters: helping the community and serving humanity.")
doc.add_page_break()

# =================== USER GUIDE & GLOSSARY ===================
h1("User Guide")
h2("For Volunteers")
body("1. Download the app and open it.")
body("2. Tap 'Sign Up', fill in your name, email, and password.")
body("3. Login and go to your Profile to add your 'Skills'.")
body("4. Go to the Home screen. You will see campaigns that match your skills at the top.")
body("5. Tap on any campaign to read the details, then press 'Join Campaign'.")
body("6. On the day of the campaign, arrive at the location, open the app, and tap 'Scan QR' to mark your attendance.")

h2("For Admins")
body("1. Open the Web Dashboard link on your computer and login with the admin credentials.")
body("2. Use the side menu to switch between Campaigns, Donations, and Users.")
body("3. To create a new campaign, go to the Campaigns tab and press the 'Add New' button.")
body("4. To generate an attendance QR code, click on a specific campaign in the list and tap 'Generate QR'. Show this screen to the volunteers.")
body("5. To record a donation, go to the Donations tab, enter the amount and donor name, and click save. The system will automatically update the total funds counter.")
doc.add_page_break()

h1("Glossary")
for term, defn in [
    ("Firebase", "A Google service used to store database records securely in the cloud."),
    ("Flutter", "A programming framework by Google used to build mobile and web apps from one single codebase."),
    ("Firestore", "The specific NoSQL real-time database service provided by Firebase."),
    ("CRUD", "Create, Read, Update, Delete — the four basic actions you can perform on database records."),
    ("UAT", "User Acceptance Testing — the process of testing the app with real people before final release."),
    ("RBAC", "Role-Based Access Control — a security system that checks if a user is an 'Admin' or 'Volunteer' before showing them specific screens."),
]:
    body(f"{term}: {defn}")

out = os.path.join(os.path.dirname(__file__), 'Thesis-FYP03', 'FYP_03_Thesis.docx')
os.makedirs(os.path.dirname(out), exist_ok=True)
doc.save(out)
inject_update_fields(out)
print(f"FYP-03 Thesis saved: {out}")
