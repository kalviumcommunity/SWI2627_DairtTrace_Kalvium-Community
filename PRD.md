# DairyTrace
## Digital Milk Collection, Quality Monitoring & Batch Traceability Platform

**Document Type:** Product Requirements Document  
**Version:** 1.0  
**Status:** Draft / Development Ready  
**Product:** DairyTrace  
**Primary Users:** Dairy Cooperative Operators, Quality Staff, Managers, Farmers, Administrators  
**Team:**
- **Edha Singh** — Project Lead / Backend
- **Kartik** — Team Member
- **Sanskriti** — Team Member

---

# 1. Product Overview

DairyTrace is a digital platform designed to replace paper-based milk collection records used by dairy cooperatives.

The platform digitally records milk quantity and quality readings at collection centers, maintains a centralized history for every farmer, automates monthly reconciliation, provides quality alerts, and creates end-to-end traceability between milk batches and their source collection records.

The system is intended to help dairy cooperatives move from fragmented paper records to a reliable, searchable, auditable digital system.

---

# 2. Problem Statement

A dairy cooperative collects milk from hundreds of farmers every morning and evening. However, quantity and quality readings at collection centers are currently captured on paper.

This creates several operational problems:

- Collection records are difficult to search and consolidate.
- Month-end reconciliation takes several days.
- Manual calculations increase the possibility of errors.
- Farmers and cooperative staff can dispute recorded quantities or quality measurements.
- Historical records are difficult to verify.
- Quality issues may only be discovered after milk has been combined into a batch.
- When a batch fails quality checks, identifying the contributing collection records and farmers is difficult.
- There is limited accountability when paper records are corrected or altered.

The cooperative needs a centralized digital system that records every collection and maintains a traceable relationship between **farmer → collection → quality reading → batch → quality outcome → reconciliation**.

---

# 3. Product Vision

> Build a reliable digital source of truth for dairy milk collection that enables accurate collection recording, early quality monitoring, faster reconciliation, and complete batch traceability.

---

# 4. Product Goals

DairyTrace will aim to:

1. Digitize milk collection records.
2. Record quantity and quality measurements against individual collections.
3. Detect abnormal or unacceptable quality readings early.
4. Maintain complete farmer collection histories.
5. Connect individual collections to milk batches.
6. Enable backward traceability from a failed batch to its contributing collections.
7. Automate farmer-wise monthly reconciliation.
8. Reduce disputes through transparent and auditable records.
9. Provide dashboards for operational monitoring.
10. Maintain an audit trail for important data changes.

---

# 5. Target Users

## 5.1 Collection Center Operator

The operator records milk received from farmers.

### Responsibilities

- Identify farmer.
- Record quantity.
- Record quality readings.
- Select collection session.
- Create or associate a collection with a batch.
- View recent collection records.
- Correct mistakes through authorized workflows.

---

## 5.2 Farmer

The farmer supplies milk to the cooperative.

### Needs

- View collection history.
- View quantity supplied.
- View quality readings.
- View applicable rates.
- View payment/reconciliation information.
- Raise a dispute when a record appears incorrect.

---

## 5.3 Quality Staff

Responsible for monitoring milk quality.

### Needs

- View quality readings.
- Monitor abnormal readings.
- Review quality alerts.
- View batch quality results.
- Investigate failed batches.
- Trace batches to source collections.

---

## 5.4 Cooperative Manager

Responsible for overall operations.

### Needs

- View collection statistics.
- Monitor quality.
- Monitor batches.
- Review disputes.
- Perform monthly reconciliation.
- Generate reports.
- Investigate quality failures.

---

## 5.5 Administrator

Responsible for system configuration.

### Responsibilities

- Manage users.
- Manage roles.
- Manage farmers.
- Manage collection centers.
- Configure quality thresholds.
- Configure pricing rules.
- Manage system settings.

---

# 6. Product Scope

## 6.1 MVP

The first version will contain:

- Authentication
- Role-based access control
- Farmer management
- Collection center management
- Digital milk collection
- Quality recording
- Quality validation
- Quality alerts
- Batch management
- Batch traceability
- Monthly reconciliation
- Dispute management
- Audit logs
- Dashboard and reports

---

# 7. Core User Workflow

