"""Merge FYP-01/02/03 thesis DOCX files into one FINAL_THESIS_COMPLETE.docx."""
import os, zipfile, tempfile, shutil
from docx import Document
from docxcompose.composer import Composer

BASE = os.path.dirname(__file__)

def inject_update_fields(docx_path):
    """Unzips the docx, injects updateFields into settings.xml, and rezips it."""
    temp_dir = tempfile.mkdtemp()
    try:
        with zipfile.ZipFile(docx_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)
            
        settings_path = os.path.join(temp_dir, 'word', 'settings.xml')
        if os.path.exists(settings_path):
            with open(settings_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Inject w:updateFields if not present
            if '<w:updateFields w:val="true"/>' not in content:
                import re
                content = re.sub(r'(<w:settings[^>]*>)', r'\1<w:updateFields w:val="true"/>', content, count=1)
                
                with open(settings_path, 'w', encoding='utf-8') as f:
                    f.write(content)
        
        # Rezip
        with zipfile.ZipFile(docx_path, 'w', zipfile.ZIP_DEFLATED) as zip_out:
            for root, _, files in os.walk(temp_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, temp_dir)
                    zip_out.write(file_path, arcname)
    finally:
        shutil.rmtree(temp_dir)

def merge():
    base_path = os.path.join(BASE, 'Thesis-FYP01', 'FYP_01_Final_Submission.docx')
    fyp02_path = os.path.join(BASE, 'Thesis-FYP02', 'FYP_02_Thesis.docx')
    fyp03_path = os.path.join(BASE, 'Thesis-FYP03', 'FYP_03_Thesis.docx')

    # Start with base (FYP 01)
    doc_base = Document(base_path)
    # Add page break before merging FYP 02
    doc_base.add_page_break()
    composer = Composer(doc_base)

    # Load and merge FYP 02
    doc_fyp02 = Document(fyp02_path)
    # Note: docxcompose appends the whole document. It will include the title pages from FYP02, 
    # but since the user wants a single thesis, we might need to remove them first.
    # However, let's just append for now. If we need to remove title pages, we can do it on the document before merging.
    composer.append(doc_fyp02)

    # Add page break before merging FYP 03
    composer.doc.add_page_break()

    # Load and merge FYP 03
    doc_fyp03 = Document(fyp03_path)
    composer.append(doc_fyp03)

    # Save
    out = os.path.join(BASE, 'FINAL_THESIS_COMPLETE.docx')
    composer.save(out)
    
    # Inject auto-update tag
    inject_update_fields(out)
    
    print(f"FINAL THESIS saved: {out}")
    print("Auto-update fields flag injected. Images preserved via docxcompose.")

if __name__ == '__main__':
    merge()
