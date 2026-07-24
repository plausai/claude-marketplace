#!/usr/bin/env bash
#
# guardrails.sh — PreToolUse hook (matcher: Bash) for the team plugin.
#
# The enforcement arm of the charter's escalation protocol: irreversible or
# external-facing commands are denied unless the CEO has explicitly approved
# the exact action in the current conversation, signalled by prefixing the
# command with TEAM_APPROVE=1. The marker is deliberate friction and an
# audit trail, not cryptographic proof — the real gate is that the Director
# is instructed to use it only after the CEO's explicit approval.
#
# Deny = exit 2 with the reason on stderr (fed back to the model).
# Must never break a session on its own bugs: internal errors exit 0 (allow).

set -u
trap 'exit 0' ERR

command -v jq >/dev/null 2>&1 || exit 0

cmd="$(cat | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -n "$cmd" ] || exit 0

# CEO-approved override marker: allow, and rely on the transcript + ledger
# for the audit trail.
case "$cmd" in
  TEAM_APPROVE=1\ *) exit 0 ;;
esac

deny() {
  echo "Blocked by team guardrails: $1. This action is on the charter's escalation list — it needs the CEO's explicit approval. Escalate via the Director; once the CEO has approved this exact action in the conversation, re-run it prefixed with TEAM_APPROVE=1 (or the CEO runs it themselves)." >&2
  exit 2
}

# Merging and releasing — external surface, CEO only.
echo "$cmd" | grep -Eq '(^|[;&|]\s*)gh\s+pr\s+merge\b'        && deny "gh pr merge (merges are the CEO's)"
echo "$cmd" | grep -Eq '(^|[;&|]\s*)gh\s+release\b'            && deny "gh release (releases are the CEO's)"

# Force pushes to the mainline.
echo "$cmd" | grep -Eq 'git\s+push[^;|&]*(--force|-f)\b[^;|&]*\b(main|master)\b' && deny "force-push to main/master"
echo "$cmd" | grep -Eq 'git\s+push[^;|&]*\b(main|master)\b[^;|&]*(--force|-f)\b' && deny "force-push to main/master"

# Infrastructure mutation.
echo "$cmd" | grep -Eq 'terraform\s+(apply|destroy)\b'         && deny "terraform apply/destroy"
echo "$cmd" | grep -Eq '(^|[;&|]\s*)aws\s+\S+\s+(delete|terminate)[-a-z]*\b' && deny "destructive aws CLI call"
echo "$cmd" | grep -Eq '(^|[;&|]\s*)kubectl\s+delete\b'        && deny "kubectl delete"

exit 0
