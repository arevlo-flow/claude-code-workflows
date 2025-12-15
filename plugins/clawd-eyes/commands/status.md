---
description: Check status of clawd-eyes servers
allowed-tools: Bash
---

# Clawd-Eyes Status

Check the status of all clawd-eyes servers and ports.

## Ports to Check

| Port | Service |
|------|---------|
| 4000 | HTTP API |
| 4001 | WebSocket |
| 5173 | Web UI (Vite) |
| 9222 | Chrome DevTools Protocol |

## Instructions

1. Check each port and report what's running:
   ```bash
   echo "=== Clawd-Eyes Server Status ==="
   echo ""
   for port in 4000 4001 5173 9222; do
     pid=$(lsof -ti :$port 2>/dev/null)
     if [ -n "$pid" ]; then
       cmd=$(ps -p $pid -o comm= 2>/dev/null)
       echo "Port $port: RUNNING (PID: $pid, Process: $cmd)"
     else
       echo "Port $port: NOT RUNNING"
     fi
   done
   ```

2. Try to hit the HTTP API status endpoint:
   ```bash
   curl -s http://localhost:4000/status 2>/dev/null || echo "API not responding"
   ```

3. Summarize the status:
   - All servers running: "Clawd-eyes is fully operational"
   - Some servers running: "Clawd-eyes is partially running" (list which)
   - No servers running: "Clawd-eyes is not running. Use /clawd-eyes:start to start"

4. If running, provide the URLs:
   - Web UI: http://localhost:5173
   - API: http://localhost:4000
   - WebSocket: ws://localhost:4001
