---
description: Start clawd-eyes backend server and web UI
allowed-tools: Bash,Read
---

# Start Clawd-Eyes

Start the clawd-eyes visual browser inspector servers.

## Instructions

1. **Find the clawd-eyes project:**
   - Search for a directory containing `clawd-eyes` with a `package.json` that has `"name": "clawd-eyes"`
   - Check common locations: current directory, parent directories, or ask the user
   - If not found, ask the user for the path to their clawd-eyes installation

2. **Kill any existing processes on clawd-eyes ports:**
   ```bash
   lsof -ti :4000 | xargs kill -9 2>/dev/null
   lsof -ti :4001 | xargs kill -9 2>/dev/null
   lsof -ti :5173 | xargs kill -9 2>/dev/null
   lsof -ti :9222 | xargs kill -9 2>/dev/null
   ```

3. **Start the servers** from the clawd-eyes directory:

   **Start backend** (in background):
   ```bash
   cd <clawd-eyes-path> && npm start &
   ```

   **Start web UI** (in background):
   ```bash
   cd <clawd-eyes-path>/web && npm run dev &
   ```

4. Wait a few seconds for servers to start

5. Report the status:
   - Backend API: http://localhost:4000
   - WebSocket: ws://localhost:4001
   - Web UI: http://localhost:5173
   - CDP: ws://localhost:9222

6. Inform the user they can open http://localhost:5173 in their browser

## Ports Used

| Port | Service |
|------|---------|
| 4000 | HTTP API |
| 4001 | WebSocket (live updates) |
| 5173 | Web UI (Vite dev server) |
| 9222 | Chrome DevTools Protocol |
