#!/bin/bash
# Deploy github-copilot-pr-cycle skill to production directory
# Copies all skill files to ~/.agents/skills/github-copilot-pr-cycle/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$SCRIPT_DIR/github-copilot-pr-cycle"
PROD_DIR="$HOME/.agents/skills/github-copilot-pr-cycle"

echo "Deploying github-copilot-pr-cycle skill..."
echo "Source: $SKILL_DIR"
echo "Target: $PROD_DIR"

if [[ ! -d "$SKILL_DIR" ]]; then
    echo "Error: Skill directory not found: $SKILL_DIR"
    exit 1
fi

mkdir -p "$PROD_DIR"

cp "$SKILL_DIR/SKILL.md" "$PROD_DIR/SKILL.md"
echo "✓ Copied SKILL.md"

cp "$SKILL_DIR/README.md" "$PROD_DIR/README.md"
echo "✓ Copied README.md"

cp "$SKILL_DIR/CHANGELOG.md" "$PROD_DIR/CHANGELOG.md"
echo "✓ Copied CHANGELOG.md"

cp "$SCRIPT_DIR/wait_for_review.sh" "$PROD_DIR/wait_for_review.sh"
chmod +x "$PROD_DIR/wait_for_review.sh"
echo "✓ Copied wait_for_review.sh"

if [[ -d "$SKILL_DIR/references" ]]; then
    mkdir -p "$PROD_DIR/references"
    cp "$SKILL_DIR/references/"* "$PROD_DIR/references/"
    echo "✓ Copied references/"
fi

echo ""
echo "Deployment complete!"
echo "Files in $PROD_DIR:"
ls -la "$PROD_DIR"
