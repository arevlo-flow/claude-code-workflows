# Clawd-Eyes Plugin

Visual browser inspector for Claude Code. Control the clawd-eyes servers from Claude Code.

## Commands

| Command | Description |
|---------|-------------|
| `/clawd-eyes:start` | Start the backend and web UI servers |
| `/clawd-eyes:stop` | Stop all servers (kills processes on ports) |
| `/clawd-eyes:status` | Check if servers are running |
| `/clawd-eyes:open` | Open the web UI in browser |

## Ports Used

| Port | Service |
|------|---------|
| 4000 | HTTP API |
| 4001 | WebSocket (live updates) |
| 5173 | Web UI (Vite dev server) |
| 9222 | Chrome DevTools Protocol |

## Requirements

- clawd-eyes project installed locally
- Node.js and npm

## Quick Start

```
/clawd-eyes:start   # Start servers
/clawd-eyes:open    # Open web UI
# ... use the inspector ...
/clawd-eyes:stop    # Stop when done
```

## Installation

Clone the clawd-eyes repository:
```bash
git clone https://github.com/arevlo/clawd-eyes.git
cd clawd-eyes
npm install
cd web && npm install
```
