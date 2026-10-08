# Firestore structure validation

## Review result

The repository does not currently define or connect to a Firestore database. Its database design and ER diagram describe PostgreSQL, and the backend uses Spring Data JPA with PostgreSQL. There are no Firestore security rules, indexes, emulator configuration, or deployed collections to inspect. This review therefore checks the proposed Firestore fixture against the DairyTrace PRD and documents the gaps that must be resolved before claiming Firestore validation.

The fixture is synthetic and safe for local validation. Its ISO-8601 datetime strings are test interchange values; a Firestore loader must convert datetime fields to `Timestamp`. Date-only values such as `collectionDate`, `batchDate`, and `effectiveFrom` should remain date-only values (or be consistently represented as Firestore timestamps if the application explicitly chooses that convention).

## Candidate collection layout

| Firestore collection | PRD/database-design coverage | Observations |
|---|---|---|
| `users` | FR-01, NFR-01 | Roles and active state are represented. Authentication identity/email and lifecycle timestamps are absent; bind documents to Firebase Auth UIDs and never store client-side password hashes or credentials. |
| `collectionCenters` | FR-02, administrator responsibilities | Code, name, location, status, and timestamps are represented. |
| `farmers` | FR-02, FR-03 | Farmer code, contact, village, center, optional user link, and status are represented. |
| `milkCollections` | FR-03–FR-05, FR-10, FR-12 | Collection identity, farmer/center/operator links, date/time/session/quantity, and batch link support the key trace path. `qualityReadings` is separate, so creating a collection and its required reading must be atomic or have an explicit pending state. |
| `qualityParameters` | FR-06–FR-08 | Configurable SNF minimum is represented. Validate units, active/effective dates, and threshold bounds before use. |
| `qualityReadings` | FR-04, FR-06–FR-08, FR-13 | Fat, SNF, temperature, adulteration, recorder, and time are represented. Using `collectionId` as the document ID enforces one reading per collection when all writes follow that convention. |
| `qualityAlerts` | FR-07, FR-08, FR-13 | Linked alert, observed value, threshold, status, and resolution fields are represented. Alert creation must be atomic with the reading or reliably retried. |
| `batches` | FR-09–FR-13 | Batch status/result and tester metadata are represented. The current fixture points to contributors through each collection's `batchId`; traceability queries require a suitable index and consistent write path. |
| `pricingRules` | FR-14–FR-15 | Rate, quality bounds, and effective dates are represented. Define deterministic precedence and prevent ambiguous overlapping active rules. |
| `reconciliations`, `reconciliationItems` | FR-14, FR-16 | Period and farmer-level totals are represented. Enforce period validity and one item per farmer/reconciliation pair, preferably with deterministic IDs or transactional writes. |
| `disputes` | FR-17–FR-18 | Collection or reconciliation-item dispute and resolution metadata are represented. Validate that exactly one target is supplied and resolution fields are consistent with status. |
| `auditLogs` | FR-16, FR-18–FR-19, NFR-05 | Actor, action, entity, before/after values, reason, and timestamp are represented. Log consequential updates in the same transaction as the change; prevent clients from rewriting/deleting audit history. |

## Requirements and enforcement gaps

Firestore is schemaless and does not provide relational foreign keys or general unique constraints. The fixture's links are strings, not enforced relationships. Security rules can validate authorization and field shapes, but complex cross-document invariants, atomic side effects, uniqueness, and transaction-level business rules must be enforced by trusted backend code (or carefully designed transactions), not assumed from the fixture.

Before using this as a production schema, specify and test:

- Required fields, types, allowed role/status/session values, quantity/range limits, and immutable fields for every document type.
- Firebase Auth UID ownership and role authorization, including least-privilege access to farmer, operator, quality, and manager data.
- Referential checks for farmer, center, operator, collection, batch, reconciliation, and audit references.
- A stable one-reading-per-collection strategy, duplicate collection/batch code prevention, and one reconciliation item per farmer-period.
- Transactional collection + quality-reading + alert workflows and batch/reconciliation finalization + audit workflows.
- Query/index definitions for farmer history, alerts, failed-batch traceability, and reconciliation period lookups.
- Retention/deletion behavior, including avoiding cascades that erase records required for auditability.

The provided `finalized-reconciliation-edit` case currently represents an authorized finalization (`accept-with-audit`); add a separate rejected case for an unauthorized edit and a subsequent mutation of a finalized period.

## Prepared fixture and local checks

`database/seed/firestore-validation-fixtures.json` contains synthetic documents for all 13 proposed collections and nine validation scenarios. It covers valid and invalid collection writes, a threshold-triggered quality alert, orphan/duplicate quality readings, failed-batch traceability, and audited reconciliation finalization.

Run the dependency-free fixture consistency checks from the repository root:

```bash
node --test database/seed/firestore-validation.test.mjs
```

These tests verify fixture shape, unique IDs, reference integrity, supported values, timestamp interchange values, and required validation scenarios. They do **not** execute Firestore security rules, indexes, transactions, or emulator behavior. Those require a concrete Firestore schema/rules implementation and Firebase Emulator Suite configuration.
