<!-- markdownlint-disable -->
NDIS Connect (Flutter)
======================

Accessible, role-based companion for NDIS participants and providers. WCAG 2.2 AA-minded design with voice-over semantics, high-contrast themes, resizable text, and offline-first patterns. Backend via Firebase; maps via Google Maps; chatbot via Dialogflow.

BMAD Delivery Plan
------------------
- Blueprint: Define IA, roles, core flows, data model, and a11y targets.
- Make: Scaffold Flutter app, core dashboards, calendar, budget, settings.
- Assess: Run a11y checks (contrast, semantics, focus), verify flows offline.
- Deliver: Wire Firebase, Maps, Dialogflow, harden security, prepare store builds.

What’s Included (v0.1)
----------------------
- Dual dashboards (participant, provider) with MyChart-style cards.
- Smart Scheduling (lightweight month grid, quick booking, streak points).
- Budget Tracker (buckets, alerts at 80%, simple pie).
- Accessibility toggles (theme, high contrast, text size, reduce motion).
- Firebase initialization stub + placeholders for Chat (Dialogflow) and Maps.

New in this iteration
---------------------
- Freemium feature guard and paywall component.
- Purchase service scaffolding (in_app_purchase) with demo unlock.
- Chatbot screen (text + voice input) using placeholder responses.
- Service Map with wait-time and accessibility filters (Google Map widget).
- Support Circle: Trello-like board for goals + basic chat.
- Plan Snapshot timeline with PDF export (printing/pdf packages).
- Smart Plan Checklist with priorities and reward toasts.
- Gamification controller: points, streaks, and badges state persisted locally.
- Notifications: Firebase Messaging + local notifications for foreground.

## Prerequisites
- Flutter SDK installed
- Xcode (iOS) and Android SDKs
- Firebase project and FlutterFire CLI

## Setup
1) Create missing platform folders (since this repo was scaffolded without `flutter create`):
   flutter create .

2) Install dependencies:
   flutter pub get

3) Configure Firebase (adds lib/firebase_options.dart):
   dart pub global activate flutterfire_cli
   flutterfire configure

4) Google Maps API keys:
   - Android: add your key to android/app/src/main/AndroidManifest.xml under <application>
     <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY"/>
   - iOS: add to ios/Runner/AppDelegate.swift or Info.plist (GMSApiKey).

5) Run the app:
   flutter run

6) Optional billing/freemium
   - Toggle premium features for dev: set `FeatureFlags.isPremiumEnabled = true` in `lib/core/feature_flags.dart`.
   - For production, add App Store Billing/Google Play Billing and gate via server flags.

7) Dialogflow integration (optional)
   - Host a lightweight HTTPS endpoint (e.g., Cloud Function) that proxies Dialogflow.
   - Launch with:
     flutter run --dart-define=DIALOGFLOW_ENDPOINT=https://your-function/ask --dart-define=DIALOGFLOW_AUTH="Bearer XYZ"

6) Optional: Enable Firestore offline persistence (on by default in mobile). Ensure network rules:
   - Use Firebase Security Rules to restrict per user/role.

Dialogflow (Chatbot)
--------------------
- Replace lib/services/chat_service.dart with a Dialogflow ES/CX integration via REST or Cloud Functions.
- Add voice input with speech_to_text and optional TTS. Respect OS-level screen readers.

Security & Privacy
------------------
- End-to-end encryption for support circle notes is scaffolded (see cryptography dep). Derive keys with PBKDF2 and store key material safely (flutter_secure_storage). Never commit secrets.

Accessibility (WCAG 2.2 AA)
---------------------------
- High-contrast theme toggle
- Resizable text (80%–180%)
- Minimum tap target sizes (>=48px)
- Semantic labels and focusable controls
- Reduce motion option

Next Steps
----------
- Wire Firebase Auth (myGov linking strategy), Firestore models, and FCM.
- Implement Service Map with filters + offline caching.
- Support Circle (permissions, real-time updates, E2E notes).
- Plan Snapshot export to PDF and share sheet.
- Freemium gating (basic vs premium AI features).

Security Notes
--------------
- Replace placeholder Firebase options via `flutterfire configure`.
- Add Firebase Rules enforcing participant/provider roles and least privilege.
- Never commit API keys. Use secrets and build-time config for Maps keys.
- For notifications on iOS, add push entitlements/APNs. On Android 13+, the plugin requests POST_NOTIFICATIONS permission.

Folder Structure
----------------
- lib/
  - controllers/ (state: auth, settings)
  - models/ (budget, appointment)
  - screens/ (dashboards, calendar, budget)
  - services/ (firebase, auth, chat, maps)
  - theme/ (AppTheme)
  - widgets/ (IconCard, BudgetPie)
