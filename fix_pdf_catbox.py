import requests
import os

PDF_PATH = r"E:\Fyp\Project-01\Project # 1 Record.pdf"
PROJECT_ID = "ngo-volunteer-app-6284b"
API_KEY = "AIzaSyDX8a1eHkvAqoOIHBlu1HB3N2CQsnilK4I"
ADMIN_EMAIL = "REDACTED@example.com"
ADMIN_PASSWORD = "a123456"

if not os.path.exists(PDF_PATH):
    print("Error: PDF file not found at", PDF_PATH)
    exit(1)

print("1. Uploading Original PDF to reliable server (Catbox.moe)...")
url = "https://catbox.moe/user/api.php"
with open(PDF_PATH, 'rb') as f:
    files = {'fileToUpload': ('Project_1_Record.pdf', f, 'application/pdf')}
    data = {'reqtype': 'fileupload'}
    resp = requests.post(url, data=data, files=files)

if resp.status_code != 200:
    print("Upload failed:", resp.text)
    exit(1)

pdf_url = resp.text.strip()
print(f"   Success! Live PDF URL: {pdf_url}")

print("\n2. Authenticating to Firebase...")
auth_resp = requests.post(
    f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}",
    json={"email": ADMIN_EMAIL, "password": ADMIN_PASSWORD, "returnSecureToken": True}
)
id_token = auth_resp.json()['idToken']
headers = {"Authorization": f"Bearer {id_token}"}
print("   Done.")

print("\n3. Updating App Database with Original PDF URL...")
patch_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/campaigns/project_01?updateMask.fieldPaths=documentUrl"
patch_resp = requests.patch(patch_url, headers=headers, json={"fields": {"documentUrl": {"stringValue": pdf_url}}})

if patch_resp.status_code == 200:
    print(f"   Database successfully updated!")
else:
    print(f"   Database update failed: {patch_resp.text}")

print("\n[DONE] Original PDF is now in the app!")
