# arevlo-swarm

Multi-agent orchestration for Claude Code - spawn background agents for parallel code analysis.

## Overview

The swarm plugin enables a "hive mind" approach to code analysis by running multiple specialized agents simultaneously. Each agent focuses on a specific concern (code review, type safety, silent failures, etc.) and writes findings to shared reports.

```
┌─────────────────────────────────────────────────────────┐
│                    YOU (Claude Code)                    │
│                  Primary development                    │
└─────────────────────┬───────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌───────────┐  ┌───────────┐  ┌───────────┐
│ Reviewer  │  │   Type    │  │  Silent   │
│   Agent   │  │ Analyzer  │  │  Hunter   │
└───────────┘  └───────────┘  └───────────┘
        │             │             │
        └──────────────┴────────────┘
                      │
              .claude/swarm/
              (shared reports)
```

## Installation

```bash
/plugin install arevlo-swarm@claude-code-workflows
```

## Commands

| Command | Description |
|---------|-------------|
| `/swarm [preset]` | Start multi-agent swarm with preset or interactive selection |
| `/spawn <agent>` | Spawn a single background agent |
| `/hive` | Check status and findings from all agents |
| `/sync` | Consolidate findings into prioritized action items |
| `/stop [agent]` | Stop one or all running agents |

## Quick Start

### 1. Start a Figma Plugin Swarm

```bash
/swarm figma
```

This spawns three agents optimized for Figma plugin development:
- **reviewer**: Code quality and patterns
- **type-analyzer**: TypeScript and Figma API types
- **silent-hunter**: Unhandled promises and silent failures

### 2. Check Status

```bash
/hive
```

See which agents are running and their latest findings.

### 3. Review Findings

```bash
/sync
```

Consolidate all findings into a prioritized action list.

### 4. Stop When Done

```bash
/stop
```

## Presets

### `figma`
For Figma plugin development. Focuses on async handling, type safety, and plugin-specific patterns.

### `review`
General code review. Focuses on code quality, complexity, and documentation.

### `full`
All available agents for comprehensive analysis.

## Available Agents

| Agent | Focus | Best For |
|-------|-------|----------|
| `reviewer` | Code quality, patterns, best practices | General review |
| `simplifier` | Complexity reduction, DRY | Refactoring |
| `type-analyzer` | TypeScript type safety | TS projects |
| `silent-hunter` | Unhandled async, silent failures | Plugins, async |
| `comment-analyzer` | TODOs, FIXMEs, documentation | Cleanup |
| `test-analyzer` | Test coverage and quality | Testing |

## How It Works

### Shared Context

Agents communicate through files in `.claude/swarm/`:

```
.claude/swarm/
├── reports/        # Agent findings (timestamped)
├── issues/         # Extracted issues
├── context/        # Shared state
├── logs/           # Agent logs
├── pids/           # Process IDs
└── sync/           # Consolidated reports
```

### Context Management

The swarm approach helps manage context limits:
- Each agent has its own context window
- Agents write findings to files (not accumulating in your session)
- You load only what you need via `/sync` or `/load-context swarm`

## Requirements

- Claude Code with plugin support
- `--dangerously-skip-permissions` enabled for background agents
- Unix-like environment (macOS, Linux, WSL)

## Workflow Example

```bash
# Start your development session
cd my-figma-plugin

# Spawn the swarm
/swarm figma

# Work on your code...
# (agents analyze in background)

# Check what they found
/hive

# Get prioritized action list
/sync

# Fix critical issues
# (agents re-analyze automatically)

# When done
/stop
```

## Tips

1. **Start lean**: Begin with 2-3 agents, add more if needed
2. **Check `/hive` periodically**: See what agents have found
3. **Use `/sync` before big changes**: Get a clean action list
4. **Agents are additive**: They accumulate findings over time

## Customization

Agent behavior can be customized by editing files in `agents/`:
- `reviewer.md` - Code review focus areas
- `silent-hunter.md` - Failure patterns to detect
- `type-analyzer.md` - Type checking rules
- etc.

## License

MIT
