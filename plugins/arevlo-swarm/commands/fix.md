---
description: Interactive fix mode - address swarm findings one by one
allowed-tools: Bash,Read,Write,Edit,AskUserQuestion,Glob,Grep
---

Interactive mode to fix issues found by swarm agents, one at a time.

## Usage

```
/fix [--critical] [--file <path>] [--agent <name>]
```

**Arguments:**
- `--critical` - Only show P0/HIGH priority issues (default)
- `--file <path>` - Only show issues in specific file
- `--agent <name>` - Only show issues from specific agent

## Steps:

1. **Load swarm findings:**
   - Read all reports from `.claude/swarm/reports/`
   - Parse issues and sort by priority (P0/HIGH first)
   - Filter based on arguments if provided

2. **Build issue queue:**
   ```
   Issue queue (6 total):
   1. [P0] main.ts:56-57 - Unhandled async message handler
   2. [P0] collector.ts:225 - Page load failures in global mode
   3. [P0] index.ts:6-19 - DOM elements without null checks
   4. [HIGH] main.ts:44-46 - Unsafe SceneNode assertion
   5. [HIGH] collector.ts:147 - Untyped boundVariables cast
   6. [HIGH] index.ts:206 - No runtime validation for messages
   ```

3. **Present first issue:**
   ```
   ┌─────────────────────────────────────────────────────────┐
   │  ISSUE 1/6 [P0]                                         │
   │                                                         │
   │  Unhandled async message handler                        │
   │  File: main.ts:56-57                                    │
   │  Agent: silent-hunter                                   │
   │                                                         │
   │  Problem:                                               │
   │  Async handler lacks try/catch. Errors will silently   │
   │  fail and break message flow.                          │
   │                                                         │
   │  Current code:                                          │
   │  ```typescript                                          │
   │  onmessage = async (msg) => {                          │
   │    await processMessage(msg);                          │
   │  }                                                      │
   │  ```                                                    │
   └─────────────────────────────────────────────────────────┘
   ```

4. **Ask user how to proceed:**

   Use AskUserQuestion tool:
   ```json
   {
     "questions": [{
       "question": "How would you like to handle this issue?",
       "header": "Action",
       "options": [
         {"label": "Fix it (Recommended)", "description": "Claude will implement the fix and show you the diff"},
         {"label": "Skip", "description": "Move to next issue without fixing"},
         {"label": "View file", "description": "Open and read the file for more context"},
         {"label": "Exit fix mode", "description": "Stop fixing, return to normal mode"}
       ],
       "multiSelect": false
     }]
   }
   ```

5. **Based on response:**

   **If "Fix it":**
   - Read the file at the specified location
   - Analyze the issue in context
   - Implement the fix using Edit tool
   - Show the diff:
     ```
     Fixed: main.ts:56-57

     - onmessage = async (msg) => {
     -   await processMessage(msg);
     - }
     + onmessage = async (msg) => {
     +   try {
     +     await processMessage(msg);
     +   } catch (error) {
     +     console.error('Message handler error:', error);
     +     figma.notify('Error processing message', { error: true });
     +   }
     + }

     [1/6 complete] Next issue? [Y/n]
     ```
   - Move to next issue

   **If "Skip":**
   - Move to next issue without changes
   - Track skipped issues for summary

   **If "View file":**
   - Read and display the file around the issue location
   - Re-ask the action question

   **If "Exit fix mode":**
   - Show summary of completed/skipped issues
   - Exit command

6. **Continue until queue empty or user exits**

7. **Show completion summary:**
   ```
   ┌─────────────────────────────────────────────────────────┐
   │  FIX MODE COMPLETE                                      │
   │                                                         │
   │  Fixed: 4 issues                                        │
   │  Skipped: 2 issues                                      │
   │                                                         │
   │  Files modified:                                        │
   │  - main.ts (2 fixes)                                    │
   │  - collector.ts (1 fix)                                 │
   │  - index.ts (1 fix)                                     │
   │                                                         │
   │  Skipped issues saved to:                               │
   │  .claude/swarm/skipped.md                               │
   │                                                         │
   │  Run tests to verify fixes: npm test                    │
   └─────────────────────────────────────────────────────────┘
   ```

## Fix Strategies by Issue Type

### Unhandled async (silent-hunter)
- Wrap in try/catch
- Add appropriate error handling (log, notify, rethrow)
- Consider error boundaries for React components

### Type issues (type-analyzer)
- Add explicit type annotations
- Replace `any` with proper types
- Add null checks where needed
- Use type guards for runtime validation

### Complexity (reviewer)
- Extract helper functions
- Simplify conditionals
- Break down large functions

### Missing null checks (silent-hunter)
- Add optional chaining (`?.`)
- Add nullish coalescing (`??`)
- Add explicit null checks with early returns

## Notes

- Fix mode reads issues from swarm reports
- All fixes are made using the Edit tool (shows diffs)
- Skipped issues are saved for later review
- After fixing, agents will re-analyze if in watch mode
- Run tests after completing fix mode to verify changes
