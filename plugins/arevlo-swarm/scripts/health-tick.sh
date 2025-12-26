#!/bin/bash
# Proxy signal monitoring - tracks tool usage as context estimate
# Part of swarm context awareness system

SWARM_DIR=".claude/swarm"
GUARDIAN_DIR="$SWARM_DIR/guardian"
METRICS_FILE="$GUARDIAN_DIR/metrics.json"

# Initialize if needed
mkdir -p "$GUARDIAN_DIR"
if [ ! -f "$METRICS_FILE" ]; then
  cat > "$METRICS_FILE" <<EOF
{
  "session_start": "$(date -Iseconds)",
  "tool_count": 0,
  "file_reads": 0,
  "file_writes": 0,
  "last_checkpoint": null,
  "alerts": []
}
EOF
fi

# Increment tool counter
TOOL_COUNT=$(jq -r '.tool_count' "$METRICS_FILE")
TOOL_COUNT=$((TOOL_COUNT + 1))

# Detect tool type from environment (if available)
# Note: This might need adjustment based on how Claude Code provides tool info
case "$TOOL_NAME" in
  Read|Glob|Grep)
    FILE_READS=$(jq -r '.file_reads' "$METRICS_FILE")
    FILE_READS=$((FILE_READS + 1))
    jq ".file_reads = $FILE_READS" "$METRICS_FILE" > tmp && mv tmp "$METRICS_FILE"
    ;;
  Write|Edit)
    FILE_WRITES=$(jq -r '.file_writes' "$METRICS_FILE")
    FILE_WRITES=$((FILE_WRITES + 1))
    jq ".file_writes = $FILE_WRITES" "$METRICS_FILE" > tmp && mv tmp "$METRICS_FILE"
    ;;
esac

# Update tool count
jq ".tool_count = $TOOL_COUNT | .last_check = \"$(date -Iseconds)\"" "$METRICS_FILE" > tmp && mv tmp "$METRICS_FILE"

# Threshold alerts (conservative estimates)
# Assume: 200 tool invocations ≈ 80% context (based on empirical observation)
# Therefore: 50 tools ≈ 20%, 100 ≈ 40%, 150 ≈ 60%, 175 ≈ 70%

if [ "$TOOL_COUNT" -eq 100 ]; then
  echo "📊 WATCH threshold reached ($TOOL_COUNT tools ≈ 40% context estimate)"
  jq '.alerts += ["WATCH: 100 tools used (~40% est), consider checkpoint"]' "$METRICS_FILE" > tmp && mv tmp "$METRICS_FILE"
fi

if [ "$TOOL_COUNT" -eq 150 ]; then
  echo "⚠️  WARNING threshold reached ($TOOL_COUNT tools ≈ 60% context estimate)"
  jq '.alerts += ["WARNING: 150 tools used (~60% est), checkpoint recommended"]' "$METRICS_FILE" > tmp && mv tmp "$METRICS_FILE"
  echo "⚠️  WARNING: Context at ~60% estimate. Consider running /checkpoint or /compact" > "$GUARDIAN_DIR/alert.txt"

  # Phase 3: Auto-prompt for export
  echo "" >> "$GUARDIAN_DIR/alert.txt"
  echo "To checkpoint now, run:" >> "$GUARDIAN_DIR/alert.txt"
  echo "  /export" >> "$GUARDIAN_DIR/alert.txt"
  echo "Save to: .claude/swarm/exports/warning-60pct-$(date +%Y%m%d-%H%M%S).txt" >> "$GUARDIAN_DIR/alert.txt"
fi

if [ "$TOOL_COUNT" -eq 175 ]; then
  echo "🚨 CRITICAL threshold reached ($TOOL_COUNT tools ≈ 70% context estimate)"
  jq '.alerts += ["CRITICAL: 175 tools used (~70% est), checkpoint urgently needed"]' "$METRICS_FILE" > tmp && mv tmp "$METRICS_FILE"
  echo "🚨 CRITICAL: Context at ~70% estimate. Run /checkpoint immediately or prepare handoff." > "$GUARDIAN_DIR/alert.txt"

  # Phase 3: Auto-prompt for export
  echo "" >> "$GUARDIAN_DIR/alert.txt"
  echo "URGENT - To checkpoint now, run:" >> "$GUARDIAN_DIR/alert.txt"
  echo "  /export" >> "$GUARDIAN_DIR/alert.txt"
  echo "Save to: .claude/swarm/exports/critical-70pct-$(date +%Y%m%d-%H%M%S).txt" >> "$GUARDIAN_DIR/alert.txt"
  echo "" >> "$GUARDIAN_DIR/alert.txt"
  echo "Or consider /handoff to spawn successor agent" >> "$GUARDIAN_DIR/alert.txt"
fi

exit 0
