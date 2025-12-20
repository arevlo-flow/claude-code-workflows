# clawd-eyes

Slash commands for managing clawd-eyes visual browser inspector.

## Commands

| Command | Description |
|---------|-------------|
| `/clawd-eyes:start` | Start backend + web UI (connects to existing browser) |
| `/clawd-eyes:stop` | Stop all clawd-eyes processes |
| `/clawd-eyes:status` | Check if services are running |
| `/clawd-eyes:open` | Open the web UI in default browser |
| `/clawd-eyes:watch` | Check for pending design requests |

## Prerequisites

**A browser must be running with CDP (Chrome DevTools Protocol) enabled on port 9222.**

### Option 1: Playwright-based project
If you have a Playwright project that launches a browser, add this arg:
```typescript
args: ['--remote-debugging-port=9222']
```

### Option 2: Launch Chrome manually
```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222
```

## Ports Used

| Port | Service |
|------|---------|
| 9222 | Browser CDP (user's browser) |
| 4000 | HTTP API |
| 4001 | WebSocket |
| 5173 | Web UI (Vite) |

## Requirements

- clawd-eyes repo cloned locally
- Node.js installed
- Dependencies installed (`npm install` in both root and `web/` directories)
- A browser running with `--remote-debugging-port=9222`

## Installation

1. Clone clawd-eyes: `git clone https://github.com/arevlo/clawd-eyes.git`
2. Install dependencies: `cd clawd-eyes && npm install && cd web && npm install`
3. Start a browser with CDP enabled (see Prerequisites above)
4. Start with `/clawd-eyes:start`

## Workflow

1. Start a browser with `--remote-debugging-port=9222`
2. Run `/clawd-eyes:start` to launch backend + web UI
3. Run `/clawd-eyes:open` to open the web UI
4. Navigate to pages in your browser
5. Click elements in the web UI to inspect them
6. Add instructions and click "Send to clawd-eyes"
7. Run `/clawd-eyes:watch` to check for requests
8. Use `get_design_context` MCP tool to get full details with screenshot

## Architecture

- **Backend** (`npm start`): Connects to existing browser via CDP, captures screenshots and DOM
- **Web UI** (`web/`): React app for viewing page screenshots and selecting elements
- **MCP Server**: Exposes `get_design_context`, `clear_design_context`, `list_elements` tools

## How It Works

1. Backend connects to browser via CDP (port 9222)
2. Captures screenshots and DOM when pages load
3. Sends data to web UI via WebSocket
4. Web UI displays screenshot with element overlays
5. User selects elements and sends design requests
6. MCP tools expose the data to Claude Code
