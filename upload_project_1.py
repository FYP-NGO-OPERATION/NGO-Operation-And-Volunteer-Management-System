import requests
import os
import json

# ==========================================
# CONFIGURATION - PLEASE UPDATE THESE FIELDS
# ==========================================
# Apna admin email aur password yahan daalein
ADMIN_EMAIL = "REDACTED@example.com" 
ADMIN_PASSWORD = "a123456"

# Aapke Firebase project ki API Key (app/lib/firebase_options.dart se li gai hai)
API_KEY = "AIzaSyDX8a1eHkvAqoOIHBlu1HB3N2CQsnilK4I"
BUCKET = "ngo-volunteer-app-6284b.appspot.com"
PROJECT_ID = "ngo-volunteer-app-6284b"

# Files ki Location
PROJECT_FOLDER = r"E:\Fyp\Project-01"
FILES_TO_UPLOAD = {
    "1.jpeg": "image/jpeg",
    "2.jpeg": "image/jpeg",
    "3.jpeg": "image/jpeg",
    "4.jpeg": "image/jpeg",
    "Official video.mp4": "video/mp4",
    "Project # 1 Record.pdf": "application/pdf"
}

# ==========================================
# 1. AUTHENTICATE TO GET TOKEN
# ==========================================
print("Authenticating with Firebase...")
auth_url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}"
auth_data = {
    "email": ADMIN_EMAIL,
    "password": ADMIN_PASSWORD,
    "returnSecureToken": True
}

resp = requests.post(auth_url, json=auth_data)
if resp.status_code != 200:
    print("Login Failed! Please check your email and password.")
    print("Error:", resp.json())
    exit(1)

auth_info = resp.json()
id_token = auth_info['idToken']
local_id = auth_info['localId']
print("Login Successful!")

# ==========================================
# 2. UPLOAD FILES TO STORAGE
# ==========================================
print("\nStarting Uploads...")
uploaded_urls = {}

for filename, content_type in FILES_TO_UPLOAD.items():
    file_path = os.path.join(PROJECT_FOLDER, filename)
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        continue
    
    # Storage Path (e.g., campaigns/project1/1.jpeg)
    import urllib.parse
    object_name = f"campaigns/project1/{filename}"
    encoded_name = urllib.parse.quote(object_name, safe='')
    upload_url = f"https://firebasestorage.googleapis.com/v0/b/{BUCKET}/o?name={encoded_name}"
    
    headers = {
        "Authorization": f"Bearer {id_token}",
        "Content-Type": content_type
    }
    
    import time
    print(f"Uploading {filename} ...")
    
    max_retries = 3
    for attempt in range(max_retries):
        try:
            with open(file_path, "rb") as f:
                upload_resp = requests.post(upload_url, headers=headers, data=f, timeout=300)
            break
        except Exception as e:
            print(f"  -> Attempt {attempt+1} failed: {e}")
            time.sleep(2)
            if attempt == max_retries - 1:
                raise
    
    if upload_resp.status_code == 200:
        download_token = upload_resp.json().get('downloadTokens')
        # URL encoding forward slashes for the public download URL
        encoded_object_name = object_name.replace("/", "%2F")
        public_url = f"https://firebasestorage.googleapis.com/v0/b/{BUCKET}/o/{encoded_object_name}?alt=media&token={download_token}"
        uploaded_urls[filename] = public_url
        print(f"  -> Success!")
    else:
        print(f"  -> Failed: {upload_resp.text}")

# ==========================================
# 3. CREATE FIRESTORE DOCUMENT
# ==========================================
print("\nCreating Project 01 Campaign in Firestore...")
firestore_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/campaigns?documentId=project_01"

# Formatting gallery URLs list
gallery_array = [{"stringValue": uploaded_urls.get(f"{i}.jpeg", "")} for i in range(1, 5) if f"{i}.jpeg" in uploaded_urls]

campaign_data = {
    "fields": {
        "id": {"stringValue": "project_01"},
        "title": {"stringValue": "Visit To Old Age Home"},
        "description": {"stringValue": "Our team decided to meet the parents of Old Age Home(Affiat). We serve them with live nashta of Halwa, Poori and Chaane. We arranged a small Mehfil-e-milaad. At the end we also cut Cake with them."},
        "type": {"stringValue": "custom"},
        "status": {"stringValue": "completed"},
        "startDate": {"timestampValue": "2023-11-02T00:00:00Z"},
        "endDate": {"timestampValue": "2023-11-20T23:59:59Z"},
        "location": {"stringValue": "Multan Afiyat Old Age Home Chungi No.9"},
        "targetGoal": {"stringValue": "19386"},
        "achievedGoal": {"stringValue": "19386"},
        "totalDonationsAmount": {"doubleValue": 19386.0},
        "totalExpenses": {"doubleValue": 19386.0},
        "beneficiaryCount": {"integerValue": 35}, 
        "createdBy": {"stringValue": local_id},
        "createdByName": {"stringValue": "Admin"},
        "ngoId": {"stringValue": "HRAS_DEFAULT_ID"},
        "createdAt": {"timestampValue": "2023-11-01T00:00:00Z"},
        
        # New Multimedia Fields
        "videoUrl": {"stringValue": uploaded_urls.get("Official video.mp4", "")},
        "documentUrl": {"stringValue": uploaded_urls.get("Project # 1 Record.pdf", "")},
        "coverImageUrl": {"stringValue": uploaded_urls.get("1.jpeg", "")},
        "galleryUrls": {"arrayValue": {"values": gallery_array}}
    }
}

db_headers = {"Authorization": f"Bearer {id_token}"}
db_resp = requests.post(firestore_url, headers=db_headers, json=campaign_data)

if db_resp.status_code == 200 or db_resp.status_code == 201:
    print("\n[SUCCESS] Project 01 Successfully Created in Firestore!")
    print("You can now open your App and check the Campaign Details!")
else:
    # If document already exists, we should patch it.
    patch_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/campaigns/project_01"
    patch_resp = requests.patch(patch_url, headers=db_headers, json=campaign_data)
    if patch_resp.status_code == 200:
        print("\n[SUCCESS] Project 01 Successfully Updated in Firestore!")
    else:
        print("\n[ERROR] Failed to save to Firestore:", patch_resp.text)
