---
description: Start clawd-eyes backend server and web UI
allowed-tools: Bash,Read
---

# Start Clawd-Eyes

Start the clawd-eyes visual browser inspector servers.

## Prerequisites

**A browser must be running with CDP enabled on port 9222.**

If you have a Playwright-based project (like dusk), add this to the browser launch args:
```typescript
args: ['--remote-debugging-port=9222']
```

Or launch Chrome/Chromium manually:
```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222
```

## Instructions

1. **Verify a browser is running with CDP on port 9222:**
   ```bash
   curl -s http://localhost:9222/json/version > /dev/null && echo "Browser CDP available" || echo "No browser on port 9222"
   ```
   If no browser is running, inform the user they need to start one first.

2. **Find the clawd-eyes project directory:**
   - Check if current directory is clawd-eyes: `cat package.json 2>/dev/null | grep '"name": "clawd-eyes"'`
   - Check common locations: `~/clawd-eyes`, `~/projects/clawd-eyes`, `~/Desktop/clawd-eyes`
   - Search for it: `find ~ -maxdepth 4 -name "clawd-eyes" -type d 2>/dev/null | head -5`
   - If not found, ask the user for the path

3. **Kill any existing processes on clawd-eyes ports:**
   ```bash
   lsof -ti :4000 :4001 :5173 2>/dev/null | xargs kill -9 2>/dev/null; echo "Ports cleared"
   ```

4. **Start the backend server** (connects to existing browser via CDP):
   ```bash
   cd <clawd-eyes-path> && npm start
   ```
   Run this in background mode using the Bash tool's `run_in_background` parameter.

5. **Wait for backend to connect** (1-2 seconds)

6. **Start the web UI** (runs in background):
   ```bash
   cd <clawd-eyes-path>/web && npm run dev
   ```
   Run this in background mode using the Bash tool's `run_in_background` parameter.

7. **Wait for Vite to start** (1-2 seconds)

8. **Verify services are running:**
   ```bash
   echo "=== clawd-eyes Status ===" && \
   echo "Browser CDP (9222): $(curl -s http://localhost:9222/json/version > /dev/null && echo 'Connected' || echo 'Not available')" && \
   echo "Backend API (4000): $(lsof -i :4000 2>/dev/null | grep LISTEN > /dev/null && echo 'Running' || echo 'Not running')" && \
   echo "WebSocket (4001): $(lsof -i :4001 2>/dev/null | grep LISTEN > /dev/null && echo 'Running' || echo 'Not running')" && \
   echo "Web UI (5173): $(lsof -i :5173 2>/dev/null | grep LISTEN > /dev/null && echo 'Running' || echo 'Not running')"
   ```

9. **Report to user:**
   - Web UI: http://localhost:5173
   - clawd-eyes is connected to their existing browser
   - Navigate in the browser, inspect elements in the web UI

## Ports Used

| Port | Service |
|------|---------|
| 9222 | Browser CDP (user's browser) |
| 4000 | HTTP API |
| 4001 | WebSocket (live updates) |
| 5173 | Web UI (Vite dev server) |

## Notes

- Backend connects to existing browser via CDP - does NOT launch its own browser
- User's browser must have `--remote-debugging-port=9222` enabled
- Works with any Chromium-based browser (Chrome, Chromium, Brave, Edge)
- Supports browsers launched by Playwright with extensions loaded
