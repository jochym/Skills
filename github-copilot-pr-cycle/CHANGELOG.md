# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-02-23

### Changed
- **Breaking**: Replaced `gh run watch` with `gh pr checks --watch` for CI monitoring
- **Breaking**: Changed reviewer from `@copilot` to `copilot-pull-request-reviewer`
- Migrated from webhook-based architecture to native CLI polling
- Simplified wait logic using bash instead of Python HTTP server

### Added
- `wait_for_review.sh` script with smart polling
- `json-repair` integration for handling malformed Copilot JSON
- `--output` flag to save review JSON to file
- `--pr` flag to specify pull request number
- Comprehensive README.md with usage examples
- This CHANGELOG.md

### Removed
- `webhook_waiter.py` (no longer needed)
- `gh webhook forward` dependency
- Complex HTTP server infrastructure

### Fixed
- More reliable CI status detection using native `gh pr checks`
- Better timeout handling in review waiting
- JSON parsing errors with automatic repair

## [1.0.0] - 2026-02-17

### Added
- Initial release of github-copilot-pr-cycle skill
- Automated PR workflow with Copilot review integration
- Basic polling mechanism for review detection
- TDD-based iteration cycle
