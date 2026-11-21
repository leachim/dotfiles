#!/bin/bash
#
# Claude Code statusline. Runs on both macOS and the Linux clusters, so every
# external tool here is either POSIX or probed for both GNU and BSD spellings.
#
# One line: model+effort | context bar | 5h and 7d rate limits | prompt cache.
# Path, git branch and session name sit at the end of the prompt footer
# (claude/mods/footer-git, via bin/claude-footer); the open PR is the footer's
# own badge.

input=$(cat)
flat=$(printf '%s' "$input" | tr -d '\n')

# Parse JSON without jq. BSD grep has no -P, so instead of a PCRE lookbehind we
# break the blob into one field per line and take the first match.
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
# obj <key> -> field lines of the flat (no nested objects) object under <key>.
obj() {
  json_lines "$(printf '%s' "$flat" | sed -n 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*{\([^}]*\)}.*/\1/p')"
}

# 45s -> 0m, 7800s -> 2h10m, 280000s -> 3d5h
fmt_dur() {
  local s=$1
  if   [ "$s" -ge 86400 ]; then printf '%dd%dh' $((s/86400)) $((s%86400/3600))
  elif [ "$s" -ge 3600 ];  then printf '%dh%02dm' $((s/3600)) $((s%3600/60))
  else                          printf '%dm' $((s/60)); fi
}

GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'
DIM='\033[2m'; RESET='\033[0m'

# threshold_color <pct> -> green/yellow/red at 70 and 90
threshold_color() {
  if   [ "$1" -ge 90 ]; then printf '%s' "$RED"
  elif [ "$1" -ge 70 ]; then printf '%s' "$YELLOW"
  else                       printf '%s' "$GREEN"; fi
}

NOW=$(date +%s)

SESSION=$(extract_str "$input_lines" session_name)
[ -z "$SESSION" ] && SESSION=$(extract_str "$input_lines" session_id | cut -c1-8)
SESSION=${SESSION:-?}
MODEL=$(extract_str "$input_lines" display_name)
MODEL=${MODEL:-?}
EFFORT=$(extract_str "$(obj effort)" level)
[ -n "$EFFORT" ] && MODEL="$MODEL $EFFORT"

# Only context_window's own used_percentage: rate_limits.* reuse the key, and
# before the first API reply the context value is null, so a first-numeric-match
# search would fall through to the five-hour rate limit.
CTX_LINES=$(json_lines "$(printf '%s' "$flat" | sed -n 's/.*"context_window"//p' | sed 's/"rate_limits".*//')")
PCT=$(printf '%s\n' "$CTX_LINES" | grep -m1 '"used_percentage"' \
  | sed -n 's/.*:[[:space:]]*\([0-9][0-9]*\).*/\1/p')
PCT=${PCT:-0}
BAR_COLOR=$(threshold_color "$PCT")
FILLED=$((PCT * 10 / 100)); EMPTY=$((10 - FILLED))
BAR=$(printf "%${FILLED}s" | tr ' ' '#')$(printf "%${EMPTY}s" | tr ' ' '-')

# Rate limits: subscribers only, and only after the session's first API reply.
# 5h shows time to reset; 7d shows how much of the week is left (◷), yellow
# once usage outruns the time gone.
LIMITS=""
FIVE=$(obj five_hour)
F_PCT=$(extract_num "$FIVE" used_percentage)
if [ -n "$F_PCT" ]; then
  F_RESET=$(extract_num "$FIVE" resets_at)
  F_LEFT=""
  [ -n "$F_RESET" ] && [ "$F_RESET" -gt "$NOW" ] && F_LEFT=" $(fmt_dur $((F_RESET - NOW)))"
  LIMITS="$LIMITS | $(threshold_color "$F_PCT")5h ${F_PCT}%${RESET}${F_LEFT}"
fi
WEEK=$(obj seven_day)
W_PCT=$(extract_num "$WEEK" used_percentage)
if [ -n "$W_PCT" ]; then
  W_RESET=$(extract_num "$WEEK" resets_at)
  W_LEFT=""; W_COLOR="$GREEN"
  if [ -n "$W_RESET" ] && [ "$W_RESET" -gt "$NOW" ]; then
    LEFT=$(( (W_RESET - NOW) * 100 / 604800 ))
    W_LEFT=" ◷ ${LEFT}%"
    [ "$W_PCT" -gt $((100 - LEFT)) ] && W_COLOR="$YELLOW"
  fi
  [ "$W_PCT" -ge 90 ] && W_COLOR="$RED"
  LIMITS="$LIMITS | ${W_COLOR}7d ${W_PCT}%${RESET}${W_LEFT}"
fi

