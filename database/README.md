# Database Management

This directory contains relational database assets for DairyTrace.

The active DairyTrace backend uses PostgreSQL. This directory also contains supplementary validation material.

## Structure

- `schema/`: Initial DDL definitions, tables, indexes, and constraints.
- `migrations/`: Incremental Flyway / Liquibase or SQL migration scripts.
- `seed/`: Initial seed data (default roles, milk quality parameter thresholds, test cooperative centers, sample farmers).

The active database design is PostgreSQL. The proposed Firestore fixture and its local consistency checks are in `seed/firestore-validation-fixtures.json` and `seed/firestore-validation.test.mjs`; review scope and Firestore-specific gaps are documented in [the Firestore validation review](../docs/database/FIRESTORE-VALIDATION.md). These files do not represent a deployed Firestore schema or security rules.
## Flutter Mobile App Setup

The DairyTrace project includes a Flutter-based mobile frontend for dairy collection and traceability workflows.

### Flutter Environment

- Flutter: 3.47.6
- Dart: 3.13.5
- Flutter channel: Stable
- IDE: Visual Studio Code
- Flutter extension: Dart Code

### Flutter SDK Setup

The Flutter SDK was installed and configured locally for development.

Verify the installation using:

```bash
flutter --version
flutter doctor