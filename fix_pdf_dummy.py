import requests
import json
import urllib.parse

# Firebase credentials
API_KEY = "AIzaSyDX8a1eHkvAqoOIHBlu1HB3N2CQsnilK4I"
PROJECT_ID = "ngo-volunteer-app-6284b"
ADMIN_EMAIL = "REDACTED@example.com"
ADMIN_PASSWORD = "a123456"

print("1. Authenticating to Firebase...")
auth_resp = requests.post(
    f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}",
    json={"email": ADMIN_EMAIL, "password": ADMIN_PASSWORD, "returnSecureToken": True}
)
id_token = auth_resp.json()['idToken']
headers = {"Authorization": f"Bearer {id_token}"}
print("   Done.")

# Set a public w3c test PDF URL
public_pdf_url = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"

print("\n2. Updating Firestore documentUrl to public w3c dummy PDF...")
patch_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/campaigns/project_01?updateMask.fieldPaths=documentUrl"
patch_resp = requests.patch(patch_url, headers=headers, json={"fields": {"documentUrl": {"stringValue": public_pdf_url}}})

if patch_resp.status_code == 200:
    print(f"   Firestore updated! PDF URL: {public_pdf_url}")
else:
    print(f"   Firestore update failed: {patch_resp.text}")

print("\n[DONE]")
