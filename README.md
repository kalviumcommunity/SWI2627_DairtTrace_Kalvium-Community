# DairyTrace

> **Digital Milk Collection, Quality Monitoring & Batch Traceability Platform**

DairyTrace is an end-to-end digital platform designed for dairy cooperatives to replace paper-based records with reliable, transparent, auditable digital tracking from milk collection to processing batches.

---

## 📂 Project Structure

```text
DairyTrace/
│
├── README.md                    # Project overview and setup documentation
├── PRD.md                       # Product requirements document
├── .gitignore                   # Git ignore specifications
├── docker-compose.yml           # Local container orchestration
│
├── backend/                     # Java / Spring Boot API service
│   ├── README.md                # Backend setup and architecture notes
│   ├── pom.xml                 # Maven configuration and dependencies
│   └── src/
│       ├── main/java/com/dairytrace/
│       │   ├── controller/      # REST endpoints
│       │   ├── service/         # Business logic
│       │   ├── repository/      # Persistence layer
│       │   ├── model/           # JPA entities
│       │   ├── dto/             # API request/response models
│       │   ├── security/        # Security configuration
│       │   ├── exception/       # Error handling
│       │   └── DairyTraceApplication.java
│       └── main/resources/
│           └── application.properties
│
├── frontend-legacy/             # Legacy web frontend (Next.js / React / TypeScript)
│   ├── README.md                # Frontend app overview and setup
│   ├── package.json             # Node.js dependencies and scripts
│   ├── public/                  # Static assets
│   ├── src/                     # App routes, components, services, hooks, libs
│   └── vitest.config.mts       # Test configuration
│
├── frontend/                    # Flutter web/desktop application prototype
│   ├── README.md                # Flutter project instructions
│   ├── lib/                     # Application screens and route definitions
│   ├── pubspec.yaml             # Flutter package configuration
│   ├── android/                 # Android project files
│   ├── ios/                     # iOS project files
│   ├── linux/                   # Linux project files
│   ├── macos/                   # macOS project files
│   ├── web/                     # Web build assets
│   └── windows/                 # Windows project files
│
├── mobile/                      # Flutter mobile app for Android/iOS
│   ├── README.md                # Mobile app notes (if present)
│   ├── lib/                     # App code and screens
│   ├── pubspec.yaml             # Mobile package configuration
│   ├── android/                 # Android project files
│   ├── ios/                     # iOS project files
│   ├── linux/                   # Linux project files
│   ├── macos/                   # macOS project files
│   ├── web/                     # Web build assets
│   └── windows/                 # Windows project files
│
├── database/                    # Database schemas, migrations, and validation fixtures
│   ├── schema/                  # DDL and schema definitions
│   ├── migrations/              # Incremental database migrations
│   └── seed/                    # Seed and fixture data for testing
│
├── docs/                        # Architecture, database, and workflow documentation
│   ├── database/                # ER diagrams and schema notes
│   └── ...                      # Additional design docs
│
├── .github/                     # GitHub templates and automation
│   ├── ISSUE_TEMPLATE/
│   ├── workflows/
│   └── pull_request_template.md
│
└── .vscode/                     # Editor configuration (if created locally)
```

Note: The repository currently includes both a legacy Next.js web frontend and separate Flutter applications. The active web app is under `frontend-legacy`, while `frontend` and `mobile` are platform-specific implementations.

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

For detailed instructions, refer to [frontend-legacy/README.md](./frontend-legacy/README.md), [frontend/README.md](./frontend/README.md), and [backend/README.md](./backend/README.md).

---

## 👥 Team

- **Edha Singh** — Project Lead / Backend
- **Kartik** — Team Member
- **Sanskriti** — Team Member

