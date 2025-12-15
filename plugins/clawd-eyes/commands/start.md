---
description: Start clawd-eyes visual browser inspector
allowed-tools: Bash,TodoWrite
---

# Start clawd-eyes

Start the clawd-eyes visual browser inspector. This will clear any existing processes on the required ports and start the backend server and web UI.

## Instructions

1. **Kill existing processes on clawd-eyes ports**
   - Check ports 4000, 4001, 5173, 9222
   - Kill any processes using these ports with `kill -9`

2. **Navigate to clawd-eyes directory**
   ```bash
   cd ~/Desktop/personal-repos/clawd-eyes
   ```

3. **Check if dependencies are installed**
   - If `node_modules` doesn't exist, run `npm install`
   - If `web/node_modules` doesn't exist, run `cd web && npm install`

4. **Start the backend server in background**
   ```bash
   npm start &
   ```
   This launches the Playwright browser and WebSocket server on ports 4000/4001/9222.

5. **Start the web UI in background**
   ```bash
   cd web && npm run dev &
   ```
   This starts Vite dev server on port 5173.

6. **Report to user**
   - Backend: http://localhost:4000 (API), ws://localhost:4001 (WebSocket)
   - Web UI: http://localhost:5173
   - CDP: ws://localhost:9222

## Notes

- The backend must be started before the web UI
- Wait ~2 seconds between starting backend and web UI
- Use `lsof -i :<port>` to check what's using a port
- All processes run in background - use `/clawd-eyes:stop` to stop them
