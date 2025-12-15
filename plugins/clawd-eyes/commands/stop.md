---
description: Stop all clawd-eyes servers by killing processes on their ports
allowed-tools: Bash
---

# Stop Clawd-Eyes

Stop all clawd-eyes servers by killing processes on the ports they use.

## Ports to Kill

| Port | Service |
|------|---------|
| 4000 | HTTP API |
| 4001 | WebSocket |
| 5173 | Web UI (Vite) |
| 9222 | Chrome DevTools Protocol |

## Instructions

1. For each port (4000, 4001, 5173, 9222):
   - Check if anything is running: `lsof -ti :PORT`
   - If a process is found, kill it: `kill -9 $(lsof -ti :PORT)`

2. Run this command to kill all clawd-eyes ports at once:
   ```bash
   for port in 4000 4001 5173 9222; do
     pid=$(lsof -ti :$port 2>/dev/null)
     if [ -n "$pid" ]; then
       echo "Killing process on port $port (PID: $pid)"
       kill -9 $pid 2>/dev/null
     fi
   done
   ```

3. Verify all ports are now free:
   ```bash
   for port in 4000 4001 5173 9222; do
     if lsof -ti :$port >/dev/null 2>&1; then
       echo "Port $port still in use"
     else
       echo "Port $port is free"
     fi
   done
   ```

4. Report which processes were killed and confirm all servers are stopped

## Notes

- This will forcefully terminate any process on these ports
- If the Chromium browser was launched by clawd-eyes, it will be closed
- Safe to run even if servers aren't running (will just report ports are free)
