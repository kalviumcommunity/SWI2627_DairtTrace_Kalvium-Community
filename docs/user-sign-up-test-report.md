# User Sign Up — test and defect report

## Scope

Tested the Flutter mobile registration flow in
[`mobile/lib/main.dart`](../mobile/lib/main.dart):

- Switching from sign-in to account creation.
- Required and malformed email validation.
- Registration-only minimum password length.
- Successful Firebase account-creation request with a trimmed email.
- User-facing handling of duplicate-email and weak-password responses.

## Defects found and fixes

| ID | Defect | Fix |
| --- | --- | --- |
| SIGNUP-01 | Duplicate and orphaned fragments in the shared app entry point prevented the authentication screen from compiling. The sign-up email field also declared two validators, and its title declared two `style` arguments. | Removed the malformed duplicate fragments and retained the shared email/password validators, one title style, and one authentication screen implementation. Cleaned adjacent duplicated widget fragments that blocked compiling the app containing sign-up. |
| SIGNUP-02 | No widget tests exercised account creation from the registration screen, so UI validation, submitted credentials, and Firebase registration errors were not verified. | Added focused tests in [`mobile/test/sign_up_test.dart`](../mobile/test/sign_up_test.dart) using a mocked Firebase Auth client. |

## Test cases added

| Case | Expected result |
| --- | --- |
| Empty email and password | Required-field messages appear; Firebase is not called. |
| Malformed email and password under six characters | Validation messages appear; Firebase is not called. |
| Valid registration form | Calls Firebase once with a whitespace-trimmed email and the entered password. |
| Firebase reports `email-already-in-use` | Displays “This email is already registered.” |
| Firebase reports `weak-password` | Displays “Choose a stronger password.” |

The success and failure cases also check the form returns from its loading state.

## Verification evidence

| Check | Result |
| --- | --- |
| `flutter test test\sign_up_test.dart` from `mobile\` | **Blocked**: Flutter is not installed or available on `PATH` (`flutter` was not recognized). |
| `flutter analyze` from `mobile\` | **Blocked**: Flutter is not installed or available on `PATH` (`flutter` was not recognized). |
| `git diff --check` | **Passed**: no whitespace errors. |
| Firebase-backed device registration | **Not run**: requires a configured Firebase project and Flutter device/runtime. |

The widget tests are added but could not be executed in this environment. Run
the two Flutter commands from `mobile\` in an environment with the Flutter SDK
to complete runtime verification.
