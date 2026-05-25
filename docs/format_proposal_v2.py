import docx
from docx.shared import Pt, Inches
import os

doc_path = r"E:\Fyp\FYP-I Project Proposal Sample.docx"
out_path = r"E:\Fyp\FYP_Proposal_Final_Formatted_V2.docx"
diagrams_dir = r"E:\Fyp\ngo_volunteer_app\docs\diagrams"

doc = docx.Document(doc_path)

# 1. Fill Existing Tables (Part A, B, C, D)
t0 = doc.tables[0]
t0.cell(1, 1).text = "Muhammad Maauz Mansoor"
t0.cell(1, 5).text = "233599"
t0.cell(2, 1).text = "233599@students.au.edu.pk"
t0.cell(2, 3).text = "2.92"
t0.cell(2, 5).text = "0312-6356467"

# Fill Table 1 with N/A for solo project to avoid empty boxes
t1 = doc.tables[1]
t1.cell(0, 1).text = "N/A (Solo Project)"
t1.cell(0, 5).text = "N/A"
t1.cell(1, 1).text = "N/A"
t1.cell(1, 3).text = "N/A"
t1.cell(1, 5).text = "N/A"

t2 = doc.tables[2]
t2.cell(0, 1).text = "Solo Project – Muhammad Maauz Mansoor"
t3 = doc.tables[3]
t3.cell(1, 1).text = "NGO Operations & Volunteer Mgt"
t3.cell(2, 1).text = "AI-Integrated Operations and Volunteer Coordination Platform for Charitable NGOs"
t3.cell(3, 1).text = "Software Engineering"
t3.cell(3, 4).text = "NGO Admins, Volunteers"
t3.cell(4, 2).text = "☑ Development"
t3.cell(4, 4).text = "☑ OO Based"
t3.cell(5, 2).text = "☑ Web App"
t3.cell(5, 3).text = "☑ Mobile App"
t4 = doc.tables[4]
t4.cell(2, 1).text = "Miss Fatima Yousuf"

# 2. Delete EVERYTHING after "Table of Contents" to give us a clean slate
start_deleting = False
for p in list(doc.paragraphs):
    if p.text.strip() == "Project Title":
        start_deleting = True
    if start_deleting:
        p._element.getparent().remove(p._element)

# 3. Helper functions to append content
def h1(text):
    p = doc.add_heading(text, level=1)
    # the template might use specific styles, but doc.add_heading uses the template's native Heading 1
    return p

def h2(text):
    return doc.add_heading(text, level=2)

def para(text):
    p = doc.add_paragraph(text)
    p.style = doc.styles['Normal']
    # ensure font is times new roman 12
    for r in p.runs:
        r.font.name = 'Times New Roman'
        r.font.size = Pt(12)
    return p

def img(filename, caption):
    path = os.path.join(diagrams_dir, filename)
    if os.path.exists(path):
        doc.add_picture(path, width=Inches(5.5))
        doc.paragraphs[-1].alignment = docx.enum.text.WD_ALIGN_PARAGRAPH.CENTER
        p = doc.add_paragraph(caption)
        p.alignment = docx.enum.text.WD_ALIGN_PARAGRAPH.CENTER
        p.style = doc.styles['Normal']

def add_custom_table(data, title=""):
    if title:
        p = doc.add_paragraph(title)
        p.style = doc.styles['Normal']
        p.runs[0].bold = True
    table = doc.add_table(rows=len(data), cols=len(data[0]))
    table.style = doc.tables[0].style
    for r_idx, row in enumerate(data):
        for c_idx, cell_val in enumerate(row):
            table.cell(r_idx, c_idx).text = str(cell_val)
    # add empty paragraph after table
    doc.add_paragraph()

# 4. Rebuild the document exactly as original
h1("Project Title")
para("AI-Integrated Operations and Volunteer Coordination Platform for Charitable NGOs")

