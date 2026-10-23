# Forms — test and defect report

## Scope

Tested form logic in the Flutter mobile app:

- Sign-in and registration email/password validation.
- Milk collection farmer-name and quantity validation.
- Collection form submission and validation wiring.

The standalone Flutter `frontend` prototype contains no data-entry form; the tested implementation is in [`mobile/lib/main.dart`](../mobile/lib/main.dart).

## Defects found and fixes

| ID | Defect | Fix |
| --- | --- | --- |
| FORM-01 | `mobile/lib/main.dart` contained duplicated/partially merged code, including invalid class-body code, malformed widget arguments, repeated named arguments, duplicate theme properties, and an incomplete auth gate. This prevented the app from compiling and blocked form testing. | Removed the duplicate fragments and restored one valid auth gate, login form, splash transition, and collection form/list layout. |
| FORM-02 | Form validation was embedded inline in duplicated field definitions, so the collection UI had inconsistent validation messages and was difficult to test independently. | Centralized the existing validation rules in [`mobile/lib/form_validators.dart`](../mobile/lib/form_validators.dart) and connected each form field to the shared functions. |
| FORM-03 | Collection-list error UI supplied two `child` arguments to one `Padding`, which is invalid. | Kept one user-facing error message while preserving diagnostic logging. |

## Test cases added

Eight unit tests in [`mobile/test/form_validators_test.dart`](../mobile/test/form_validators_test.dart) cover:

| Area | Cases |
| --- | --- |
| Email | Missing, malformed, and valid addresses with surrounding whitespace. |
| Password | Missing values; short registration password rejected; the same short password allowed for sign-in; valid registration password accepted. |
| Farmer name | Missing, too short, invalid characters, and a valid trimmed name. |
| Milk quantity | Missing, malformed, zero, negative, non-finite, and valid positive decimal input. |

## Verification evidence

| Check | Result |
| --- | --- |
| Workspace diagnostics for `mobile/lib/main.dart`, `mobile/lib/form_validators.dart`, and `mobile/test/form_validators_test.dart` | **No errors found** by the available Problems check. |
| `git diff --check` | **Passed** (exit code 0; no whitespace errors). |
| `flutter analyze` from `mobile/` | **Not run**: the Flutter executable is unavailable (`flutter` is not recognized as a command). |
| `flutter test test\form_validators_test.dart` from `mobile/` | **Not run**: blocked by the same missing Flutter executable (exit code 1). |
| Manual Firebase-backed form submission | **Not run**: requires a Flutter runtime and configured Firebase services. |

The unit tests have been added but not executed in this environment. Run the two blocked Flutter commands from the `mobile/` directory after installing the Flutter SDK to complete runtime verification.
