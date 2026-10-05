# DairyTrace ER Diagram

## Entity Relationship Diagram

```mermaid
erDiagram

    USER {
        UUID id PK
        VARCHAR name
        VARCHAR email UK
        VARCHAR role
    }

    FARMER {
        UUID id PK
        VARCHAR farmer_code UK
        VARCHAR name
        VARCHAR phone
        UUID center_id FK
        UUID user_id FK
        VARCHAR status
    }

    COLLECTION_CENTER {
        UUID id PK
        VARCHAR center_code UK
        VARCHAR name
        VARCHAR location
    }

    COLLECTION {
        UUID id PK
        VARCHAR collection_code UK
        UUID farmer_id FK
        UUID center_id FK
        UUID operator_id FK
        DATE collection_date
        VARCHAR session
        DECIMAL quantity_liters
        UUID batch_id FK
    }

    QUALITY_READING {
        UUID id PK
        UUID collection_id FK
        DECIMAL fat_percentage
        DECIMAL snf_percentage
        DECIMAL temperature
        BOOLEAN adulteration_detected
    }

    QUALITY_ALERT {
        UUID id PK
        UUID collection_id FK
        VARCHAR parameter
        DECIMAL observed_value
        DECIMAL threshold_value
        VARCHAR status
    }

    BATCH {
        UUID id PK
        VARCHAR batch_code UK
        UUID center_id FK
        DATE batch_date
        VARCHAR session
        VARCHAR status
        VARCHAR quality_result
    }

    PRICING_RULE {
        UUID id PK
        VARCHAR name
        DECIMAL rate_per_liter
        DATE effective_from
        DATE effective_to
    }

    RECONCILIATION {
        UUID id PK
        DATE period_start
        DATE period_end
        VARCHAR status
    }

    RECONCILIATION_ITEM {
        UUID id PK
        UUID reconciliation_id FK
        UUID farmer_id FK
        DECIMAL total_quantity_liters
        DECIMAL calculated_amount
    }

    DISPUTE {
        UUID id PK
        UUID farmer_id FK
        UUID collection_id FK
        UUID reconciliation_item_id FK
        TEXT description
        VARCHAR status
    }

    AUDIT_LOG {
        UUID id PK
        UUID user_id FK
        VARCHAR action
        VARCHAR entity_type
        UUID entity_id
        TIMESTAMP created_at
    }


    USER ||--o| FARMER : "has"

    COLLECTION_CENTER ||--o{ FARMER : "serves"
    COLLECTION_CENTER ||--o{ COLLECTION : "records"
    COLLECTION_CENTER ||--o{ BATCH : "creates"

    FARMER ||--o{ COLLECTION : "makes"
    USER ||--o{ COLLECTION : "records"

    COLLECTION ||--|| QUALITY_READING : "has"
    COLLECTION ||--o{ QUALITY_ALERT : "generates"

    BATCH ||--o{ COLLECTION : "contains"

    RECONCILIATION ||--o{ RECONCILIATION_ITEM : "contains"
    FARMER ||--o{ RECONCILIATION_ITEM : "has"

    FARMER ||--o{ DISPUTE : "raises"
    COLLECTION ||--o{ DISPUTE : "concerns"
    RECONCILIATION_ITEM ||--o{ DISPUTE : "concerns"

    USER ||--o{ AUDIT_LOG : "creates"