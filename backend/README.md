# DairyTrace - Backend Service

Spring Boot REST API service powering DairyTrace milk collection, quality inspection, batch tracking, and farmer reconciliation.

---

## 📁 Package Architecture

```text
src/main/java/com/dairytrace/
├── config/       # Spring configuration classes (CORS, Swagger/OpenAPI, etc.)
├── controller/   # REST Controllers defining HTTP endpoints
├── service/      # Service interfaces and implementations containing core business rules
├── repository/   # Spring Data JPA repositories for database access
├── model/        # JPA Entity models mapping relational schema
├── dto/          # Data Transfer Objects for API request/response payloads
├── security/     # JWT authentication, filters, and user authorization rules
├── exception/    # Custom exception classes and global ControllerAdvice handlers
└── DairyTraceApplication.java # Application bootstrap class
```

---

## 🛠️ Tech Stack & Requirements

- **Java**: 17+
- **Framework**: Spring Boot 3.2+
- **Persistence**: Spring Data JPA & Hibernate
- **Database**: PostgreSQL 15+
- **Build Tool**: Apache Maven 3.8+

---

## 🚀 Running Locally

### 1. Start the Database
```bash
docker run --name dairytrace-db -e POSTGRES_DB=dairytrace -e POSTGRES_USER=dairyuser -e POSTGRES_PASSWORD=dairypassword -p 5432:5432 -d postgres:15-alpine
```

### 2. Build & Run Application
```bash
# Build with Maven
mvn clean package

# Run the Spring Boot application
mvn spring-boot:run
```

The API will be available at `http://localhost:8080/api`.