```text
Farmer
   ↓
Collection Center
   ↓
Farmer Identification
   ↓
Milk Quantity Recorded
   ↓
Quality Readings Recorded
   ↓
System Validation
   ↓
Collection Record Created
   ↓
Collection Added to Batch
   ↓
Batch Quality Testing
   ↓
 ┌───────────────┐
 │               │
Pass            Fail
 │               │
 ↓               ↓
Processing     Investigation
                 ↓
          Trace Batch
                 ↓
       Source Collections
                 ↓
              Farmers
```

---

# 8. Functional Requirements

## FR-01: Authentication

The system must provide secure authentication for registered users.

### Requirements

- User login.
- Password hashing.
- JWT-based authentication.
- Token validation.
- Logout/session handling.
- Role-based authorization.

### Roles

```text
ADMIN
MANAGER
OPERATOR
QUALITY_STAFF
FARMER
```

---

# 9. Farmer Management

## FR-02: Farmer Registration

Authorized users can register farmers.

### Farmer information

- Farmer ID
- Name
- Contact number
- Village/address
- Assigned collection center
- Registration date
- Status

Example:

```text
Farmer ID: FMR-1024
Name: Rajesh Kumar
Village: Rampur
Center: CENTER-03
Status: Active
```

---

## FR-03: Farmer History

The system must provide a farmer's historical information.

The history should include:

- Collection date
- Session
- Quantity
- Quality readings
- Rate
- Amount
- Batch ID
- Disputes
- Adjustments

---

# 10. Collection Management

## FR-04: Create Collection Record

The collection operator must be able to create a digital collection record.

### Required information

- Farmer ID
- Collection center
- Session
- Date
- Time
- Quantity
- Quality readings
- Operator ID

The system generates a unique collection ID.

Example:

```text
Collection ID:
COL-20260928-00452
```

---

## FR-05: Collection Sessions

Each collection must belong to a session.

Supported sessions:

```text
MORNING
EVENING
```

The system must prevent invalid or ambiguous session data.

---

# 11. Quality Management

## FR-06: Quality Recording

The system must record quality parameters associated with each collection.

Possible parameters include:

- Fat percentage
- SNF percentage
- Temperature
- Adulteration result
- Other configurable quality parameters

The exact parameters should be configurable rather than hard-coded where practical.

---

## FR-07: Quality Validation

The system must validate entered readings against configured thresholds.

Example:

```text
SNF threshold = 8.5%

Entered:
SNF = 7.9%

Result:
QUALITY ALERT
```

The system must clearly indicate when a reading falls outside the configured acceptable range.

---

## FR-08: Quality Alerts

When a quality parameter violates a configured threshold:

- Create a quality alert.
- Associate it with the collection.
- Record the parameter responsible.
- Record the observed value.
- Record the expected threshold.
- Record timestamp.
- Make the alert visible to authorized staff.

Example:

```text
QUALITY ALERT

Collection: COL-452
Parameter: SNF
Observed: 7.9%
Minimum: 8.5%
Status: Open
```

---

# 12. Batch Management

## FR-09: Create Batch

Authorized users must be able to create a milk batch.

A batch should contain:

- Batch ID
- Collection center
- Date
- Session
- Creation timestamp
- Status
- Associated collections

Example:

```text
Batch:
BATCH-20260928-007

Center:
CENTER-03

Session:
MORNING

Status:
PENDING
```

---

## FR-10: Associate Collections With Batch

Individual collection records must be associated with a batch.

The system must maintain:

```text
Batch
  ↓
Collection
  ↓
Farmer
```

A collection should not silently belong to multiple incompatible batches.

---

# 13. Batch Quality Result

## FR-11: Record Batch Quality Result

Authorized quality staff must be able to record the final batch quality outcome.

Possible statuses:

```text
PENDING
PASSED
FAILED
QUARANTINED
RELEASED
```

The system must record:

- Result
- Tester
- Timestamp
- Notes
- Relevant quality values

---

# 14. Batch Traceability

## FR-12: Trace Batch

Users with appropriate permissions must be able to inspect all collections associated with a batch.

Example:

```text
BATCH-007
     ↓
COL-421
     ↓
FMR-1024

COL-422
     ↓
FMR-1082

COL-423
     ↓
FMR-1104
```

The system must allow authorized users to move from:

**Batch → Collection → Farmer**

---

## FR-13: Failed Batch Investigation

When a batch fails quality testing, the system must allow users to:

1. Open the failed batch.
2. View batch quality information.
3. View all contributing collections.
4. View collection-level quality readings.
5. Identify associated farmers.
6. Review relevant alerts.
7. Review audit history.

