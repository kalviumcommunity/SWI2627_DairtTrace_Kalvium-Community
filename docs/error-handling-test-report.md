# Error Handling — test and defect report

## Scope

Tested the Flutter mobile app's user-visible error handling for Firebase
startup, authentication, collection save/delete operations, sign-out, and
collection-list loading. The auth-gate tests also cover recovery after the
authentication state stream fails.

## Defects found and fixes

| ID | Defect | Fix |
| --- | --- | --- |
| ERR-01 | `mobile/lib/main.dart` and `mobile/test/services/collection_service_test.dart` contained duplicated, interleaved fragments from an incomplete merge, preventing compilation and test discovery. | Restored both files to their last complete versions. |
| ERR-02 | Collection-list failure showed “try again” guidance but provided no way to retry its failed stream. | Added a **Try Again** action that recreates the stream and returns to loading state. |
| ERR-03 | Unrecognized Firebase authentication errors displayed the raw Firebase error message, which could reveal implementation details and was not consistently actionable. | Show a generic retry message for unknown auth errors while preserving specific user-facing messages for known codes. |

## Tests

[`mobile/test/auth_gate_test.dart`](../mobile/test/auth_gate_test.dart) covers
loading, signed-in/signed-out routing, and recovery after an auth stream error.

[`mobile/test/error_handling_test.dart`](../mobile/test/error_handling_test.dart)
covers Firebase startup guidance, mapped and unmapped authentication failures,
unexpected sign-in errors, Firestore permission errors on save, failed
sign-out, permission-denied and unexpected collection-delete failures, and
collection-list retry and recovery. The deletion tests verify backend details
are not exposed to the user.

The existing
[`mobile/test/services/collection_service_test.dart`](../mobile/test/services/collection_service_test.dart)
continues to cover collection fetch, deletion, and timestamp behavior.

## Verification evidence

| Check | Result |
| --- | --- |
| `flutter test test\auth_gate_test.dart test\error_handling_test.dart test\services\collection_service_test.dart` from `mobile\` | **Not run**: blocked because the Flutter executable is not installed or available on `PATH` (`flutter` was not recognized). |
| `flutter analyze` from `mobile\` | **Not run**: blocked because the Flutter executable is not installed or available on `PATH` (`flutter` was not recognized). |
| `git diff --check` | **Passed**. |
| Firebase-backed device test | **Not run**: requires Firebase configuration and a Flutter device/runtime. |
