---
description: Watch for design requests and notify when received
allowed-tools: Bash, mcp__clawd-eyes__get_design_context
---

# Watch for Design Requests

Poll the clawd-eyes MCP for pending design requests and notify when one arrives.

## Instructions

1. **Start polling loop**
   - Check every 3 seconds for pending requests
   - Use `mcp__clawd-eyes__get_design_context` tool
   - If response contains "No pending design request" → continue polling
   - If request found → notify user and stop

2. **On request found**
   - Display notification: "Design request received!"
   - Show brief summary: element selector + first 50 chars of instruction
   - Tell user: "Use `get_design_context` to see full details"

3. **Run in background**
   - This runs as a background task
   - User can continue working while watching
   - Stop after 5 minutes of no requests (timeout)
   - Maximum 100 poll attempts

4. **Polling implementation**
   - Use a loop counter to track attempts
   - Sleep 3 seconds between checks
   - Print "." every 10 checks to show still watching

## Usage

After starting clawd-eyes:
1. Run `/clawd-eyes:watch` to start watching
2. Select element in web UI and send request
3. Claude Code will notify you when request arrives
