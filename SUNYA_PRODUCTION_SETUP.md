# SUNYA production configuration

## AI providers

Configure these only on the backend. Never ship provider API keys inside the Flutter APK.

- OPENAI_API_KEY
- OPENAI_MODEL (default: gpt-5.6)
- GEMINI_API_KEY
- GEMINI_MODEL (default: gemini-2.5-flash)
- SUNYA_GEMINI_MODEL (default: gemini-2.5-flash)
- ANTHROPIC_API_KEY
- CLAUDE_MODEL
- SUNYA_AI_ENABLED=true

The mobile app sends a normalized health context and selected provider to `/v1/ai/chat`.

## Google account login

Create an Android OAuth client and a server/web OAuth client in Google Cloud.

Configure:
- GOOGLE_CLIENT_ID
- GOOGLE_SERVER_CLIENT_ID
- GOOGLE_WEB_CLIENT_ID on the backend

Register the release SHA-1/SHA-256 fingerprints for the Android application.

The backend verifies Google ID tokens before treating the Google `sub` claim as the stable account identifier.

## Health Connect

SUNYA requests only data types used by the current health engine. The app checks feature availability before requesting each type, so one unsupported data type does not block the complete permission flow.

For Google Play publication, complete the Health Connect data-access declaration and provide a user-facing justification for each sensitive health permission.

Medical Records/FHIR is intentionally a separate Android-native phase because Health Connect exposes it through Jetpack's native Medical Records API rather than the current Flutter health abstraction.

## SUNYA AI subscription

Initial product ID:
- `sunya_ai_monthly`

Launch pricing target:
- ₹99/month

Trial:
- 7 days

The Flutter client contains the Play Billing purchase flow. Durable entitlement must be granted only after server-side purchase verification before production launch. Configure the subscription and its free-trial offer in Google Play Console.

## Recommended release flow

1. Configure Google OAuth credentials.
2. Configure AI provider secrets on the backend.
3. Create `sunya_ai_monthly` in Play Console.
4. Configure the 7-day introductory offer.
5. Complete Health Connect declarations.
6. Build a signed Android App Bundle/APK.
7. Test Google login, Health Connect permissions, AI providers, trial and restore-purchase flows on a real device.
8. Verify the final CI run and artifact before distribution.
