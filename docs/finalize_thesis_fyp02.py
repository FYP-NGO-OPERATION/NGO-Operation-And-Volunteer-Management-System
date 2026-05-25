import os
from docx import Document
from docx.shared import Pt, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH

def main():
    base_path = r"E:\Fyp\ngo_volunteer_app\docs"
    input_file = os.path.join(base_path, "FINAL_THESIS_COMPLETE.docx")
    output_file = os.path.join(base_path, "FYP02_THESIS_FINAL.docx")
    
    if not os.path.exists(input_file):
        print(f"Error: Could not find {input_file}")
        return

    doc = Document(input_file)

    # 1. Add Placeholders Chapter at the end
    doc.add_page_break()
    h1 = doc.add_heading("Chapter 6: System Implementation & UI Verification", level=1)
    
    # Text introduction
    intro = doc.add_paragraph("This chapter presents the actual implementation of the HRAS mobile and web interfaces. "
                              "The system was developed strictly according to the phase-based feature flag methodology, "
                              "ensuring isolation between FYP-01 core features and FYP-02 advanced modules. "
                              "The following sections provide visual verification of the operational system.")
    
    placeholders = [
        ("6.1 Login and Authentication Interface", "[PLACEHOLDER: Insert Screenshot of Login Screen here]"),
        ("6.2 Administrator Dashboard", "[PLACEHOLDER: Insert Screenshot of Dashboard with stats here]"),
        ("6.3 Campaign Management", "[PLACEHOLDER: Insert Screenshot of Active Campaigns List here]"),
        ("6.4 Donation Processing", "[PLACEHOLDER: Insert Screenshot of Donation Form here]"),
        ("6.5 Smart Matching Engine (FYP-02)", "[PLACEHOLDER: Insert Screenshot of Recommended Campaigns Screen showing match scores here]"),
        ("6.6 QR Attendance Flow (FYP-02)", "[PLACEHOLDER: Insert Screenshot of QR Code Scanner and Success Message here]"),
        ("6.7 PDF Monthly Reporting (FYP-02)", "[PLACEHOLDER: Insert Screenshot of Generated PDF Report here]"),
        ("6.8 Public Landing Page", "[PLACEHOLDER: Insert Screenshot of Next.js SEO Landing Page here]")
    ]

    for title, instruction in placeholders:
        # Add heading 2
        doc.add_heading(title, level=2)
        # Add instruction block
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run = p.add_run(instruction)
        run.bold = True
        run.italic = True
        run.font.color.rgb = docx.shared.RGBColor(255, 0, 0) if hasattr(docx, 'shared') else None
        
        # Add space for the user to paste the image
        doc.add_paragraph("\n\n")

    # 2. Add IEEE References Placeholder if it doesn't exist
    doc.add_page_break()
    doc.add_heading("References", level=1)
    ref = doc.add_paragraph()
    ref.add_run("[1] F. Yousuf, \"Guidelines for FYP Academic Writing,\" Air University, Multan, 2026.\n"
                "[2] Firebase Documentation, \"Cloud Functions for Firebase,\" Google, 2026. [Online]. Available: https://firebase.google.com/docs/functions\n"
                "[3] Flutter Docs, \"Cross-platform UI Toolkit,\" Google, 2026.")

    doc.save(output_file)
    print(f"Success! Generated {output_file} with FYP-02 placeholders and formatting.")

if __name__ == "__main__":
    import docx
    main()
