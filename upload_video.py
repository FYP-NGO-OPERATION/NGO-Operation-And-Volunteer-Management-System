import requests
import os
import json

API_KEY = "AIzaSyDX8a1eHkvAqoOIHBlu1HB3N2CQsnilK4I"
BUCKET = "ngo-volunteer-app-6284b.appspot.com"
PROJECT_ID = "ngo-volunteer-app-6284b"
ADMIN_EMAIL = "REDACTED@example.com"
ADMIN_PASSWORD = "a123456"

# File
video_path = r"E:\Fyp\Project-01\Official video.mp4"

print("1. Authenticating...")
auth_resp = requests.post(
    f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}",
    json={"email": ADMIN_EMAIL, "password": ADMIN_PASSWORD, "returnSecureToken": True}
)
if auth_resp.status_code != 200:
    print("Auth failed", auth_resp.text)
    exit(1)
id_token = auth_resp.json()['idToken']
headers = {"Authorization": f"Bearer {id_token}", "Content-Type": "video/mp4"}

print(f"2. Uploading {video_path} to Firebase Storage...")
with open(video_path, 'rb') as f:
    upload_url = f"https://firebasestorage.googleapis.com/v0/b/{BUCKET}/o?name=campaigns%2Fproject_01%2FOfficial_video.mp4"
    resp = requests.post(upload_url, headers=headers, data=f)
    if resp.status_code == 200:
        download_tokens = resp.json().get('downloadTokens')
        final_video_url = f"https://firebasestorage.googleapis.com/v0/b/{BUCKET}/o/campaigns%2Fproject_01%2FOfficial_video.mp4?alt=media&token={download_tokens}"
        print("   Upload successful! URL:", final_video_url)
        
        # Patch Firestore
        print("3. Patching Firestore document...")
        db_headers = {"Authorization": f"Bearer {id_token}"}
        patch_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/campaigns/project_01?updateMask.fieldPaths=videoUrl"
        patch_resp = requests.patch(patch_url, headers=db_headers, json={"fields": {"videoUrl": {"stringValue": final_video_url}}})
        if patch_resp.status_code == 200:
            print("   Firestore updated successfully!")
        else:
            print("   Failed to update Firestore:", patch_resp.text)
    else:
        print("   Upload failed:", resp.text)
