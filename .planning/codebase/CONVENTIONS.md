# Conventions

**Date:** 2026-04-24

## Code Style
- Strict adherence to `flutter_lints`.
- All `BuildContext` usage across async gaps must be protected with `if (!mounted) return;`.

## Data Handling
- Subscriptions to Firestore streams must be explicitly cancelled in `dispose()` to prevent memory leaks, especially crucial for Web builds.

## Privacy Rules
- UI masking applied dynamically. Example: Donors' real names are hidden (replaced with "Anonymous Donor") from public/volunteer views, while admins retain full visibility.
