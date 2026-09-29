#!/usr/bin/env bash
set -euo pipefail

STAT_ITERS=1000
FILE_ITERS=2000
LS_ITERS=200
SIZE_MB=256
KEEP_ARTIFACTS=0

usage() {
  cat <<'EOF'
Usage:
  fs-latency-bench.sh [options] [PATH ...]

Description:
  Runs filesystem latency micro-benchmarks and prints side-by-side results.
  If no PATH is provided, defaults are auto-selected from common cluster paths.

Options:
  -n, --stat-iters N    Number of stat() iterations (default: 1000)
  -f, --file-iters N    Number of touch/rm file iterations (default: 2000)
  -l, --ls-iters N      Number of ls iterations (default: 200)
  -s, --size-mb N       Size in MB for read/write tests (default: 256)
  -k, --keep            Keep test artifacts (for inspection)
  -h, --help            Show this help

Examples:
  fs-latency-bench.sh
  fs-latency-bench.sh "$HOME" "/cluster/home/$USER" "/cluster/work/bewi/members/$USER"
  fs-latency-bench.sh -n 2000 -f 3000 -s 512 "$HOME" "/cluster/home/$USER"
EOF
}

is_int() {
  [[ "${1:-}" =~ ^[0-9]+$ ]]
}

DATE_NOW_NS_FMT='+%s%N'
_sample_now_ns="$(date "$DATE_NOW_NS_FMT" 2>/dev/null || true)"
if ! [[ "$_sample_now_ns" =~ ^[0-9]+$ ]]; then
  echo "Error: this script requires GNU date with nanosecond support (%N)." >&2
  exit 1
fi
unset _sample_now_ns

declare -a INPUT_PATHS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--stat-iters)
      shift
      is_int "${1:-}" || { echo "Invalid --stat-iters value" >&2; exit 1; }
      STAT_ITERS="$1"
      ;;
    -f|--file-iters)
      shift
      is_int "${1:-}" || { echo "Invalid --file-iters value" >&2; exit 1; }
      FILE_ITERS="$1"
      ;;
    -l|--ls-iters)
      shift
      is_int "${1:-}" || { echo "Invalid --ls-iters value" >&2; exit 1; }
      LS_ITERS="$1"
      ;;
    -s|--size-mb)
      shift
      is_int "${1:-}" || { echo "Invalid --size-mb value" >&2; exit 1; }
      SIZE_MB="$1"
      ;;
    -k|--keep)
      KEEP_ARTIFACTS=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      INPUT_PATHS+=("$1")
      ;;
  esac
  shift
done

