# Integrations

**Date:** 2026-04-24

## Firebase Authentication
- Used for user login, registration, and role management.
- Supports distinct roles: `Admin`, `Volunteer`, `Public`.

## Firebase Cloud Firestore
- Serves as the primary NoSQL database.
- Key collections: `users`, `campaigns`, `donations`, `announcements`, `distributions`, `expenses`.
- Web implementation has persistent storage disabled explicitly (`persistenceEnabled: false`) to avoid cross-tab crashing errors (`INTERNAL ASSERTION FAILED`).

## Payment Simulation
- Fake/Simulated payment gateway for demonstration in `PaymentProcessingScreen`.
- Simulates API handshake delays and generates realistic transaction IDs without touching a real bank processor.
