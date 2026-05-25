import requests
import json

API_KEY = "AIzaSyDX8a1eHkvAqoOIHBlu1HB3N2CQsnilK4I"
PROJECT_ID = "ngo-volunteer-app-6284b"
ADMIN_EMAIL = "REDACTED@example.com" 
ADMIN_PASSWORD = "a123456"

# Auth
auth_url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}"
auth_data = {"email": ADMIN_EMAIL, "password": ADMIN_PASSWORD, "returnSecureToken": True}
resp = requests.post(auth_url, json=auth_data)
id_token = resp.json()['idToken']
local_id = resp.json()['localId']
headers = {"Authorization": f"Bearer {id_token}"}
base_timestamp = "2023-11-02T10:00:00Z"

def create_root_doc(collection, doc_id, fields):
    url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/{collection}?documentId={doc_id}"
    resp = requests.post(url, headers=headers, json={"fields": fields})
    if resp.status_code == 200 or resp.status_code == 201:
        print(f"Created {collection}/{doc_id}")
    elif resp.status_code == 409:
        patch_url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/{collection}/{doc_id}"
        requests.patch(patch_url, headers=headers, json={"fields": fields})
        print(f"Updated {collection}/{doc_id}")
    else:
        print(f"Error {collection}/{doc_id}:", resp.text)

# 1. Update Photos
photo_urls = [
  "https://res.cloudinary.com/dcl3q1pcd/image/upload/v1778241358/campaigns/project_01/rrsv7qeeqbxtrdhh5jff.jpg",
  "https://res.cloudinary.com/dcl3q1pcd/image/upload/v1778241360/campaigns/project_01/d4h0jppbucbiltbtiwjh.jpg",
  "https://res.cloudinary.com/dcl3q1pcd/image/upload/v1778241361/campaigns/project_01/huibm9gekxp0oenq1sgt.jpg",
  "https://res.cloudinary.com/dcl3q1pcd/image/upload/v1778241362/campaigns/project_01/tma1hckrgruyajnnnwas.jpg"
]

for i, url in enumerate(photo_urls):
    p_id = f"photo_{i+1}"
    p_fields = {
        "id": {"stringValue": p_id},
        "campaignId": {"stringValue": "project_01"},
        "imageUrl": {"stringValue": url},
        "caption": {"stringValue": "Visit to Old Age Home Activity"},
        "uploadedBy": {"stringValue": local_id},
        "uploaderName": {"stringValue": "Admin"},
        "createdAt": {"timestampValue": base_timestamp},
    }
    create_root_doc("campaign_photos", p_id, p_fields)

# 2. Add Distribution
d_fields = {
    "id": {"stringValue": "dist_1"},
    "campaignId": {"stringValue": "project_01"},
    "itemType": {"stringValue": "food"},
    "quantity": {"integerValue": 35},
    "unit": {"stringValue": "people"},
    "distributedTo": {"integerValue": 35},
    "distributedBy": {"stringValue": local_id},
    "distributedAt": {"timestampValue": base_timestamp},
    "location": {"stringValue": "Multan Afiyat Old Age Home"},
    "notes": {"stringValue": "Served live nashta of Halwa, Poori and Chaane"},
}
create_root_doc("distributions", "dist_1", d_fields)

print("Gallery URLs updated and Distribution added!")
