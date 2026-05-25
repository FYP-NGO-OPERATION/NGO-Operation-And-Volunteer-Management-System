import requests
import json

API_KEY = "AIzaSyDX8a1eHkvAqoOIHBlu1HB3N2CQsnilK4I"
PROJECT_ID = "ngo-volunteer-app-6284b"
ADMIN_EMAIL = "REDACTED@example.com" 
ADMIN_PASSWORD = "a123456"

# 1. Auth
auth_url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}"
auth_data = {"email": ADMIN_EMAIL, "password": ADMIN_PASSWORD, "returnSecureToken": True}
resp = requests.post(auth_url, json=auth_data)
id_token = resp.json()['idToken']
headers = {"Authorization": f"Bearer {id_token}"}

# 2. Patch Campaign PDF URL
patch_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/campaigns/project_01?updateMask.fieldPaths=documentUrl"

pdf_url = "https://res.cloudinary.com/dcl3q1pcd/raw/upload/fl_attachment/v1778241358/campaigns/project_01/ispvmrjpzee8fhtuk0o9.pdf"

patch_resp = requests.patch(patch_url, headers=headers, json={"fields": {"documentUrl": {"stringValue": pdf_url}}})
if patch_resp.status_code == 200:
    print("PDF URL patched to Google Docs Viewer successfully!")
else:
    print("Failed to patch PDF URL:", patch_resp.text)
