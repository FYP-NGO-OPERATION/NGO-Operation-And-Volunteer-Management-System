import requests
import json

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

print("\n2. Restoring Media URLs to Campaign Document...")
patch_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/campaigns/project_01?updateMask.fieldPaths=coverImageUrl&updateMask.fieldPaths=galleryUrls"

photo_urls = [
  "https://res.cloudinary.com/dcl3q1pcd/image/upload/v1778241358/campaigns/project_01/rrsv7qeeqbxtrdhh5jff.jpg",
  "https://res.cloudinary.com/dcl3q1pcd/image/upload/v1778241360/campaigns/project_01/d4h0jppbucbiltbtiwjh.jpg",
  "https://res.cloudinary.com/dcl3q1pcd/image/upload/v1778241361/campaigns/project_01/huibm9gekxp0oenq1sgt.jpg",
  "https://res.cloudinary.com/dcl3q1pcd/image/upload/v1778241362/campaigns/project_01/tma1hckrgruyajnnnwas.jpg"
]

gallery_array = [{"stringValue": url} for url in photo_urls]

fields = {
    "coverImageUrl": {"stringValue": photo_urls[0]},
    "galleryUrls": {"arrayValue": {"values": gallery_array}}
}

patch_resp = requests.patch(patch_url, headers=headers, json={"fields": fields})

if patch_resp.status_code == 200:
    print("   Database successfully updated! Images restored.")
else:
    print("   Database update failed:", patch_resp.text)

print("\n[DONE]")
