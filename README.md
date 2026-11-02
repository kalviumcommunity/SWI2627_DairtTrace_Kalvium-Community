# DairyTrace

## Product Requirements Document

**Product:** DairyTrace  
**Project Type:** Digital Milk Collection, Quality Monitoring & Batch Traceability Platform  
**Project Lead:** Edha Singh  
**Team Members:** Kartik, Sanskriti  
**Current Primary Client:** Flutter Mobile Application  
**Current Authentication / Data Layer:** Firebase Authentication + Cloud Firestore  
**Backend Foundation:** Java Spring Boot + PostgreSQL  
**Status:** Active Development

---

# 1. Product Overview

DairyTrace is a digital platform designed for dairy cooperatives to replace paper-based milk collection records with transparent, traceable, and auditable digital workflows.

The platform focuses on recording milk collections from farmers, tracking quality readings, identifying quality problems earlier, preserving collection history, and eventually tracing rejected processing batches back to the farmers and source collections responsible for them.

The project also aims to reduce the amount of manual work required during reconciliation and minimize disputes caused by handwritten or inconsistent collection records.

---

# 2. Problem Statement

A dairy cooperative collects milk from hundreds of farmers every morning and evening, but quantity and quality readings at collection centers are captured on paper.

This creates several operational problems:

- Month-end reconciliation takes several days.
- Farmers may dispute recorded quantities or quality readings.
- Paper records can be lost, changed, or entered incorrectly.
- Quality problems may only be identified after milk from multiple farmers has already been mixed.
- Rejected batches cannot easily be traced back to their source collections.
- There is limited visibility into historical farmer and collection data.
- Collection center staff do not receive immediate feedback when a reading indicates poor-quality milk.

DairyTrace addresses these problems by digitizing the complete collection workflow and maintaining traceable records.

---

# 3. Product Goal

The goal of DairyTrace is to provide a reliable digital workflow from:

**Farmer → Milk Collection → Quality Reading → Quality Status → Batch → Reconciliation → Dispute / Audit**

The system should allow dairy cooperative staff to know:

- Who supplied the milk.
- When the milk was collected.
- How much milk was collected.
- What quality readings were recorded.
- Whether the collection passed quality checks.
- Which collections contributed to a processing batch.
- Which farmer contributed to a rejected batch.
- How farmer payment calculations were generated.
- What happened when a farmer disputed a reading or payment.

---

# 4. Current Implementation Baseline

The project currently contains multiple application layers.

## 4.1 Flutter Mobile Application

Directory:

`mobile/`

This is currently the most actively developed application.

Current work includes:

- Firebase initialization.
- Firebase Authentication.
- Authentication state handling.
- Login workflow.
- Loading and error states for authentication.
- Milk collection form.
- Collection validation.
- Collection creation.
- Collection listing.
- Collection deletion.
- Firestore integration.
- Reusable SnackBar-based feedback.
- Confirmation dialog before destructive actions.
- Error handling for Firestore and authentication failures.
- Image upload service foundation.
- Automated widget and service tests.

Current important files include:

```text
mobile/lib/
├── firebase_options.dart
├── form_validators.dart
├── main.dart
├── models/
│   └── collection.dart
├── services/
│   ├── collection_service.dart
│   └── image_upload_service.dart
└── utils/
    └── user_feedback.dart
```

Current tests include:

```text
mobile/test/
├── auth_gate_test.dart
├── error_handling_test.dart
├── form_validators_test.dart
├── services/
│   ├── collection_service_test.dart
│   └── image_upload_service_test.dart
└── utils/
    └── user_feedback_test.dart
```

Quality-reading and quality-alert functionality is part of the current development phase and should be treated as an active feature until fully validated end-to-end.

---

## 4.2 Spring Boot Backend

Directory:

`backend/`

The backend foundation uses:

- Java
- Spring Boot
- Maven
- PostgreSQL
- Spring Data JPA
- REST APIs

Existing backend work includes application structure, database connectivity planning, health endpoints, dashboard summary work, and entity/repository/service architecture.

Target backend structure:

```text
backend/src/main/java/com/dairytrace/
├── controller/
├── service/
├── repository/
├── model/
├── dto/
├── security/
├── exception/
└── DairyTraceApplication.java
```

The Spring Boot + PostgreSQL architecture remains the intended structured backend architecture for the full system.

However, the current Flutter mobile workflow is primarily using Firebase Authentication and Firestore.

A later integration or migration decision is required before production deployment.

---

## 4.3 Legacy Web Application

Directory:

`frontend-legacy/`

The repository also contains the earlier React / Next.js frontend work.

