# GitHub CLI Commands Reference

This document provides detailed information about the `gh` commands used in the github-copilot-pr-cycle workflow.

## PR Checks Monitoring

### `gh pr checks --watch`

Monitor CI/CD checks for a pull request.

```bash
gh pr checks [<number> | <url> | <branch>] [flags]
```

**Flags:**
- `--watch` - Watch checks until they finish
- `--fail-fast` - Exit immediately on first check failure
- `--interval int` - Refresh interval in seconds (default: 10)
- `--required` - Only show required checks
- `--json fields` - Output JSON with specified fields

**Exit Codes:**
- `0` - All checks passed
- `1` - Checks failed
- `8` - Checks still pending (used with --watch)

**Example:**
```bash
# Wait for all checks to pass, exit on first failure
gh pr checks --watch --fail-fast --interval 10
```

## Pull Request Management

### `gh pr edit`

Edit a pull request's title, body, reviewers, etc.

```bash
gh pr edit [<number> | <url> | <branch>] [flags]
```

**Flags:**
- `--add-reviewer login` - Add a reviewer
- `--remove-reviewer login` - Remove a reviewer
- `--title string` - Set the title
- `--body string` - Set the body

**Example:**
```bash
# Add Copilot as reviewer
gh pr edit --add-reviewer "copilot-pull-request-reviewer"
```

### `gh pr view`

View a pull request's details and metadata.

```bash
gh pr view [<number> | <url> | <branch>] [flags]
```

**Flags:**
- `--json fields` - Output JSON with specified fields
- `--jq expression` - Filter JSON using jq expression

**Common JSON Fields:**
- `reviews` - Pull request reviews
- `comments` - Review comments
- `author` - PR author
- `statusCheckRollup` - CI status checks

**Example:**
```bash
# Get latest Copilot review
gh pr view --json reviews \
  --jq '[.reviews[] | select(.author.login == "copilot-pull-request-reviewer")] | sort_by(.submittedAt) | last'
```

## API Access

### `gh api`

Make authenticated HTTP requests to the GitHub API.

```bash
gh api <endpoint> [flags]
```

**Flags:**
- `--method` - HTTP method (GET, POST, PUT, DELETE)
- `--field` - Add a parameter to the request
- `--preview` - Enable API preview features

**Example:**
```bash
# Get all reviews for a PR
gh api repos/{owner}/{repo}/pulls/{number}/reviews
```

## Best Practices

### 1. Always Wait for CI First

```bash
# WRONG: Requesting review before CI passes
gh pr edit --add-reviewer "copilot"
gh pr checks --watch

# CORRECT: Wait for CI, then request review
gh pr checks --watch --fail-fast
gh pr edit --add-reviewer "copilot-pull-request-reviewer"
```

### 2. Use Exit Status for Automation

```bash
# Chain commands with && for fail-fast behavior
gh pr checks --watch --fail-fast && \
  gh pr edit --add-reviewer "copilot-pull-request-reviewer"
```

### 3. Filter JSON Efficiently

```bash
# Get only the body of the latest Copilot review
gh pr view --json reviews \
  --jq '.reviews[] | select(.author.login == "copilot-pull-request-reviewer") | .body'
```

### 4. Handle Multiple Reviews

```bash
# Get all Copilot reviews sorted by date
gh pr view --json reviews \
  --jq '[.reviews[] | select(.author.login | contains("copilot"))] | sort_by(.submittedAt)'
```

## Troubleshooting

### Command Not Found

Ensure GitHub CLI is installed and in PATH:
```bash
which gh
gh --version
```

### Authentication Issues

Re-authenticate with GitHub:
```bash
gh auth login
gh auth status
```

### Rate Limiting

Check API rate limit status:
```bash
gh api rate_limit
```

### Permission Errors

Ensure you have write access to the repository:
```bash
gh api repos/{owner}/{repo}/permission
```

## Related Resources

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [gh pr checks](https://cli.github.com/manual/gh_pr_checks)
- [gh pr edit](https://cli.github.com/manual/gh_pr_edit)
- [gh pr view](https://cli.github.com/manual/gh_pr_view)
- [GitHub API Reference](https://docs.github.com/en/rest)
