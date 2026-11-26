#!/bin/bash
#
# Claude Code statusline. Runs on both macOS and the Linux clusters, so every
# external tool here is either POSIX or probed for both GNU and BSD spellings.
#
# One line: model+effort | context bar | session cost and tokens | 5h and 7d rate limits | prompt cache,
# with a coloured state bar above it while the session waits, asks or is done.
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

GREEN='\033[32m'; YELLOW='\033[33m'; ORANGE='\033[38;5;208m'; RED='\033[31m'
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
# Each shows the share of the limit still left, then the time left (◷): 5h until
# its reset, 7d as a share of the week. Both turn orange at 20% left and red at
# 10%; 5h is yellow from 30%, 7d once the limit left falls more than 5 points
# below the week left.
LIMITS=""
# This session's running totals: cost at API prices, then input (uncached and
# cache writes, i.e. what a cold cache re-sends; cheap cache reads left out) and
# output tokens summed over the main transcript's API
# replies, each counted once although it spans several lines. Only the bytes
# added since the last refresh are read: the offset, the totals and the last
# reply's counts (its lines can straddle a refresh) are kept per session.
COST=$(obj cost | sed -n 's/.*"total_cost_usd"[[:space:]]*:[[:space:]]*\([0-9.eE+-]*\).*/\1/p' | head -1)
# 950 -> 950, 45200 -> 45k, 1234567 -> 1.2M
fmt_tok() {
  if   [ "$1" -ge 1000000 ]; then printf '%d.%dM' $(($1/1000000)) $(($1%1000000/100000))
  elif [ "$1" -ge 1000 ];    then printf '%dk' $(($1/1000))
  else                            printf '%d' "$1"; fi
}
TRANSCRIPT=$(extract_str "$input_lines" transcript_path)
TOKENS=""
TOK_SID=$(extract_str "$input_lines" session_id); TOK_SID=${TOK_SID//[^A-Za-z0-9_-]/}
TOK_FILE="$HOME/.cache/claude-state/${TOK_SID:-none}.tok"
if [ -r "$TRANSCRIPT" ] && [ -n "$TOK_SID" ]; then
  # State: <offset> <in> <out> <last id> <last in> <last out>; reset when the
  # file shrank (rewritten) or there is none.
  read -r T_OFF T_IN T_OUT T_ID T_LIN T_LOUT 2>/dev/null < "$TOK_FILE"
  SIZE=$(wc -c < "$TRANSCRIPT" | tr -d ' ')
  case "$T_OFF$T_IN$T_OUT$T_LIN$T_LOUT" in ''|*[!0-9]*) T_OFF=0 ;; esac
  [ "$T_OFF" -gt "$SIZE" ] && T_OFF=0
  [ "$T_OFF" -eq 0 ] && { T_IN=0; T_OUT=0; T_ID=-; T_LIN=0; T_LOUT=0; }
  if [ "$SIZE" -gt "$T_OFF" ]; then
    # Byte counts need LC_ALL=C. A last line without its newline is still being
    # written: leave it for the next refresh.
    STATE=$(tail -c +$((T_OFF + 1)) "$TRANSCRIPT" | head -c $((SIZE - T_OFF)) | LC_ALL=C awk \
      -v off="$T_OFF" -v size=$((SIZE - T_OFF)) -v tin="$T_IN" -v tout="$T_OUT" \
      -v lid="$T_ID" -v lin="$T_LIN" -v lout="$T_LOUT" '
      function num(u, k) { return match(u, "\"" k "\":[0-9]+") ? substr(u, RSTART + length(k) + 3, RLENGTH - length(k) - 3) + 0 : 0 }
      function take(l,   id, u, o) {
        if (l !~ /"type":"assistant"/ || !match(l, /"id":"msg_[^"]*"/)) return
        id = substr(l, RSTART + 6, RLENGTH - 7)
        if (!match(l, /"usage":\{/)) return
        u = substr(l, RSTART)
        in_[id] = num(u, "input_tokens") + num(u, "cache_creation_input_tokens")
        o = num(u, "output_tokens"); if (o > out[id]) out[id] = o
        lid = id
      }
      BEGIN { in_[lid] = lin; out[lid] = lout; tin -= lin; tout -= lout }
      { if (n) take(prev); prev = $0; n = 1; bytes += length($0) + 1 }
      END {
        if (n && bytes <= size) take(prev); else if (n) bytes -= length(prev) + 1
        for (i in in_) { tin += in_[i]; tout += out[i] }
        print off + bytes, tin, tout, lid, in_[lid], out[lid]
      }')
    if [ -n "$STATE" ]; then
      read -r T_OFF T_IN T_OUT T_ID T_LIN T_LOUT <<< "$STATE"
      mkdir -p "${TOK_FILE%/*}" 2>/dev/null && printf '%s\n' "$STATE" > "$TOK_FILE" 2>/dev/null
    fi
  fi
  TOKENS=" ↑$(fmt_tok "${T_IN:-0}") ↓$(fmt_tok "${T_OUT:-0}")"
fi
[ -n "$COST" ] && LIMITS=" | ${DIM}$(LC_NUMERIC=C printf '$%.0f' "$COST" 2>/dev/null)${TOKENS}${RESET}"
FIVE=$(obj five_hour)
F_PCT=$(extract_num "$FIVE" used_percentage)
if [ -n "$F_PCT" ]; then
  F_RESET=$(extract_num "$FIVE" resets_at)
  F_LEFT=""
  [ -n "$F_RESET" ] && [ "$F_RESET" -gt "$NOW" ] && F_LEFT=" ◷ $(fmt_dur $((F_RESET - NOW)))"
  F_COLOR=$(threshold_color "$F_PCT")
  [ "$F_PCT" -ge 80 ] && [ "$F_PCT" -lt 90 ] && F_COLOR="$ORANGE"
  LIMITS="$LIMITS | ${F_COLOR}5h $((100 - F_PCT))%${RESET}${F_LEFT}"
fi
WEEK=$(obj seven_day)
W_PCT=$(extract_num "$WEEK" used_percentage)
if [ -n "$W_PCT" ]; then
  W_RESET=$(extract_num "$WEEK" resets_at)
  W_LEFT=""; W_COLOR="$GREEN"
  if [ -n "$W_RESET" ] && [ "$W_RESET" -gt "$NOW" ]; then
    LEFT=$(( (W_RESET - NOW) * 100 / 604800 ))
    W_LEFT=" ◷ ${LEFT}%"
    [ $((100 - W_PCT)) -lt $((LEFT - 5)) ] && W_COLOR="$YELLOW"
  fi
  [ "$W_PCT" -ge 80 ] && W_COLOR="$ORANGE"
  [ "$W_PCT" -ge 90 ] && W_COLOR="$RED"
  LIMITS="$LIMITS | ${W_COLOR}7d $((100 - W_PCT))%${RESET}${W_LEFT}"
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
# Columns a plain string takes: terminals draw ◷ two wide.
width() { local t=${1//◷/}; echo $(( 2 * ${#1} - ${#t} )); }

LINE="${DIM}${MODEL}${RESET} ${BAR_COLOR}${BAR}${RESET} ${PCT}%${LIMITS}${CACHE}"

# Full-width bar (per session, so per pane) on its own line above the stats:
# amber while the session waits on background work that will resume it, red
# when it is your move. A long wait label is cut at the pane edge, not wrapped.
if [ -n "$STATE_BG" ]; then
  PLAIN=" ${STATE_LABEL}"
  while [ "$(width "$PLAIN")" -ge "$COLS" ]; do PLAIN="${PLAIN%?}"; done
  PAD=$(( COLS - 1 - $(width "$PLAIN") ))
  [ "$PAD" -gt 0 ] && PLAIN="$PLAIN$(printf "%${PAD}s" "")"
  printf '%b%s%b\n' "$STATE_BG" "$PLAIN" "$RESET"
fi
printf '%b\n' "$LINE"
