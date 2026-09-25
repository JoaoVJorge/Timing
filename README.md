# Timing

Flutter app for focus sessions, reading, daily goals, schedules and shared
group progress.

## Local setup

1. Install the Flutter SDK required by `pubspec.yaml`.
2. Fill `lib/env/debug.env` with the Supabase project URL and publishable key
   when backend integration is needed.
3. Run `flutter pub get`.
4. Start the configured development app with
   `flutter run --dart-define-from-file=lib/env/debug.env`. A plain
   `flutter run` starts without backend integration.

Environment files are compile-time inputs and are not bundled as generic asset
directories. For release builds, pass `lib/env/prod.env` through
`--dart-define-from-file`, for example:

```sh
flutter build apk --release --dart-define-from-file=lib/env/prod.env
```

A release build fails during startup when the Supabase configuration is
missing, preventing a backendless binary from being published silently. The
complete backend schema and security configuration are kept in `backend/schema/`,
split into ordered sections (see [backend/README.md](backend/README.md)).

## Backend security deployment

Apply the `backend/schema/` sections, in order, after pulling schema changes.
They are idempotent and include RLS, least-privilege grants, private profile
data, validated activity writes, image limits, storage policies, and legacy
data cleanup. They contain no credentials. To apply everything in one paste,
copy the concatenated sections:

```sh
cat backend/schema/*.sql | pbcopy
```

For mobile OAuth, add the following exact redirect URL to the Supabase Auth
allow list before releasing the matching app build:

```text
com.moonstone.timing://login-callback
```

Remove the legacy `timing://login-callback` allow-list entry after all active
builds have migrated.
