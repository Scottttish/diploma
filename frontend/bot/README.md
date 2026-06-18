# ASAR Telegram bot

A Telegram bot for managing service requests and customer inquiries. Users can create requests, track status, view history, and receive real-time notifications entirely inside Telegram.

---

## Features

User registration is performed once per account, optionally collecting a phone number for callback support.

Service requests can be created with structured input including service type, description, and optional location. Location input supports both Telegram geolocation and manual address entry, with automatic reverse geocoding.

Users can track all requests with full metadata including status, priority, creation time, and deadline. Individual request status can be queried by ID.

The system provides real-time notifications when request status changes (e.g., assigned, in progress, completed).

The interface supports multiple languages with full Russian localization and backend-ready architecture for additional languages.

Navigation is based on a persistent menu with quick access to main functions.

---

## User Flow

Start: User launches the bot using `/start`, triggering registration with Telegram profile data and optional phone number.

Create Request: User selects service type, enters description, and optionally provides location.

Review & Submit: A summary is generated for confirmation before submission.

Track Progress: Users can view all requests or query a specific request status.

Receive Updates: The bot pushes notifications when request status changes.

---

## Installation

Clone repository and navigate to bot directory:

```bash
cd frontend/bot
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Create `.env` file:

```env
BOT_TOKEN=<your_telegram_bot_token>
BACKEND_URL=http://localhost:8000
TELEGRAM_WEBHOOK_SECRET=<optional_webhook_secret>
NOTIFY_SERVER_HOST=0.0.0.0
NOTIFY_SERVER_PORT=8080
```

Run the bot:

```bash
python main.py
```

---

## Configuration

Configuration is managed via environment variables loaded from `.env`.

* `BOT_TOKEN` - Telegram bot token from BotFather (required)
* `BACKEND_URL` - Backend API base URL (default: [http://localhost:8000](http://localhost:8000))
* `TELEGRAM_WEBHOOK_SECRET` - Optional webhook authentication secret
* `NOTIFY_SERVER_HOST` - Host for notification server (default: 0.0.0.0)
* `NOTIFY_SERVER_PORT` - Port for notification server (default: 8080)

---

## Usage

### Commands

* `/start` - Register and initialize bot
* `/create` - Create a new service request
* `/tasks` - List all user requests
* `/status` - Check request status by ID
* `/help` - Show help and status descriptions
* `/cancel` - Cancel current operation

### Menu Buttons

* Create Request - Start new request flow
* My Requests - View request history
* Request Status - Lookup request by ID
* Help - Instructions and status reference

---

## Project Structure

```
main.py                 Bot entry point (polling + dispatcher setup)
config.py              Environment configuration (Pydantic)
handlers/
    start.py           User registration flow
    tasks.py           Request creation, listing, status lookup
    menu.py            Main menu and help handlers
keyboards/            Telegram UI keyboards
states/               FSM state definitions
services/
    api_client.py     Backend API communication layer
    geocoder.py       Reverse geocoding (OpenStreetMap)
notifications/
    webhook server    Receives backend status updates
```

---

## System Overview

The bot acts as a Telegram-based frontend for a service management backend. It provides structured request creation, persistent tracking, and push-based updates via a notification server.

Location data is normalized through geocoding before being stored or sent to backend systems.

All stateful interactions are handled using a finite state machine to ensure predictable multi-step workflows.
