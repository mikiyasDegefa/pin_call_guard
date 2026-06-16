# PIN Call Guard

A simple Flutter Android app that lets you protect specific outgoing phone
numbers with a PIN. When you dial a protected number from the app's built-in
dialer, you'll be asked to enter your PIN before the call is placed. Other
numbers dial normally.

## Features

- Set/change a PIN (stored as a SHA-256 hash on-device only)
- Add protected numbers from your contacts or manually
- Remove protected numbers (requires PIN)
- Built-in dialer screen — protected numbers prompt for PIN before calling

## How it works

This is a self-contained app: it does **not** intercept the system dialer or
calls made from other apps. You use this app's own dialer screen to place
calls. If the number you dial matches one in your protected list, you'll be
asked for the PIN first.

## Building

### Locally
```bash
flutter pub get
flutter build apk --release
```
The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

### Via GitHub Actions
Push to `main` or run the "Build APK" workflow manually from the Actions tab.
Two artifacts are produced:
- `pin-call-guard-debug` — debug APK, easiest to install for testing
- `pin-call-guard-release` — release APK (unsigned, uses debug signing config
  for convenience — replace with your own signing config before publishing)

Download the artifact zip, extract the `.apk`, and install it on your Android
device (enable "install from unknown sources" if prompted).

## Permissions

- `CALL_PHONE` — to place calls from the in-app dialer
- `READ_CONTACTS` — to pick numbers from your contacts when adding protected
  entries

## Notes

- Minimum Android SDK: 23 (Android 6.0)
- The PIN is stored locally via `shared_preferences` as a hash; it never
  leaves the device.
