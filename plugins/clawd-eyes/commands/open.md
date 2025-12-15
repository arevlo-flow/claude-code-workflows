---
description: Open the clawd-eyes web UI in the default browser
allowed-tools: Bash
---

# Open Clawd-Eyes

Open the clawd-eyes web UI in the default browser.

## Instructions

1. First check if the web UI server is running on port 5173:
   ```bash
   lsof -ti :5173 >/dev/null 2>&1 && echo "running" || echo "not running"
   ```

2. If NOT running:
   - Inform the user the server is not running
   - Suggest running `/clawd-eyes:start` first
   - Do NOT open the browser

3. If RUNNING:
   - Open the URL in the default browser:
   ```bash
   open http://localhost:5173
   ```
   - Confirm the browser was opened

## URL

Web UI: http://localhost:5173
