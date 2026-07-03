#!/usr/bin/env bash
# install.sh — deploy skills to all registered harness paths
# Reads install targets from the per-skill .targets files in adapters/.
# Idempotent — safe to re-run. Uses symlinks by default.
#
# Usage: ./install.sh [--copy]
#   --copy  copy files instead of symlinking (useful when target can't follow symlinks)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="symlink"
[[ "${1:-}" == "--copy" ]] && MODE="copy"

installed=0
missing=0

# Each line in registry.yml that is a real skill entry looks like:
#   - name: verify
#     source: skills/workflow/verify.md
#     install_to:
#       - path: ~/.claude/commands/verify.md
# We parse it with a small awk program rather than a YAML library.

while IFS= read -r line; do
  # Strip leading whitespace
  trimmed="${line#"${line%%[![:space:]]*}"}"

  # Detect source: line
  if [[ "$trimmed" =~ ^source:[[:space:]]+(.+)$ ]]; then
    current_source="${BASH_REMATCH[1]}"
  fi

  # Detect path: line under install_to
  if [[ "$trimmed" =~ ^-[[:space:]]+path:[[:space:]]+(.+)$ ]]; then
    target_path="${BASH_REMATCH[1]}"
    # Expand ~ manually
    target_path="${target_path/#\~/$HOME}"

    if [[ -z "${current_source:-}" ]]; then
      echo "  WARN: found path with no preceding source, skipping: $target_path"
      continue
    fi

    source_path="$SCRIPT_DIR/$current_source"

    if [[ ! -f "$source_path" ]]; then
      echo "  MISSING source: $current_source (skipping)"
      ((missing++)) || true
      continue
    fi

    # Ensure target directory exists
    mkdir -p "$(dirname "$target_path")"

    # Remove stale link or file
    [[ -L "$target_path" || -f "$target_path" ]] && rm "$target_path"

    if [[ "$MODE" == "copy" ]]; then
      cp "$source_path" "$target_path"
      echo "  copied  $current_source → $target_path"
    else
      ln -s "$source_path" "$target_path"
      echo "  linked  $current_source → $target_path"
    fi

    ((installed++)) || true
  fi
done < "$SCRIPT_DIR/registry.yml"

echo ""
if [[ $installed -eq 0 && $missing -eq 0 ]]; then
  echo "No skills registered yet. Add entries to registry.yml to get started."
else
  echo "Done. $installed install target(s) processed. $missing missing source(s) skipped."
fi
