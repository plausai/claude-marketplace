#!/usr/bin/env bash
#
# Structural + version-bump validation for the marketplace. Run locally before
# pushing; CI runs the same script (.github/workflows/validate.yml).
#
# Checks:
#   1. marketplace.json parses and has the required fields + at least one plugin.
#   2. every plugin.json parses and has the required fields.
#   3. every SKILL.md starts with YAML frontmatter (---).
#   4. version bump: if anything under .claude-plugin/ or plugins/ changed vs the
#      base branch, marketplace.json must bump its version, and a changed plugin
#      must bump its own plugin.json version.
#
# The base branch defaults to "main" and can be overridden with BASE_BRANCH.
# On the default branch itself, the bump check is skipped (it was enforced on the PR).
#
set -euo pipefail

echo "=== Structural validation ==="
test -f .claude-plugin/marketplace.json || { echo "marketplace.json missing"; exit 1; }
jq empty .claude-plugin/marketplace.json
for field in name version owner plugins; do
  jq -e ".${field}" .claude-plugin/marketplace.json > /dev/null \
    || { echo "marketplace.json missing required field: ${field}"; exit 1; }
done
plugin_count=$(jq '.plugins | length' .claude-plugin/marketplace.json)
if [ "${plugin_count}" -lt 1 ]; then
  echo "marketplace.json has no plugins listed"; exit 1
fi
echo "marketplace.json OK (${plugin_count} plugin(s))"

echo "Validating each plugin manifest..."
found=0
while IFS= read -r manifest; do
  found=$((found+1))
  echo "  ${manifest}"
  jq empty "${manifest}"
  for field in name version description; do
    jq -e ".${field}" "${manifest}" > /dev/null \
      || { echo "  ${manifest} missing required field: ${field}"; exit 1; }
  done
done < <(find plugins -type f -path '*/.claude-plugin/plugin.json')
if [ "${found}" -lt 1 ]; then
  echo "no plugin.json files found under plugins/"; exit 1
fi
echo "All plugin manifests OK (${found} found)."

echo "Validating SKILL.md frontmatter..."
skill_count=0
while IFS= read -r skill; do
  skill_count=$((skill_count+1))
  first_line=$(head -n 1 "${skill}")
  if [ "${first_line}" != "---" ]; then
    echo "FAIL: ${skill} does not start with YAML frontmatter (---)"; exit 1
  fi
done < <(find plugins -type f -name 'SKILL.md')
echo "All SKILL.md files OK (${skill_count} found)."

echo ""
echo "=== Version-bump check ==="
base_branch="${BASE_BRANCH:-main}"
current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"

if [ "${current_branch}" = "${base_branch}" ]; then
  echo "On ${base_branch}; version bump is enforced on PRs. Skipping."
  exit 0
fi

if ! git rev-parse --verify --quiet "origin/${base_branch}" >/dev/null; then
  if ! git fetch --quiet origin "${base_branch}" 2>/dev/null; then
    echo "No origin/${base_branch} to compare against; skipping version-bump check."
    exit 0
  fi
fi

changed=$(git diff --name-only "origin/${base_branch}...HEAD" -- '.claude-plugin/' 'plugins/' || true)
if [ -z "${changed}" ]; then
  echo "No marketplace or plugin changes vs origin/${base_branch}; nothing to check."
  exit 0
fi

echo "Marketplace / plugin changes detected:"
echo "${changed}" | sed 's/^/  /'

head_mp=$(jq -r '.version' .claude-plugin/marketplace.json)
base_mp=$(git show "origin/${base_branch}:.claude-plugin/marketplace.json" 2>/dev/null | jq -r '.version' || echo "")
if [ -z "${base_mp}" ] || [ "${base_mp}" = "null" ]; then
  echo "Could not read marketplace.json version on origin/${base_branch}; skipping marketplace bump check."
elif [ "${head_mp}" = "${base_mp}" ]; then
  echo ""
  echo "FAIL: marketplace.json version is still ${head_mp} but contents under .claude-plugin/ or plugins/ changed."
  echo "      Bump the 'version' field in .claude-plugin/marketplace.json before merging."
  exit 1
else
  echo "marketplace.json version: ${base_mp} -> ${head_mp} OK"
fi

for plugin_dir in plugins/*/; do
  plugin_name=$(basename "${plugin_dir}")
  echo "${changed}" | grep -qE "^plugins/${plugin_name}/" || continue
  plugin_manifest="${plugin_dir}.claude-plugin/plugin.json"
  [ -f "${plugin_manifest}" ] || continue
  head_pv=$(jq -r '.version' "${plugin_manifest}")
  if base_pv=$(git show "origin/${base_branch}:${plugin_manifest}" 2>/dev/null | jq -r '.version'); then
    if [ -z "${base_pv}" ] || [ "${base_pv}" = "null" ]; then
      echo "  ${plugin_name}: could not read base version; skipping."
      continue
    fi
    if [ "${head_pv}" = "${base_pv}" ]; then
      echo ""
      echo "FAIL: plugin '${plugin_name}' changed but plugin.json version is still ${head_pv}."
      echo "      Bump the 'version' field in ${plugin_manifest} before merging."
      exit 1
    fi
    echo "  ${plugin_name}: ${base_pv} -> ${head_pv} OK"
  else
    echo "  ${plugin_name}: new plugin (no base to compare) OK"
  fi
done

echo "Version-bump check passed."
