#!/bin/bash
#
# Claude Code statusline. Runs on both macOS and the Linux clusters, so every
# external tool here is either POSIX or probed for both GNU and BSD spellings.

CACHE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/statusline_blocks_cache.json"
CACHE_MAX_AGE=60

# ccusage is a bun global; it is not always on PATH when Claude Code spawns us.
CCUSAGE=$(command -v ccusage 2>/dev/null)
if [ -z "$CCUSAGE" ] && [ -x "$HOME/.bun/bin/ccusage" ]; then
  CCUSAGE="$HOME/.bun/bin/ccusage"
fi

# timeout(1) is GNU; on macOS it arrives as gtimeout unless coreutils' gnubin
# is on PATH. Empty means "run without a time limit".
TIMEOUT=""
if command -v timeout >/dev/null 2>&1; then
  TIMEOUT="timeout 10"
elif command -v gtimeout >/dev/null 2>&1; then
  TIMEOUT="gtimeout 10"
fi

input=$(cat)

# Parse JSON without jq. BSD grep has no -P, so instead of a PCRE lookbehind we
# break the blob into one field per line and take the first match, which is the
# same semantics the old `grep -oP ... | head -1` had.
json_lines() { printf '%s' "$1" | tr '{},' '\n\n\n'; }
input_lines=$(json_lines "$input")

# extract_str <lines> <key> -> string value
extract_str() {
  printf '%s\n' "$1" | sed -n 's/.*"'"$2"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1
}
# extract_num <lines> <key> -> integer part of a bare (unquoted) numeric value.
# Integer-only on purpose: these feed $(( )), and a float there is a fatal
# arithmetic syntax error, not a rounding problem.
extract_num() {
  printf '%s\n' "$1" | sed -n 's/.*"'"$2"'"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -1
}

# Seconds since epoch for a file, GNU then BSD.
file_mtime() {
  stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}

# ISO-8601 UTC timestamp -> epoch seconds, GNU then BSD.
to_epoch() {
  local ts=$1 stripped
  date -d "$ts" +%s 2>/dev/null && return
  stripped=${ts%Z}
  stripped=${stripped%%.*}
  TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null && return
  echo 0
}

SESSION=$(extract_str "$input_lines" session_name)
[ -z "$SESSION" ] && SESSION=$(extract_str "$input_lines" session_id | cut -c1-8)
SESSION=${SESSION:-?}
MODEL=$(extract_str "$input_lines" display_name)
MODEL=${MODEL:-?}
PCT=$(extract_num "$input_lines" used_percentage | cut -d. -f1)
PCT=${PCT:-0}
DURATION_MS=$(extract_num "$input_lines" total_duration_ms | cut -d. -f1)
DURATION_MS=${DURATION_MS:-0}

# Colors
GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; DIM='\033[2m'; RESET='\033[0m'

if [ "$PCT" -ge 90 ] 2>/dev/null; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ] 2>/dev/null; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT * 10 / 100)); EMPTY=$((10 - FILLED))
BAR=$(printf "%${FILLED}s" | tr ' ' '#')$(printf "%${EMPTY}s" | tr ' ' '-')

# Duration in h m format, omit 0h
TOTAL_SECS=$((DURATION_MS / 1000))
D_HRS=$((TOTAL_SECS / 3600)); D_MINS=$(( (TOTAL_SECS % 3600) / 60 ))
if [ "$D_HRS" -gt 0 ]; then
  DURATION="${D_HRS}h ${D_MINS}m spent"
else
  DURATION="${D_MINS}m spent"
fi

# ccusage statusline
CCUSAGE_LINE=""
if [ -n "$CCUSAGE" ]; then
  CCUSAGE_LINE=$(printf '%s' "$input" | $TIMEOUT $CCUSAGE statusline 2>/dev/null || true)
fi

# Block budget: refresh cache if stale
USED_PCT="?"
PROJ_PCT="?"
NOW=$(date +%s)
if [ -f "$CACHE" ]; then
  CACHE_AGE=$((NOW - $(file_mtime "$CACHE")))
else
  CACHE_AGE=$((CACHE_MAX_AGE + 1))
fi

if [ -n "$CCUSAGE" ] && [ "$CACHE_AGE" -gt "$CACHE_MAX_AGE" ]; then
  mkdir -p "$(dirname "$CACHE")"
  (tmp=$(mktemp "${CACHE}.XXXXXX") || exit 0
   if $TIMEOUT $CCUSAGE blocks --active --token-limit max --json > "$tmp" 2>/dev/null; then
     mv "$tmp" "$CACHE"
   else
     rm -f "$tmp"
   fi) &
fi

TIME_LEFT="?"
if [ -f "$CACHE" ]; then
  CACHE_LINES=$(json_lines "$(cat "$CACHE")")
  TOTAL_TOKENS=$(extract_num "$CACHE_LINES" totalTokens)
  LIMIT=$(extract_num "$CACHE_LINES" limit)
  PROJ_TOKENS=$(extract_num "$CACHE_LINES" projectedUsage)
  if [ -n "$LIMIT" ] && [ "$LIMIT" -gt 0 ] 2>/dev/null; then
    [ -n "$TOTAL_TOKENS" ] && USED_PCT="$((TOTAL_TOKENS * 100 / LIMIT))%"
    [ -n "$PROJ_TOKENS" ] && PROJ_PCT="$((PROJ_TOKENS * 100 / LIMIT))%"
  fi
  # Compute time left from block endTime in UTC
  END_TIME=$(extract_str "$CACHE_LINES" endTime)
  if [ -n "$END_TIME" ]; then
    END_EPOCH=$(to_epoch "$END_TIME")
    NOW_UTC=$(date -u +%s)
    REMAIN_S=$((END_EPOCH - NOW_UTC))
    if [ "$REMAIN_S" -gt 0 ]; then
      TIME_LEFT="$((REMAIN_S / 3600))h $((REMAIN_S % 3600 / 60))m"
    else
      TIME_LEFT="0m"
    fi
  fi
fi

# Line 1
echo -e "${DIM}${MODEL}${RESET} | ${DIM}[$SESSION]${RESET} ${BAR_COLOR}${BAR}${RESET} ${PCT}% | ${USED_PCT} used | ${PROJ_PCT} proj | ${TIME_LEFT} left | ${DURATION}"

# Line 2: ccusage with model and (time left) stripped. ccusage prints its input
# validation errors on stdout, not stderr, so a payload it rejects would spill a
# multi-line blob into the statusline -- keep one line and drop known errors.
if [ -n "$CCUSAGE_LINE" ] && ! printf '%s' "$CCUSAGE_LINE" | grep -q 'Invalid input format'; then
  printf '%s\n' "$CCUSAGE_LINE" | head -1 | sed 's/^[^|]*| //; s/ ([^)]*left)//'
fi
