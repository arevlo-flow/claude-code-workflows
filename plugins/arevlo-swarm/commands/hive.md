---
description: Check status of running agents and view their findings
allowed-tools: Bash,Read
---

View the status of all running swarm agents and their latest findings.

## Usage

```
/hive [agent] [--issues] [--summary]
```

**Arguments:**
- `agent` - (optional) Show only specific agent's status
- `--issues` - Show only issues/problems found
- `--summary` - Condensed summary of all findings

## Steps:

1. **Check for active swarm:**
   - Look for `.claude/swarm/manifest.json`
   - If not found, inform user no swarm is active

2. **Gather agent statuses:**
   ```bash
   for pid_file in .claude/swarm/pids/*.pid; do
     agent=$(basename "$pid_file" .pid)
     pid=$(cat "$pid_file")
     if ps -p $pid > /dev/null 2>&1; then
       echo "$agent: RUNNING (PID $pid)"
     else
       echo "$agent: STOPPED"
     fi
   done
   ```

3. **Display status table:**
   ```
   🐝 SWARM STATUS
   ═══════════════════════════════════════
   Agent           Status    Last Report
   ───────────────────────────────────────
   reviewer        RUNNING   2 min ago
   type-analyzer   RUNNING   5 min ago
   silent-hunter   STOPPED   15 min ago
   ═══════════════════════════════════════
   ```

4. **Show recent findings (if any):**
   - Read latest report from each agent
   - Summarize key findings:
     - Critical issues (🔴)
     - Warnings (🟡)
     - Suggestions (🟢)

5. **If `--issues` flag:**
   - Filter to only show problems found
   - Aggregate from `.claude/swarm/issues/`

6. **If `--summary` flag:**
   - One-line summary per agent
   - Total counts of issues found

## Output Example

```
🐝 SWARM STATUS
Started: 2024-01-15 10:30:00 (45 min ago)

AGENTS
┌─────────────────┬─────────┬─────────────┬──────────┐
│ Agent           │ Status  │ Last Report │ Findings │
├─────────────────┼─────────┼─────────────┼──────────┤
│ reviewer        │ 🟢 RUN  │ 2 min ago   │ 3 issues │
│ type-analyzer   │ 🟢 RUN  │ 5 min ago   │ 1 issue  │
│ silent-hunter   │ 🔴 STOP │ 15 min ago  │ 2 issues │
└─────────────────┴─────────┴─────────────┴──────────┘

RECENT FINDINGS
───────────────────────────────────────────────────────
🔴 [silent-hunter] Unhandled promise in figma.ts:45
   → async function missing try/catch
   
🟡 [reviewer] Complex function in handler.ts:120
   → Cyclomatic complexity: 15 (threshold: 10)
   
🟢 [type-analyzer] Type inference suggestion
   → Consider explicit return type in utils.ts:30
───────────────────────────────────────────────────────

Run /sync to consolidate and prioritize issues.
```

## Notes

- Shows real-time status of background agents
- Reports are accumulated over time
- Use `/sync` to consolidate findings into actionable tasks
