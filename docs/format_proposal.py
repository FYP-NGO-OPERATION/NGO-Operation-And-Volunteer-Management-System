import docx
from docx.shared import Pt, Inches
import os

doc_path = r"E:\Fyp\FYP-I Project Proposal Sample.docx"
out_path = r"E:\Fyp\FYP_Proposal_Final_Formatted.docx"
diagrams_dir = r"E:\Fyp\ngo_volunteer_app\docs\diagrams"

doc = docx.Document(doc_path)

# 1. Fill Tables
t0 = doc.tables[0]
t0.cell(1, 1).text = "Muhammad Maauz Mansoor"
t0.cell(1, 5).text = "233599"
t0.cell(2, 1).text = "maauz@example.com"
t0.cell(2, 3).text = "3.5+"
t0.cell(2, 5).text = "0300-XXXXXXX"

t2 = doc.tables[2]
t2.cell(0, 1).text = "HRAS Dev"

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

# 2. Map all 12 Headings to their content
content_map = {
    "Project Title": [
        "AI-Integrated Operations and Volunteer Coordination Platform for Charitable NGOs"
    ],
    "Project Overview": [
        "When looking at the landscape of social welfare in Pakistan, we see that Non-Governmental Organizations (NGOs) are doing tremendous work. Large organizations like Alkhidmat, Edhi, and JDC have naturally adopted digital solutions to manage their massive scale. However, a significant gap exists for smaller, community-level organizations, specifically 'Hamesha Rahein Apke Saath', the welfare society partnered with for this project. They are entirely reliant on scattered WhatsApp groups and handwritten registers for everything from volunteer coordination to managing donations.",
        "This manual approach causes real operational friction. Communication gets buried in chats, making campaign tracking nearly impossible. Financial transparency suffers because there isn't a unified way to log cash versus online donations, let alone track itemized expenses. Furthermore, keeping track of volunteer attendance is disorganized.",
        "To solve this, I am developing a comprehensive, AI-integrated platform built with Flutter. It will act as a centralized hub to handle campaigns, track volunteers securely, log donations accurately, and use data to generate automated reports. This shifts the organization from surviving on messy paperwork to operating with complete data-driven clarity."
    ],
    "Project Goals and Objectives": [
        "The overarching vision for this project is to fundamentally modernize how small-to-medium charitable organizations operate. Specifically, the objectives are to:",
        "1. Create a unified digital ecosystem that seamlessly handles the entire lifecycle of an NGO's operations, moving them away from fragmented tools.",
        "2. Establish complete operational transparency by centralizing real-time tracking for all incoming donations, outgoing expenses, and volunteer activities.",
        "3. Introduce accessible AI capabilities that provide administrators with actionable insights and automated reporting, reducing administrative burden."
    ],
    "High-Level System Components": [
        "1. Cross-Platform Mobile Application (Flutter): A unified interface for volunteers to register, view active campaigns, and track their participation history.",
        "2. Administrative Web Dashboard (Flutter Web): A secure portal for NGO executives to manage campaigns, oversee financial logs, and access macro-level analytics.",
        "3. Real-Time Cloud Infrastructure (Firebase): Utilizing Firestore for sub-second data synchronization and Firebase Auth for encrypted Role-Based Access Control (RBAC).",
        "4. Intelligent Reporting Engine: Utilizing backend APIs to automatically synthesize end-of-month campaign summaries and trends."
    ],
    "Optional Functional Units": [
        "1. Cryptographic QR Attendance: Allowing field coordinators to generate unique QR codes for campaigns, which volunteers can scan to automatically verify their presence.",
        "2. Dynamic PDF Receipt Generation: Automatically generating and emailing formal, immutable financial receipts to donors upon transaction verification.",
        "3. Smart Matching Algorithm: Analyzing a volunteer's predefined skill tags (e.g., medical, logistics) and actively suggesting relevant campaigns to maximize resource allocation."
    ],
    "Assumptions": [
        "1. End-users (administrators and volunteers) will have consistent access to smartphones and standard mobile internet connectivity (3G/4G).",
        "2. The partner NGO will continue to provide real-world operational data and feedback for User Acceptance Testing (UAT).",
        "3. Google Firebase will maintain its free-tier scalability thresholds throughout the development lifecycle."
    ],
    "Issues": [
        "1. Mitigating the learning curve for non-technical NGO administrators transitioning from paper-based systems to a fully digital dashboard.",
        "2. Ensuring the architectural integrity of the real-time database when operating in areas with heavily fluctuating network latency."
    ],
    "Exclusions": [
        "The system will not handle payment gateway integrations (e.g., Stripe, JazzCash) directly within the MVP phase due to corporate compliance constraints; donations will be logged manually or via uploaded receipts. The system will also exclude automated background checks for volunteers."
    ],
    "Application Architecture": [
        "The system utilizes a 3-tier architecture. The presentation layer consists of a cross-platform Flutter application for volunteers and a Flutter Web dashboard for administrators. The business logic and data access layers are handled by Firebase (Firestore for NoSQL data synchronization and Firebase Auth for authentication).",
        "IMAGE:" + os.path.join(diagrams_dir, "ch5_component_arch.png")
    ],
    "Gantt Chart": [
        "The project follows an Agile iterative lifecycle spanning two semesters. The diagram below illustrates the major milestones and their estimated time allocations.",
        "IMAGE:" + os.path.join(diagrams_dir, "ch8_strategic_roadmap.png")
    ],
    "Hardware and Software Specification": [
        "Hardware Requirements: Standard PC/Mac for development (8GB RAM minimum). Android/iOS device for testing.",
        "Software Requirements: Windows/macOS, Flutter SDK, Dart, Android Studio / VS Code, Firebase CLI."
    ],
    "Tools and Technologies": [
        "1. Flutter & Dart: Chosen for the frontend to enable single-codebase deployment to Android, iOS, and Web, significantly reducing development time while maintaining 60fps native performance.",
        "2. Google Firebase (Firestore & Auth): Chosen as the Backend-as-a-Service (BaaS) for its superior real-time data synchronization, eliminating the need to write custom REST APIs for basic CRUD operations.",
        "3. Python: Utilized for backend AI analytics and diagram generation due to its robust data science libraries."
    ],
    "Expertise of Team Members": [
        "The team consists of one member, Muhammad Maauz Mansoor (233599). The developer has prior experience in Dart and Flutter UI development from coursework and personal projects. Concepts of database design, object-oriented programming, and software engineering methodologies have been successfully completed in the prior semesters."
    ],
    "References": [
        "[1] S. Newman, 'Building Microservices: Designing Fine-Grained Systems', O'Reilly Media, 2015.",
        "[2] Google, 'Flutter Architectural Overview', [Online]. Available: https://docs.flutter.dev/resources/architectural-overview.",
        "[3] Firebase Documentation, 'Understand Cloud Firestore', [Online]. Available: https://firebase.google.com/docs/firestore."
    ]
}

