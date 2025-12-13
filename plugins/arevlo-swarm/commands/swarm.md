---
description: Spawn and orchestrate multiple background agents for parallel workflows
allowed-tools: Bash,Read,Write,AskUserQuestion
---

Start a multi-agent swarm for parallel task execution. Agents run in separate terminals and communicate via shared files.

## Usage

```
/swarm [preset] [--watch] [--focus <path>]
```

**Flags:**
- `--watch` - Keep agents running continuously, re-analyze on file changes
- `--focus <path>` - Only analyze files in specified path (e.g., `--focus src/components`)

**Presets:**
- `review` - General code review (reviewer + simplifier + comment-analyzer)
- `quality` - Code quality focus (reviewer + type-analyzer + test-analyzer)
- `security` - Error handling & safety (silent-hunter + reviewer)
- `cleanup` - Tech debt reduction (simplifier + comment-analyzer)
- `full` - All available agents
- `figma` - Figma plugin development (reviewer + type-analyzer + silent-hunter)
- (none) - Auto-detect and recommend based on project

## Steps:

1. **Check for existing swarm:**
   - Look for `.claude/swarm/` directory
   - If directory does not exist: Proceed to step 2
   - If directory exists: Check if any agents are ACTUALLY running

   **a. Check PID liveness:**

   **bash/zsh (macOS, Linux, Git Bash, WSL):**
   ```bash
   running_count=0
   running_agents=""
   for pid_file in .claude/swarm/pids/*.pid 2>/dev/null; do
     if [ -f "$pid_file" ]; then
       agent=$(basename "$pid_file" .pid)
       pid=$(cat "$pid_file")
       if ps -p $pid > /dev/null 2>&1; then
         ((running_count++))
         running_agents="$running_agents $agent"
       fi
     fi
   done
   ```

   **PowerShell (Windows):**
   ```powershell
   $runningCount = 0
   $runningAgents = @()
   Get-ChildItem .claude/swarm/pids/*.pid -ErrorAction SilentlyContinue | ForEach-Object {
       $agent = $_.BaseName
       $pidValue = Get-Content $_.FullName
       if (Get-Process -Id $pidValue -ErrorAction SilentlyContinue) {
           $runningCount++
           $runningAgents += $agent
       }
   }
   ```

   **b. If ALL PIDs are dead (stale session):**

   Show message and auto-cleanup:
   ```
   Previous swarm session found. Checking status...

   All agents have completed. Archiving session...
   ```

   **Archive and cleanup (bash/zsh):**
   ```bash
   archive_dir=".claude/swarm/archive/$(date +%Y%m%d-%H%M%S)"
   mkdir -p "$archive_dir"
   mv .claude/swarm/reports/*.md "$archive_dir/" 2>/dev/null
   rm -f .claude/swarm/pids/*.pid
   rm -f .claude/swarm/manifest.json
   rm -f .claude/swarm/started_at
   # Keep only last 5 archives
   ls -dt .claude/swarm/archive/*/ 2>/dev/null | tail -n +6 | xargs rm -rf 2>/dev/null
   ```

   **Archive and cleanup (PowerShell):**
   ```powershell
   $archiveDir = ".claude/swarm/archive/$(Get-Date -Format 'yyyyMMdd-HHmmss')"
   New-Item -ItemType Directory -Force -Path $archiveDir
   Move-Item .claude/swarm/reports/*.md $archiveDir -ErrorAction SilentlyContinue
   Remove-Item .claude/swarm/pids/*.pid -ErrorAction SilentlyContinue
   Remove-Item .claude/swarm/manifest.json -ErrorAction SilentlyContinue
   Remove-Item .claude/swarm/started_at -ErrorAction SilentlyContinue
   # Keep only last 5 archives
   Get-ChildItem .claude/swarm/archive -Directory | Sort-Object CreationTime -Descending | Select-Object -Skip 5 | Remove-Item -Recurse -Force
   ```

   Show:
   ```
   ✓ Archived reports to .claude/swarm/archive/<timestamp>/
   ✓ Cleaned up stale state files

   Starting fresh swarm...
   ```

   Then proceed to step 2.

   **c. If SOME PIDs are still running:**

   Show running agents table and ask user:
   ```
   A swarm is already running with these agents:

   | Agent         | Focus                     | Status  |
   |---------------|---------------------------|---------|
   | reviewer      | Code quality and patterns | Running |
   | type-analyzer | TypeScript type issues    | Running |
   | silent-hunter | Unhandled async errors    | Running |

   What would you like to do?
   1. Keep existing swarm - Use /hive to check agent findings
   2. Stop and restart - Stop current swarm and start fresh with different preset
   3. Add agents - Add more agents to the existing swarm
   ```

   Use AskUserQuestion to get user choice.

2. **Initialize swarm directory:**

   **bash/zsh (macOS, Linux, Git Bash, WSL):**
   ```bash
   mkdir -p .claude/swarm/{reports,issues,context,logs,pids}
   echo "$(date -Iseconds)" > .claude/swarm/started_at
   ```

   **PowerShell (Windows):**
   ```powershell
   $dirs = @('reports','issues','context','logs','pids')
   $dirs | ForEach-Object { New-Item -ItemType Directory -Force -Path ".claude/swarm/$_" }
   Get-Date -Format o | Out-File .claude/swarm/started_at
   ```

