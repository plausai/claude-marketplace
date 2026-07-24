---
description: Finance reports the team's model spend — per model, per session, in USD and GBP — from the ledger and session transcripts, plus AWS costs where credentials allow.
argument-hint: "[optional: 'aws' to include AWS Cost Explorer]"
---

# /team:costs

Dispatch the **finance** agent with the following brief, then relay its report to the CEO verbatim (plus your own one-line read on whether the £50 gate is near):

> Produce the team's spend report. Run `${CLAUDE_PLUGIN_ROOT}/scripts/cost-report.sh` from the repository root (it reads `team/prices.json` and this project's Claude Code transcripts). Cross-reference `team/ledger/agents.jsonl` for who spent it (which roles, which ceremonies). Present: totals in USD and GBP, breakdown by model, the most expensive activity, and the position against the £50 escalation gate. State the caveats honestly: transcript-based figures are approximate and include the CEO's own conversation turns, prices.json is a cached rate card, and the FX rate is manual. If asked for AWS ("aws" in the arguments), also attempt `aws ce get-cost-and-usage` for month-to-date, and degrade gracefully if credentials are absent.

Arguments: $ARGUMENTS
