---
name: sdd-constitution
description: Use when a project has no specs/constitution.md yet, or the user wants to set or change project-wide engineering principles that every SDD spec and plan must respect.
---

# SDD — Constitution

The constitution is the short list of principles every spec, plan and task in this repo
must respect. It is written once and amended rarely, on purpose.

## Step 0 — Load project settings

Before anything else, read these if they exist. Missing files are normal; use the defaults.

1. `.sdd/config.yaml` in the project, else `~/.sdd/config.yaml`. Defaults:
   `specs_dir: specs`, `language: en`, `ids: {requirement: REQ, task: T}`,
   `gates: [specify, plan, tasks]`, `verify_command: ""`,
   `phases: [constitution, specify, plan, tasks, implement, verify]`.
2. Template: `.sdd/templates/constitution.md`, else `~/.sdd/templates/constitution.md`,
   else `templates/constitution.md` next to this file.
3. Extra rules: `.sdd/rules/all.md` and `.sdd/rules/constitution.md` (project, then global).
   They add to this skill; when they conflict with it, they win.

Write every artifact in `language`. Use the configured ID prefixes everywhere this skill
says `REQ` or `T`.

## Step 1 — Learn the project as it is

Read the README, build/package files, CI config, lint and test setup, and a few
representative source files. Record what you **observed**, not what you would prefer:
language and runtime, the real test command, the real lint/format command.

## Step 2 — Draft principles

Write 5–9 principles. Each one:

- is **testable** — a reviewer can answer yes or no to "does this change respect it?"
  ("Public functions have type hints", not "Write clean code");
- carries a one-line *Why*;
- reflects this project, not generic advice. If the codebase already follows a rule
  consistently, it is a principle; if it does not, ask the user before adding it.

Ask the user which principles they want to add or drop. Suggest the detected test command
as `verify_command` for `.sdd/config.yaml`.

## Step 3 — Write it

Write `<specs_dir>/constitution.md` from the template. If the file already exists, do not
overwrite it: show the proposed changes as a diff, and on approval apply them and add a row
to its Amendments table.

Show the user the result. Specs and plans written from now on must check themselves
against it.
