import docx
from docx.shared import Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

doc = docx.Document()

# Title
title = doc.add_heading('FYP Defense: Ultimate Q&A Preparation Guide', 0)
title.alignment = WD_ALIGN_PARAGRAPH.CENTER

# ---------------------------------------------------------
doc.add_heading('Part 1: How to Explain the Problem Statement', level=1)
p = doc.add_paragraph()
p.add_run('How to start speaking (Elevator Pitch):\n').bold = True
p.add_run('"Sir/Madam, imagine a small local NGO like Hamesha Rahein Apke Saath. Right now, they run entirely on WhatsApp and physical notebooks. If someone donates Rs. 1000, it goes in a paper register. If 20 volunteers show up for a medical camp, attendance is taken on a piece of paper.\n\nThis creates 3 massive problems:\n1. Financial Opacity: Receipts get lost, and calculating total monthly expenses vs. donations is a nightmare.\n2. Volunteer Mismanagement: It is impossible to track which volunteer is active and who has stopped coming.\n3. Zero Analytics: Because everything is on paper, the NGO cannot analyze their own growth or performance.\n\nMy platform digitizes this entire process. It is an internal ERP system that tracks every single rupee, logs every volunteer\'s attendance, and uses AI to generate performance reports automatically."')

# ---------------------------------------------------------
doc.add_heading('Part 2: Questions from your PPT (Presentation)', level=1)

q_a = [
    ('Q1: Why do we need this app when Edhi and Alkhidmat already have apps?',
     'Answer: Their apps are B2C (Business to Consumer) – they are designed for the general public to give donations. My application is an Internal Operations System (B2B) for the NGO admins and volunteers. It is designed to manage the internal workflow, attendance, and expense tracking, which public donation apps do not do.'),
    
    ('Q2: In Slide 6, you showed a 4-Tier Architecture. What exactly is the AI Services Layer?',
     'Answer: Instead of just doing simple CRUD (Create, Read, Update, Delete) operations, my system uses Firebase ML and backend algorithms to analyze historical data. For example, it looks at past campaigns and predicts which type of campaigns (like ration drives vs. medical camps) attract the most volunteers, and auto-generates monthly performance reports.'),
    
    ('Q3: Why did you choose Flutter (Slide 11) instead of native Android (Java/Kotlin)?',
     'Answer: Since I am working solo, time efficiency is critical. Flutter allows me to write one Dart codebase and compile it into an Android App, an iOS App, and a Web Dashboard for admins. It saves months of development time while still providing 60 FPS native performance.'),
    
    ('Q4: Why use Cloud Firestore (NoSQL) instead of MySQL?',
     'Answer: The admin dashboard needs to be "Real-Time". If a volunteer marks their attendance in the field, the admin\'s web dashboard should update instantly without refreshing the page. Firestore does this automatically using real-time listeners. Doing this in MySQL would require me to build complex WebSockets from scratch.'),
     
    ('Q5: How will your Role-Based Access Control (Slide 8) work?',
     'Answer: I am using Firebase Authentication. When a user logs in, the system checks their customized "Claims". A volunteer will only see the campaigns they can join. An Admin will have access to the financial ledgers and the AI analytics dashboard.')
]

for q, a in q_a:
    pq = doc.add_paragraph()
    r_q = pq.add_run(q)
    r_q.bold = True
    r_q.font.color.rgb = RGBColor(0, 51, 204) # Blue questions
    
    pa = doc.add_paragraph()
    r_a = pa.add_run(a)
    r_a.font.color.rgb = RGBColor(0, 128, 0) # Green answers
    doc.add_paragraph()

# ---------------------------------------------------------
doc.add_heading('Part 3: Questions from your Proposal Document', level=1)

q_a_doc = [
    ('Q6: In Section 6 (Exclusions), you mentioned no Live Payment Gateways (Stripe/JazzCash). Why?',
     'Answer: Sir, integrating live financial APIs requires formal business registration (NTN, Corporate Bank Accounts) which an FYP student cannot legally obtain. To keep the project realistic and achievable, the system accurately logs donations and verifies uploaded bank receipts, but the actual bank transfer happens outside the app.'),
    
    ('Q7: Your Gantt Chart shows completion of Chapter 1 and 2. How will you finish development?',
     'Answer: FYP-I (Semester 1) is strictly focused on Requirements Engineering, Literature Review (Chapters 1 & 2), UI/UX mockups, and building the core MVP (Authentication & Campaign tables). The heavy development, AI integration, and testing (Chapters 3-6) will be executed entirely in FYP-II (Semester 2).'),
    
    ('Q8: What is the "Smart Matching Algorithm" mentioned in your optional units?',
     'Answer: When a volunteer registers, they select skill tags (e.g., "Medical", "Logistics", "Teaching"). When an admin creates a new medical camp, the algorithm filters the database and sends targeted push notifications only to volunteers with the "Medical" tag. This optimizes resource allocation.'),
     
    ('Q9: Is the scope of this project too big for a single student?',
     'Answer: I have carefully scoped the project. By leveraging BaaS (Backend as a Service) like Firebase, I don\'t have to build a server, write API endpoints, or manage database security from scratch. This allows me to focus purely on the frontend business logic and AI integration, making it highly achievable for a solo developer.')
]

for q, a in q_a_doc:
    pq = doc.add_paragraph()
    r_q = pq.add_run(q)
    r_q.bold = True
    r_q.font.color.rgb = RGBColor(0, 51, 204)
    
    pa = doc.add_paragraph()
    r_a = pa.add_run(a)
    r_a.font.color.rgb = RGBColor(0, 128, 0)
    doc.add_paragraph()

doc.save(r'E:\Fyp\FYP_Defense_QA_Preparation.docx')
print("Successfully generated QA guide.")
