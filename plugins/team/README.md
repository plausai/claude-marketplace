# team

An autonomous engineering team in a box, packaged as a Claude Code plugin. You are the CEO; a **Director** and **Visionary** report to you from the main conversation and steer a roster of role agents through delivery pipelines with real quality gates, a spend ledger, and hard guardrails.

## Design in one paragraph

Claude Code sub-agents cannot spawn sub-agents, and only the main conversation can talk to the user. So the two roles whose job is talking to the CEO — Director and Visionary — are **skills** that shape the main loop, while every delivery role is an **agent** the Director dispatches. The reporting hierarchy executes as sequencing: managers return plans and verdicts, the Director dispatches the next stage. Seniority is a dispatch policy rather than a set of duplicate agents (T1 → haiku, T2 → sonnet, T3 → staff-engineer at the session model), finance is a hook (data capture) plus a reporting agent, and the charter (`skills/director/assets/charter.md`, seeded into each project as `team/charter.md`) is the single source of truth for the chain of command, the fixed stack (Go, AWS, GitHub), and the escalation protocol (£50 spend gate; stack, external-surface, security-posture, and hiring decisions are always the CEO's).

## The roster

| Role | Kind | Job |
|------|------|-----|
| Director | skill (main loop) | Triage, convene, sequence, enforce spend gate, report to the CEO |
| Visionary | skill (main loop) | Strategy with the CEO; VISION.md / ROADMAP.md; challenges direction |
| engineering-manager | agent | Work breakdown, tiering, parallelisation plan |
| project-manager | agent | Backlog as GitHub issues with acceptance criteria |
| architect | agent | Design below stack level; ADRs in team/decisions/ |
| tech-lead | agent | Final technical review gate (APPROVE / REQUEST CHANGES) |
| staff-engineer | agent | T3: gnarly bugs, performance, cross-cutting work |
| backend-engineer | agent | Go implementation (the workhorse) |
| ai-engineer | agent | LLM features, prompts, evals, cost discipline |
| platform-engineer | agent | AWS/Terraform to plan stage; apply is gated |
| devops-engineer | agent | GitHub Actions, release mechanics, dev tooling |
| security-engineer | agent | Surface-delta review gate + govulncheck/secret evidence |
| qa-engineer | agent | Acceptance-criteria verification gate (PASS / FAIL) |
| tech-writer | agent | Docs, changelogs, README — verified against source |
| ops | agent | Runbooks, incidents, readiness reviews (one role, deliberately) |
| finance | agent | Spend reports from ledger + transcripts; £50 gate arithmetic |
| marketing-lead | agent | Positioning, naming, launch drafts; the CEO publishes |

There is deliberately **no frontend agent** — the charter ships without a frontend stack, and the first piece of frontend work triggers a stack decision by the CEO.

## Ceremonies

| Command | What happens |
|---------|--------------|
| `/team <ask>` | Director triages and routes — the front door |
| `/team:plan <intent>` | Vision check → PM backlog → architect input → the CEO approves before anything is built |
| `/team:build <issue\|task>` | EM breakdown → design → parallel implementation → QA + security + tech-lead gates → docs → PR (never merged) |
| `/team:standup` | Evidence-based state of play + decisions awaiting the CEO |
| `/team:costs` | Finance: spend by model and activity, USD/GBP, gate position |
| `/team:retro` | The team proposes changes to its own prompts/charter as a PR to this repo |
| `/team:vision <topic>` | Strategy session with the Visionary |

## Hooks

- **SessionStart** — in team-founded projects, injects the charter preamble and `team/STATE.md` so sessions resume with context. Silent elsewhere.
- **PostToolUse (Task/Agent)** — appends every dispatch to `team/ledger/agents.jsonl` (who, what, when, which model).
- **PreToolUse (Bash)** — guardrails: denies `gh pr merge`, `gh release`, force-pushes to main, `terraform apply|destroy`, destructive `aws`/`kubectl` calls. Override only with `TEAM_APPROVE=1` after the CEO's explicit approval in the conversation.
- **PreToolUse (Write/Edit)** — secret scan: blocks writes containing high-confidence credential patterns (AWS keys, GitHub/Anthropic/Slack tokens, private key blocks).

Honest note on enforcement: hooks are friction and audit, not cryptography — a model could construct commands that evade a regex. For hard enforcement, add `permissions.deny` rules in the consuming repo's `.claude/settings.json`.

## Project layout the team creates (`team/` in each consuming repo)

```
team/
  charter.md          # the constitution (seeded, per-project tunable)
  STATE.md            # current position, updated every ceremony
  prices.json         # rate card for /team:costs
  decisions/          # ADRs
  ledger/agents.jsonl # every dispatch (automatic)
  runbooks/           # ops procedures
  VISION.md ROADMAP.md marketing/   # as the Visionary/marketing produce them
```

## Install

```text
/plugin marketplace add plausai/claude-marketplace
/plugin install team@plausai
```

Then, inside a project the team should run, say `/team` and let the Director found the office.
