#!/usr/bin/env bash
# install.sh — deploy skills to all registered harness paths
# Run from the common-skills directory. Idempotent.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="$SCRIPT_DIR/registry.yml"

if ! command -v python3 &>/dev/null; then
  echo "Error: python3 is required to parse registry.yml" >&2
  exit 1
fi

# Parse registry and install each skill
python3 - <<EOF
import yaml, os, sys

registry_path = "$REGISTRY"
script_dir = "$SCRIPT_DIR"

with open(registry_path) as f:
    registry = yaml.safe_load(f)

skills = registry.get("skills") or []

if not skills:
    print("No skills registered yet. Add entries to registry.yml to get started.")
    sys.exit(0)

installed = 0
for skill in skills:
    name = skill["name"]
    source = os.path.join(script_dir, skill["source"])

    if not os.path.exists(source):
        print(f"  MISSING source: {skill['source']} (skipping {name})")
        continue

    for target_entry in skill.get("install_to", []):
        target_path = os.path.expanduser(target_entry["path"])
        mode = target_entry.get("mode", "symlink")

        # Make parent directory if needed
        os.makedirs(os.path.dirname(target_path), exist_ok=True)

        # Remove stale link or file
        if os.path.islink(target_path) or os.path.exists(target_path):
            os.remove(target_path)

        if mode == "copy":
            import shutil
            shutil.copy2(source, target_path)
            print(f"  copied  {name} → {target_path}")
        else:
            os.symlink(source, target_path)
            print(f"  linked  {name} → {target_path}")

        installed += 1

print(f"\nDone. {installed} install target(s) processed.")
EOF
