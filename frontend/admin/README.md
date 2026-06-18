# ASAR Admin Panel

## Overview

ASAR Admin is an administrative web interface for managing field service operations, task dispatching, and workforce coordination. It enables real-time monitoring of work orders, resource allocation, SLA control, and operational analytics for service organizations.

---

## Features

Task management covers the full lifecycle of service orders: creation, assignment, tracking, completion, and approval/rejection workflows.

Worker management includes role-based access control (worker, dispatcher, manager, administrator), skill assignment, and team structure administration.

Task dispatching is supported via an interactive interface with drag-and-drop assignment and workload visualization for balancing.

Service catalogs allow configuration of service types, equipment inventory, and SLA rules with automated deadline calculation.

The dashboard provides real-time operational metrics including task distribution by status, overdue tasks, and workforce load.

Analytics include performance indicators such as completion rates, productivity metrics, and service-type distribution.

Map view provides geographic visualization of tasks and equipment locations.

Real-time chat enables communication between dispatchers and field workers for operational coordination.

Notifications system delivers updates on task status changes and system events.

Multilingual support is available for English, Russian, and Kazakh interfaces.

Task history includes a full audit trail of status transitions with timestamps and comments.

File attachment support allows uploading and managing documents related to service orders.

---

## Admin Workflow

Authentication
Users log in with role-based access depending on their function (dispatcher, manager, administrator).

Dashboard Review
Operational overview of tasks, overdue items, and workforce availability.

Task Processing
Incoming tasks are reviewed and assigned based on worker skills and current workload.

Task Dispatching
Tasks are distributed using drag-and-drop interface or direct assignment.

Status Monitoring
Task progress is tracked through lifecycle stages from in-progress to completion.

Task Review
Completed tasks are verified and either approved or returned for correction.

Worker Communication
Chat is used to clarify task requirements and operational details.

Performance Analysis
Analytics are reviewed to evaluate productivity and SLA compliance.

System Administration
User accounts, service catalogs, equipment lists, and SLA configurations are maintained.

---

## Installation

### Prerequisites

* Node.js (LTS version recommended)
* npm or yarn package manager
* Backend services running (API required)

---

### Setup

Install dependencies:

```bash
npm install
```

Configure environment variables for API connection.

Start development server:

```bash
npm run dev
```

Build for production:

```bash
npm run build
```

---

## Configuration

The application depends on backend services for:

* Authentication
* Task and order management
* Worker and user data
* Service and equipment catalogs
* Analytics and reporting
* File storage and uploads

Configuration is managed through environment variables, primarily the backend API base URL.

The system supports English, Russian, and Kazakh languages via `vue-i18n`, with automatic language loading based on user settings.

---

## Usage

### Dispatchers

Monitor task pipeline through the dashboard, including status distribution and overdue items.

Assign tasks to workers using the scheduling interface or drag-and-drop planner.

Use the map view to monitor spatial distribution of active work.

Communicate with field workers via integrated chat for task clarification.

---

### Managers

Review workforce productivity and SLA compliance metrics.

Analyze business performance through analytics dashboards.

Monitor client-related activity and operational trends.

Access system-wide notifications and reports.

---

### Administrators

Manage user accounts including workers, dispatchers, and managers.

Configure service types, equipment catalogs, and operational rules.

Define SLA policies and enforcement parameters.

Control access permissions and role assignments.

Maintain system integrity through user and password management.

---

## Project Structure

```
src/
├── api/          Backend API integration layer
├── components/   Reusable UI components
│   ├── layout/   Page layout structures
│   ├── ui/       Base UI elements
│   └── animations/ UI animations
├── views/        Application pages (modules)
├── stores/       Pinia state management
├── router/       Vue Router configuration
├── i18n/         Localization (EN, RU, KK)
└── utils/        Utility functions and helpers
```

---

## Technologies

Vue 3 - Frontend framework for reactive UI
Vite - Build tool and development server
Pinia - State management system
Vue Router - Routing layer
Vue-i18n - Internationalization support
Tailwind CSS - Utility-first styling framework
Leaflet - Interactive map visualization
Axios - HTTP client for API communication
