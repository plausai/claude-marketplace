---
description: Run the team's planning pipeline — Visionary context check, PM turns intent into GitHub issues with acceptance criteria, architect weighs in where the shape is unclear. Nothing gets built until the CEO approves.
argument-hint: "[the initiative or intent to plan]"
---

# /team:plan

Load the `team:director` skill (via the Skill tool) if not already active, then run the **plan pipeline** on the intent below.

1. Read `team/VISION.md` and `team/ROADMAP.md` if present; flag any tension between this intent and the vision.
2. Dispatch the project-manager agent to draft the backlog: GitHub issues with acceptance criteria, labels (`team/backlog`, `tier:*`), and dependency order. Create them with `gh issue create`.
3. Where the technical shape is genuinely unclear, dispatch the architect for options and a recommendation.
4. Report to the CEO: the proposed backlog, the sequencing, spend estimate for delivering it, and every decision that is theirs (stack, spend, external surface). **Do not start building.**

Intent: $ARGUMENTS