declare -a PATHS=()
if [[ ${#INPUT_PATHS[@]} -gt 0 ]]; then
  PATHS=("${INPUT_PATHS[@]}")
else
  PATHS+=("$HOME")
  [[ -d "/cluster/home/$USER" ]] && PATHS+=("/cluster/home/$USER")
  [[ -d "/cluster/work/bewi/members/$USER" ]] && PATHS+=("/cluster/work/bewi/members/$USER")
fi

if [[ ${#PATHS[@]} -eq 0 ]]; then
  echo "No valid paths to test." >&2
  exit 1
fi

# Remove duplicates while preserving order.
declare -A _seen_paths=()
declare -a _deduped_paths=()
for p in "${PATHS[@]}"; do
  if [[ -z "${_seen_paths[$p]+x}" ]]; then
    _seen_paths["$p"]=1
    _deduped_paths+=("$p")
  fi
done
PATHS=("${_deduped_paths[@]}")
unset _seen_paths _deduped_paths

declare -A RESULTS=()
declare -a TESTS=(
  "stat xN"
  "touch xN"
  "rm xN"
  "ls -la xN"
  "cat first read"
  "dd read"
  "dd write+fdatasync"
)

now_ns() {
  date "$DATE_NOW_NS_FMT"
}

fmt_ms() {
  local ms="$1"
  awk -v ms="$ms" 'BEGIN {
    if (ms < 0) { printf "ERR"; exit }
    if (ms >= 1000) { printf "%.3fs", ms/1000.0; exit }
    printf "%dms", ms
  }'
}

measure_ms() {
  local start end
  start="$(now_ns)"
  "$@"
  end="$(now_ns)"
  echo $(( (end - start) / 1000000 ))
}

sanitize_path_label() {
  local p="$1"
  if [[ "$p" == "$HOME" ]]; then
    echo "~"
  else
    echo "$p"
  fi
}

run_for_path() {
  local path="$1"
  local label="$2"
  local tmp_dir
  tmp_dir="$path/.fs-lat-bench.$$"

  if [[ ! -d "$path" ]]; then
    echo "Skipping non-directory path: $path" >&2
    return 0
  fi
  if [[ ! -w "$path" ]]; then
    echo "Skipping non-writable path: $path" >&2
    return 0
  fi

  mkdir -p "$tmp_dir"

  RESULTS["$label|stat xN"]="$(measure_ms bash -c "for ((i=1; i<=$STAT_ITERS; i++)); do stat \"$path\" >/dev/null 2>&1; done")"

  RESULTS["$label|touch xN"]="$(measure_ms bash -c "
    for ((i=1; i<=$FILE_ITERS; i++)); do
      : > \"$tmp_dir/f.\$i\"
    done
  ")"

  RESULTS["$label|rm xN"]="$(measure_ms bash -c "rm -f \"$tmp_dir\"/f.*")"

  RESULTS["$label|ls -la xN"]="$(measure_ms bash -c "for ((i=1; i<=$LS_ITERS; i++)); do ls -la \"$path\" >/dev/null 2>&1; done")"

  measure_ms bash -c "dd if=/dev/zero of=\"$tmp_dir/read.bin\" bs=1M count=\"$SIZE_MB\" conv=fsync status=none >/dev/null 2>&1" >/dev/null
  RESULTS["$label|cat first read"]="$(measure_ms bash -c "cat \"$tmp_dir/read.bin\" >/dev/null")"
  RESULTS["$label|dd read"]="$(measure_ms bash -c "dd if=\"$tmp_dir/read.bin\" of=/dev/null bs=4M status=none >/dev/null 2>&1")"

  local write_blocks=$(( (SIZE_MB + 3) / 4 ))
  RESULTS["$label|dd write+fdatasync"]="$(measure_ms bash -c "dd if=/dev/zero of=\"$tmp_dir/write.bin\" bs=4M count=\"$write_blocks\" conv=fdatasync status=none >/dev/null 2>&1")"

  if [[ "$KEEP_ARTIFACTS" -eq 0 ]]; then
    rm -rf "$tmp_dir"
  else
    echo "Kept artifacts: $tmp_dir" >&2
  fi
}

declare -a LABELS=()
for p in "${PATHS[@]}"; do
  LABELS+=("$(sanitize_path_label "$p")")
done

echo "Running benchmarks:"
for i in "${!PATHS[@]}"; do
  echo "  - ${LABELS[$i]} (${PATHS[$i]})"
done
echo

for i in "${!PATHS[@]}"; do
  run_for_path "${PATHS[$i]}" "${LABELS[$i]}"
done

printf "%-22s" "Test"
for label in "${LABELS[@]}"; do
  printf " | %18s" "$label"
done
echo

printf "%-22s" "----------------------"
for _ in "${LABELS[@]}"; do
  printf " | %18s" "------------------"
done
echo

for test in "${TESTS[@]}"; do
  printf "%-22s" "$test"
  for label in "${LABELS[@]}"; do
    key="$label|$test"
    v="${RESULTS[$key]:--1}"
    printf " | %18s" "$(fmt_ms "$v")"
  done
  echo
done

echo
echo "Notes:"
echo "  - 'stat/touch/rm/ls' reflect metadata latency."
echo "  - 'cat first read' reflects first-byte/read-open behavior on cached file."
echo "  - 'dd read/write' reflect sustained throughput plus sync cost."
