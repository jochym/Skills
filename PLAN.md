# Plan: github-copilot-pr-cycle v2.0 (Native CLI)

## 🎯 Goal
Optimize reliability and simplicity by using native `gh` CLI commands instead of complex webhook infrastructure.

## 🏗️ Architecture: "Native CLI"

### Design Principles
1. **No external dependencies**: Use only `gh`, `bash`, and `jq` (already available).
2. **Fail-fast**: Exit immediately on CI failures.
3. **Simple polling**: Lightweight bash loops for review waiting (sufficient for human-scale timing).

### Components
1. **`gh pr checks --watch`**: Native CI monitoring with `--fail-fast` and `--exit-status`.
2. **`wait_for_review.sh`**: Simple bash script that polls `gh pr view --json reviews` until Copilot review appears.
3. **Updated `SKILL.md`**: Streamlined workflow using native commands.

## 🔄 New Workflow

### 1. Pre-flight Check (Local)
- Run `pytest` locally.
- Only push if tests pass.

### 2. CI Monitoring (Native)
```bash
gh pr checks --watch --fail-fast --interval 10
```
- Exit code 0: All checks passed.
- Exit code 1: Checks failed (stop immediately).
- Exit code 8: Checks still pending (keep waiting).

### 3. Request Copilot Review
```bash
gh pr edit --add-reviewer "copilot-pull-request-reviewer"
```

### 4. Review Monitoring (Smart Polling)
```bash
./wait_for_review.sh --author "copilot-pull-request-reviewer" --timeout 900
```
- Polls every 10 seconds.
- Checks for `submittedAt` field (review submitted).
- Verifies "Pull request overview" in body.
- Exits with timeout after 15 minutes.

### 5. Fetch Review Content
```bash
gh pr view --json reviews \
  --jq '[.reviews[] | select(.author.login == "copilot-pull-request-reviewer")] | sort_by(.submittedAt) | last'
```

## 🚀 Release Process (Production)
Staged approach to avoid working on "live" files:
1. **Dev**: Edit files in `~/Projects/Skills/github-copilot-pr-cycle/`.
2. **Verify**: Test in sandbox project.
3. **Release**: Run `deploy.sh` to copy/link files to `~/.agents/skills/`.

## 📋 TODO
- [x] Create `wait_for_review.sh` script (bash polling loop).
- [x] Create `deploy.sh` script for production release.
- [x] Update `SKILL.md` with native `gh pr checks --watch` command.
- [x] Add `json-repair` logic verification to the workflow.
- [ ] Test workflow on real PR with Copilot review.
