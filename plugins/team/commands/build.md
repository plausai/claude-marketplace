---
description: Run the team's build pipeline on a task or GitHub issue — EM breakdown, design where needed, parallel implementation, QA + security + tech-lead gates, docs, then a PR. Never merges.
argument-hint: "[issue number, issue URL, or a description of the work]"
---

# /team:build

Load the `team:director` skill (via the Skill tool) if it is not already active, then run the **build pipeline** end to end on the target below.

Reminders that bite in practice:

- If the target is a GitHub issue, read it first with `gh issue view` — the acceptance criteria live there.
- Dispatch tiers per the charter: T1 → `model: haiku`, T2 → `model: sonnet`, T3 → staff-engineer at the session default. Independent tasks go out in parallel, in one message, with worktree isolation when they overlap on files.
- Gates are real: a REQUEST CHANGES verdict loops the work back with findings; the second failed loop escalates to staff-engineer.
- Estimate spend before starting. Above £50 estimated, stop and ask the CEO first.
- Finish with a PR via `gh` and the standard Director report. Never merge.

Target: $ARGUMENTS
