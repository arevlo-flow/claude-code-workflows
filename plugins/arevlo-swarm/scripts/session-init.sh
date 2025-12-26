#!/bin/bash
# Initialize swarm workspace and check for prior session exports
# Part of swarm context awareness system

SWARM_DIR=".claude/swarm"

# Create directory structure
mkdir -p "$SWARM_DIR"/{exports,progress,guardian,research,plans,context,handoff}

# Initialize metrics for new session
cat > "$SWARM_DIR/guardian/metrics.json" <<EOF
{
  "session_start": "$(date -Iseconds)",
  "tool_count": 0,
  "file_reads": 0,
  "file_writes": 0,
  "last_checkpoint": null,
  "alerts": []
}
EOF

# Check for prior session exports
RECENT_EXPORTS=$(find "$SWARM_DIR/exports" -name "*.txt" -type f -mtime -7 2>/dev/null | sort -r | head -3)

if [ -n "$RECENT_EXPORTS" ]; then
  echo "=== Prior Session Exports Available ==="
  echo ""
  echo "$RECENT_EXPORTS" | while read export_file; do
    filename=$(basename "$export_file")
    # Use platform-appropriate stat command
    if [[ "$OSTYPE" == "darwin"* ]]; then
      mod_time=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$export_file" 2>/dev/null)
    else
      mod_time=$(stat -c "%y" "$export_file" 2>/dev/null | cut -d' ' -f1,2 | cut -d: -f1,2)
    fi
    echo "  📄 $filename (modified: $mod_time)"
  done
  echo ""
  echo "To resume from a checkpoint, use: /resume"
  echo "========================================"
fi

echo "✓ Swarm workspace initialized"
echo "✓ Context monitoring active"
