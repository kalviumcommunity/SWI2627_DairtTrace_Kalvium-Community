# User Logout — test and defect report

## Scope

Tested the web logout flow in `frontend-legacy`:

- The logout button clears the active session and replaces the current route with `/login`.
- Protected content is not rendered after logout or when no session exists.
- Logout remains navigable when the browser denies access to session storage.
- Session helpers behave consistently when no session exists or browser storage is unavailable.

## Defect found and fix

| ID | Defect | Fix |
| --- | --- | --- |
| LOGOUT-01 | Accessing `window.sessionStorage` can throw a browser `SecurityError` in restricted contexts. The previous availability check accessed the property directly, so logout stopped before redirecting to `/login`. | `getSessionStorage()` now treats only `SecurityError` as unavailable storage. Session checks return false, logout exits safely, and session creation reports the existing explicit unavailable-storage error. Unexpected errors are rethrown. |

When storage access is denied, the browser does not permit the application to remove the stored value. The route guard treats storage as unavailable and does not render protected content.

## Test cases

| Case | Expected result |
| --- | --- |
| Active session, standard logout | Session is cleared and the router replaces the page with `/login`. |
| Protected screen after logout or without a session | Protected content is not rendered and the router redirects to `/login`. |
| Browser throws `SecurityError` when reading session storage | Session check returns false, logout does not throw, and the logout button still redirects to `/login`. |
| Session creation when storage is denied | A clear unavailable-storage error is reported. |
| Logout with no active session or without a browser global | Logout does not throw. |

## Verification evidence

Commands were run from `frontend-legacy`:

| Command | Result |
| --- | --- |
| `npm test -- --run src/services/authService.test.ts src/components/layout/logout.test.tsx` | **Passed** — 2 test files, 8 tests. |
| `npm test -- --run` | **Passed** — 3 test files, 10 tests. |
| `git diff --check` | **Passed** — no whitespace errors. |
| Regression test before the fix | **Failed as expected** — `hasActiveSession()` propagated the simulated browser `SecurityError` while reading `sessionStorage`. |

The Flutter `MilkCollectionPage` sign-out flow is outside this web test run. Flutter is not installed or available on `PATH` in this environment, so no Flutter widget/device test was run.
