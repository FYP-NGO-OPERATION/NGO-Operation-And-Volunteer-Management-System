# Architecture

**Date:** 2026-04-24

## Pattern: MVCS / Provider Pattern
- **Models:** Strong-typed Dart classes with `fromJson`/`toJson` for Firestore mapping (`lib/models/`).
- **Views:** Stateful and Stateless widgets separated into screens and reusable widgets (`lib/screens/`, `lib/widgets/`).
- **Controllers/Providers:** `ChangeNotifier` classes handling business logic and exposing state (`lib/providers/`).
- **Services:** Pure Dart classes wrapping Firebase SDK calls, avoiding context dependencies (`lib/services/`).

## Web & Desktop Support
- Responsive UI paradigms implemented:
- `AdminLayout` utilizes `NavigationRail` for wide screens (desktop/web) and `Drawer` for narrow screens (mobile).
- Async gap protection is strictly enforced (`if (!mounted) return;`) across UI handlers.
