#!/usr/bin/env bash
#
# session-start.sh — SessionStart hook for the team plugin.
#
# If the current project has been founded (team/ exists), emit a short
# preamble plus the team's state so every session resumes where the last
# one left off. In repositories without a team/ directory this hook stays
# silent — the plugin should be invisible until engaged.
#
# Must never fail a session: on any error, exit 0 with no output.

set -u
trap 'exit 0' ERR

[ -f "team/STATE.md" ] || [ -f "team/charter.md" ] || exit 0

cat <<'PREAMBLE'
This project is run by an autonomous engineering team (team plugin). The human user is the CEO; the Director and Visionary report to them and steer the role agents. The charter at team/charter.md is the constitution: the stack is fixed (Go, AWS, GitHub), stack/spend/external decisions always escalate to the CEO, and the spend gate is £50. Engage the team with /team, or any ceremony (/team:plan, /team:build, /team:standup, /team:costs, /team:retro, /team:vision).

Current team state follows:
PREAMBLE

if [ -f "team/STATE.md" ]; then
  head -n 60 "team/STATE.md"
fi

exit 0
