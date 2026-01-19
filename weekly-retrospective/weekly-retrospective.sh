#!/bin/bash

# ============================================================
# Claude Code Weekly Retrospective Script
#
# Analyzes your Claude Code usage patterns and generates
# a weekly retrospective report.
#
# GitHub: https://github.com/bangdori/ai-tips
# ============================================================

set -e

# ========== Configuration (via Environment Variables) ==========
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
HISTORY_FILE="${HISTORY_FILE:-$CLAUDE_DIR/history.jsonl}"
STATS_FILE="${STATS_FILE:-$CLAUDE_DIR/stats-cache.json}"

# Output settings
OUTPUT_DIR="${RETROSPECTIVE_OUTPUT_DIR:-$CLAUDE_DIR/retrospectives}"
OUTPUT_FORMAT="${RETROSPECTIVE_FORMAT:-file}"  # file, stdout
ANALYSIS_DAYS="${RETROSPECTIVE_DAYS:-7}"

# Claude model (sonnet, opus, haiku)
CLAUDE_MODEL="${RETROSPECTIVE_MODEL:-sonnet}"

# ========== Initialize ==========
mkdir -p "$OUTPUT_DIR"

today=$(date +%Y-%m-%d)
# macOS uses -v, Linux uses -d
past_date=$(date -v-${ANALYSIS_DAYS}d +%Y-%m-%d 2>/dev/null || date -d "$ANALYSIS_DAYS days ago" +%Y-%m-%d)
output_file="$OUTPUT_DIR/retrospective-${today}.md"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
}

log "========== Weekly Retrospective Start =========="
log "Period: $past_date ~ $today"

# ========== Validate Data Files ==========
if [ ! -f "$HISTORY_FILE" ]; then
  log "Error: history.jsonl not found at $HISTORY_FILE"
  log "Make sure you have Claude Code installed and have used it at least once."
  exit 1
fi

# ========== Temp Files ==========
temp_dir=$(mktemp -d)
analysis_file="$temp_dir/analysis.json"
trap "rm -rf $temp_dir" EXIT

# Calculate timestamp (milliseconds)
past_ms=$(( ($(date +%s) - ANALYSIS_DAYS*24*60*60) * 1000 ))

# ========== 1. Collect User Inputs ==========
user_inputs=$(tail -1000 "$HISTORY_FILE" | jq -c --argjson cutoff "$past_ms" \
  'select(.timestamp > $cutoff) | select(.display | length > 0) | select(.display | startswith("/") | not)' 2>/dev/null | tail -150)
input_count=$(echo "$user_inputs" | grep -c . || echo 0)

# ========== 2. Collect Weekly Stats ==========
if [ -f "$STATS_FILE" ]; then
  weekly_stats=$(jq --arg from "$past_date" --arg to "$today" '
    .dailyActivity | map(select(.date >= $from and .date <= $to)) |
    {
      totalMessages: (map(.messageCount) | add // 0),
      totalSessions: (map(.sessionCount) | add // 0),
      totalToolCalls: (map(.toolCallCount) | add // 0),
      activeDays: length,
      dailyBreakdown: map({date, messages: .messageCount, sessions: .sessionCount, tools: .toolCallCount})
    }
  ' "$STATS_FILE" 2>/dev/null)
else
  weekly_stats='{"totalMessages":0,"totalSessions":0,"totalToolCalls":0,"activeDays":0,"dailyBreakdown":[]}'
fi

# ========== 3. Project Usage Stats ==========
project_stats=$(tail -1000 "$HISTORY_FILE" | jq -c --argjson cutoff "$past_ms" 'select(.timestamp > $cutoff)' 2>/dev/null | \
  jq -s 'group_by(.project) | map({project: (.[0].project | split("/") | last), count: length}) | sort_by(-.count) | .[0:5]' 2>/dev/null || echo "[]")

# ========== 4. Hourly Usage Pattern ==========
hourly_pattern=$(tail -1000 "$HISTORY_FILE" | jq -c --argjson cutoff "$past_ms" 'select(.timestamp > $cutoff)' 2>/dev/null | \
  jq -s 'map(.timestamp / 1000 | strftime("%H") | tonumber) | group_by(.) | map({hour: .[0], count: length}) | sort_by(.hour)' 2>/dev/null || echo "[]")

# ========== 5. Generate Analysis JSON ==========
cat > "$analysis_file" << EOF
{
  "period": "${past_date} ~ ${today}",
  "stats": $weekly_stats,
  "topProjects": $project_stats,
  "hourlyPattern": $hourly_pattern,
  "recentInputs": $(echo "$user_inputs" | jq -s '.' 2>/dev/null || echo "[]")
}
EOF

# Check minimum data
if [ "$input_count" -lt 3 ]; then
  log "Not enough data to analyze (only ${input_count} inputs found)"
  exit 0
fi

log "Data collected - ${input_count} inputs"

# ========== Call Claude API ==========
# Customize the prompt below to change retrospective format
PROMPT="You are a mentor helping developers with weekly retrospectives.

Here is Claude Code usage data for the past ${ANALYSIS_DAYS} days:

$(cat "$analysis_file")

Analyze this data and write a retrospective from these 3 perspectives:

## 1. Growth Areas
- Weaknesses observed in work patterns
- Repeated mistakes to address
- Suggested areas for further study

## 2. AI Usage Analysis
- Good: Effective patterns in using Claude
- Improve: Areas where Claude could have been used more efficiently
- Specific tips (prompt writing, tool usage, etc.)

## 3. Automation Suggestions
- If there are repetitive patterns, suggest automation methods
- Claude Code features: Hooks, Slash Commands, Skills
- Include actual example code or configurations

---

Guidelines:
- Keep each section to 2-4 sentences, focusing on key points
- Only mention things actually found in the data (don't make things up)
- If a section doesn't apply, simply say 'No notable patterns'
- Write in clean Markdown format
- Write in the same language as the user's inputs (if Korean inputs, respond in Korean)"

# Generate result
result=$(claude --model "$CLAUDE_MODEL" -p "$PROMPT" 2>&1)

# ========== Output ==========
case "$OUTPUT_FORMAT" in
  stdout)
    echo "$result"
    ;;
  file|*)
    {
      echo "# Weekly Retrospective"
      echo ""
      echo "> **Generated:** $(date '+%Y-%m-%d %H:%M:%S')"
      echo "> **Period:** ${past_date} ~ ${today}"
      echo "> **Model:** ${CLAUDE_MODEL}"
      echo ""
      echo "---"
      echo ""
      echo "$result"
    } > "$output_file"
    log "Saved to: $output_file"
    echo "$output_file"
    ;;
esac

log "========== Weekly Retrospective Complete =========="
