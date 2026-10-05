#!/usr/bin/env bash
# install.sh — deploy skills to all registered harness paths
# Reads install targets from registry.yml.
# Each target can specify mode: copy or mode: symlink.
# Default mode is copy — symlinks are fragile across agent environments.
#
# Usage: ./install.sh [--symlink]
#   --symlink  override all entries to use symlinks instead of copying

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_MODE=""
[[ "${1:-}" == "--symlink" ]] && GLOBAL_MODE="symlink"

installed=0
missing=0
current_source=""
current_mode="copy"

while IFS= read -r line; do
  trimmed="${line#"${line%%[![:space:]]*}"}"

  # Detect source: line
  if [[ "$trimmed" =~ ^source:[[:space:]]+(.+)$ ]]; then
    current_source="${BASH_REMATCH[1]}"
    current_mode="copy"  # reset mode for each new source
  fi

  # Detect mode: line
  if [[ "$trimmed" =~ ^mode:[[:space:]]+(.+)$ ]]; then
    current_mode="${BASH_REMATCH[1]}"
  fi

  # Detect path: line under install_to
  if [[ "$trimmed" =~ ^-[[:space:]]+path:[[:space:]]+(.+)$ ]]; then
    target_path="${BASH_REMATCH[1]}"
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

    mkdir -p "$(dirname "$target_path")"
    [[ -L "$target_path" || -f "$target_path" ]] && rm "$target_path"

    # Per-entry mode, overridden by global flag if set
    effective_mode="${GLOBAL_MODE:-$current_mode}"

    if [[ "$effective_mode" == "symlink" ]]; then
      ln -s "$source_path" "$target_path"
      echo "  linked  $current_source → $target_path"
    else
      cp "$source_path" "$target_path"
      echo "  copied  $current_source → $target_path"
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