The system should provide traceability information for investigation but should not automatically claim that a particular farmer caused a batch failure unless the underlying data supports that conclusion.

---

# 15. Reconciliation

## FR-14: Farmer-wise Reconciliation

The system must calculate farmer-wise collection totals for a selected period.

Example:

```text
September 2026

Farmer: FMR-1024

Total Milk: 842 L
Collections: 52
Average Fat: 4.1%
Average SNF: 8.7%

Calculated Amount: ₹XX,XXX
```

---

## FR-15: Pricing Rules

The system should support configurable pricing rules.

Pricing may depend on:

- Quantity
- Fat
- SNF
- Quality category
- Date/period
- Cooperative-defined pricing rules

The pricing logic must be centralized so that the same rules are consistently applied.

---

## FR-16: Reconciliation Status

Each reconciliation period should have a status.

```text
OPEN
CALCULATING
REVIEW
FINALIZED
```

Once finalized, modifications should require appropriate authorization and create an audit record.

---

# 16. Dispute Management

## FR-17: Create Dispute

A farmer or authorized employee should be able to create a dispute against a collection or reconciliation record.

Example:

```text
Collection:
COL-452

Dispute:
"Quantity recorded as 16 L,
but farmer claims 18 L."
```

---

## FR-18: Dispute Resolution

Authorized staff should be able to:

- Review disputed record.
- Review audit history.
- Review related information.
- Add resolution notes.
- Resolve or reject the dispute.

Possible statuses:

```text
OPEN
UNDER_REVIEW
RESOLVED
REJECTED
```

Every resolution must record the responsible user and timestamp.

---

# 17. Audit Logging

## FR-19: Audit Trail

Important system actions must be logged.

Audit information should include:

- User
- Action
- Entity
- Entity ID
- Previous value
- New value
- Timestamp
- Reason, where applicable

Example:

```text
Collection: COL-452

Changed by: MANAGER-03
Field: Quantity
Previous: 16 L
New: 18 L
Reason: Verified weighing-machine record
Time: 07:15 AM
```

This creates accountability and supports dispute resolution.

---

# 18. Dashboard

## FR-20: Operations Dashboard

Managers should see an overview of cooperative operations.

### Dashboard metrics

- Today's total milk collection
- Number of farmers served
- Number of active collection centers
- Quality alerts
- Failed batches
- Pending disputes
- Reconciliation progress

Example:

```text
Today's Collection
12,842 L

Farmers
642

Quality Alerts
7

Failed Batches
1

Pending Disputes
4
```

---

# 19. Reports

The system should generate reports for:

### Collection

- Daily collection
- Center-wise collection
- Farmer-wise collection
- Session-wise collection

### Quality

- Quality alerts
- Quality trends
- Failed batches
- Quality parameter distribution

### Financial

- Farmer-wise reconciliation
- Monthly payable amount
- Collection totals

### Traceability

- Batch history
- Batch-to-farmer mapping
- Failed batch investigation

---

# 20. Search and Filtering

Users should be able to search and filter records by:

- Farmer ID
- Collection ID
- Batch ID
- Collection center
- Date range
- Morning/evening session
- Quality status
- Batch status
- Dispute status

---

# 21. Non-Functional Requirements

## NFR-01: Security

The system must:

- Hash passwords.
- Use authenticated API access.
- Implement role-based authorization.
- Validate user input.
- Protect sensitive endpoints.
- Prevent unauthorized record modification.
- Maintain audit logs.
- Never expose passwords in API responses.

---

## NFR-02: Data Integrity

The system must maintain consistency between:

```text
Farmer
Collection
Quality Reading
Batch
Reconciliation
```

Foreign-key/relationship constraints should prevent orphaned records.

---

## NFR-03: Performance

The system should support hundreds of farmers and thousands of collection records without noticeable degradation for normal operations.

Database queries should use appropriate indexes for commonly searched fields.

Potential indexes:

```text
farmer_id
collection_date
center_id
batch_id
status
```

---

## NFR-04: Availability

Collection operators should be able to access the system during morning and evening collection periods with minimal downtime.

---

## NFR-05: Auditability

Important data modifications must be traceable to the responsible user.

---

## NFR-06: Usability

The collection interface should prioritize speed because operators may record hundreds of collections during a session.

The collection workflow should require as few unnecessary interactions as possible.

---

# 22. Business Rules

### BR-01

Every collection must belong to exactly one farmer.

### BR-02

Every collection must have a collection timestamp.

### BR-03

Every collection must identify its collection center.

