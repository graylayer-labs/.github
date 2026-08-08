#!/bin/bash
# Sync labels from .codex/label-schema.yaml to all repos in the org
# Usage: ./label-sync.sh <org-name> [repo1 repo2 ...]
# If no repos specified, applies to all repos in the org

set -e

ORG=${1:?Usage: label-sync.sh <org-name> [repo1 repo2 ...]}
shift  # consume org name

# Get all repos in org if none specified
if [ $# -eq 0 ]; then
    REPOS=$(gh repo list "$ORG" --json name --jq '.[].name')
else
    REPOS="$@"
fi

# Parse labels from YAML (simple grep-based approach)
# Assumes format: - name: label-name
#                  color: "hexcode"
#                  description: "text"

echo "Syncing labels to $ORG repos..."

for repo in $REPOS; do
    echo "Processing $ORG/$repo..."

    # Extract labels from YAML
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*-[[:space:]]+name:[[:space:]]+(.*) ]]; then
            name="${BASH_REMATCH[1]}"
            # Read next two lines for color and description
            read -r color_line
            read -r desc_line

            if [[ $color_line =~ color:[[:space:]]*\"([^\"]+)\" ]]; then
                color="${BASH_REMATCH[1]}"
            fi

            if [[ $desc_line =~ description:[[:space:]]+(.*) ]]; then
                desc="${BASH_REMATCH[1]}"
            fi

            # Create label via gh
            echo "  Creating label: $name"
            gh label create "$name" \
                --repo "$ORG/$repo" \
                --color "$color" \
                --description "$desc" \
                2>/dev/null || echo "    (label already exists)"
        fi
    done < .codex/label-schema.yaml
done

echo "✓ Labels synced!"
