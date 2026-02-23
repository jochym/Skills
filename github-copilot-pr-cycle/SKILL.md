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
   gh pr checks --watch --fail-fast --interval 10
   ```
5. **Request Copilot Review**: Only after CI is green:
   ```bash
   gh pr edit --add-reviewer "copilot-pull-request-reviewer"
   ```
6. **Wait for Copilot Review**: Use the wait script to poll for review completion.
   ```bash
   ./wait_for_review.sh --author "copilot-pull-request-reviewer" --timeout 900
   ```
7. **Fetch Review Content**: Get the full review body for processing.
   ```bash
   gh pr view --json reviews \
     --jq '[.reviews[] | select(.author.login == "copilot-pull-request-reviewer")] | sort_by(.submittedAt) | last'
   ```
8. **Verify & React**: Monitor for "Pull request overview" and unresolved threads.
9. **Repeat/Finish**: If new comments, return to step 1. Otherwise, finish and report.

## Phase 2: Automated Iteration Cycle

### Step 2: Wait for CI Success
Use `gh pr checks --watch --fail-fast --interval 10`. This native command:
- Exit code 0: All checks passed.
- Exit code 1: Checks failed (stop immediately, fix CI).
- Exit code 8: Checks still pending (command keeps waiting).

### Step 3: Request Copilot Review
Use `copilot-pull-request-reviewer` (no @ symbol needed in gh CLI).

### Step 4: Monitor for Completion
The `wait_for_review.sh` script handles:
1. Polling every 10 seconds.
2. Checking for `submittedAt` field (review submitted).
3. Verifying body contains "Pull request overview".
4. Timeout after 15 minutes (configurable).

### Step 5: Parse Review
Use `jq` to extract review body and comments:
```bash
gh pr view --json reviews \
  --jq '.reviews[] | select(.author.login == "copilot-pull-request-reviewer") | .body'
```

## Autonomous Decision Rules
- **Low Confidence Comments**: Analyze critically. If it's a real bug, fix using TDD. If stylistic/disagree, leave for human review.
- **CI Failures**: Fix immediately without requesting new review.
