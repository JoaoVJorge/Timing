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
complete backend schema and security configuration are kept in the single
`backend/supabase-setup.sql` file.
