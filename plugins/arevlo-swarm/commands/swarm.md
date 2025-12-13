---
description: Spawn and orchestrate multiple background agents for parallel workflows
allowed-tools: Bash,Read,Write,AskUserQuestion
---

Start a multi-agent swarm for parallel task execution. Agents run in separate terminals and communicate via shared files.

## Usage

```
/swarm [preset]
```

**Presets:**
- `figma` - Figma plugin development (reviewer + type analyzer + silent failure hunter)
- `review` - Code review suite (reviewer + simplifier + comment analyzer)
- `full` - All available agents
- (none) - Interactive selection

## Steps:

1. **Check for existing swarm:**
   - Look for `.claude/swarm/` directory
   - If exists, ask if user wants to stop existing swarm or add to it

2. **Initialize swarm directory:**
   ```bash
   mkdir -p .claude/swarm/{reports,issues,context}
   echo "$(date -Iseconds)" > .claude/swarm/started_at
   ```

3. **Select agents based on preset or prompt user:**
   
   **Available agents:**
   | Agent | Description | Best for |
   |-------|-------------|----------|
   | `reviewer` | Code quality and patterns | General review |
   | `simplifier` | Reduce complexity | Refactoring |
   | `type-analyzer` | TypeScript/type issues | TS projects |
   | `silent-hunter` | Unhandled async errors | Plugins, async code |
   | `comment-analyzer` | TODO/FIXME tracking | Documentation |
   | `test-analyzer` | Test coverage gaps | Testing |

4. **Spawn selected agents:**
   - For each agent, run in background:
   ```bash
   # Example for reviewer agent
   nohup claude --agent reviewer \
     --watch "src/**/*.ts" \
     --output ".claude/swarm/reports/reviewer-$(date +%s).md" \
     --dangerously-skip-permissions \
     > .claude/swarm/logs/reviewer.log 2>&1 &
   echo $! > .claude/swarm/pids/reviewer.pid
   ```

5. **Create swarm manifest:**
   - Write `.claude/swarm/manifest.json` with:
     - Active agents and their PIDs
     - Start time
     - Watch patterns
     - Report locations

6. **Output status:**
   - List running agents
   - Show how to check reports: `/hive`
   - Show how to stop: `/swarm stop`

## Presets Configuration

### figma preset
```json
{
  "agents": ["reviewer", "type-analyzer", "silent-hunter"],
  "watch": "src/**/*.{ts,tsx}",
  "focus": "Figma plugin patterns, async handling, type safety"
}
```

### review preset
```json
{
  "agents": ["reviewer", "simplifier", "comment-analyzer"],
  "watch": "src/**/*.{ts,tsx,js,jsx}",
  "focus": "Code quality, complexity, documentation"
}
```

## Notes

- Requires Claude Code with `--dangerously-skip-permissions` enabled
- Agents write to `.claude/swarm/reports/` for async review
- Use `/hive` to check agent status and findings
- Use `/sync` to consolidate findings into actionable items
