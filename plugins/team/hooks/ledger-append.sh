#!/usr/bin/env bash
#
# ledger-append.sh — PostToolUse hook (matcher: Task|Agent) for the team plugin.
#
# Finance's data-capture arm: every sub-agent dispatch in a team-founded
# project is appended to team/ledger/agents.jsonl as one JSON line —
# timestamp, session, transcript path, role, and task description. The
# /team:costs ceremony joins this activity log with transcript token usage.
#
# Silent in projects without a team/ directory. Must never fail a session:
# on any error, exit 0.

set -u
trap 'exit 0' ERR

[ -d "team" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

input="$(cat)"

mkdir -p team/ledger

printf '%s' "$input" | jq -c '{
  ts: (now | todate),
  session_id: (.session_id // null),
  transcript_path: (.transcript_path // null),
  role: (.tool_input.subagent_type // "unknown"),
  model: (.tool_input.model // null),
  task: (.tool_input.description // null)
}' >> team/ledger/agents.jsonl 2>/dev/null

exit 0
