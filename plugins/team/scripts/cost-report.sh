#!/usr/bin/env bash
#
# cost-report.sh — model spend for this project's Claude Code sessions.
#
# Reads every session transcript for the current project from
# ~/.claude/projects/<flattened-cwd>/*.jsonl, sums token usage per model,
# and prices it with team/prices.json (prefix-matched model keys, so
# date-suffixed IDs resolve). Emits a single JSON document.
#
# Caveats (also stated by the finance agent): figures are approximate;
# they cover the whole project's sessions, including the CEO's own turns;
# resumed sessions can double-count; prices.json is a cached rate card.
#
# Usage: cost-report.sh [transcript-dir]

set -euo pipefail

PRICES="team/prices.json"
if [ ! -f "$PRICES" ]; then
  echo "error: no team/prices.json in $(pwd) — run /team once to found the team directory" >&2
  exit 1
fi
command -v jq >/dev/null 2>&1 || { echo "error: jq is required" >&2; exit 1; }

DIR="${1:-$HOME/.claude/projects/$(pwd | tr '/' '-')}"
if [ ! -d "$DIR" ]; then
  echo "error: no transcript directory at $DIR" >&2
  exit 1
fi

shopt -s nullglob
files=("$DIR"/*.jsonl)
if [ ${#files[@]} -eq 0 ]; then
  echo '{"by_model":[],"total_usd":0,"total_gbp":0,"sessions":0,"note":"no transcripts found"}'
  exit 0
fi

jq -s --slurpfile P "$PRICES" '
  ($P[0]) as $prices |
  [ .[]
    | select((.message.usage? // empty) != null and (.message.model? // empty) != null)
    | {
        model: .message.model,
        in:  (.message.usage.input_tokens // 0),
        out: (.message.usage.output_tokens // 0),
        cw:  (.message.usage.cache_creation_input_tokens // 0),
        cr:  (.message.usage.cache_read_input_tokens // 0)
      }
  ]
  | group_by(.model)
  | map({
      model: .[0].model,
      input_tokens:       (map(.in)  | add),
      output_tokens:      (map(.out) | add),
      cache_write_tokens: (map(.cw)  | add),
      cache_read_tokens:  (map(.cr)  | add),
      calls: length
    })
  | map(
      . as $m |
      ( $prices.models
        | to_entries
        | map(.key as $k | select($m.model | startswith($k)))
        | (.[0].value // $prices.default)
      ) as $p |
      . + { usd: ((($m.input_tokens       * $p.input) +
                   ($m.output_tokens      * $p.output) +
                   ($m.cache_write_tokens * $p.cache_write) +
                   ($m.cache_read_tokens  * $p.cache_read)) / 1000000) }
    )
  | {
      by_model: .,
      total_usd: ((map(.usd) | add) // 0),
      total_gbp: (((map(.usd) | add) // 0) * ($prices.fx_usd_to_gbp // 0.78)),
      prices_note: ($prices._notes // "")
    }
' "${files[@]}" | jq --argjson n "${#files[@]}" '. + {sessions: $n}'
