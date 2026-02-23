# github-copilot-pr-cycle

Fully automated PR cycle with GitHub Copilot. Handles PR creation, Copilot review requests, iterative fixes, and comment resolution autonomously.

## Features

- **Automated CI Monitoring**: Wait for GitHub Actions to complete using native `gh` CLI
- **Copilot Review Integration**: Automatically request and wait for Copilot code reviews
- **Smart Polling**: Lightweight bash-based waiting with timeout protection
- **JSON Repair**: Handle malformed JSON output from Copilot reviews
- **Fail-Fast**: Exit immediately on CI failures to save time

## Installation

This skill is installed in `~/.agents/skills/github-copilot-pr-cycle/` and includes:

- `SKILL.md` - Skill definition and instructions
- `wait_for_review.sh` - Review monitoring script

## Usage

### Quick Start

```bash
# 1. Wait for CI to pass
gh pr checks --watch --fail-fast --interval 10

# 2. Request Copilot review
gh pr edit --add-reviewer "copilot-pull-request-reviewer"

# 3. Wait for Copilot review
~/.agents/skills/github-copilot-pr-cycle/wait_for_review.sh \
  --author "copilot-pull-request-reviewer" \
  --timeout 900

# 4. Fetch review content
gh pr view --json reviews \
  --jq '.reviews[] | select(.author.login == "copilot-pull-request-reviewer") | .body'
```

### Script Options

```bash
wait_for_review.sh --author <login> [OPTIONS]

Options:
  --author     GitHub login of the reviewer (required)
  --timeout    Maximum wait time in seconds (default: 900)
  --pr         Pull request number (default: current branch PR)
  --interval   Polling interval in seconds (default: 10)
  --output     Output file for review JSON (optional)
```

### Examples

Wait for Copilot review with default timeout (15 minutes):
```bash
wait_for_review.sh --author "copilot-pull-request-reviewer"
```

Wait with custom timeout and save output:
```bash
wait_for_review.sh --author "copilot-pull-request-reviewer" \
  --timeout 600 \
  --output /tmp/copilot_review.json
```

Wait for specific PR:
```bash
wait_for_review.sh --author "copilot-pull-request-reviewer" \
  --pr 42
```

## Workflow

1. **Pre-flight**: Run local tests (`pytest`)
2. **Commit & Push**: Push changes to GitHub
3. **CI Monitoring**: Wait for GitHub Actions to pass
4. **Request Review**: Add Copilot as reviewer
5. **Wait for Review**: Poll until Copilot submits review
6. **Process Review**: Extract and analyze feedback
7. **Iterate**: Fix issues and repeat or merge

## Requirements

- GitHub CLI (`gh`)
- Bash 4.0+
- `jq` for JSON processing
- Python 3 with `json-repair` package (for malformed JSON handling)

## Exit Codes

- `0`: Review detected successfully
- `1`: Timeout or error occurred
- `8`: Still waiting (during polling)

## Troubleshooting

### Copilot review not detected
- Ensure Copilot is enabled for the repository
- Check that `copilot-pull-request-reviewer` is a valid reviewer
- Increase timeout if review takes longer than 15 minutes

### JSON parsing errors
- The script automatically repairs malformed JSON using `json-repair`
- If issues persist, check the raw output with `--output` flag

### CI checks fail
- The `--fail-fast` flag exits immediately on failure
- Fix CI issues before requesting Copilot review

## License

MIT

## Contributing

1. Fork the repository
2. Create a feature branch
3. Test changes with real PRs
4. Submit a pull request
