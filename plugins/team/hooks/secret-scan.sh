#!/usr/bin/env bash
#
# secret-scan.sh — PreToolUse hook (matcher: Write|Edit|MultiEdit) for the
# team plugin. The security engineer's automated arm: blocks file writes
# whose content matches well-known credential patterns. Conservative on
# purpose — high-confidence token shapes only, to keep false positives from
# becoming noise the team learns to ignore.
#
# Deny = exit 2 with the reason on stderr. Internal errors exit 0 (allow) —
# the hook must never brick a session.

set -u
trap 'exit 0' ERR

command -v jq >/dev/null 2>&1 || exit 0

content="$(cat | jq -r '(.tool_input.content // .tool_input.new_string // empty)' 2>/dev/null)"
[ -n "$content" ] || exit 0

deny() {
  echo "Blocked by team secret scan: content appears to contain $1. Credentials never go in files — use AWS Secrets Manager or environment configuration, and rotate this credential if it is real. If this is genuinely a dummy/test fixture, restructure it so it does not match a live credential format (e.g. AKIAXXXX...EXAMPLE)." >&2
  exit 2
}

printf '%s' "$content" | grep -Eq 'AKIA[0-9A-Z]{16}'                          && deny "an AWS access key ID"
printf '%s' "$content" | grep -Eq 'aws_secret_access_key\s*[=:]\s*[A-Za-z0-9/+=]{30,}' && deny "an AWS secret access key"
printf '%s' "$content" | grep -Eq 'ghp_[A-Za-z0-9]{30,}'                       && deny "a GitHub personal access token"
printf '%s' "$content" | grep -Eq 'github_pat_[A-Za-z0-9_]{20,}'               && deny "a GitHub fine-grained PAT"
printf '%s' "$content" | grep -Eq 'sk-ant-[A-Za-z0-9_-]{20,}'                  && deny "an Anthropic API key"
printf '%s' "$content" | grep -Eq 'xox[bpoas]-[A-Za-z0-9-]{10,}'               && deny "a Slack token"
printf '%s' "$content" | grep -Eq -- '-----BEGIN (RSA |EC |DSA |OPENSSH |PGP )?PRIVATE KEY( BLOCK)?-----' && deny "a private key block"

exit 0
