#!/bin/bash
# Streams agent activity events, one line per change.
#   Started agents:  +agent_name
#   Stopped agents:  -agent_name
#   Space-separated running list: agent1 agent2 ...
# Emits a running-list line after each event batch, and a stop event
# immediately when a watched PID exits (via per-PID watcher subshells).
AGENTS="opencode claude codex gemini copilot crush grok omp pi"
MAINPID=$$
declare -A was_running
prev=""

report() {
  local names='' p
  for p in $AGENTS; do
    pgrep -x "$p" >/dev/null 2>&1 && names="$names $p"
  done
  echo "${names# }"
}

emit_diff() {
  local cur running stopped p
  cur="$(report)"
  running=($cur)
  stopped=()

  for p in $AGENTS; do
    local is_running=false
    for r in "${running[@]}"; do
      [[ "$r" == "$p" ]] && is_running=true && break
    done
    if $is_running; then
      if [[ -z "${was_running[$p]+_}" ]]; then
        echo "+$p"
      fi
      was_running[$p]=1
    else
      if [[ -n "${was_running[$p]+_}" ]]; then
        echo "-$p"
        stopped+=("$p")
      fi
      unset "was_running[$p]"
    fi
  done

  if [[ "$cur" != "$prev" ]]; then
    prev="$cur"
    echo "$cur"
  fi
}

rm -f /tmp/agent-active.*
trap 'rm -f /tmp/agent-active.$$.*' EXIT
emit_diff
while true; do
  for p in $AGENTS; do
    for pid in $(pgrep -x "$p" 2>/dev/null); do
      guard="/tmp/agent-active.$$.$pid"
      if [[ ! -e "$guard" ]]; then
        touch "$guard"
        ( while kill -0 "$MAINPID" 2>/dev/null && kill -0 "$pid" 2>/dev/null; do sleep 0.05; done
          rm -f "$guard"
          if ! kill -0 "$MAINPID" 2>/dev/null; then exit 0; fi
          echo "-$p"
          report
        ) &
      fi
    done
  done
  emit_diff
  sleep 0.4
done
