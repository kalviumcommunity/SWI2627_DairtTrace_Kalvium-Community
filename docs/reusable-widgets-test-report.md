# Reusable Widgets – Test and defect report

## Feature under test

The DairyTrace session guard and reusable layout widget flow were validated around the authenticated screen controls:

- `ProtectedScreen` keeps protected content behind a valid session.
- `LogoutButton` clears the browser session and redirects to `/login`.
- `ReusableWidget` provides a reusable card container for dashboard and status panels.

## Defect identified

The browser session helpers were using `window.sessionStorage` directly. This works in a browser, but it breaks in non-browser contexts where `window` is unavailable (for example, server-side rendering or other runtime sandboxes). The failure mode is a runtime exception before the guard can redirect or clear the current session.

## Fix implemented

The session storage access is now guarded in [frontend-legacy/src/services/authService.ts](../frontend-legacy/src/services/authService.ts):

- `hasActiveSession()` returns `false` when storage is unavailable.
- `logout()` exits gracefully when the browser environment is absent.
- `startSession()` still validates the incoming token, but now throws a clear environment error instead of crashing with a `ReferenceError`.

The reusable widget shell was also added in [frontend-legacy/src/components/ui/ReusableWidget.tsx](../frontend-legacy/src/components/ui/ReusableWidget.tsx), with a test suite in [frontend-legacy/src/components/ui/ReusableWidget.test.tsx](../frontend-legacy/src/components/ui/ReusableWidget.test.tsx).

## Verification

Command run:

```bash
cd "c:\Study Material\Simulated Work\SWI2627_DairtTrace_Kalvium-Community\frontend-legacy" && npm test -- --run
```

Result:

- 3 test files passed
- 8 tests passed
- Exit code: 0

This confirms the session guard, logout flow, and reusable widget checks all pass with the fix in place.
