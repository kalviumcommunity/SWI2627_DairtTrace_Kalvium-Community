# DairyTrace - Frontend Application

Modern web interface for the DairyTrace platform built with Next.js, React, and TypeScript.

---

## 📁 Directory Structure

```text
src/
├── app/                  # App router routes & pages
│   ├── login/            # Authentication & session management
│   ├── dashboard/        # Operational overview & KPIs
│   ├── farmers/          # Farmer registry & management
│   ├── collections/      # Daily milk intake entry & logs
│   ├── quality/          # Quality inspection & test results
│   ├── batches/          # Milk batch aggregation & tracking
│   ├── reconciliation/   # Monthly farmer payouts & settlements
│   └── disputes/         # Dispute submission & audit trails
│
├── components/           # Modular UI components
│   ├── ui/               # Core primitives (buttons, inputs, modals, badges)
│   ├── layout/           # Sidebar, header, navigation, and page containers
│   ├── forms/            # Form components with validation
│   ├── tables/           # Data grids and collection lists
│   └── charts/           # Visualization widgets for volumes & quality metrics
│
├── services/             # HTTP API client integrations
├── hooks/                # Custom React state and side-effect hooks
├── lib/                  # Utilities, formatters, and constants
└── types/                # Domain models and TypeScript interfaces
```

---

## 🚀 Getting Started

### Installation
```bash
npm install
```

### Development Server
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to view the application.

### Build for Production
```bash
npm run build
npm start
```

### Logout and protected screens
The auth service stores the current JWT in `sessionStorage` for the browser tab.
Use `LogoutButton` to clear that client session and navigate to `/login`, and
wrap authenticated screen content in `ProtectedScreen` so a missing session
does not render protected content.

Run the logout/session tests with:
```bash
npm test
```

This client-side logout clears the browser's token; backend token revocation and
authentication endpoints are not implemented in this repository yet.
