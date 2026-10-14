# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Seven Spec-Driven Development skills in the open Agent Skills format: `sdd` (cycle and
  routing), `sdd-constitution`, `sdd-specify`, `sdd-plan`, `sdd-tasks`, `sdd-implement`,
  `sdd-verify`, with templates for every artifact.
- Claude Code plugin and one-plugin marketplace (`astromesh-sdd@astromesh`).
- `install.sh` and `install.ps1` for Claude Code, `.agents/skills` agents (Codex CLI,
  OpenCode, Kimi Code, Gemini CLI, GitHub Copilot) and `AGENTS.md`.
- Customization through `.sdd/`: `config.yaml`, template overrides, per-phase rules and
  custom phases (`templates/my-phase`), with an example folder and `docs/extending.md`.
- Per-platform install guide with the official source for every path.
- Worked example `examples/specs/001-slugify-title`, produced by the skills.

Tested before release: the full cycle (specify → verify, PASS) in Claude Code from
`.claude/skills`; specify and plan in OpenCode from `.agents/skills`, with the `.claude`
copy removed. Kimi Code, Codex CLI, Gemini CLI and GitHub Copilot are installed to their
documented paths but not yet run end to end.