This application is retained for reference and previous implementation work but is not currently the primary DairyTrace mobile workflow.

---

## 4.4 Flutter Prototype

Directory:

`frontend/`

A separate Flutter prototype also exists.

The active mobile implementation is currently located under:

`mobile/`

---

# 5. Target Users

## 5.1 Collection Center Operator

Responsible for recording milk received from farmers.

The operator should be able to:

- Identify a farmer.
- Record milk quantity.
- Record quality readings.
- Submit collection data.
- Receive validation feedback.
- Receive quality alerts.
- View collection history.
- Correct or remove records where permitted.

---

## 5.2 Cooperative Administrator

Responsible for monitoring operations.

The administrator should eventually be able to:

- Manage farmers.
- Monitor collection centers.
- Review collections.
- Review quality alerts.
- Create and inspect batches.
- Run reconciliation.
- Investigate disputes.
- Review audit history.

---

## 5.3 Farmer

The farmer is the source of milk collections.

Future versions should allow farmers to access:

- Their recorded collection history.
- Quantity records.
- Quality readings.
- Payment information.
- Dispute status.

Direct farmer login is not currently a core MVP requirement.

---

# 6. Functional Requirements

# 6.1 Authentication

## Requirements

The application must allow authorized users to securely access DairyTrace.

The system should:

- Support user authentication.
- Maintain authentication state.
- Show a loading state while authentication is being determined.
- Redirect unauthenticated users to login.
- Redirect authenticated users into the application.
- Handle authentication failures safely.
- Allow authentication retry.
- Support logout.
- Display understandable errors rather than backend exception details.

## Current Status

Implemented and covered by automated tests.

---

# 6.2 Milk Collection Recording

Each milk collection should represent milk received from one farmer during a specific collection session.

Required information should include:

- Farmer identifier.
- Collection center.
- Date and time.
- Collection session where applicable.
- Quantity in liters.
- Quality readings.
- Collection status.

The system must:

- Validate required fields.
- Prevent invalid numeric input.
- Store successful collections persistently.
- Preserve form values if saving fails.
- Show successful save feedback.
- Show meaningful error feedback.
- Display saved collections.

## Current Status

Core collection creation, validation, Firestore interaction, listing, deletion, and feedback are implemented or under active validation.

---

# 6.3 Milk Quality Recording

Each collection should support quality readings.

MVP quality measurements include:

- Fat percentage.
- SNF percentage.
- Temperature.

Future quality measurements may include:

- Density.
- Acidity.
- Lactometer reading.
- Adulteration test results.
- Water contamination checks.
- Antibiotic residue test.

The quality readings must remain linked to the original collection.

---

# 6.4 Automated Quality Evaluation

The application should automatically evaluate milk quality when a collection is submitted.

Possible statuses:

```text
ACCEPTED
ALERT
REJECTED
UNKNOWN
```

For the current MVP:

- `ACCEPTED` indicates readings are inside configured limits.
- `ALERT` indicates one or more readings fall outside configured limits.
- `UNKNOWN` may be used for older records without quality readings.

Quality thresholds must be maintained centrally rather than repeated throughout the user interface.

The system should explain why a quality alert occurred.

Example:

```text
Quality Alert
Fat percentage is below the configured minimum.
```

A poor-quality record should normally still be stored so that the cooperative retains traceability.

## Current Status

Active implementation phase.

---

# 6.5 User Feedback

The application should clearly communicate the result of user actions.

Reusable feedback currently supports:

- Success SnackBars.
- Error SnackBars.
- Informational SnackBars.
- Confirmation dialogs.

Examples:

```text
Collection saved successfully.
```

```text
Unable to save collection.
```

```text
Are you sure you want to delete this collection?
```

## Current Status

Implemented.

---

# 6.6 Collection Deletion

The application should not immediately perform destructive actions.

Before deleting a collection:

1. The user selects delete.
2. DairyTrace displays a confirmation dialog.
3. The user confirms or cancels.
4. The record is deleted only after confirmation.
5. Success or failure feedback is shown.

## Current Status

Implemented as part of the user-feedback workflow.

---

# 6.7 Collection History

The application should provide a list of recorded milk collections.

Each record should eventually display:

- Farmer.
- Quantity.
- Date/time.
- Fat.
- SNF.
- Temperature.
- Quality status.

Users should be able to identify quality-alert collections quickly.

## Current Status

Collection listing exists. Quality status display is part of the current quality-monitoring development phase.

---

# 6.8 Farmer Management

The full DairyTrace system should maintain farmer profiles.

Target farmer fields include:

