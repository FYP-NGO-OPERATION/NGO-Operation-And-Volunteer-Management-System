"""Merge FYP-01/02/03 thesis DOCX files into one FINAL_THESIS_COMPLETE.docx."""
import os, copy
from docx import Document
from docx.shared import Pt, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement, ns
from docx.enum.section import WD_SECTION

BASE = os.path.dirname(__file__)

def merge():
    # Use FYP-01 as the base (has front matter + Ch 1-2)
    base_path = os.path.join(BASE, 'Thesis-FYP01', 'FYP_01_Final_Submission.docx')
    doc = Document(base_path)

    # Load FYP-02 (Ch 3-6) and FYP-03 (Ch 7-8)
    fyp02 = Document(os.path.join(BASE, 'Thesis-FYP02', 'FYP_02_Thesis.docx'))
    fyp03 = Document(os.path.join(BASE, 'Thesis-FYP03', 'FYP_03_Thesis.docx'))

    def append_doc(target, source, skip_title_page=True):
        """Append paragraphs and tables from source to target."""
        started = not skip_title_page
        for element in source.element.body:
            tag = element.tag.split('}')[-1] if '}' in element.tag else element.tag
            if tag == 'sectPr':
                continue
            # Skip title page (first few elements until we hit a Heading 1 with "Chapter")
            if not started:
                if tag == 'p':
                    text = element.text or ''
                    if 'Chapter 3' in text or 'Chapter 7' in text:
                        started = True
                    else:
                        continue
                else:
                    continue
            # Add page break before first chapter heading
            copied = copy.deepcopy(element)
            target.element.body.append(copied)

    # Add page break before Ch 3
    doc.add_page_break()
    append_doc(doc, fyp02, skip_title_page=True)

    # Add page break before Ch 7
    doc.add_page_break()
    append_doc(doc, fyp03, skip_title_page=True)

    # Save
    out = os.path.join(BASE, 'FINAL_THESIS_COMPLETE.docx')
    doc.save(out)
    print(f"FINAL THESIS saved: {out}")

    # Verify structure
    headings = []
    final = Document(out)
    for p in final.paragraphs:
        if p.style.name.startswith('Heading 1'):
            headings.append(p.text)
    print(f"\nHeading 1 entries found: {len(headings)}")
    for h in headings:
        print(f"  - {h}")

if __name__ == '__main__':
    merge()
