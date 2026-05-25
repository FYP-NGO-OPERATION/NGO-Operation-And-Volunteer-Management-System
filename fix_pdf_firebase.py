import requests
import json
import urllib.parse
import os

PDF_PATH = r"E:\Fyp\Project-01\Project # 1 Record.pdf"
CAMPAIGN_ID = "project_01"

# Firebase credentials
API_KEY = "AIzaSyDX8a1eHkvAqoOIHBlu1HB3N2CQsnilK4I"
PROJECT_ID = "ngo-volunteer-app-6284b"
ADMIN_EMAIL = "REDACTED@example.com"
ADMIN_PASSWORD = "a123456"

# THE FIX: NEW FIREBASE STORAGE BUCKET FORMAT
BUCKET = "ngo-volunteer-app-6284b.firebasestorage.app"

print("1. Authenticating to Firebase...")
auth_resp = requests.post(
    f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}",
    json={"email": ADMIN_EMAIL, "password": ADMIN_PASSWORD, "returnSecureToken": True}
)
if auth_resp.status_code != 200:
    print("Login Failed:", auth_resp.text)
    exit(1)

id_token = auth_resp.json()['idToken']
print("   Done.")

print("\n2. Uploading PDF to Firebase Storage...")
object_name = f"campaigns/project_01/Project # 1 Record.pdf"
encoded_name = urllib.parse.quote(object_name, safe='')

# New Firebase Storage API endpoint structure for .firebasestorage.app domains
# Actually, the API endpoint is usually the same, just the bucket name changes
upload_url = f"https://firebasestorage.googleapis.com/v0/b/{BUCKET}/o?name={encoded_name}"

upload_headers = {
    "Authorization": f"Bearer {id_token}",
    "Content-Type": "application/pdf"
}

if not os.path.exists(PDF_PATH):
    print(f"Error: Could not find PDF at {PDF_PATH}")
    exit(1)

with open(PDF_PATH, "rb") as f:
    upload_resp = requests.post(upload_url, headers=upload_headers, data=f, timeout=300)

if upload_resp.status_code == 200:
    token = upload_resp.json().get("downloadTokens")
    # For public URL construction
    encoded_path = object_name.replace("/", "%2F").replace(" ", "%20").replace("#", "%23")
    pdf_url = f"https://firebasestorage.googleapis.com/v0/b/{BUCKET}/o/{encoded_path}?alt=media&token={token}"
    print(f"   Firebase Storage upload success!")
    print(f"   URL: {pdf_url}")
else:
    print(f"   Firebase Storage upload failed: {upload_resp.text}")
    # Let's try the old appspot domain just in case it's actually configured that way
    print("   Trying old appspot.com bucket...")
    BUCKET = "ngo-volunteer-app-6284b.appspot.com"
    upload_url = f"https://firebasestorage.googleapis.com/v0/b/{BUCKET}/o?name={encoded_name}"
    with open(PDF_PATH, "rb") as f:
        upload_resp = requests.post(upload_url, headers=upload_headers, data=f, timeout=300)
    
    if upload_resp.status_code == 200:
        token = upload_resp.json().get("downloadTokens")
        encoded_path = object_name.replace("/", "%2F").replace(" ", "%20").replace("#", "%23")
        pdf_url = f"https://firebasestorage.googleapis.com/v0/b/{BUCKET}/o/{encoded_path}?alt=media&token={token}"
        print(f"   Firebase Storage upload success on appspot!")
        print(f"   URL: {pdf_url}")
    else:
        print(f"   Appspot Firebase Storage upload also failed: {upload_resp.text}")
        exit(1)

print("\n3. Updating Firestore documentUrl...")
patch_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/campaigns/project_01?updateMask.fieldPaths=documentUrl"
patch_resp = requests.patch(patch_url, headers={"Authorization": f"Bearer {id_token}"}, json={"fields": {"documentUrl": {"stringValue": pdf_url}}})

if patch_resp.status_code == 200:
    print(f"   Firestore updated!")
else:
    print(f"   Firestore update failed: {patch_resp.text}")

print("\n[DONE] Your Original PDF is now live!")
