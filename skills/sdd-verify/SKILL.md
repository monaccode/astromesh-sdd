---
name: sdd-verify
description: Use when every task in tasks.md is checked, or before calling a feature done, merging or releasing it. Traces every requirement to its tasks and to evidence produced now, and writes verify.md - flagging anything uncovered instead of passing it.
---

# SDD — Verify

Verification answers one question with evidence: **does the system do what the spec says?**
Its output, `verify.md`, is the record a reviewer reads before accepting the feature.

## Step 0 — Load project settings

Before anything else, read these if they exist. Missing files are normal; use the defaults.

1. `.sdd/config.yaml` in the project, else `~/.sdd/config.yaml`. Defaults:
   `specs_dir: specs`, `language: en`, `ids: {requirement: REQ, task: T}`,
   `gates: [specify, plan, tasks]`, `verify_command: ""`,
   `phases: [constitution, specify, plan, tasks, implement, verify]`.
2. Template: `.sdd/templates/verify.md`, else `~/.sdd/templates/verify.md`,
   else `templates/verify.md` next to this file.
3. Extra rules: `.sdd/rules/all.md` and `.sdd/rules/verify.md` (project, then global).
   They add to this skill; when they conflict with it, they win.

Write every artifact in `language`. Use the configured ID prefixes everywhere this skill
says `REQ` or `T`.

## Step 1 — Run the suite

Run `verify_command`. If it is empty, use the test command in
`<specs_dir>/constitution.md`; if there is none, ask the user. Keep the last 20 lines of
the real output and the exit status. Do not summarize from memory or from an earlier run.

## Step 2 — Trace every requirement

For each requirement in `spec.md` (skip `~~removed~~` ones):

- **Tasks** — which tasks in `tasks.md` cite it.
- **Evidence** — produced in this run: the test that exercises its acceptance criteria and
  its result, or a manual check you perform now with what you observed. "The code handles
  it" is not evidence.
- **Status** — ✅ covered (evidence passes) · ⚠️ partial (some acceptance criteria not
  exercised) · ❌ uncovered (no task, or no evidence, or evidence fails).

Also collect: tasks that cite no requirement (scope creep), and unticked tasks.

## Step 3 — Verdict

**PASS** only if the suite passed, every non-removed requirement is ✅, and no task is
unticked. Anything else is **FAIL**. Never mark ✅ without evidence produced in this run,
and never round ⚠️ up to ✅.

## Step 4 — Write verify.md

Write `verify.md` from the template. On FAIL, fill "Next actions" with where to go back
to: a missing requirement → `sdd-specify`; a requirement with no task → `sdd-tasks`; a
failing check → `sdd-implement`.

Show the user the verdict and the traceability table.