- Farmer ID.
- Full name.
- Phone number.
- Address.
- Village.
- Bank account details.
- KYC information.
- Active / inactive status.
- Registration date.

## Current Status

Defined in project architecture but not yet complete in the current mobile MVP.

---

# 6.9 Batch Traceability

Collections should eventually be grouped into processing or storage batches.

Each batch must preserve links to its source collections.

Required relationship:

```text
Batch
  ↓
Collection
  ↓
Farmer
```

If a batch is rejected, the cooperative should be able to identify:

- Which collections contributed to it.
- Which farmers supplied those collections.
- Their corresponding quality readings.
- When each collection occurred.
- Which collection center received the milk.

## Current Status

Planned for the next development phase.

---

# 6.10 Reconciliation

The reconciliation module should calculate farmer totals for a selected period.

The system should eventually support:

- Total quantity supplied.
- Collection count.
- Quality-based rates.
- Total payable amount.
- Adjustments.
- Reconciliation status.

Example:

```text
Farmer: F001
Period: October 2026

Total Milk: 425 L
Average Fat: 4.1%
Calculated Amount: ₹18,750
Adjustment: ₹0
Final Payable: ₹18,750
Status: RECONCILED
```

## Current Status

Architecture and database entities have been planned. Complete end-to-end mobile workflow is pending.

---

# 6.11 Dispute Management

A farmer or cooperative operator should eventually be able to raise a dispute against:

- Quantity.
- Quality reading.
- Payment amount.
- Missing collection.

A dispute should contain:

- Farmer.
- Related collection or reconciliation.
- Reason.
- Description.
- Status.
- Created timestamp.
- Resolution.
- Resolved timestamp.

Possible states:

```text
OPEN
UNDER_REVIEW
RESOLVED
REJECTED
```

## Current Status

Planned.

---

# 6.12 Audit Trail

Sensitive changes should eventually generate audit records.

Examples:

- Collection created.
- Collection edited.
- Collection deleted.
- Quality result changed.
- Batch created.
- Reconciliation completed.
- Dispute resolved.

Audit records should contain:

- User.
- Action.
- Entity.
- Entity identifier.
- Timestamp.
- Previous value where applicable.
- New value where applicable.

## Current Status

Planned in the full database architecture.

---

# 7. Core Data Model

The full DairyTrace architecture currently considers the following entities:

```text
User
Farmer
CollectionCenter
Collection
QualityReading
QualityAlert
Batch
PricingRule
Reconciliation
ReconciliationItem
Dispute
AuditLog
```

The current mobile MVP primarily operates around:

```text
User
Collection
Quality information
```

The data model will progressively expand as batch traceability and reconciliation are implemented.

---

# 8. Current Technology Stack

## Mobile

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase configuration
- Flutter widget testing
- Mocktail where required for testing

## Backend

- Java
- Spring Boot
- Spring Data JPA
- Maven
- PostgreSQL

## Legacy Web

- React
- Next.js
- TypeScript

## Infrastructure

- Docker
- Docker Compose
- Git
- GitHub
- GitHub Issues
- Pull Requests
- Feature branches

---

# 9. Current Repository Structure

```text
DairyTrace/
│
├── README.md
├── PRD.md
├── .gitignore
├── docker-compose.yml
│
├── backend/
│   ├── pom.xml
│   └── src/
│
├── frontend-legacy/
│   ├── package.json
│   └── src/
│
├── frontend/
│   ├── lib/
│   └── pubspec.yaml
│
├── mobile/
│   ├── lib/
│   │   ├── firebase_options.dart
│   │   ├── form_validators.dart
│   │   ├── main.dart
│   │   ├── models/
│   │   │   └── collection.dart
│   │   ├── services/
│   │   │   ├── collection_service.dart
│   │   │   └── image_upload_service.dart
│   │   └── utils/
│   │       └── user_feedback.dart
│   │
│   ├── test/
│   │   ├── auth_gate_test.dart
│   │   ├── error_handling_test.dart
│   │   ├── form_validators_test.dart
│   │   ├── services/
│   │   └── utils/
│   │
│   └── pubspec.yaml
│
├── database/
│   ├── schema/
│   ├── migrations/
│   └── seed/
│
├── docs/
│
└── .github/
    ├── ISSUE_TEMPLATE/
    ├── workflows/
    └── pull_request_template.md
```

---

# 10. Testing Requirements

The project should maintain automated tests for critical workflows.

Current test areas include:

- Authentication state.
- Authentication failures.
- Authentication retry.
- Form validation.
- Collection services.
- Firestore failure handling.
- Image upload service.
- User feedback.
- Collection save failure.
- Collection stream retry.
- Sign-out errors.

