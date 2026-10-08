# Database Management

This directory contains relational database assets for DairyTrace.

The active DairyTrace backend uses PostgreSQL. This directory also contains supplementary validation material.

## Structure

- `schema/`: Initial DDL definitions, tables, indexes, and constraints.
- `migrations/`: Incremental Flyway / Liquibase or SQL migration scripts.
- `seed/`: Initial seed data (default roles, milk quality parameter thresholds, test cooperative centers, sample farmers).
- `firestore/`: Synthetic validation fixtures for the proposed Firestore mapping. These are not a Firestore schema, emulator import, or production seed; Firebase is not currently integrated.

See [Firestore validation](../docs/database/FIRESTORE-VALIDATION.md) for the structure review, known gaps, and fixture usage.

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