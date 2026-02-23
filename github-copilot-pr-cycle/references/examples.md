# Usage Examples

Real-world examples of using the github-copilot-pr-cycle workflow.

## Example 1: Simple Bug Fix

### Scenario
Fix a null pointer exception in user authentication.

### Workflow

```bash
# 1. Create feature branch
git checkout -b fix/null-pointer-auth

# 2. Make changes
$EDITOR src/auth.py
# Add null check before accessing user object

# 3. Run local tests
pytest tests/test_auth.py -v

# 4. Commit and push
git add src/auth.py
git commit -m "fix: add null check in authentication"
git push -u origin fix/null-pointer-auth

# 5. Create PR
gh pr create \
  --title "fix: add null check in authentication" \
  --body "Fixes null pointer exception when user object is None"

# 6. Wait for CI
gh pr checks --watch --fail-fast

# 7. Request Copilot review
gh pr edit --add-reviewer "copilot-pull-request-reviewer"

# 8. Wait for Copilot
~/.agents/skills/github-copilot-pr-cycle/wait_for_review.sh \
  --author "copilot-pull-request-reviewer"

# 9. Review feedback and iterate if needed
```

## Example 2: New Feature Implementation

### Scenario
Add a new calculator module with tests.

### Workflow

```bash
# 1. Create feature branch
git checkout -b feature/calculator

# 2. Implement feature with TDD
# Write tests first
$EDITOR test_calculator.py

# Run failing tests
pytest test_calculator.py -v

# Implement code
$EDITOR calculator.py

# Run tests until passing
pytest test_calculator.py -v

# 3. Commit incrementally
git add test_calculator.py
git commit -m "test: add calculator unit tests"

git add calculator.py
git commit -m "feat: implement calculator module"

git push -u origin feature/calculator

# 4. Create PR
gh pr create \
  --title "feat: add calculator module" \
  --body "Implements basic math operations with full test coverage"

# 5. Wait for CI
gh pr checks --watch --fail-fast

# 6. Request Copilot review
gh pr edit --add-reviewer "copilot-pull-request-reviewer"

# 7. Wait and save review
~/.agents/skills/github-copilot-pr-cycle/wait_for_review.sh \
  --author "copilot-pull-request-reviewer" \
  --output /tmp/copilot_review.json

# 8. Analyze review
cat /tmp/copilot_review.json | jq -r '.body'

# 9. Address feedback if needed
# ... make changes ...
git commit -am "fix: address Copilot review comments"
git push

# 10. Repeat from step 5 if new review needed
```

## Example 3: Refactoring with Multiple Iterations

### Scenario
Refactor database layer for better performance.

```bash
# Initial refactoring
git checkout -b refactor/db-layer

# Make changes across multiple files
# ... refactoring ...

git commit -am "refactor: improve database query performance"
git push -u origin refactor/db-layer

gh pr create \
  --title "refactor: optimize database queries" \
  --body "Reduces query time by 40% through indexing and query optimization"

# First CI check
gh pr checks --watch --fail-fast

# First Copilot review
gh pr edit --add-reviewer "copilot-pull-request-reviewer"
wait_for_review.sh --author "copilot-pull-request-reviewer" --output review1.json

# Address feedback
# ... make changes based on review1.json ...
git commit -am "address Copilot feedback: add connection pooling"
git push

# Second review (if needed)
gh pr edit --add-reviewer "copilot-pull-request-reviewer"
wait_for_review.sh --author "copilot-pull-request-reviewer" --output review2.json

# Compare reviews
diff <(jq .body review1.json) <(jq .body review2.json)
```

## Example 4: Automated Script Integration

### Scenario
Integrate the workflow into a custom automation script.

```bash
#!/bin/bash
# auto-pr.sh - Automated PR workflow

set -e

PR_TITLE="$1"
PR_BODY="$2"
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

echo "Creating PR: $PR_TITLE"
gh pr create --title "$PR_TITLE" --body "$PR_BODY"

echo "Waiting for CI..."
if ! gh pr checks --watch --fail-fast --interval 10; then
    echo "CI failed! Please fix and re-run."
    exit 1
fi

echo "CI passed! Requesting Copilot review..."
gh pr edit --add-reviewer "copilot-pull-request-reviewer"

echo "Waiting for Copilot review (timeout: 15 min)..."
if ! wait_for_review.sh --author "copilot-pull-request-reviewer" --timeout 900; then
    echo "Timeout waiting for Copilot review."
    exit 1
fi

echo "Copilot review received!"
echo "Review the PR at: $(gh pr view --web)"
```

### Usage
```bash
./auto-pr.sh "feat: add new endpoint" "Implements /api/users endpoint"
```

## Example 5: Handling CI Failures

### Scenario
CI fails and needs immediate attention.

```bash
# Start watching CI
gh pr checks --watch --fail-fast

# CI fails (exit code 1)
# Script exits immediately due to --fail-fast

# Check what failed
gh pr checks --json name,state,bucket

# Fix the issue
$EDITOR failing_test.py
git commit -am "fix: resolve test failure"
git push

# CI automatically re-runs
# Watch again
gh pr checks --watch --fail-fast

# Once green, request review
gh pr edit --add-reviewer "copilot-pull-request-reviewer"
```

## Example 6: Custom Timeout and Polling

### Scenario
Large PR requires extended review time.

```bash
# Wait up to 30 minutes for Copilot review
wait_for_review.sh \
  --author "copilot-pull-request-reviewer" \
  --timeout 1800 \
  --interval 15 \
  --output copilot_review.json

# Check if review was received
if [ $? -eq 0 ]; then
    echo "Review received!"
    jq -r '.body' copilot_review.json
else
    echo "Review timed out. Checking status..."
    gh pr view --json reviews
fi
```

## Tips

1. **Save Reviews**: Always use `--output` to save reviews for later reference
2. **Check JSON**: Use `jq` to parse and analyze review content
3. **Timeout Wisely**: Set appropriate timeouts based on PR complexity
4. **Iterate Fast**: Address feedback quickly to maintain momentum
5. **Monitor CI**: Use `--fail-fast` to catch issues early
