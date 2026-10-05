# DairyTrace Database Design

## 1. Overview

DairyTrace uses PostgreSQL as its relational database.

The database is designed around the following core workflow:

Farmer → Collection → Quality Reading → Batch → Reconciliation

The database must maintain data integrity, support traceability, and provide an auditable history of important changes.

---

## 2. Core Entities

The initial database contains the following entities:

1. User
2. Farmer
3. CollectionCenter
4. Collection
5. QualityReading
6. QualityAlert
7. Batch
8. PricingRule
9. Reconciliation
10. ReconciliationItem
11. Dispute
12. AuditLog

---

## 3. User

Stores application users and their roles.

| Field | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| name | VARCHAR(100) | NOT NULL |
| email | VARCHAR(255) | UNIQUE, NOT NULL |
| password_hash | VARCHAR(255) | NOT NULL |
| role | VARCHAR(30) | NOT NULL |
| is_active | BOOLEAN | DEFAULT TRUE |
| created_at | TIMESTAMP | NOT NULL |
| updated_at | TIMESTAMP | NOT NULL |

### Roles

- ADMIN
- MANAGER
- OPERATOR
- QUALITY_STAFF
- FARMER

---

## 4. Farmer

Stores farmer information.

| Field | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| farmer_code | VARCHAR(50) | UNIQUE, NOT NULL |
| name | VARCHAR(100) | NOT NULL |
| phone | VARCHAR(20) | NOT NULL |
| village | VARCHAR(100) | NOT NULL |
| center_id | UUID | FK → CollectionCenter.id |
| user_id | UUID | FK → User.id, NULLABLE |
| status | VARCHAR(20) | NOT NULL |
| created_at | TIMESTAMP | NOT NULL |
| updated_at | TIMESTAMP | NOT NULL |

A farmer may optionally have a user account for accessing the farmer portal.

---

## 5. CollectionCenter

Stores dairy milk collection centers.

| Field | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| center_code | VARCHAR(50) | UNIQUE, NOT NULL |
| name | VARCHAR(100) | NOT NULL |
| location | VARCHAR(255) | NOT NULL |
| status | VARCHAR(20) | NOT NULL |
| created_at | TIMESTAMP | NOT NULL |
| updated_at | TIMESTAMP | NOT NULL |

---

## 6. Collection

Stores each individual milk collection transaction.

| Field | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| collection_code | VARCHAR(50) | UNIQUE, NOT NULL |
| farmer_id | UUID | FK → Farmer.id |
| center_id | UUID | FK → CollectionCenter.id |
| operator_id | UUID | FK → User.id |
| collection_date | DATE | NOT NULL |
| collection_time | TIMESTAMP | NOT NULL |
| session | VARCHAR(20) | NOT NULL |
| quantity_liters | DECIMAL(10,2) | NOT NULL |
| batch_id | UUID | FK → Batch.id, NULLABLE |
| created_at | TIMESTAMP | NOT NULL |
| updated_at | TIMESTAMP | NOT NULL |

### Session values

- MORNING
- EVENING

A collection belongs to exactly one farmer and one collection center.

A collection can be associated with one batch.

---

## 7. QualityReading

Stores quality measurements for a collection.

| Field | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| collection_id | UUID | UNIQUE, FK → Collection.id |
| fat_percentage | DECIMAL(5,2) | NOT NULL |
| snf_percentage | DECIMAL(5,2) | NOT NULL |
| temperature | DECIMAL(5,2) | NULLABLE |
| adulteration_detected | BOOLEAN | DEFAULT FALSE |
| recorded_by | UUID | FK → User.id |
| recorded_at | TIMESTAMP | NOT NULL |

Each collection has one quality reading record in the MVP.

---

## 8. QualityAlert

Stores quality threshold violations.

| Field | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| collection_id | UUID | FK → Collection.id |
| parameter | VARCHAR(50) | NOT NULL |
| observed_value | DECIMAL(10,2) | NOT NULL |
| threshold_value | DECIMAL(10,2) | NOT NULL |
| status | VARCHAR(20) | NOT NULL |
| created_at | TIMESTAMP | NOT NULL |
| resolved_at | TIMESTAMP | NULLABLE |
| resolved_by | UUID | FK → User.id, NULLABLE |

