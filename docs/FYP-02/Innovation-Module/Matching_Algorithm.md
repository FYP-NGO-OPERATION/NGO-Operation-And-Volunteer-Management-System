# Smart Matching Algorithm — Technical Documentation

## Overview

The HRAS Smart Matching Algorithm recommends campaigns to volunteers based on a weighted scoring model. It is designed to be **real, explainable, and transparent** — not black-box AI.

## Algorithm

### Scoring Formula

```
Total Score = (Skill Score × 0.50) + (Location Score × 0.30) + (Availability Score × 0.20)
```

### Factor 1: Skills Match (50%)

Maps each user skill keyword to relevant `CampaignType` values.

**Scoring:**
- **1.0** → Multiple skills match the campaign type
- **0.7** → One skill matches
- **0.3** → User has no skills listed (neutral)
- **0.1** → Has skills but none match this campaign type

**Example:**
- User skills: `["medical", "first aid"]`
- Campaign type: `Medical`
- Result: 1.0 (two skills match)

### Factor 2: Location Match (30%)

Compares user address with campaign location using string matching.

**Scoring:**
- **1.0** → Same city detected (e.g., both contain "Multan")
- **0.8** → Partial string containment
- **0.3** → User has no address (neutral)
- **0.1** → Different locations

**Supported cities:** Multan, Lahore, Karachi, Islamabad, Rawalpindi, Faisalabad, Peshawar, Quetta, Hyderabad, Sialkot, Gujranwala, Bahawalpur, Sargodha, Sahiwal, Dera Ghazi Khan.

### Factor 3: Availability (20%)

Checks if the volunteer is already registered for the campaign.

**Scoring:**
- **1.0** → Not registered (available)
- **0.0** → Already registered

## Quality Labels

| Score | Label |
|-------|-------|
| ≥ 80% | Excellent Match |
| ≥ 60% | Good Match |
| ≥ 40% | Fair Match |
| < 40% | Low Match |

## Implementation

- **File:** `lib/services/matching_service.dart`
- **Model:** `lib/models/match_result_model.dart`
- **Screen:** `lib/screens/campaigns/recommended_campaigns_screen.dart`
- **Feature Gate:** `FeatureFlags.isSmartMatchingEnabled`

## Limitations

1. Location matching is string-based, not GPS-based
2. Skill matching depends on user profile completeness
3. No historical performance data is used (future enhancement)
4. No machine learning — purely rule-based weighted scoring