h1("Project Overview")
para("When looking at the landscape of social welfare in Pakistan, we see that Non-Governmental Organizations (NGOs) are doing tremendous work. Large organizations like Alkhidmat, Edhi, and JDC have naturally adopted digital solutions to manage their massive scale. However, I noticed a huge gap when observing smaller, community-level organizations, specifically 'Hamesha Rahein Apke Saath', the welfare society I am partnering with for this project. They are entirely reliant on scattered WhatsApp groups and handwritten registers for everything from volunteer coordination to managing donations.")
para("This manual approach causes real operational headaches. Communication gets buried in WhatsApp chats, making campaign tracking nearly impossible. Financial transparency takes a hit because there isn't a unified way to log cash versus online donations, let alone track itemized expenses. Furthermore, keeping track of which volunteer attended which campaign is completely disorganized.")
para("To solve this, I am developing a comprehensive, AI-integrated platform. It will be built with Flutter so that admins and volunteers can access it on any device (Web, Android, iOS) without needing separate codebases. It will act as a centralized hub to handle campaigns, track volunteers, log donations and expenses accurately, and, most innovatively, use AI to analyze campaign performance and generate automated reports. This shifts the organization from surviving on messy paperwork to operating with data-driven clarity.")

add_custom_table([
    ['Feature', 'Alkhidmat App', 'Edhi Foundation', 'JDC Welfare App', 'Proposed System'],
    ['Campaign Mgmt', 'No', 'No', 'No', 'Yes (Full Lifecycle)'],
    ['Volunteer Tracking', 'No', 'No', 'No', 'Yes (Attendance)'],
    ['Donation Tracking', 'Online Only', 'Manual', 'Online Only', 'Yes (Cash + Online)'],
    ['Expense Tracking', 'No', 'No', 'No', 'Yes (Itemized)'],
    ['AI Analytics', 'No', 'No', 'No', 'Yes (Smart Insights)']
], "Table 1: Comparative Analysis of Existing NGO Applications vs. Proposed System")

h1("Project Goals and Objectives")
para("The overarching vision for this project is to fundamentally modernize how small-to-medium charitable organizations operate. Specifically, the goals are to:")
para("• Create a unified digital ecosystem that seamlessly handles the entire lifecycle of an NGO's operations.")
para("• Establish complete operational transparency by centralizing real-time tracking for all incoming donations, outgoing expenses, and volunteer activities.")
para("• Introduce accessible AI capabilities that provide administrators with actionable insights and automated reporting.")
para("• Deliver a genuinely cross-platform experience (Web and Mobile) from a single codebase.")

h1("High-Level System Components")
para("To make this platform functional, it is broken down into several core components. These modules represent the backbone of the system;")
add_custom_table([
    ['#', 'Module Name', 'Description'],
    ['1', 'User Management', 'Manages secure registration, login, and profiles. Enforces role-based permissions.'],
    ['2', 'Campaign Management', 'The central hub for creating campaigns, categorizing them, and tracking their status.'],
    ['3', 'Volunteer Coordination', 'Allows volunteers to join active campaigns. Provides admins the tools to mark attendance.'],
    ['4', 'Donation Tracking', 'A comprehensive ledger for recording all donations, categorizing them by payment method.'],
    ['5', 'Expense Tracking', 'Logs every operational expense against specific campaigns.'],
    ['6', 'AI Analytics Engine', 'Processes historical data to provide performance scores and generates reports.'],
    ['7', 'Interactive Dashboard', 'The main landing screen providing a bird\'s-eye view of all operations.']
], "Table 2: Core System Modules")

img('ch1_workflow.png', "Figure 1: Module Concept Map illustrating the interconnected nature of the platform")

h1("Optional Functional Units")
para("1. Push Notifications: Sending real-time device alerts for new campaign announcements.")
para("2. Global Announcements: A dedicated module for admins to broadcast organization-wide news.")
para("3. Campaign Media Gallery: Allowing volunteers to upload photos from the field.")
para("4. Beneficiary Verification System: Digital profiles for the people receiving aid.")
para("5. Data Export Tools: Providing the ability to export financial and volunteer data to CSV or PDF.")

h1("Exclusions")
para("1. Live Payment Gateway Integration: The system will accurately log donations, but it will not process actual credit card or JazzCash transactions directly through APIs.")
para("2. Multi-Language Support: The interface will be developed exclusively in English. Urdu localization is deferred to future iterations.")
para("3. Direct Social Media Integration: The app will not feature automated posting to platforms like Facebook or Twitter.")

h1("Application Architecture")
para("To ensure the system is scalable, maintainable, and responsive, I have designed a Four-Tier Architecture. This structure separates the user interface from the backend logic and the new AI capabilities.")
para("• Presentation Layer (Client): Built with Flutter, this layer handles all user interactions across Web, Android, and iOS.")
para("• AI Services Layer: This specialized tier processes data to provide the platform's intelligent features.")
para("• Backend Services Layer (Firebase): Acts as the bridge between the client and data. It utilizes Firebase Authentication.")
para("• Data Layer (Cloud Firestore): A highly scalable NoSQL database configured with specific collections.")