### Alert statuses

- OPEN
- REVIEWED
- RESOLVED

---

## 9. Batch

Stores batches created from collected milk.

| Field | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| batch_code | VARCHAR(50) | UNIQUE, NOT NULL |
| center_id | UUID | FK → CollectionCenter.id |
| batch_date | DATE | NOT NULL |
| session | VARCHAR(20) | NOT NULL |
| status | VARCHAR(20) | NOT NULL |
| quality_result | VARCHAR(20) | NULLABLE |
| tested_by | UUID | FK → User.id, NULLABLE |
| tested_at | TIMESTAMP | NULLABLE |
| notes | TEXT | NULLABLE |
| created_at | TIMESTAMP | NOT NULL |
| updated_at | TIMESTAMP | NOT NULL |

### Batch statuses

- PENDING
- PASSED
- FAILED
- QUARANTINED
- RELEASED

Collections are connected to a batch through `Collection.batch_id`.

This allows:

Batch → Collections → Farmers

for traceability.

---

## 10. PricingRule

Stores cooperative pricing rules.

| Field | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| name | VARCHAR(100) | NOT NULL |
| min_fat | DECIMAL(5,2) | NULLABLE |
| max_fat | DECIMAL(5,2) | NULLABLE |
| min_snf | DECIMAL(5,2) | NULLABLE |
| max_snf | DECIMAL(5,2) | NULLABLE |
| rate_per_liter | DECIMAL(10,2) | NOT NULL |
| effective_from | DATE | NOT NULL |
| effective_to | DATE | NULLABLE |
| is_active | BOOLEAN | DEFAULT TRUE |
| created_at | TIMESTAMP | NOT NULL |

Pricing rules are used during reconciliation.

---

## 11. Reconciliation

Represents a reconciliation period.

| Field | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| period_start | DATE | NOT NULL |
| period_end | DATE | NOT NULL |
| status | VARCHAR(20) | NOT NULL |
| finalized_by | UUID | FK → User.id, NULLABLE |
| finalized_at | TIMESTAMP | NULLABLE |
| created_at | TIMESTAMP | NOT NULL |

### Reconciliation statuses

- OPEN
- CALCULATING
- REVIEW
- FINALIZED

---

## 12. ReconciliationItem

Stores farmer-level reconciliation results.

| Field | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| reconciliation_id | UUID | FK → Reconciliation.id |
| farmer_id | UUID | FK → Farmer.id |
| total_quantity_liters | DECIMAL(12,2) | NOT NULL |
| average_fat | DECIMAL(5,2) | NULLABLE |
| average_snf | DECIMAL(5,2) | NULLABLE |
| calculated_amount | DECIMAL(12,2) | NOT NULL |
| created_at | TIMESTAMP | NOT NULL |

One reconciliation period can contain many farmer reconciliation items.

---

## 13. Dispute

Stores disputes raised against collection or reconciliation records.

| Field | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| farmer_id | UUID | FK → Farmer.id |
| collection_id | UUID | FK → Collection.id, NULLABLE |
| reconciliation_item_id | UUID | FK → ReconciliationItem.id, NULLABLE |
| description | TEXT | NOT NULL |
| status | VARCHAR(20) | NOT NULL |
| raised_at | TIMESTAMP | NOT NULL |
| resolved_by | UUID | FK → User.id, NULLABLE |
| resolved_at | TIMESTAMP | NULLABLE |
| resolution_notes | TEXT | NULLABLE |

### Dispute statuses

- OPEN
- UNDER_REVIEW
- RESOLVED
- REJECTED

---

## 14. AuditLog

Stores important changes made to system records.

| Field | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| user_id | UUID | FK → User.id |
| action | VARCHAR(50) | NOT NULL |
| entity_type | VARCHAR(50) | NOT NULL |
| entity_id | UUID | NOT NULL |
| old_value | JSONB | NULLABLE |
| new_value | JSONB | NULLABLE |
| reason | TEXT | NULLABLE |
| created_at | TIMESTAMP | NOT NULL |

Audit logs provide accountability for important record changes.

---

# 15. Main Relationships

### Farmer → Collection

One farmer can have many collections.

```text
Farmer 1 ────────< Collection