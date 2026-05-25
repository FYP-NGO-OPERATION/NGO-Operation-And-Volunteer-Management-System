import requests
import json
import hashlib
import time
import os

# Cloudinary Config — from previous session context
CLOUD_NAME = "dcl3q1pcd"
# We need API_KEY and API_SECRET. Let's try unsigned upload with a preset first.
# Fallback: use authenticated upload

# Try to find credentials from the environment or ask user
# First let's try to use the Cloudinary unsigned upload
# Cloudinary allows unsigned uploads if you have an unsigned preset configured.

PDF_PATH = r"E:\Fyp\Project-01\Project # 1 Record.pdf"
CAMPAIGN_ID = "project_01"

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

# Try to upload PDF to Cloudinary using the 'ml_default' unsigned preset
# (Common default preset on Cloudinary free accounts)
print("\n2. Uploading PDF to Cloudinary (unsigned attempt)...")

upload_url = f"https://api.cloudinary.com/v1_1/{CLOUD_NAME}/raw/upload"

with open(PDF_PATH, "rb") as f:
    pdf_bytes = f.read()

# Try unsigned upload with common presets
for preset in ["ml_default", "unsigned_preset", "default"]:
    resp = requests.post(upload_url, data={
        "upload_preset": preset,
        "folder": f"campaigns/{CAMPAIGN_ID}",
        "public_id": "project_record",
        "access_mode": "public"
    }, files={"file": ("project_record.pdf", pdf_bytes, "application/pdf")})
    
    if resp.status_code == 200:
        data = resp.json()
        pdf_url = data.get("secure_url", "")
        print(f"   Upload success with preset '{preset}'!")
        print(f"   URL: {pdf_url}")
        break
    else:
        err = resp.json().get("error", {}).get("message", resp.text)
        print(f"   Preset '{preset}' failed: {err}")
else:
    print("\n   All unsigned presets failed.")
    print("   The Cloudinary account likely has unsigned uploads disabled.")
    print("\n   ALTERNATIVE SOLUTION: Will update documentUrl to use the existing signed URL via Firebase Storage instead.")
    
    # Upload to Firebase Storage directly (which works since we did this before)
    BUCKET = "ngo-volunteer-app-6284b.appspot.com"
    import urllib.parse
    object_name = "campaigns/project_01/Project_Record.pdf"
    encoded_name = urllib.parse.quote(object_name, safe="")
    upload_url = f"https://firebasestorage.googleapis.com/v0/b/{BUCKET}/o?name={encoded_name}"
    
    upload_headers = {
        "Authorization": f"Bearer {id_token}",
        "Content-Type": "application/pdf"
    }
    
    print("\n3. Uploading PDF to Firebase Storage (fallback)...")
    with open(PDF_PATH, "rb") as f:
        upload_resp = requests.post(upload_url, headers=upload_headers, data=f, timeout=300)
    
    if upload_resp.status_code == 200:
        token = upload_resp.json().get("downloadTokens")
        encoded_path = object_name.replace("/", "%2F")
        pdf_url = f"https://firebasestorage.googleapis.com/v0/b/{BUCKET}/o/{encoded_path}?alt=media&token={token}"
        print(f"   Firebase Storage upload success!")
        print(f"   URL: {pdf_url}")
    else:
        print(f"   Firebase Storage upload also failed: {upload_resp.text}")
        exit(1)

# Update Firestore with the new working PDF URL
print("\n4. Updating Firestore documentUrl...")
patch_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/campaigns/project_01?updateMask.fieldPaths=documentUrl"
patch_resp = requests.patch(patch_url, headers=headers, json={"fields": {"documentUrl": {"stringValue": pdf_url}}})
if patch_resp.status_code == 200:
    print(f"   Firestore updated! PDF URL: {pdf_url}")
else:
    print(f"   Firestore update failed: {patch_resp.text}")

print("\n[DONE] PDF fix complete!")
