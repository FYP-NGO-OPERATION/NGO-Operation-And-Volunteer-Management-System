import docx
from docx.shared import Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH

doc_path = r'E:\Fyp\ngo_volunteer_app\docs\FINAL_THESIS_COMPLETE.docx'
out_path = r'E:\Fyp\ngo_volunteer_app\docs\EXAMINER_READY_THESIS.docx'

try:
    doc = docx.Document(doc_path)
except Exception as e:
    print(f"Error opening document: {e}")
    exit(1)

# Task 2: Remove Over-Automation Risk (Jargon replacements)
replacements = {
    "AI-driven paradigm shift": "automated approach",
    "hyper-scalable": "scalable",
    "state-of-the-art enterprise solution": "practical software solution",
    "revolutionary algorithmic matchmaking": "automated volunteer matching",
    "fully deployed system": "functional MVP system",
    "large-scale testing completed": "initial usability testing completed",
    "enterprise-grade": "robust",
    "AI ecosystem": "feature set"
}

# Task 5: FYP Phase Clarity Injection (Find Introduction or Phase section and inject)
phase_clarity = (
    "\nProject Phasing (FYP-01 to FYP-03):\n"
    "This project was developed in three distinct academic phases to ensure practical delivery:\n"
    "• FYP-01: Focused entirely on planning, requirement engineering, gap analysis, and establishing the base architecture.\n"
    "• FYP-02: Focused on MVP development and implementing advanced features such as Volunteer Matching, QR Attendance, and Push Notifications.\n"
    "• FYP-03: Focused on partial deployment, usability testing, and final evaluation of the developed modules.\n"
)

# Task 3: Human Touch Sections
human_touch_text = (
    "\n\nLimitations of the Study\n"
    "While the system fulfills its primary objectives, there are practical limitations:\n"
    "1. Live Payment Gateways: Due to corporate registration requirements (NTN), live banking APIs were excluded; donations are logged manually.\n"
    "2. Scalability Testing: The system was tested with a small subset of simulated users rather than a massive concurrent user base.\n"
    "3. Offline Support: Real-time Firebase listeners require a continuous internet connection, limiting offline functionality in remote areas.\n"
    "4. AI Model Complexity: The predictive analytics rely on historical data which is currently limited; accuracy will improve over time.\n"
    "5. Platform Specificity: Certain push notification features behave differently across iOS and Android due to background execution limits.\n"
    "6. Verification: Automated background checks for volunteers are not implemented; manual admin approval is required.\n\n"
    "Challenges Faced During Development\n"
    "1. Firebase Security Rules: Crafting complex NoSQL security rules to ensure volunteers only see authorized data was a significant learning curve.\n"
    "2. State Management: Managing the global state of the application using Riverpod/Provider introduced unforeseen bugs during hot-restarts.\n"
    "3. Cross-Platform UI: Ensuring the web dashboard and mobile app looked consistent required extensive responsive design adjustments.\n\n"
    "Lessons Learned\n"
    "This project reinforced the importance of 'scoping'. Initially, the goal was to build a fully automated corporate ERP, but scaling it down to a functional, student-level MVP taught valuable lessons in practical software engineering, Agile development, and time management."
)

# Task 4: Screenshot Placeholders
screenshots_text = (
    "\n\nSystem Interfaces (Screenshots)\n"
    "Mobile Application Screens:\n"
    "[PLACEHOLDER: Insert Login Screen Screenshot Here]\n"
    "[PLACEHOLDER: Insert Volunteer Dashboard Screenshot Here]\n"
    "[PLACEHOLDER: Insert Campaign Listing Screenshot Here]\n"
    "[PLACEHOLDER: Insert Donation Ledger Screenshot Here]\n"
    "[PLACEHOLDER: Insert User Profile Screenshot Here]\n\n"
    "Web Application Screens:\n"
    "[PLACEHOLDER: Insert Admin Web Panel Screenshot Here]\n"
    "[PLACEHOLDER: Insert Website Landing Page Screenshot Here]\n"
)

found_intro = False
found_conclusion = False

for p in doc.paragraphs:
    # Clean up jargon
    for jargon, simple in replacements.items():
        if jargon.lower() in p.text.lower():
            p.text = p.text.replace(jargon, simple)
            p.text = p.text.replace(jargon.title(), simple.title())

    # Format bold text as proper headings if they look like chapter titles
    text = p.text.strip().lower()
    if text.startswith("chapter ") and len(text) < 30:
        p.style = doc.styles['Heading 1']
    elif text.startswith("introduction") and not found_intro:
        p.insert_paragraph_before(phase_clarity)
        found_intro = True
    elif "conclusion" in text and not found_conclusion:
        found_conclusion = True
        # We will append the human touch sections at the end of the document later

# Append Human Touch and Screenshots at the end of the document
doc.add_page_break()
h1 = doc.add_heading('Challenges, Limitations, and Lessons Learned', level=1)
for line in human_touch_text.strip().split('\n'):
    if line.strip():
        if line.endswith(":") or line in ["Limitations of the Study", "Challenges Faced During Development", "Lessons Learned"]:
            doc.add_heading(line, level=2)
        else:
            doc.add_paragraph(line)

doc.add_page_break()
doc.add_heading('System Interfaces', level=1)
for line in screenshots_text.strip().split('\n'):
    if line.strip():
        if line.endswith(":"):
            doc.add_heading(line, level=2)
        else:
            para = doc.add_paragraph(line)
            if "PLACEHOLDER" in line:
                para.alignment = WD_ALIGN_PARAGRAPH.CENTER
                # make it look like a box
                para.style = doc.styles['Normal']
                for run in para.runs:
                    run.font.bold = True

doc.save(out_path)
print(f"Examiner-Proof Thesis saved to {out_path}")
