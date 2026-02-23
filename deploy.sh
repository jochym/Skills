#!/bin/bash
# Deploy skills from development directory to production location

DEV_DIR="/home/jochym/Projects/Skills"
PROD_DIR="/home/jochym/.agents/skills"

echo "🚀 Starting deployment of skills..."

# Ensure production directory exists
mkdir -p "$PROD_DIR"

# Loop through subdirectories in development folder
for skill in "$DEV_DIR"/*/; do
    skill_name=$(basename "$skill")
    
    # Skip hidden directories or files
    if [[ "$skill_name" == "."* ]] || [ ! -d "$skill" ]; then
        continue
    fi
    
    echo "📦 Deploying skill: $skill_name"
    
    # Create target directory
    mkdir -p "$PROD_DIR/$skill_name"
    
    # Sync files (excluding git data)
    rsync -av --exclude='.git' "$skill" "$PROD_DIR/$skill_name/"
done

echo "✅ Deployment complete!"