### BR-04

Every collection must have a session.

### BR-05

Every collection must have quantity information.

### BR-06

Quality readings must be validated against configured thresholds.

### BR-07

A finalized reconciliation should not be silently modified.

### BR-08

Important modifications must create audit records.

### BR-09

A failed batch must remain traceable to its associated collections.

### BR-10

Users can only perform actions permitted by their roles.

---

# 23. Data Model — Initial Entities

The initial database will contain:

```text
User
Farmer
CollectionCenter
Collection
QualityReading
Batch
BatchCollection
QualityAlert
PricingRule
Reconciliation
ReconciliationItem
Dispute
AuditLog
```

### Relationship overview

```text
User
 │
 ├──────────────┐
 │              │
 ▼              ▼
Collection    AuditLog
 │
 ├──── Farmer
 │
 ├──── CollectionCenter
 │
 ├──── QualityReading
 │
 ├──── QualityAlert
 │
 └──── Batch
          │
          ▼
     Batch Quality Result
```

---

# 24. Suggested API Structure

The backend can expose REST APIs.

## Authentication

```text
POST /api/auth/login
POST /api/auth/logout
GET  /api/auth/me
```

## Farmers

```text
GET    /api/farmers
POST   /api/farmers
GET    /api/farmers/:id
PUT    /api/farmers/:id
PATCH  /api/farmers/:id/status
```

## Collections

```text
GET  /api/collections
POST /api/collections
GET  /api/collections/:id
PUT  /api/collections/:id
```

## Quality

```text
GET  /api/quality/alerts
GET  /api/quality/collections/:id
POST /api/quality/thresholds
```

## Batches

```text
GET  /api/batches
POST /api/batches
GET  /api/batches/:id
GET  /api/batches/:id/trace
PATCH /api/batches/:id/result
```

## Reconciliation

```text
GET  /api/reconciliation
POST /api/reconciliation/run
GET  /api/reconciliation/:id
POST /api/reconciliation/:id/finalize
```

## Disputes

```text
GET  /api/disputes
POST /api/disputes
PATCH /api/disputes/:id
```

## Dashboard

```text
GET /api/dashboard/summary
GET /api/dashboard/collections
GET /api/dashboard/quality
```

---

# 25. AI / LLM Layer

AI is not required for the core transaction workflow.

The core system must remain functional without an LLM.

AI can be introduced as an intelligence layer on top of structured data.

## AI Feature 1 — Natural Language Analytics

A manager could ask:

> "Show me centers where SNF alerts increased this week."

The system translates the request into a safe database query and returns relevant structured results.

---

## AI Feature 2 — Quality Summary

The system could generate:

> "This week's quality alerts were concentrated in three collection centers. Evening collections accounted for a larger share of alerts than morning collections."

The statement should be generated from verified database data.

---

## AI Feature 3 — Anomaly Detection

The system can identify unusual patterns such as:

- sudden increase in quality alerts
- unusual quantity changes
- repeated abnormal readings
- unusual center-level patterns

AI/ML should support investigation rather than automatically assigning blame.

---

# 26. AI Architecture

```text
User
  │
  ▼
Frontend
  │
  ▼
Backend API
  │
  ├──────────────► PostgreSQL
  │
  ▼
AI Service
  │
  ├── Retrieve relevant data
  │
  ├── Validate/aggregate data
  │
  ▼
LLM API
  │
  ▼
Structured response
  │
  ▼
Frontend
```

The backend should control what information is provided to the LLM rather than giving the model unrestricted database access.

---

# 27. Recommended Technology Stack

## Frontend

**Next.js / React**

- Dashboard
- Collection interface
- Farmer management
- Batch management
- Reports
- Authentication UI

## Backend

**Spring Boot**

- REST APIs
- Business logic
- Authentication
- Authorization
- Reconciliation engine
- Batch traceability
- Audit logging

## Database

**PostgreSQL**

Suitable for the relational relationships between:

```text
Farmers
Collections
Quality
Batches
Reconciliation
Disputes
Users
```

## Authentication

**JWT + Spring Security**

## Deployment

Potential setup:

```text
Frontend → Vercel
Backend → Render / Railway / AWS
Database → PostgreSQL / Neon / Supabase
```

## AI

An LLM API can be integrated later for natural-language analytics and summaries.

---

# 28. UI Screens

The MVP should contain approximately these screens:

### Authentication

1. Login

### Dashboard

2. Manager Dashboard

### Farmers

