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
split into ordered sections. The generated `backend/supabase-setup.sql` file is
the single deployment bundle (see [backend/README.md](backend/README.md)).

## Backend security deployment

Apply `backend/supabase-setup.sql` after pulling backend schema changes. It is
generated from the ordered `backend/schema/` sections and includes RLS,
least-privilege grants, private profile data, validated activity writes, image
limits, storage policies, and legacy data cleanup. It contains no credentials.
To copy it for the Supabase SQL editor:

```sh
pbcopy < backend/supabase-setup.sql
```

For mobile OAuth, add the following exact redirect URL to the Supabase Auth
allow list before releasing the matching app build:

```text
com.moonstone.timing://login-callback
```

Remove the legacy `timing://login-callback` allow-list entry after all active
builds have migrated.
