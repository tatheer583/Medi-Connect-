# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased] — 2026-10-24 (round 2)
- **Brand logo:** new MediConnect icon (rounded-square brand gradient, white
  medical cross with heartbeat pulse) generated as vectors via golden tests
  (`test/logo_golden_test.dart` → `tool/copy_logo_assets.ps1`); applied to
  Android launcher icons, web favicon/PWA icons, in-app splash, and README.
- **Dashboard upgrade:** time-based greeting; next-appointment hero card with
  date badge and "Today/Tomorrow/in N days" chip; three live stat chips
  (appointments, prescriptions, reminders); email-verification banner with
  working Resend (dismissible); lists now show only upcoming, non-cancelled
  appointments; doctor schedule shows today/pending/upcoming counts and
  "Today" badges.
- **Doctor availability toggle:** doctors can go visible/hidden in the
  patient directory in real time (writes the `available` flag; booking
  buttons disable for hidden doctors).
- **Auth-state fix (keepAlive):** the Riverpod auth state was auto-disposed
  on screen transitions, so dashboards hydrated empty (missing name/userId).
  `AuthService` and the router are now `keepAlive: true` (generated files
  updated by hand — build_runner is currently incompatible with the Dart 3.13
  SDK's analyzer; see note below).
- **Session-adoption login:** signing in while a valid Appwrite cookie
  session exists no longer errors ("session is active") — the app adopts the
  active session instead.
- **Session handling on web:** Appwrite keeps the session in a shared
  browser cookie and refuses to open a second one ("session is active"),
  which made login — and worst, registration — fail after a previous sign-in
  on the same browser. Both flows now replace the stale session with the
  credentials entered (`_establishSessionFor`), so registering or switching
  accounts always works.
- **Doctor search:** live debounced search (450 ms) with clear button.

> Build note: `dart run build_runner` currently crashes with this toolchain
> (riverpod_generator 2.6.x pins an analyzer older than the Dart 3.13 SDK
> syntax). If providers change, hand-edit the `.g.dart` files or upgrade to
> riverpod_generator 3.x.

## [Unreleased] — 2026-10-24
- **Real doctor directory:** doctor sign-up now publishes the doctor to the
  `doctors` collection (specialty + consultation fee collected at
  registration); demo doctor list removed from search — the directory is
  100% live Appwrite data with specialty filter chips, availability badges
  and "New" (unrated) badges.
- **Passwordless sign-in:** new "Sign in with Email Code" flow on the login
  screen using Appwrite email-OTP (real 6-digit code emailed and verified
  server-side). The old self-verifying OTP demo screen was replaced.
- **Email verification:** registration sends a real Appwrite verification
  email; new `/verify-email` deep-link route completes it in-app.
- **Password reset end-to-end:** reset links now deep-link to the deployed
  web app's `/reset-password` route where the user sets a new password
  (`updateRecovery`); the dead `mediconnect.app` fallback URL was removed.
- **Clinic setup syncs to cloud:** practice name/phone persist to the
  `users` collection (previously device-only preferences).
- **Startup crash fix:** `AppwriteService` no longer resolves its own
  `client` getter over the global client (infinite recursion at init);
  every service method now auto-initializes.
- **Database indexes:** `setup_appwrite.ps1` now creates the fulltext index
  on `doctors.name` (required for `Query.search`) and key indexes for all
  ordering/filter queries.

## [v1.0.0] - 2026-07-07
- Initial stable release published to GitHub.
- Added GitHub Actions for automated APK building and CI workflows.
- Mobile: Flutter client improvements and assets.
- Backend: Node.js/TypeScript API and Appwrite integration.

## Tags pushed
- `v1.0.0`
- `v1.0.0-20260707020741` (timestamped)

---

For details on changes between releases, see the releases page on GitHub: https://github.com/tatheer583/Medi-Connect-/releases
