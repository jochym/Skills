---
name: github-copilot-pr-cycle
description: Fully automated PR cycle with GitHub Copilot. Handles PR creation, Copilot review requests, iterative fixes, and comment resolution autonomously. User only initiates process and reviews final summary for merge decision.
---

# GitHub Copilot PR Cycle (Automated)

## Workflow Overview

1. **TDD Fixes**: Implement fixes for review comments using Test-Driven Development.
2. **Internal Tests**: Run local test suite (`pytest`) to ensure stability.
3. **Commit & Push**: Commit changes and push to origin.
4. **Wait for CI Success (CRITICAL)**: Wait for standard CI checks to pass BEFORE requesting review.
   ```bash
   gh run watch $(gh run list --limit 1 --json databaseId --jq '.[0].databaseId') --compact --exit-status
   ```
5. **Request Copilot Review**: Only after CI is green:
   `gh pr edit <PR> --add-reviewer "@copilot"`
6. **Wait for Copilot Review**: Wait for Copilot's specific workflow to complete and then fetch results.
   ```bash
   gh run watch $(gh run list --workflow "Copilot code review" --limit 1 --json databaseId --jq '.[0].databaseId') --compact --exit-status && \
   gh pr view <PR> --json reviews --jq '[.reviews[] | select(.author.login | contains("copilot"))] | sort_by(.submittedAt) | last'
   ```
7. **Verify & React**: Monitor for "Pull request overview" and unresolved threads.
8. **Repeat/Finish**: If new comments, return to step 1. Otherwise, finish and report.

## Phase 2: Automated Iteration Cycle

### Step 2: Wait for CI Success
Always wait for the latest run to complete successfully before engaging Copilot. Use `--compact` to reduce output noise and `--exit-status` for reliable chaining.

### Step 3: Request Copilot Review
Use `@copilot` (with @ symbol). Never use comments to trigger reviews.

### Step 4: Monitor for Completion
Wait for:
1. `gh run watch --compact --exit-status` for the Copilot workflow to finish.
2. `submittedAt` field is NOT null in PR reviews.
3. Body contains "Pull request overview".
4. Thread count matches the number reported in the overview ("generated X comments").

## Autonomous Decision Rules
- **Low Confidence Comments**: Analyze critically. If it's a real bug, fix using TDD. If stylistic/disagree, leave for human review.
- **CI Failures**: Fix immediately without requesting new review.
