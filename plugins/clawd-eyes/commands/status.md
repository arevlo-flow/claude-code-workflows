---
description: Check status of clawd-eyes servers
allowed-tools: Bash
---

# Check Clawd-Eyes Status

Check if clawd-eyes services are running.

## Instructions

1. **Check each service:**
   ```bash
   echo "=== clawd-eyes Status ===" && \
   echo "Browser CDP (9222): $(curl -s http://localhost:9222/json/version > /dev/null && echo 'Available' || echo 'Not available')" && \
   echo "Backend API (4000): $(lsof -i :4000 2>/dev/null | grep LISTEN > /dev/null && echo 'Running' || echo 'Not running')" && \
   echo "WebSocket (4001): $(lsof -i :4001 2>/dev/null | grep LISTEN > /dev/null && echo 'Running' || echo 'Not running')" && \
   echo "Web UI (5173): $(lsof -i :5173 2>/dev/null | grep LISTEN > /dev/null && echo 'Running' || echo 'Not running')"
   ```

2. **Report to user**
   - If all are running: "clawd-eyes is fully running"
   - If CDP not available: "No browser with CDP on port 9222. Start a browser with --remote-debugging-port=9222"
   - If backend not running: "Backend not running - use /clawd-eyes:start"
   - If web UI not running: "Web UI not running - use /clawd-eyes:start"

## Services

| Port | Service | Description |
|------|---------|-------------|
| 9222 | Browser CDP | User's browser with remote debugging |
| 4000 | Backend API | HTTP API for requests |
| 4001 | WebSocket | Live page updates |
| 5173 | Web UI | Vite dev server |

## URLs (when running)

| Service | URL |
|---------|-----|
| Web UI | http://localhost:5173 |
| API | http://localhost:4000 |
| WebSocket | ws://localhost:4001 |
| CDP | http://localhost:9222 |