The quality-monitoring module should additionally include tests for:

- Accepted quality values.
- Low-fat alert.
- Low-SNF alert.
- High-temperature alert.
- Multiple simultaneous quality failures.
- Quality serialization and persistence.

Before merging a feature branch:

```bash
flutter analyze
```

must complete without analyzer errors.

And:

```bash
flutter test
```

should complete successfully.

---

# 11. Non-Functional Requirements

## Reliability

Collection records must not silently disappear or fail without informing the user.

## Traceability

Every important milk record should eventually be traceable to its farmer and downstream batch.

## Security

Authentication must protect operational data.

Sensitive details should not be exposed through user-facing error messages.

## Usability

Collection center staff should be able to record milk with minimal steps.

## Data Integrity

Numeric fields must be validated before persistence.

## Maintainability

Business rules such as quality thresholds should remain separate from UI code.

## Testability

Critical workflows should be designed so that services and state can be mocked during automated testing.

---

# 12. MVP Definition

The DairyTrace MVP will be considered successful when the following workflow operates end-to-end:

```text
Login
  ↓
Identify Farmer
  ↓
Record Milk Collection
  ↓
Record Quality Readings
  ↓
Automatic Quality Evaluation
  ↓
Store Collection
  ↓
Display Collection History
  ↓
Create / Associate Batch
  ↓
Trace Batch Back to Collection
  ↓
Trace Collection Back to Farmer
```

The minimum submission should prioritize this workflow over non-essential visual features.

---

# 13. Development Priorities

## Completed / Mostly Completed

- Flutter mobile project setup.
- Firebase setup.
- Authentication.
- Authentication state handling.
- Collection form foundation.
- Validation.
- Firestore collection service.
- Collection list.
- Error handling.
- SnackBar feedback.
- Confirmation dialog.
- Automated test foundation.

## Current Priority

- Milk quality readings.
- Automatic quality alerts.
- Persisting quality status.
- Displaying quality status.

## Next Priority

- Batch creation.
- Collection-to-batch relationships.
- Backward batch traceability.

## Following Priority

- Reconciliation.
- Pricing rules.
- Farmer payouts.
- Disputes.
- Audit trail.

---

# 14. Current Known Architecture Decision

The repository currently contains two possible backend/data approaches:

### Current Mobile Implementation

```text
Flutter
   ↓
Firebase Authentication
   ↓
Cloud Firestore
```

### Original Full Architecture

```text
Flutter / Web
      ↓
Spring Boot REST API
      ↓
PostgreSQL
```

For the remaining submission period, development should prioritize completing a stable and demonstrable end-to-end workflow rather than performing a high-risk last-minute architecture migration.

The Spring Boot + PostgreSQL implementation can continue as the long-term backend architecture after the MVP workflow is stabilized.

---

# 15. Submission Success Criteria

The final submission should demonstrate:

- User authentication.
- Digital milk collection.
- Persistent collection records.
- Form validation.
- Quality reading capture.
- Immediate quality alerts.
- Quality status history.
- Safe collection deletion.
- Error feedback.
- Automated tests.
- Batch traceability.
- Basic reconciliation where time permits.
- Documentation explaining the architecture and remaining planned modules.

The demo should clearly explain how DairyTrace solves the original problem:

**Paper records → digital collection**

**Late quality detection → immediate quality alert**

**Untraceable rejected batch → farmer-level collection traceability**

**Manual reconciliation → structured digital reconciliation**

---

# 16. Future Enhancements

Future versions of DairyTrace may include:

- IoT milk analyzer integration.
- Bluetooth weighing scale integration.
- QR-based farmer identification.
- RFID farmer cards.
- Automated payout integration.
- SMS / WhatsApp collection receipts.
- Farmer mobile portal.
- Advanced adulteration detection.
- Predictive quality analytics.
- Cooperative performance dashboards.
- Offline-first collection mode.
- Automatic synchronization when connectivity returns.
- Role-based access control.
- Full Spring Boot / PostgreSQL integration.
- Immutable audit history.

---

# 17. Product Vision

DairyTrace should evolve from a digital collection-recording application into a complete traceability platform for dairy cooperatives.

The long-term goal is for every liter of milk entering the cooperative to have a digital history:

```text
Farmer
   ↓
Collection
   ↓
Quality
   ↓
Collection Center
   ↓
Batch
   ↓
Processing
   ↓
Reconciliation
   ↓
Payment
   ↓
Audit
```

This allows the cooperative to identify quality problems earlier, resolve disputes with reliable records, reduce reconciliation time, and trace rejected milk back to its original source.