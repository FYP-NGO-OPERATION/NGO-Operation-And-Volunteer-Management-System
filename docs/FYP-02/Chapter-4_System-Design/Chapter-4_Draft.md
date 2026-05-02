# Chapter 4: System Design & Specification

## 4.1 Introduction

This chapter presents the detailed system design and specification for the FYP-02 advanced features: Smart Matching Algorithm, QR Attendance System, and Push Notifications (FCM). Each subsystem is designed to integrate seamlessly with the existing FYP-01 architecture.

## 4.2 Smart Matching Algorithm

### 4.2.1 Algorithm Design

The matching algorithm uses a **weighted scoring model** to recommend campaigns to volunteers:

| Factor | Weight | Description |
|--------|--------|-------------|
| Skills Match | 50% | Maps user skills to campaign type compatibility |
| Location Match | 30% | String-based city/area comparison |
| Availability | 20% | Bonus if not already registered for the campaign |

**Formula:**
```
score = (skillMatch × 0.50) + (locationMatch × 0.30) + (availabilityBonus × 0.20)
```

### 4.2.2 Skill-to-Campaign Type Mapping

| Skill Keywords | Mapped Campaign Types |
|---------------|----------------------|
| medical, healthcare, doctor, nursing, first aid | Medical |
| teaching, education, tutoring | Education |
| cooking, food | Ration, Ramadan, Eid |
| logistics, driving, distribution | Ration, Winter Drive |
| environment, gardening | Plantation, Water Birds |
| childcare, social work | Orphanage, Education |

### 4.2.3 Match Quality Levels

| Score Range | Quality Label |
|-------------|--------------|
| 80–100% | Excellent Match |
| 60–79% | Good Match |
| 40–59% | Fair Match |
| 0–39% | Low Match |

## 4.3 QR Attendance System

### 4.3.1 Architecture

```
Admin generates QR → QR contains JSON payload → Volunteer scans with camera
→ System parses payload → Verifies registration → Marks attendance in Firestore
```

### 4.3.2 QR Payload Structure

```json
{
  "type": "hras_attendance",
  "campaignId": "abc123",
  "campaignTitle": "Winter Drive 2025",
  "generatedAt": "2025-12-01T10:00:00Z"
}
```

### 4.3.3 Scan Result States

| State | Condition |
|-------|-----------|
| ✅ Success | Volunteer registered + not yet attended |
| ❌ Not Registered | Volunteer not found for this campaign |
| ⚠️ Already Attended | Status already marked as 'attended' |
| ❌ Invalid QR | QR code is not from HRAS system |

## 4.4 Push Notifications (FCM)

### 4.4.1 Architecture

1. App requests notification permission on login
2. FCM token is stored in user's Firestore document
3. User subscribes to `campaigns` topic
4. Server (or Cloud Function) sends notifications to topic/token
5. App handles foreground messages via `onMessage` listener

### 4.4.2 Notification Scenarios

| Trigger | Target | Message |
|---------|--------|---------|
| New campaign created | All volunteers (topic) | "New campaign: {title}" |
| Volunteer assigned | Individual (token) | "You've been assigned to {title}" |
| Campaign status change | Registered volunteers | "Campaign {title} is now {status}" |

## 4.5 Data Flow Diagram

```
┌──────────────┐     ┌─────────────────┐     ┌──────────────┐
│   Volunteer  │────▶│ Matching Engine  │────▶│ Recommended  │
│   Profile    │     │ (Score + Rank)   │     │  Campaigns   │
└──────────────┘     └─────────────────┘     └──────────────┘

┌──────────────┐     ┌─────────────────┐     ┌──────────────┐
│  Admin (QR)  │────▶│  QR Generator   │────▶│   Display    │
│  Campaign    │     │  (JSON Payload) │     │  QR Code     │
└──────────────┘     └─────────────────┘     └──────────────┘

┌──────────────┐     ┌─────────────────┐     ┌──────────────┐
│  Volunteer   │────▶│  QR Scanner     │────▶│  Firestore   │
│  (Camera)    │     │  (Parse + Mark) │     │  Attendance  │
└──────────────┘     └─────────────────┘     └──────────────┘
```

## 4.6 Chapter Summary

This chapter specified the three core FYP-02 features: a weighted matching algorithm with explainable scoring, a QR-based attendance system with secure JSON payloads, and FCM push notification integration with topic-based routing. All features are designed to integrate with existing Firestore collections and are gated behind compile-time feature flags.
