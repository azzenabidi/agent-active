#!/bin/bash
# Streams agent activity events, one line per change.
#   Started agents:  +agent_name
#   Stopped agents:  -agent_name
#   Space-separated running list: agent1 agent2 ...
AGENTS="opencode claude codex gemini copilot crush grok omp pi"
MAINPID=$$
declare -A was_running
declare -A reported_stopped
prev=""

report() {
  local names='' p
  for p in $AGENTS; do
    pgrep -x "$p" >/dev/null 2>&1 && names="$names $p"
  done
  echo "${names# }"
}

emit_diff() {
  local cur running p
  cur="$(report)"
  running=($cur)

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
      unset "reported_stopped[$p]"
    else
      if [[ -n "${was_running[$p]+_}" && -z "${reported_stopped[$p]+_}" ]]; then
        reported_stopped[$p]=1
        echo "-$p"
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
  emit_diff
  sleep 0.4
done