# 3. Replace text
for i, p in enumerate(doc.paragraphs):
    text = p.text.strip()
    
    # Check if this paragraph matches any of our target headings
    for key in content_map.keys():
        if text.startswith(key):
            # Find all subsequent instructional paragraphs until the next heading
            j = i + 1
            section_paras = []
            while j < len(doc.paragraphs):
                next_p = doc.paragraphs[j]
                nt = next_p.text.strip()
                # If we hit another known heading or a Word 'Heading' style, stop
                is_heading = any(nt.startswith(k) for k in content_map.keys())
                if is_heading or "Table of Contents" in nt or next_p.style.name.startswith('Heading'):
                    break
                if nt != "":
                    section_paras.append(next_p)
                j += 1
            
            # Clear instructional text
            for sp in section_paras:
                sp.text = ""
            
            # Use the first empty paragraph to insert our data
            if section_paras:
                target_p = section_paras[0]
                target_p.text = "" # Ensure it's clear
                for content_item in content_map[key]:
                    if content_item.startswith("IMAGE:"):
                        img_path = content_item.replace("IMAGE:", "")
                        if os.path.exists(img_path):
                            run = target_p.add_run()
                            run.add_picture(img_path, width=Inches(5.0))
                            target_p.alignment = docx.enum.text.WD_ALIGN_PARAGRAPH.CENTER
                            target_p.add_run("\n")
                    else:
                        run = target_p.add_run(content_item + "\n\n")
                        run.font.name = 'Times New Roman'
                        run.font.size = Pt(12)
            break # Move to next paragraph

doc.save(out_path)
print("Complete!")
