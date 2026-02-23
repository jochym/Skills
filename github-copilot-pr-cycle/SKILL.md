---
name: github-copilot-pr-cycle
description: Fully automated PR cycle with GitHub Copilot. Handles PR creation, Copilot review requests, iterative fixes, and comment resolution autonomously. User only initiates process and reviews final summary for merge decision.
compatibility: opencode>=1.0.0
---

# GitHub Copilot PR Cycle (Automated)

## Overview

This skill automates the complete pull request review cycle with GitHub Copilot. It handles CI monitoring, review requests, and feedback iteration with minimal human intervention.

## When to Use

- After pushing code changes that require review
- Before merging feature branches
- When iterating on Copilot feedback
- For maintaining code quality standards

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- `jq` for JSON processing
- Python 3 with `json-repair` package
- Copilot enabled for the repository

## Workflow

### 1. Pre-flight Checks (Local)

Before pushing:

```bash
# Run local tests
pytest

# Ensure code is clean
git status
```

### 2. Commit and Push

```bash
git add .
git commit -m "feat: your changes"
git push
```

### 3. Wait for CI Success (CRITICAL)

Always wait for CI to pass BEFORE requesting Copilot review:

```bash
gh pr checks --watch --fail-fast --interval 10
```

**Exit codes:**
- `0`: All checks passed → proceed to step 4
- `1`: Checks failed → fix CI first
- `8`: Still pending → keep waiting

### 4. Request Copilot Review

```bash
gh pr edit --add-reviewer "copilot-pull-request-reviewer"
```

**Note:** Use the exact login `copilot-pull-request-reviewer` (no @ symbol).

### 5. Wait for Copilot Review

Use the provided script to wait for review submission:

```bash
~/.agents/skills/github-copilot-pr-cycle/wait_for_review.sh \
  --author "copilot-pull-request-reviewer" \
  --timeout 900 \
  --output /tmp/copilot_review.json
```

**Script options:**
- `--author` (required): Reviewer to wait for
- `--timeout`: Maximum wait time in seconds (default: 900)
- `--pr`: Specific PR number (default: current branch)
- `--interval`: Polling interval in seconds (default: 10)
- `--output`: Save review JSON to file

### 6. Fetch and Process Review

```bash
# Get full review body
gh pr view --json reviews \
  --jq '.reviews[] | select(.author.login == "copilot-pull-request-reviewer") | .body'

# Or use saved output
cat /tmp/copilot_review.json | jq -r '.body'
```

### 7. Analyze and Iterate

**Review the feedback:**
- Check for "Pull request overview" section
- Count generated comments
- Identify actionable items

**Decision rules:**
- **Real bugs**: Fix using TDD approach
- **Style suggestions**: Use judgment, can defer to human reviewer
- **CI failures**: Fix immediately before next review

**If changes needed:**
```bash
# Make fixes
git add .
git commit -m "fix: address Copilot review comments"
git push

# Return to step 3 (wait for CI)
```

**If satisfied:**
- Review summary for merge decision
- Merge when ready

## Files

- `SKILL.md` - This skill definition
- `wait_for_review.sh` - Review monitoring script
- `README.md` - User documentation
- `CHANGELOG.md` - Version history
- `references/gh-commands.md` - GitHub CLI reference
- `references/examples.md` - Usage examples

## Troubleshooting

### Review not detected
- Verify Copilot is enabled for the repository
- Check reviewer login: `gh pr view --json reviews`
- Increase timeout for large PRs

### JSON parsing errors
- Script auto-repairs malformed JSON
- Use `--output` to inspect raw JSON

### CI keeps failing
- Run tests locally first: `pytest`
- Check GitHub Actions logs: `gh run view`

## Related Skills

- `test-driven-development` - TDD workflow
- `systematic-debugging` - Debugging methodology

## Version

2.0.0 (Native CLI architecture)