3. **Select agents based on preset or auto-detect:**

   **If preset provided:** Use the preset configuration.

   **If no preset (auto-detect):**

   a. Detect project stack by checking for config files:
      - `tsconfig.json` → TypeScript → include `type-analyzer`
      - `package.json` with test script → include `test-analyzer`
      - `pytest.ini`, `setup.py`, `pyproject.toml` → Python project
      - `go.mod` → Go project
      - `Cargo.toml` → Rust project

   b. Check for indicators of tech debt:
      - Search for TODO/FIXME comments → many found → include `comment-analyzer`
      - Check for test directory → not found → include `test-analyzer`
      - Check git history → many commits → brownfield (include `simplifier`)

   c. Present recommendation to user:
      ```
      Detected: TypeScript project (React), no tests found

      Recommended agents:
        - reviewer (code quality)
        - type-analyzer (TypeScript)
        - test-analyzer (no tests detected)

      Proceed with these agents? [Y/n]
      ```

   d. If user declines, show available agents for manual selection.

   **Available agents:**
   | Agent | Description | Best for |
   |-------|-------------|----------|
   | `reviewer` | Code quality and patterns | General review |
   | `simplifier` | Reduce complexity | Refactoring, brownfield |
   | `type-analyzer` | TypeScript/type issues | TS projects |
   | `silent-hunter` | Unhandled async errors | Async code, plugins |
   | `comment-analyzer` | TODO/FIXME tracking | Documentation, cleanup |
   | `test-analyzer` | Test coverage gaps | Testing |

4. **Spawn selected agents:**
   - For each agent, run in background:

   **bash/zsh (macOS, Linux, Git Bash, WSL):**
   ```bash
   # Example for reviewer agent
   nohup claude --agent reviewer \
     --watch "src/**/*.ts" \
     --output ".claude/swarm/reports/reviewer-$(date +%s).md" \
     --dangerously-skip-permissions \
     > .claude/swarm/logs/reviewer.log 2>&1 &
   echo $! > .claude/swarm/pids/reviewer.pid
   ```

   **PowerShell (Windows):**
   ```powershell
   # Example for reviewer agent
   $timestamp = [int](Get-Date -UFormat %s)
   $process = Start-Process claude -ArgumentList @(
     '--agent', 'reviewer',
     '--watch', 'src/**/*.ts',
     '--output', ".claude/swarm/reports/reviewer-$timestamp.md",
     '--dangerously-skip-permissions'
   ) -RedirectStandardOutput ".claude/swarm/logs/reviewer.log" `
     -RedirectStandardError ".claude/swarm/logs/reviewer-err.log" `
     -PassThru -NoNewWindow
   $process.Id | Out-File .claude/swarm/pids/reviewer.pid
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

### review preset
General code review for any project.
```json
{
  "agents": ["reviewer", "simplifier", "comment-analyzer"],
  "watch": "**/*.{ts,tsx,js,jsx,py,go,rs}",
  "focus": "Code quality, complexity, documentation"
}
```

### quality preset
Code quality and correctness focus.
```json
{
  "agents": ["reviewer", "type-analyzer", "test-analyzer"],
  "watch": "**/*.{ts,tsx,js,jsx}",
  "focus": "Type safety, test coverage, patterns"
}
```

### security preset
Error handling and safety focus.
```json
{
  "agents": ["silent-hunter", "reviewer"],
  "watch": "**/*.{ts,tsx,js,jsx}",
  "focus": "Unhandled errors, async issues, failure modes"
}
```

### cleanup preset
Tech debt and documentation focus.
```json
{
  "agents": ["simplifier", "comment-analyzer"],
  "watch": "**/*.{ts,tsx,js,jsx,py,go,rs}",
  "focus": "Complexity reduction, TODO tracking, documentation"
}
```

### full preset
All available agents for comprehensive analysis.
```json
{
  "agents": ["reviewer", "simplifier", "type-analyzer", "silent-hunter", "comment-analyzer", "test-analyzer"],
  "watch": "**/*.{ts,tsx,js,jsx}",
  "focus": "Comprehensive code analysis"
}
```

### figma preset
Figma plugin development (example of domain-specific preset).
```json
{
  "agents": ["reviewer", "type-analyzer", "silent-hunter"],
  "watch": "src/**/*.{ts,tsx}",
  "focus": "Figma plugin patterns, async handling, type safety"
}
```

## Watch Mode

When `--watch` flag is used, agents run continuously and re-analyze when files change.

**Behavior:**
- Agents stay running after initial analysis
- File changes trigger re-analysis of affected files
- New findings are appended to reports
- Use `/hive` to see latest findings at any time

**Watch mode workflow:**
```
┌─────────────────────────────────────────────────────────┐
│  SWARM (watch mode)                                     │
│                                                         │
│  Agents are watching for changes...                     │
│  Last analysis: 2 min ago                               │
│                                                         │
│  You: [make code changes]                               │
│  Agents: [re-analyze changed files]                     │
│  You: /hive → see new findings                          │
│  You: /fix → address issues                             │
│  Agents: [re-analyze fixed files]                       │
│  ...continuous feedback loop...                         │
│                                                         │
│  Use /swarm stop to end watch mode                      │
└─────────────────────────────────────────────────────────┘
```

**When to use watch mode:**
- During active development sessions
- When refactoring large portions of code
- When you want continuous feedback as you code

**When NOT to use watch mode:**
- One-time code review before PR
- Quick analysis of unfamiliar codebase
- Resource-constrained environments

## Focus Mode

When `--focus <path>` flag is used, agents only analyze files in the specified path.

**Examples:**
```bash
/swarm figma --focus src/components    # Only analyze components
/swarm review --focus src/api          # Only review API code
/swarm --focus src/features/auth       # Focus on auth feature
```

**Use cases:**
- Large monorepo with many packages
- Working on specific feature area
- Reducing noise from unrelated code

## Notes

- Requires Claude Code with `--dangerously-skip-permissions` enabled
- Agents write to `.claude/swarm/reports/` for async review
- Use `/hive` to check agent status and findings
- Use `/sync` to consolidate findings into actionable items
- Use `/fix` to interactively address issues one by one
