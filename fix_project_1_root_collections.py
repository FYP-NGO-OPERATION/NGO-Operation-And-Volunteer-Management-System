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

donations = [
    {"id": "don_1", "donorName": "Ali Raza", "category": "money", "quantity": "Cash", "amount": 10000, "amountCash": 10000, "amountOnline": 0, "paymentMethod": "cash", "description": "General donation"},
    {"id": "don_2", "donorName": "Fatima", "category": "money", "quantity": "Bank Transfer", "amount": 5000, "amountCash": 0, "amountOnline": 5000, "paymentMethod": "bank_transfer", "description": "Zakat"},
    {"id": "don_3", "donorName": "Anonymous", "category": "money", "quantity": "JazzCash", "amount": 4386, "amountCash": 0, "amountOnline": 4386, "paymentMethod": "mobile_wallet", "description": "Sadaqah"}
]

for d in donations:
    fields = {
        "id": {"stringValue": d["id"]},
        "campaignId": {"stringValue": "project_01"},
        "campaignTitle": {"stringValue": "Visit To Old Age Home"},
        "donorName": {"stringValue": d["donorName"]},
        "category": {"stringValue": d["category"]},
        "quantity": {"stringValue": d["quantity"]},
        "amount": {"doubleValue": float(d["amount"])},
        "amountCash": {"doubleValue": float(d["amountCash"])},
        "amountOnline": {"doubleValue": float(d["amountOnline"])},
        "paymentMethod": {"stringValue": d["paymentMethod"]},
        "description": {"stringValue": d["description"]},
        "receivedBy": {"stringValue": local_id},
        "receivedByName": {"stringValue": "Admin"},
        "receivedAt": {"timestampValue": base_timestamp},
        "createdAt": {"timestampValue": base_timestamp},
    }
    create_root_doc("donations", d["id"], fields)

expenses = [
    {"id": "exp_1", "itemName": "Halwa Poori", "category": "food", "quantity": 35, "unitPrice": 250, "totalAmount": 8750},
    {"id": "exp_2", "itemName": "Cake & Sweets", "category": "food", "quantity": 1, "unitPrice": 4500, "totalAmount": 4500},
    {"id": "exp_3", "itemName": "Mehfil-e-Milaad Setup", "category": "logistics", "quantity": 1, "unitPrice": 4000, "totalAmount": 4000},
    {"id": "exp_4", "itemName": "Transport", "category": "transport", "quantity": 1, "unitPrice": 2136, "totalAmount": 2136},
]

for e in expenses:
    fields = {
        "id": {"stringValue": e["id"]},
        "campaignId": {"stringValue": "project_01"},
        "itemName": {"stringValue": e["itemName"]},
        "category": {"stringValue": e["category"]},
        "quantity": {"integerValue": e["quantity"]},
        "unitPrice": {"doubleValue": float(e["unitPrice"])},
        "totalAmount": {"doubleValue": float(e["totalAmount"])},
        "addedBy": {"stringValue": local_id},
        "addedByName": {"stringValue": "Admin"},
        "createdAt": {"timestampValue": base_timestamp},
    }
    create_root_doc("expenses", e["id"], fields)

b_fields = {
    "id": {"stringValue": "ben_1"},
    "campaignId": {"stringValue": "project_01"},
    "name": {"stringValue": "Old Age Home Residents (Affiat)"},
    "address": {"stringValue": "Multan Afiyat Old Age Home Chungi No.9"},
    "familySize": {"integerValue": 35},
    "itemsReceived": {"stringValue": "Nashta (Halwa, Poori, Chaane) and Cake"},
    "receivedAt": {"timestampValue": base_timestamp},
    "addedBy": {"stringValue": local_id},
}
create_root_doc("beneficiaries", "ben_1", b_fields)

photo_urls = [
    "https://res.cloudinary.com/dcl3q1pcd/image/upload/v1778241355/campaigns/project1/1.jpeg",
    "https://res.cloudinary.com/dcl3q1pcd/image/upload/v1778241354/campaigns/project1/2.jpeg",
    "https://res.cloudinary.com/dcl3q1pcd/image/upload/v1778241355/campaigns/project1/3.jpeg",
    "https://res.cloudinary.com/dcl3q1pcd/image/upload/v1778241354/campaigns/project1/4.jpeg"
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

print("Done inserting to root collections!")
