# SUNYA release setup

## Google account login

The mobile app uses `google_sign_in` and supports build-time `GOOGLE_CLIENT_ID` and `GOOGLE_SERVER_CLIENT_ID` values.

For Android, register the app with Google/Firebase and configure the Android package plus signing SHA. The Google Sign-In Android integration can also read a web OAuth client from `google-services.json`.

Set these GitHub Actions secrets when using Dart defines:

- `GOOGLE_CLIENT_ID`
- `GOOGLE_SERVER_CLIENT_ID`
- `SUNYA_ADMIN_EMAIL` (optional; this account receives SUNYA AI premium access without a subscription)

Without OAuth configuration, the login screen remains visible but sign-in will report that the build is not configured.

## Health Connect

SUNYA requests only data types reported as available by the health plugin. This prevents an unavailable type such as walking/running distance from aborting the entire permission request.

The release workflow declares Health Connect read permissions for the supported health categories. Historical access is declared separately because Android requires an additional permission for data older than 30 days.

## AI providers

The app exposes four choices:

- ChatGPT
- Gemini
- Claude
- SUNYA AI

All provider credentials stay on the backend. The APK never contains provider API keys.

Backend environment variables are documented in `backend/.env.example`.

SUNYA AI currently uses the Gemini backend route as its model provider while the product layer, entitlement and health-context pipeline remain provider-independent. This can be changed to a dedicated SUNYA model later without changing the mobile AI interface.

## SUNYA AI trial and subscription

Product ID:

`sunya_ai_monthly`

The app includes a seven-day SUNYA AI trial state and a Google Play subscription purchase flow. For production billing, create the matching subscription in Google Play Console and configure the introductory seven-day free-trial offer there. The final store price is controlled by Google Play; the current product UI targets roughly ₹79/month.

A production launch should also verify purchase tokens on the backend before granting durable premium entitlement.

## Health intelligence pipeline

The AI context is built from:

1. Google Health Connect data
2. User body profile and body measurement history
3. Body-region measurements
4. Nutrition and meal history
5. Hydration logs
6. Sleep history
7. Deterministic derived metrics such as BMI, BMR, targets and recovery
8. Source/provenance metadata

This context is sent to the selected AI provider only when the user asks an AI question.
