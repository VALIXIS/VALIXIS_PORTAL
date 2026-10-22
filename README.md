# VALIXIS Portal

[![Flutter CI/CD](https://github.com/VALIXIS/VALIXIS_PORTAL/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/VALIXIS/VALIXIS_PORTAL/actions/workflows/flutter_ci.yml)
[![License](https://img.shields.io/badge/License-Proprietary-blue.svg)](LICENSE)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.x%20Stable-02569B?logo=flutter)](https://flutter.dev)

VALIXIS Portal is an enterprise business operating system and operations portal built with Flutter and Dart. It unifies customer relationship management (CRM), invoicing, task and sprint orchestration, telemetry monitoring, and role-based access control (RBAC) into a unified, responsive web and desktop experience.

---

## Architecture Overview

The codebase is organized into domain-driven modular features following clean architecture principles:

```
lib/
├── app/                  # Application bootstrap, routing, theme, and global providers
├── core/                 # Shared infrastructure, base HTTP/Supabase clients, error handling
├── business_os/          # Business Operating System module
│   ├── core/             # BOS theme, layout shell, and network clients
│   └── features/         # CRM, Leads, Invoices, Products, Contacts, Organizations, Settings
├── pulse/                # Real-time operational telemetry, executive dashboards, KPIs
├── flow/                 # Sprint orchestration, task management, kanban, filter pipelines
└── shared/               # Shared cross-module widgets, adaptive app shell, state models
```

### Core Modules

* **Business OS (`lib/business_os/`)**: Handles CRM pipelines, quote & invoice generation, lead lifecycle stages, customer communications, and financial summaries.
* **Pulse (`lib/pulse/`)**: Executive observability suite providing real-time KPI telemetry, active deployment tracking, and store metrics.
* **Flow (`lib/flow/`)**: Sprint planning, agile task orchestration, multi-criteria filtering, and role-based task delegation.
* **Shared Shell (`lib/shared/`)**: Adaptive navigation rail, responsive layout wrappers, role-based view isolation, and profile switcher.

---

## Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.24.0` stable)
* [Dart SDK](https://dart.dev/get-dart) (`>=3.5.0`)
* Google Chrome (for web target) or desktop build tools
* Docker & Docker Compose (optional, for containerized execution)

### 1. Clone & Setup Environment

```bash
git clone https://github.com/VALIXIS/VALIXIS_PORTAL.git
cd VALIXIS_PORTAL

# Copy the environment template
cp .env.example .env
```

Open `.env` and fill in your Supabase configuration credentials:

```dotenv
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
WHATSAPP_SERVICE_URL=http://localhost:3000
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run Locally

Launch the portal in Chrome with web renderer:

```bash
flutter run -d chrome
```

For release web build:

```bash
flutter build web --release
```

---

## Containerized Execution (Docker)

To run the app inside an isolated container:

```bash
# Build and run the web server container
docker compose up --build
```

Access the portal at `http://localhost:8080`.

VS Code Dev Containers and GitHub Codespaces are pre-configured in `.devcontainer/devcontainer.json`.

---

## Testing & Quality Assurance

### Run Tests

Execute the full suite of unit, widget, and security tests:

```bash
flutter test
```

### Generate Coverage Report

```bash
flutter test --coverage
```

Code coverage is output to `coverage/lcov.info`.

### Static Analysis & Linting

Verify lint rules, formatting, and type checks:

```bash
flutter analyze
```

---

## Environment Variables Reference

| Variable | Description | Required | Default |
| :--- | :--- | :--- | :--- |
| `SUPABASE_URL` | Supabase project API gateway endpoint | Yes | — |
| `SUPABASE_ANON_KEY` | Public anonymous JWT client key | Yes | — |
| `WHATSAPP_SERVICE_URL`| Microservice endpoint for customer messaging | No | `http://localhost:3000` |
| `APP_ENV` | Runtime environment (`development`, `production`) | No | `development` |
| `PORT` | Local web preview server port | No | `8080` |

---

## Continuous Integration & Security

Every pull request and push to `main` undergoes automated verification via GitHub Actions:
* **Static Analysis**: Enforced by Dart analyzer via `flutter analyze`.
* **Automated Testing**: Unit and widget test suite execution via `flutter test --coverage`.
* **Security Scans**: Automated secret detection and dependency verification.
* **Hermetic Web Build**: Complete Flutter web compilation artifact generation.

---

## License

Proprietary and Confidential. Copyright © 2026 VALIXIS. All rights reserved.
