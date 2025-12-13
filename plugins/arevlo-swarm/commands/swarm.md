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
   - If exists, ask if user wants to stop existing swarm or add to it

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

## Notes

- Requires Claude Code with `--dangerously-skip-permissions` enabled
- Agents write to `.claude/swarm/reports/` for async review
- Use `/hive` to check agent status and findings
- Use `/sync` to consolidate findings into actionable items
