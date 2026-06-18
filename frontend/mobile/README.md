# ASAR Mobile app

## Project Title

ASAR – Mobile application for field service workers to manage assigned work orders, track progress, communicate with clients and dispatchers, and monitor performance metrics.

---

## Short Description

ASAR is a mobile solution for field professionals executing service tasks across a region. It supports work order lifecycle management, real-time GPS tracking, client/dispatcher communication, SLA monitoring, and work verification through photo evidence.

The application connects field operations with central dispatch systems through structured task management, location-aware workflows, and performance analytics.

---

## Features

User authentication is based on secure email/password login with session persistence.

Work orders can be viewed, accepted, and completed with real-time status updates. Each order includes SLA deadlines, service description, client details, and location data.

Real-time GPS tracking updates worker position periodically in the background.

Map integration provides visual task representation and route navigation support.

Communication is handled via in-app messaging integrated with external systems (e.g. Telegram bot).

Work completion requires photo-based verification with support for multiple images.

Each work order maintains a full activity timeline with timestamps and status changes.

Performance analytics provide KPI tracking, weekly trends, and monthly summaries.

A completed work ledger stores historical job records with duration and evidence data.

Support chat enables direct communication with technical support.

The interface supports multiple languages including English, Russian, and Kazakh.

Theme switching allows light and dark mode customization.

External navigation apps (Google Maps, etc.) can be launched from within the app.

---

## User Flow

1. Startup & Authentication
   User logs in using email credentials and optional session persistence.

2. Schedule View
   After login, the system displays assigned work orders for the current day.

3. Order Selection
   User opens a work order to view details, chat, or activity history.

4. Order Acceptance
   Assigned orders can be accepted, changing status to “In Progress”.

5. Navigation
   User views the job location on the map or launches external navigation.

6. Work Execution
   Field task is performed on-site according to service requirements.

7. Completion
   Order is completed by uploading required photo evidence.

8. Review
   Completed jobs are accessible via ledger and analytics dashboards.

9. Logout
   User can modify settings, change preferences, or sign out.

---

## Installation

### Prerequisites

* Flutter SDK 3.0+
* Dart SDK (bundled with Flutter)
* Android Studio / Xcode for device emulation or builds
* Physical device or emulator

---

### Setup

Install dependencies:

```bash id="k9q2lm"
flutter pub get
```

Run application:

```bash id="t7x8zc"
flutter run
```

---

## Configuration

The application depends on backend and device-level permissions.

Backend API configuration is handled via `ApiClient`.

Required permissions:

* Location access (GPS tracking)
* Camera and photo library (work verification)
* Storage access (secure token persistence)

Localization and theme preferences are stored locally and restored on startup.

Core configuration constants are defined in:
`lib/core/constants/app_constants.dart`

---

## Usage

### Authentication

User logs in with email and password. Optional “remember me” enables session persistence.

---

### Work Order Management

Work orders are available in the schedule screen.

Each order includes:

* Service details
* SLA deadline
* Location data
* Client contact information
* Status timeline

Available actions:

* Accept order (changes status to In Progress)
* View details (tabs: Details / Chat / Activity)
* Navigate to location
* Complete order with photo upload

---

### Navigation

Location can be:

* Viewed in embedded map
* Opened in external navigation apps (Google Maps, etc.)

---

### Completion Flow

To complete a work order:

* Perform required service task
* Upload at least one photo as proof
* Submit completion confirmation

---

### Analytics

Analytics screen provides:

* KPI metrics
* Weekly performance trends
* Monthly statistics
* Historical comparisons

---

### Completed Work Ledger

Includes:

* List of finished work orders
* Duration tracking
* Photo count per task
* Paginated history with refresh support

---

### Settings

User can:

* Change password
* Switch theme (light/dark)
* Change language
* Access support chat
* Sign out

---

## Project Structure

Layered architecture:

lib/core
Core utilities, constants, networking, routing, theming.

lib/data
Data sources, repositories, API models.

lib/domain
Business logic entities and repository interfaces.

lib/presentation
UI layer with screens and state management.

---

### Main Screens

lib/presentation/screens/auth/ — Authentication
lib/presentation/screens/schedule/ — Work order list
lib/presentation/screens/work_order/ — Order details and actions
lib/presentation/screens/map/ — Location and routing
lib/presentation/screens/chat/ — Messaging system
lib/presentation/screens/analytics/ — Performance analytics
lib/presentation/screens/ledger/ — Completed jobs history
lib/presentation/screens/settings/ — User preferences
