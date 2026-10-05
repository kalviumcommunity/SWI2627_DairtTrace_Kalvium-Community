# DairyTrace

> **Digital Milk Collection, Quality Monitoring & Batch Traceability Platform**

DairyTrace is an end-to-end digital platform designed for dairy cooperatives to replace paper-based records with reliable, transparent, auditable digital tracking from milk collection to processing batches.

---

## 📂 Project Structure

```text
DairyTrace/
│
├── README.md                   # Project overview and setup documentation
├── PRD.md                      # Product Requirements Document
├── .gitignore                  # Git ignore specifications
├── docker-compose.yml          # Multi-container local orchestration
│
├── frontend/                   # Frontend web application (Next.js / React)
│   ├── README.md               # Frontend setup and architecture guide
│   ├── package.json            # Node.js dependencies and scripts
│   ├── src/
│   │   ├── app/                # Application routes (login, dashboard, farmers, etc.)
│   │   ├── components/         # Reusable UI, layout, forms, tables, and charts
│   │   ├── services/           # API integration and client services
│   │   ├── hooks/              # Custom React hooks
│   │   ├── lib/                # Shared utilities and helper functions
│   │   └── types/              # TypeScript interface & type definitions
│   └── public/                 # Static assets
│
├── backend/                    # Backend API service (Java / Spring Boot)
│   ├── README.md               # Backend architecture and setup instructions
│   ├── pom.xml                 # Maven configuration and dependencies
│   └── src/
│       ├── main/
│       │   ├── java/com/dairytrace/
│       │   │   ├── config/     # Application & security configs
│       │   │   ├── controller/ # REST API endpoints
│       │   │   ├── service/    # Business logic layer
│       │   │   ├── repository/ # Spring Data JPA repositories
│       │   │   ├── model/      # Database entities
│       │   │   ├── dto/        # Data Transfer Objects
│       │   │   ├── security/   # Authentication & authorization
│       │   │   ├── exception/  # Global error handling
│       │   │   └── DairyTraceApplication.java # Spring Boot entrypoint
│       │   └── resources/
│       │       ├── application.properties
│       │       └── db/         # Migration scripts
│       └── test/               # Unit and integration tests
│
├── database/                   # Database schemas, migrations, and seed scripts
│   ├── schema/                 # DDL and base table definitions
│   ├── migrations/             # Incremental database migrations
│   └── seed/                   # Sample and demo seed datasets
│
├── docs/                       # Comprehensive documentation
│   ├── architecture/           # Architecture diagrams and system design
│   ├── api/                    # OpenAPI / REST API specifications
│   ├── database/               # Entity relationship diagrams and schemas
│   └── workflows/              # Business flow and process documentation
│
└── .github/                    # CI/CD and repository templates
    ├── workflows/              # GitHub Actions workflows
    ├── ISSUE_TEMPLATE/         # Bug reports and feature request templates
    └── pull_request_template.md# PR contribution checklist
```

---

## 🚀 Key Modules & Capabilities

- **Farmer Management**: Profiles, KYC, bank details, and active status tracking.
- **Collection Recording**: Daily morning/evening milk intake records (liters, fat %, SNF, density, temperature).
- **Quality Control**: Automated threshold checks, adulteration tests, and quality acceptance/rejection workflows.
- **Batch Traceability**: Aggregation of collections into storage silos and processing batches with backward traceability.
- **Reconciliation & Payouts**: Automated calculation of farmer earnings based on quality-rate matrices.
- **Dispute Resolution**: Transparent audit trails and dispute handling workflows.

---

## 🛠️ Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js (v18+) & npm
- Java JDK 17+ & Maven 3.8+

### Running with Docker Compose
```bash
# Clone the repository and navigate to root
cd DairyTrace

# Start PostgreSQL database, backend service, and frontend application
docker-compose up -d
```

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080/api
- **Database**: localhost:5432 (PostgreSQL)

For detailed instructions, refer to [frontend/README.md](file:///c:/Users/edhas/SWI2627_DairtTrace_Kalvium-Community/frontend/README.md) and [backend/README.md](file:///c:/Users/edhas/SWI2627_DairtTrace_Kalvium-Community/backend/README.md).

---

## 👥 Team

- **Edha Singh** — Project Lead / Backend
- **Kartik** — Team Member
- **Sanskriti** — Team Member

