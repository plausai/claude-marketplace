---
description: The Director gives the CEO the state of play — in-flight work, open PRs and issues, blockers, spend position, and anything awaiting their decision.
argument-hint: "[optional focus, e.g. a project or issue]"
---

# /team:standup

Load the `team:director` skill (via the Skill tool) if not already active, then produce a stand-up for the CEO. Gather evidence rather than reciting memory:

1. `team/STATE.md` — the last recorded position.
2. `gh issue list` and `gh pr list` — the live position (open items, labels, review states).
3. `git log --oneline` since the last stand-up, and `git status` for uncommitted drift.
4. The ledger (`team/ledger/agents.jsonl`) for activity since the last report; run `/team:costs`-style estimation only if spend looks material.

Report: what moved, what is blocked and why, what is awaiting the CEO (with the decision memo for each), spend position against the £50 gate, and what the team intends to do next. Update `team/STATE.md` afterwards.

Focus: $ARGUMENTS
