# accounting_software

A new Flutter project.

## Configuration

Client settings are injected at build time and are **not** committed:

1. Copy the example file:
   `cp config/dart_defines.example.json config/dart_defines.json`
2. Fill in the values (JSON has no comments, so the rules are here):
   - `SUPABASE_URL` and `SUPABASE_ANON_KEY` — **required** on every platform.
     The app refuses to start without them. Only the public anon key belongs
     here; never the `service_role` key.
   - `GOOGLE_CLIENT_ID` — the OAuth *Web* client ID from Google Cloud Console.
     **Required on Web** (the app refuses to start without it). On Android/iOS
     it may stay empty; the platform configuration is used instead.
3. Run with the file:
   `flutter run --dart-define-from-file=config/dart_defines.json`

`config/dart_defines.json` is git-ignored.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