3. Farmer List
4. Farmer Details
5. Add/Edit Farmer

### Collection

6. New Collection
7. Collection History
8. Collection Details

### Quality

9. Quality Dashboard
10. Quality Alerts
11. Quality Details

### Batches

12. Batch List
13. Batch Details
14. Batch Traceability

### Reconciliation

15. Reconciliation Dashboard
16. Farmer Reconciliation Details

### Disputes

17. Dispute List
18. Dispute Details

### Administration

19. Users
20. Collection Centers
21. Quality Thresholds
22. Pricing Rules

---

# 29. MVP User Stories

## Collection Operator

**US-01**

> As a collection operator, I want to select a farmer and record their milk quantity and quality readings so that the collection is digitally stored.

**Acceptance Criteria**

- Farmer can be selected.
- Quantity is required.
- Required quality readings are validated.
- Collection receives a unique ID.
- Operator is recorded.
- Timestamp is automatically generated.

---

## Farmer

**US-02**

> As a farmer, I want to view my collection history so that I can verify the records maintained by the cooperative.

**Acceptance Criteria**

- Farmer can view past collections.
- Quantity is displayed.
- Quality readings are displayed.
- Date/session are displayed.
- Relevant batch information is available.

---

## Quality Staff

**US-03**

> As quality staff, I want to see quality alerts so that I can investigate abnormal milk readings.

**Acceptance Criteria**

- Alerts show affected collection.
- Parameter is displayed.
- Observed value is displayed.
- Threshold is displayed.
- Alert status can be updated.

---

## Manager

**US-04**

> As a manager, I want to trace a failed batch back to its contributing collections so that I can investigate the source of the quality issue.

**Acceptance Criteria**

- Failed batch is identifiable.
- Associated collections are listed.
- Farmers associated with those collections are visible.
- Collection-level quality readings are accessible.
- Audit history is accessible.

---

## Manager

**US-05**

> As a manager, I want to run monthly reconciliation so that farmer payment calculations do not require manual consolidation of paper records.

**Acceptance Criteria**

- Date range can be selected.
- Farmer totals are calculated.
- Pricing rules are applied.
- Results can be reviewed.
- Reconciliation can be finalized.

---

# 30. MVP Success Criteria

The MVP will be considered successful when a cooperative can complete the following workflow entirely digitally:

```text
Register Farmer
       ↓
Record Collection
       ↓
Record Quality
       ↓
Generate Collection ID
       ↓
Associate With Batch
       ↓
Record Batch Result
       ↓
Trace Batch
       ↓
Calculate Farmer Totals
       ↓
Generate Reconciliation
```

The system should also provide a reliable audit trail for important changes.

---

# 31. Out of Scope for MVP

To prevent scope creep, the following are not required in Version 1:

- Full accounting system
- Direct bank payment processing
- IoT milk analyzers
- Hardware integration
- GPS tracking
- Advanced predictive ML models
- Computer vision
- Blockchain
- Multi-country taxation
- Complex supply-chain optimization

These can be considered later.

---

# 32. Future Roadmap

## Phase 1 — MVP

```text
Authentication
Farmer Management
Collection
Quality
Batch
Traceability
Reconciliation
Disputes
Dashboard
Audit Logs
```

## Phase 2 — Operational Expansion

```text
Digital receipts
QR farmer identification
Mobile/PWA collection interface
Notifications
Payment integration
Advanced reporting
Offline collection support
```

## Phase 3 — Intelligence

```text
AI analytics
Anomaly detection
Natural-language queries
Automated reports
Quality trend analysis
Predictive quality monitoring
```

---

# 33. Key Product Differentiator

The central differentiator of DairyTrace is not simply digitizing paper records.

It creates a connected chain of information:

```text
FARMER
   ↓
COLLECTION
   ↓
QUALITY
   ↓
BATCH
   ↓
BATCH RESULT
   ↓
TRACEABILITY
   ↓
RECONCILIATION
```

This allows the cooperative to move from **record keeping** to **traceable operational management**.

---

# 34. Final Product Definition

DairyTrace is a digital milk collection and traceability platform that enables dairy cooperatives to replace paper-based collection records with a centralized, auditable system.

The platform records individual milk collections and quality readings, detects quality issues, connects collections to batches, enables backward traceability when a batch fails, automates farmer-wise reconciliation, and provides operational dashboards.

The system is designed around one central principle:

> **Every quantity and quality reading should have a digital, searchable, auditable connection back to its source.**