# Prompt cache: time until the cached prefix goes cold, and once cold, the
# tokens the next message re-sends (they count against the limits above).
# prompt_cache has nested objects, so read its keys from the whole payload;
# none of them occur elsewhere.
CACHE=""
if printf '%s\n' "$input_lines" | grep -q '"caching_observed"[[:space:]]*:[[:space:]]*true'; then
  C_EXP=$(extract_num "$input_lines" expires_at)
  if printf '%s\n' "$input_lines" | grep -q '"warm"[[:space:]]*:[[:space:]]*true' \
     && [ -n "$C_EXP" ] && [ "$C_EXP" -gt "$NOW" ]; then
    C_LEFT=$((C_EXP - NOW))
    C_COLOR="$DIM"; [ "$C_LEFT" -lt 300 ] && C_COLOR="$YELLOW"
    CACHE=" | ${C_COLOR}cache $(fmt_dur "$C_LEFT")${RESET}"
  else
    C_TOK=$(extract_num "$input_lines" recache_tokens_if_cold)
    CACHE=" | ${RED}cache cold${C_TOK:+ +$((C_TOK / 1000))k}${RESET}"
  fi
fi

# Busy state written by bin/claude-state from hooks: "<run|ask|idle> <start epoch>".
SESSION_ID=$(extract_str "$input_lines" session_id)
SESSION_ID=${SESSION_ID//[^A-Za-z0-9_-]/}

# Only the status line is told the session name; bin/claude-footer reads it here.
NAME_FILE="$HOME/.cache/claude-state/${SESSION_ID}.name"
if [ -n "$SESSION_ID" ] && [ "$(cat "$NAME_FILE" 2>/dev/null)" != "$SESSION" ]; then
  mkdir -p "${NAME_FILE%/*}" 2>/dev/null && chmod 700 "${NAME_FILE%/*}" 2>/dev/null
  printf '%s\n' "$SESSION" > "$NAME_FILE" 2>/dev/null
fi
STATE_BG=""; STATE_LABEL=""
STATE_FILE="$HOME/.cache/claude-state/${SESSION_ID:-none}"
if [ -n "$SESSION_ID" ] && read -r ST_STATE ST_START ST_LABEL 2>/dev/null < "$STATE_FILE"; then
  case "$ST_START" in ''|*[!0-9]*) ST_START=$NOW ;; esac
  S=$(( NOW - ST_START ))
  if   [ "$S" -ge 3600 ]; then EL=$(printf '%dh%02dm' $((S/3600)) $((S%3600/60)))
  elif [ "$S" -ge 60 ];   then EL=$(printf '%dm%02ds' $((S/60)) $((S%60)))
  else                         EL="${S}s"; fi
  case "$ST_STATE" in
    # run (actively working) keeps the normal colours on purpose.
    ask) STATE_BG='\033[97;41m'; STATE_LABEL="● needs you $EL" ;;
    wait) STATE_BG='\033[30;43m'; STATE_LABEL="◷ waiting $EL${ST_LABEL:+ on: $ST_LABEL}" ;;
    done) STATE_BG='\033[97;41m'; STATE_LABEL="✔ finished $EL ago" ;;
  esac
fi

# Pane width: tmux's when inside it, else what Claude Code sets; 85 (half a
# 13" screen) when neither says.
COLS=""
[ -n "$TMUX_PANE" ] && COLS=$(tmux display -p -t "$TMUX_PANE" '#{pane_width}' 2>/dev/null)
COLS=${COLS:-${COLUMNS:-0}}
[ "$COLS" -gt 0 ] 2>/dev/null || COLS=85

strip() { printf '%b' "$1" | sed $'s/\033\\[[0-9;]*m//g'; }

LINE="${DIM}${MODEL}${RESET} ${BAR_COLOR}${BAR}${RESET} ${PCT}%${LIMITS}${CACHE}"

# Full-width bar (per session, so per pane): amber while the session waits on
# background work that will resume it, red when it is your move. The label
# pushes the line past narrow panes; cut the end rather than wrap.
if [ -n "$STATE_BG" ]; then
  PLAIN=" ${STATE_LABEL} | $(strip "$LINE")"
  [ "${#PLAIN}" -ge "$COLS" ] && PLAIN="${PLAIN:0:COLS-1}" && PLAIN="${PLAIN% | *}"
  PAD=$(( COLS - 1 - ${#PLAIN} ))
  [ "$PAD" -gt 0 ] && PLAIN="$PLAIN$(printf "%${PAD}s" "")"
  printf '%b%s%b\n' "$STATE_BG" "$PLAIN" "$RESET"
else
  printf '%b\n' "$LINE"
fi
