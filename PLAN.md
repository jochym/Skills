# Plan: github-copilot-pr-cycle v2.0 (Event-Driven)

## 🎯 Goal
Achieve 100% reliability in GitHub interaction and optimize Copilot agent resources by moving from polling to an event-driven architecture.

## 🏗️ Architecture: "Webhook Waiter"

### Components
1. **`webhook_waiter.py`**: A lightweight Python helper script that:
   - Starts a temporary local HTTP server.
   - Listens for specific GitHub Webhook payloads.
   - Filters by `event_type`, `action`, and `SHA`.
   - Exits with success once the expected signal is received.
2. **`gh webhook forward`**: Used to tunnel events from GitHub to the local waiter.
3. **Updated `SKILL.md`**: New workflow instructions utilizing these tools.

## 🔄 New Workflow

### 1. Pre-flight Check (Local)
- Run `pytest` locally.
- Only push if tests pass.

### 2. CI Monitoring (Deterministic)
- Start `gh webhook forward --repo=$REPO --url=http://localhost:3000`.
- Run `webhook_waiter.py --event check_suite --status completed --conclusion success --sha $(git rev-parse HEAD)`.
- *Fallback:* `gh run watch --exit-status`.

### 3. Review Request
- `gh pr edit $PR --add-reviewer "@copilot"`.

### 4. Review Monitoring (Deterministic)
- Run `webhook_waiter.py --event pull_request_review --action submitted --user copilot-pull-request-reviewer`.
- Wait for exit signal.
- Verify "Pull request overview" exists.

## 🚀 Release Process (Production)
To ensure we don't work on "live" files, we use a staged approach:
1. **Dev**: Edit files in `~/Projects/Skills/github-copilot-pr-cycle/`.
2. **Verify**: Test in a sandbox project.
3. **Release**: Run `deploy.sh` to copy/link files to `~/.agents/skills/`.

## 📋 TODO
- [ ] Create `webhook_waiter.py` script.
- [ ] Create `deploy.sh` script for production release.
- [ ] Update `SKILL.md` with new commands.
- [ ] Add `json-repair` logic verification to the new workflow.
