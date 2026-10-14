---
name: sdd-tasks
description: Use when plan.md is approved and tasks.md does not exist yet, or the plan changed. Breaks the plan into small, ordered, independently verifiable tasks, each citing its requirements and naming the exact check that proves it done.
---

# SDD — Tasks

`tasks.md` is the checklist implementation follows. A good task is the smallest unit that
can be reviewed on its own and has a check that proves it done.

## Step 0 — Load project settings

Before anything else, read these if they exist. Missing files are normal; use the defaults.

1. `.sdd/config.yaml` in the project, else `~/.sdd/config.yaml`. Defaults:
   `specs_dir: specs`, `language: en`, `ids: {requirement: REQ, task: T}`,
   `gates: [specify, plan, tasks]`, `verify_command: ""`,
   `phases: [constitution, specify, plan, tasks, implement, verify]`.
2. Template: `.sdd/templates/tasks.md`, else `~/.sdd/templates/tasks.md`,
   else `templates/tasks.md` next to this file.
3. Extra rules: `.sdd/rules/all.md` and `.sdd/rules/tasks.md` (project, then global).
   They add to this skill; when they conflict with it, they win.

Write every artifact in `language`. Use the configured ID prefixes everywhere this skill
says `REQ` or `T`.

## Step 1 — Cut the plan into tasks

Read `plan.md` and `spec.md`. Then:

- One task = one reviewable unit. Fold setup, configuration and docs into the task whose
  deliverable needs them instead of making them tasks of their own.
- Tests live in the same task as the code they test, and are written first.
- Order tasks so each one builds on finished ones. Mark tasks that can run in parallel
  (no shared files, no dependency) with `[P]`.

## Step 2 — Write tasks.md

Write `tasks.md` from the template. Each task is:

```
- [ ] T-n — <imperative title> (REQ-a, REQ-b)
  - files: `<path>`, `<path>`
  - check: `<runnable command>` → <expected result>
  - depends: T-m | —
```

`check` is a command whose output proves the task done (a test, a build, a curl). Only
when no command can prove it, write a manual step with its observable outcome
("open /settings, the toggle is visible"). "Code compiles" is not a check for a feature.

## Step 3 — Coverage

Fill the Coverage table: every non-removed requirement and the tasks that cite it. Every
requirement appears at least once; every task cites at least one requirement.

## When the plan changes

Add new tasks with the next free number; IDs are not reused. Do not untick finished tasks
unless their check no longer passes.

## Gate

If `tasks` is in `gates`: show the user the artifact path and a 3–5 line summary, list any
`[NEEDS CLARIFICATION]` items, and **stop**. Do not start the next phase until the user
approves. If it is not in `gates`, say which phase runs next and continue.
