# Contribution guide

How to add a plugin or a skill to this marketplace. Run `./scripts/validate.sh` before pushing —
CI runs the same checks.

## Concepts

- **Marketplace** — this repo. `.claude-plugin/marketplace.json` lists every plugin and its version.
- **Plugin** — a bundle installed as a unit (`plugins/<name>/`). Its `.claude-plugin/plugin.json`
  is the manifest.
- **Skill** — one capability (`plugins/<plugin>/skills/<skill>/SKILL.md`). A plugin can hold many.

## Add a skill to an existing plugin

1. Create `plugins/<plugin>/skills/<skill-name>/SKILL.md`.
2. Start it with YAML frontmatter:

   ```yaml
   ---
   name: <skill-name>
   description: <when Claude should load this skill — see "Descriptions" below>
   ---
   ```

   Then the body: what Claude should do, concisely, ending with an explicit list of what to flag.
3. Bump the plugin's `plugin.json` `version` and the `marketplace.json` `version`.
4. Update the plugin's `description` in both manifests if the skill list changed materially.

## Add a new plugin

1. Create `plugins/<name>/.claude-plugin/plugin.json`:

   ```json
   {
     "name": "<name>",
     "version": "0.1.0",
     "description": "<what it bundles and what it ships>",
     "author": { "name": "Plaus AI", "url": "https://github.com/plausai" },
     "homepage": "https://github.com/plausai/claude-marketplace",
     "keywords": ["..."]
   }
   ```

2. Add at least one skill (see above).
3. Add the plugin to the `plugins` array in `.claude-plugin/marketplace.json` with a matching
   `version`, and bump the marketplace `version`.
4. Add an owner line to `CODEOWNERS`.

## Descriptions

A skill's `description` is what Claude matches against to decide whether to load it. Make it
**pushy**: name the concrete triggers ("Use whenever…", plus quoted phrases a user would actually
type) and say to apply it proactively. Vague descriptions never fire.

## Versioning

Semver. **One bump per PR above the base**, not per commit: bump `marketplace.json` once, and each
touched plugin's `plugin.json` once. `validate.sh` fails the PR if a change under `.claude-plugin/`
or `plugins/` did not bump the relevant version.

## House rules

- **Vendor-neutral.** No company names, internal tools, or personal references — this is public.
- **No stubs.** Ship real first-pass content, not `TODO`.
