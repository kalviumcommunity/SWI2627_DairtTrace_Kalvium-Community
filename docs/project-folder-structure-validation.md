# Project Folder Structure Validation

## Defect summary

The repository documentation described the web frontend as a Next.js app under `frontend/`, but the repository layout shows that:

- `frontend-legacy/` is the active Next.js + React project
- `frontend/` is a Flutter web/desktop project
- `mobile/` is a separate Flutter mobile project

This mismatch created a misleading project view and could lead to wrong setup or maintenance decisions.

## Root cause

The root `README.md` was manually documenting a folder structure that did not reflect the actual repository layout on disk. The docs also used machine-specific absolute links to a local path rather than repository-relative documentation links.

## Fix applied

- Corrected the project tree in [README.md](../README.md)
- Updated the setup links to repository-relative paths
- Clarified that the active legacy web app lives in `frontend-legacy/` and that `frontend/` and `mobile/` are separate Flutter implementations

## Validation evidence

Command run from the repository root:

```bash
node --test database/seed/*.test.mjs
```

Result:

```text
✔ Firestore milk collection samples expose the current backend mapping edge cases (0.9253ms)
✔ fixture has unique document IDs and the expected DairyTrace collections (1.7629ms)
✔ seed references resolve and quality-reading uniqueness is respected (0.8394ms)
✔ collection, quality, batch, and period values satisfy the fixture's domain constraints (9.3306ms)
✔ validation cases cover representative acceptance, rejection, and workflow outcomes (0.4915ms)
✔ collection edit scenarios validate updates and read back the changed fixture state (0.9801ms)

ℹ tests 6
ℹ pass 6
ℹ fail 0
```

This confirms the project structure documentation fix did not introduce regressions in the repository's validation checks.
