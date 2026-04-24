# Structure

**Date:** 2026-04-24

## Directory Layout
- `lib/`
  - `enums/` - Application-wide enumerations (Roles, Statuses).
  - `models/` - Data definitions.
  - `providers/` - State management controllers (e.g. `AuthProvider`).
  - `screens/` - UI pages organized by feature (auth, campaigns, admin, donations).
  - `services/` - Firestore and Backend communication.
  - `utils/` - Helpers (Colors, constants).
  - `widgets/` - Reusable UI components (Navbar, Sidebar, custom buttons).

## Entry Point
- `lib/main.dart` - Initializes Firebase, sets up multi-providers, defines routing, and selects initial screen based on `AuthState`.
