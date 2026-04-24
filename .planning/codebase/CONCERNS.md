# Concerns & Tech Debt

**Date:** 2026-04-24

## Web Platform Instability
- **Fixed Issue:** Firestore persistent caching on the web was causing `INTERNAL ASSERTION FAILED` during hot restarts. Disabled via `persistenceEnabled: false`.
- **Ongoing:** Web performance depends heavily on the JS compiler. CanvasKit renderer should be used for better performance if UI stutter occurs.

## Code Quality
- Some provider files (e.g., `campaign_provider.dart`) handle multiple responsibilities. Consider separating logic if it grows further.
- Strict `mounted` checks were retrofitted; any new async UI code must not forget them.

## Payment Simulation
- The gateway is purely a simulation. For real-world deployment, Stripe or Razorpay SDKs must replace the `PaymentProcessingScreen` logic.
