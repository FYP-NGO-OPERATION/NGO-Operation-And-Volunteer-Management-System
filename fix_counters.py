import requests

API_KEY = "AIzaSyDX8a1eHkvAqoOIHBlu1HB3N2CQsnilK4I"
PROJECT_ID = "ngo-volunteer-app-6284b"
ADMIN_EMAIL = "REDACTED@example.com" 
ADMIN_PASSWORD = "a123456"

# Auth
auth_url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}"
resp = requests.post(auth_url, json={"email": ADMIN_EMAIL, "password": ADMIN_PASSWORD, "returnSecureToken": True})
id_token = resp.json()['idToken']
headers = {"Authorization": f"Bearer {id_token}"}
base = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

def patch_fields(path, fields):
    field_paths = "&".join([f"updateMask.fieldPaths={k}" for k in fields.keys()])
    resp = requests.patch(f"{base}/{path}?{field_paths}", headers=headers, json={"fields": fields})
    status = "OK" if resp.status_code == 200 else "FAIL"
    print(f"[{status}] PATCH {path}: {resp.status_code}")

# 1. Fix Cloudinary PDF URL - use /fl_attachment removal so raw URL works
pdf_url = "https://res.cloudinary.com/dcl3q1pcd/raw/upload/v1778241358/campaigns/project_01/ispvmrjpzee8fhtuk0o9.pdf"
patch_fields("campaigns/project_01", {
    "documentUrl": {"stringValue": pdf_url},
    # Fix campaign stats counters from the actual root collection data
    "totalDonationsAmount": {"doubleValue": 19386.0},
    "totalDonationsCount": {"integerValue": 3},
    "beneficiaryCount": {"integerValue": 35},
    "distributionCount": {"integerValue": 35},
    "totalExpenses": {"doubleValue": 19386.0},
})

print("\nDone! Campaign counters and PDF URL updated.")
print(f"\nPDF URL set to: {pdf_url}")
