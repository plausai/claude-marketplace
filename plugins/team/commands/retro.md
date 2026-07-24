---
description: The team inspects its own performance — what worked, what thrashed, where money was wasted — and proposes concrete changes to its charter, prompts, and pipelines as a PR against the marketplace repo that ships this plugin.
argument-hint: "[optional scope, e.g. 'last build' or an issue number]"
---

# /team:retro

Load the `team:director` skill (via the Skill tool) if not already active, then run a retrospective. This is the team's self-improvement loop — the output is change, not therapy.

1. Gather evidence: `team/ledger/agents.jsonl` (dispatch counts, which roles were convened for what), gate outcomes recorded in STATE/issues (how often work bounced), spend via the finance route if material, and any friction the CEO raised in conversation.
2. Identify at most three findings that would change behaviour: a prompt that produced thrash, a gate that caught nothing, a tier misrouted (T2 work sent as T1), an escalation that fired too often or too late.
3. For each finding, propose the concrete edit: which file in the `team` plugin (agent prompt, charter section, pipeline step) and what changes.
4. Charter-protected sections (chain of command, fixed stack, escalation protocol) are proposals to the CEO only — never edit them unilaterally.
5. With the CEO's agreement, apply the edits in the marketplace repository that ships this plugin (see the plugin's homepage) on a branch and open a PR, so the team's own evolution is reviewed like any other change.

Scope: $ARGUMENTS
