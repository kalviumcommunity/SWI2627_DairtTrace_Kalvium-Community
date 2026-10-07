# Firestore Structure Validation

## Validation result

**Status: not validated against a deployed Firestore database.** The repository currently documents and configures PostgreSQL for the Spring Boot backend. It contains no Firestore schema, Firebase configuration, Firestore Security Rules, composite-index definitions, emulator setup, or Firestore SDK integration. The structure below is therefore a requirements-based proposal, not an existing implementation.

The review used the DairyTrace requirements in [PRD.md](../../PRD.md), the relational model in [DATABASE-DESIGN.md](DATABASE-DESIGN.md), and the current backend persistence configuration. The PRD's principal integrity chain is:

```text
Farmer → Collection → Quality Reading → Batch → Reconciliation
```

### Findings against the requirements

| Requirement | Firestore validation observation | Result |
|---|---|---|
| Record users, farmers, centers, collections, quality readings, alerts, batches, pricing, reconciliation, disputes, and audit history | These entities exist in the relational design, but no Firestore collections or documents are implemented. | Not implemented |
| Required collection ownership, timestamp, center, session, and quantity | A Firestore document can carry these fields, but no deployed schema or write validator enforces them. | Not validated |
| Quality thresholds and alerts | The PRD requires configurable thresholds and linked alerts; no Firestore threshold documents or alert workflow exists. | Not implemented |
| Batch-to-collection-to-farmer traceability | Firestore has no foreign keys. Reference existence and consistency must be checked by trusted application code; no such Firestore checks exist here. | Not validated |
| Reconciliation finalization and auditability | No Firestore transaction, authorization policy, immutable audit workflow, or emulator test exists. | Not implemented |
| Search and query performance | No Firestore query definitions or composite indexes exist to check against the expected filters. | Not validated |
| Access control | No Firestore Security Rules or Firebase Authentication integration exists. | Not implemented |

## Proposed Firestore mapping for future validation

Use top-level collections to keep records independently queryable and avoid unbounded arrays. Suggested document paths:

```text
users/{authUid}
farmers/{farmerId}
collectionCenters/{centerId}
milkCollections/{collectionId}
qualityReadings/{collectionId}
qualityAlerts/{alertId}
batches/{batchId}
qualityParameters/{parameterId}
pricingRules/{pricingRuleId}
reconciliations/{reconciliationId}
reconciliationItems/{reconciliationItemId}
disputes/{disputeId}
auditLogs/{auditLogId}
```

Store document references as stable IDs (or Firestore `DocumentReference` values consistently); do not duplicate the same relationship in multiple writable arrays. For the proposed mapping, `milkCollections.batchId` is the single batch link and batch traceability is a query on `milkCollections` by `batchId`. If the product later allows a collection to be split across batches, model that as a separate link collection rather than an unbounded batch array.

Suggested field and integrity rules:

- Use Firestore `Timestamp` for event and audit times, and numeric values for quantity, percentages, and rates. The JSON fixture uses ISO-8601 strings only for portability and must be converted by a test harness.
- Keep authentication credentials in Firebase Authentication, not user profile documents. Store only the profile and role data needed by the application.
- Validate required fields, value types, allowed enums (`MORNING`/`EVENING`, lifecycle statuses), positive quantity, and date consistency in trusted backend code.
- Enforce unique business codes and one quality reading per collection transactionally. Firestore does not provide relational unique constraints.
- On every write, validate that related farmer, center, operator, batch, and reconciliation documents exist and that their IDs and center/session/date values are consistent. Firestore does not provide foreign keys.
- Create the quality alert when a configured threshold is violated, in the same trusted workflow as the reading write where practical. A below-threshold reading is valid data, not a rejected write.
- Finalize reconciliations and write their audit record atomically. Deny unauthorized client writes through Security Rules; keep privileged backend/service-account credentials server-side.
- Before shipping, derive composite indexes from actual query shapes (for example collections by `farmerId` and `collectionDate`, collections by `centerId` and `collectionDate`, and collections by `batchId`), then verify them against the Firestore emulator or a non-production project.

## Synthetic validation data

[validation-fixtures.json](../../database/firestore/validation-fixtures.json) contains a synthetic end-to-end scenario and acceptance/rejection cases for:

- A collection with required ownership, center, operator, session, timestamp, and quantity fields.
- A below-threshold SNF reading and its associated open quality alert.
- A failed batch whose contributing collections can be followed back to both farmers.
- Pricing, open reconciliation, dispute, and audit documents.
- Missing references, invalid session, zero quantity, orphan/duplicate reading, and authorized reconciliation finalization.

The fixture contains no production identifiers or credentials. It is test input only; it is not a Firebase emulator import, deployment seed, or proof that Firestore rules enforce these outcomes. `accept-with-alert` and `accept-with-audit` require application workflow assertions in addition to document-write checks.

## Validation steps once Firestore is integrated

1. Add the Firestore data model, Firebase Authentication integration, Security Rules, and required index definitions.
2. Load the fixture into a Firestore emulator or isolated non-production project, converting timestamp strings to Firestore `Timestamp` values.
3. Execute each case using the same trusted write path used by the application, and assert both the outcome and resulting related documents.
4. Add Rules unit tests for anonymous access, role boundaries, unauthorized edits, and user/tenant scoping.
5. Exercise traceability and common filtered queries with the declared indexes; verify both empty and multi-record result sets.
6. Record the exact emulator/test command and results here after those tests exist.

No live Firestore test was run: this repository has no Firestore integration or emulator/test harness to execute these fixtures against.
