# CLAUDE.md — claude-marketplace

Context for Claude Code when working **on** this repo. (For installing the plugins, see `README.md`.)

## What this is

`plausai/claude-marketplace` is a public, vendor-neutral Claude Code plugin marketplace. It ships
skills, agents, and hooks that are useful to anyone, in any repo — no company-specific
assumptions. This is a docs/config repo: no APIs, no services, no deploys.

## Repo layout

```
.claude-plugin/marketplace.json          # Catalogue: marketplace identity + list of plugins
plugins/
  workflow-standards/                     # First plugin
    .claude-plugin/plugin.json            # Plugin manifest
    skills/<name>/SKILL.md                # One skill per directory
scripts/validate.sh                       # Structural + version-bump checks
.github/workflows/validate.yml            # CI: runs validate.sh
CODEOWNERS
```

`.claude-plugin/marketplace.json` is the index; each `plugins/<name>/.claude-plugin/plugin.json`
is the actual plugin definition. Both must agree on the plugin's version.

## Adding a plugin or skill

See [`docs/contribution-guide.md`](docs/contribution-guide.md) — where files go, required
frontmatter, and the versioning rules.

## Versioning rules

Semver (`MAJOR.MINOR.PATCH`). **One bump per PR above the base**: bump `marketplace.json`
`version`, and each touched plugin's `plugin.json` `version`, once for the PR. `scripts/validate.sh`
enforces this on PRs.

## Style bar

- **No placeholders or stubs.** A skill ships with real first-pass content.
- **Skill descriptions must be pushy.** They are matched against to decide whether to load the
  skill; vague descriptions never trigger. Aggressive triggers are deliberate.
- **Vendor-neutral.** No company names, internal tools, or private references — this is a public
  marketplace. Genericise anything ported from a private source.

## Before you push

1. ☐ Bumped `marketplace.json` `version` (if you touched `.claude-plugin/` or `plugins/`).
2. ☐ Bumped `plugin.json` `version` for any plugin whose contents you touched.
3. ☐ Updated `CODEOWNERS` if you added a new plugin.
4. ☐ Updated `README.md` if you changed anything user-facing.
5. ☐ `./scripts/validate.sh` passes.
