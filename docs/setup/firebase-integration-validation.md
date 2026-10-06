# Firebase integration validation

## Current status

Firebase is **not currently integrated** into the Flutter app. This is a validation result, not confirmation of a working Firebase connection.

The repository review found:

- `mobile/lib/main.dart` starts the Flutter app without initializing Firebase.
- `mobile/pubspec.yaml` does not declare Firebase Flutter packages.
- The Android app Gradle configuration does not apply the Google Services plugin.
- The iOS app delegate has no Firebase-specific setup.
- No generated `firebase_options.dart`, Android `google-services.json`, or iOS `GoogleService-Info.plist` was found.

As a result, Firebase initialization, project configuration, and runtime configuration-failure behavior could not be exercised.

## Setup requirements

Before Firebase can be validated:

1. Create or select a Firebase project and register each target platform using the app's actual application identifiers.
2. Install the Firebase CLI and FlutterFire CLI, then configure the Flutter app from `mobile/` with `flutterfire configure`. This should generate the platform options used by the app.
3. Add only the Firebase Flutter packages required by the features being implemented. Configure the Android Google Services Gradle plugin and provide the platform-specific Firebase configuration for Android and iOS as generated/provisioned by the setup process.
4. Initialize Flutter and Firebase before `runApp`, using the generated current-platform options. Do not catch initialization errors and continue as though Firebase is available; surface a useful failure so a broken setup is actionable.
5. Keep service-account credentials and other private server credentials out of the client app and repository. Firebase client configuration is not a substitute for correctly configured Firebase security rules.

Follow the official [Flutter setup guide](https://firebase.google.com/docs/flutter/setup) for version-specific package and native project configuration instructions.

## Validation checklist

Once integration and project configuration are in place, verify:

- A normal app launch initializes Firebase exactly once for each platform.
- Each supported target selects its generated platform options.
- Missing generated options or invalid configuration produces an actionable startup failure rather than a silent success or a later, unrelated error.
- Automated tests cover successful startup and the initialization-failure path without depending on a live Firebase project where possible.
- A configured-device smoke test confirms startup against the intended Firebase project. Do not use production data for setup checks.

Run the mobile checks from the `mobile/` directory:

```bash
flutter pub get
flutter analyze
flutter test
```

For a configured target, also launch the app using the appropriate Flutter device/build command and confirm the Firebase project and app identifier are the expected non-production values.

## Validation performed for this repository review

| Check | Result |
| --- | --- |
| Search app and platform setup for Firebase initialization/configuration | No Firebase integration or platform configuration found |
| `flutter test` | Not run: the Flutter executable is unavailable in the review environment |
| `flutter analyze` | Not run: the Flutter executable is unavailable in the review environment |
