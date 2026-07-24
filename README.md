# claude-marketplace

A curated [Claude Code](https://docs.claude.com/en/docs/claude-code) plugin marketplace of
skills, agents, and hooks that benefit everyone. Vendor-neutral and general-purpose — install
these into any repo to make Claude apply good habits proactively rather than only when asked.

## What's in here

| Path | What it is |
| --- | --- |
| `.claude-plugin/marketplace.json` | Marketplace manifest. Lists every plugin shipped from this repo. |
| `plugins/workflow-standards/` | Workflow standards as skills. v0.1 ships `sycophancy` — a critical-thinking-partner mode that challenges your reasoning by default. |
| `scripts/validate.sh` | Structural + version-bump validation. Run it locally; CI runs the same script. |
| `.github/workflows/validate.yml` | Runs `validate.sh` on every push and pull request. |
| `CODEOWNERS` | Ownership of marketplace config and individual plugins. |

## Install

From any Claude Code session:

1. **Add the marketplace.** Because this repo is on GitHub, the `owner/repo` shorthand works:

   ```text
   /plugin marketplace add plausai/claude-marketplace
   ```

2. **Install a plugin:**

   ```text
   /plugin install workflow-standards@plausai
   ```

3. **Verify.** In a new session, `/sycophancy` should be available as a slash command.

To update later: `/plugin marketplace update plausai`.

### Pinning to a version

By default the marketplace tracks the default branch. To pin to a release tag, append `#v<version>`:

```text
/plugin marketplace add plausai/claude-marketplace#v0.1.0
/plugin install workflow-standards@plausai
```

The pin applies to the whole marketplace; every plugin resolves at the pinned ref. To change it,
remove and re-add the marketplace at the new ref.

## Plugins

### `workflow-standards`

Standards for how you work — with Claude and with your team.

- **`sycophancy`** — switches Claude into a critical-thinking partner that argues the strongest
  opposing case, surfaces untested assumptions, and reviews your weakest points first, instead of
  agreeing with you. Loads automatically when you ask for a gut-check, and is invocable directly
  as `/sycophancy`.

## Contributing

See [`docs/contribution-guide.md`](docs/contribution-guide.md) for how to add a plugin or a skill,
the required manifest fields, and the versioning rules. Run `./scripts/validate.sh` before you
push — CI runs the same checks.