img('ch5_component_arch.png', "Figure 2: Four-Tier Application Architecture integrating AI Services")

h1("Gantt Chart")
para("The timeline for this project spans the 16-week duration of FYP-1. I have carefully mapped the development phases to align with the required deliverables.")

add_custom_table([
    ['Chapter', 'Sections Covered'],
    ['Chapter 1:\nIntroduction', '1.1 Background\n1.2 Problem Statement\n1.3 Objectives\n1.4 Scope'],
    ['Chapter 2:\nRelated Work', '2.1 Literature Review\n2.2 Existing Systems\n2.3 Critical Analysis']
], "Table 3: FYP-I Chapter Structure Mapping")

add_custom_table([
    ['#', 'Activity / Phase', 'Weeks', 'Responsible'],
    ['1', 'Requirement Analysis & Proposal', 'Wk 1–2', 'M. Maauz'],
    ['2', 'Literature Review & Gap Analysis', 'Wk 2–4', 'M. Maauz'],
    ['3', 'System Design & Architecture', 'Wk 5–6', 'M. Maauz'],
    ['4', 'User Management & Auth', 'Wk 7–9', 'M. Maauz'],
    ['5', 'Campaign Management Module', 'Wk 9–11', 'M. Maauz'],
    ['6', 'Donation Tracking & Analytics', 'Wk 12–14', 'M. Maauz'],
    ['7', 'Testing & Documentation', 'Wk 14–16', 'M. Maauz']
], "Table 4: FYP-I Gantt Chart mapped to Timeline")

img('ch8_strategic_roadmap.png', "Figure 3: Visual representation of the project timeline")

h1("Hardware and Software Specification")
add_custom_table([
    ['Component', 'Specification'],
    ['Development Machine', 'Laptop/PC with minimum 8 GB RAM, Intel i5'],
    ['Operating System', 'Windows 10/11 for development environments'],
    ['Mobile Testing Device', 'Android smartphone for physical device testing'],
    ['Internet Connection', 'Stable broadband connection required for Firebase']
], "Table 5: Hardware Requirements")

add_custom_table([
    ['Software', 'Purpose'],
    ['VS Code / Android Studio', 'Primary IDEs chosen for efficient Flutter development'],
    ['Flutter SDK (3.x)', 'The core cross-platform UI framework'],
    ['Dart SDK', 'The underlying object-oriented programming language'],
    ['Git & GitHub', 'Essential for version control'],
    ['Chrome / Edge Browser', 'Used for testing the web application build']
], "Table 6: Software Requirements")

h1("Tools and Technologies (With Reasoning)")
add_custom_table([
    ['Technology', 'Category', 'Reasoning'],
    ['Flutter', 'Front-End UI', 'Chosen because it allows the creation of natively compiled applications for mobile and web from a single codebase.'],
    ['Dart', 'Programming Language', 'Provides strong object-oriented features, null-safety, and hot reload.'],
    ['Firebase', 'Backend', 'Eliminates the need to build a custom backend server from scratch.'],
    ['Cloud Firestore', 'Database', 'A NoSQL cloud database that naturally handles real-time data synchronization.'],
    ['Firebase ML Kit', 'AI Services', 'Allows integration of on-device machine learning capabilities.']
], "Table 7: Selected Tools and Technologies")

h1("Expertise of Team Members")
add_custom_table([
    ['Team Member', 'Role', 'Relevant Skills & Expertise'],
    ['Muhammad Maauz Mansoor', 'Full-Stack Developer', '• Flutter & Dart\n• OOP Principles\n• Firebase Firestore\n• Git/GitHub']
], "Table 8: Team Member Technical Expertise")

h1("References")
para("[1] S. Newman, 'Building Microservices: Designing Fine-Grained Systems', O'Reilly Media, 2015.")
para("[2] Google, 'Flutter Architectural Overview', [Online]. Available: https://docs.flutter.dev/resources/architectural-overview.")
para("[3] Firebase Documentation, 'Understand Cloud Firestore', [Online]. Available: https://firebase.google.com/docs/firestore.")
para("[4] 'State of AI in Nonprofits 2025,' Nonprofit Technology Network, 2025.")
para("[5] A. Smith, 'AI-Enabled Transformation of Volunteer Services,' International Journal of Global Economics, 2025.")

doc.save(out_path)
print("Complete Rebuild Finished Successfully!")
