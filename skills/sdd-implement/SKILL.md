---
name: sdd-implement
description: Use when tasks.md exists with unchecked tasks. Implements exactly one task at a time - test first where the check is a test - runs its check, and only then ticks it. Sends any new or changed requirement back to the spec before coding it.
---

# SDD — Implement

Implementation follows `tasks.md` one task at a time. A task is done when its check passed
in this session — not when the code looks right.

## Step 0 — Load project settings

Before anything else, read these if they exist. Missing files are normal; use the defaults.

1. `.sdd/config.yaml` in the project, else `~/.sdd/config.yaml`. Defaults:
   `specs_dir: specs`, `language: en`, `ids: {requirement: REQ, task: T}`,
   `gates: [specify, plan, tasks]`, `verify_command: ""`,
   `phases: [constitution, specify, plan, tasks, implement, verify]`.
2. Extra rules: `.sdd/rules/all.md` and `.sdd/rules/implement.md` (project, then global).
   They add to this skill; when they conflict with it, they win.

Write every artifact in `language`. Use the configured ID prefixes everywhere this skill
says `REQ` or `T`.

## The loop

For each task:

1. **Pick** the first unticked task whose `depends` are all ticked, or the one the user
   names. Read the requirements it cites in `spec.md` and the matching plan steps.
2. **Test first.** If the task's check is a test, write that test now and run it. It must
   fail, and fail because the behavior is missing (not because of a typo or an import
   error). A test that passes before the code exists is not testing the task.
3. **Implement the minimum** that makes the check pass. Do not build ahead of the tasks.
4. **Run the task's `check`** and read the output. Compare it with the expected result in
   `tasks.md`. Also run the project's test suite (`verify_command`, else the constitution's
   test command) — a green task with a red suite is not done.
5. **Tick it** only on a passing check: `- [x] T-n — … — done YYYY-MM-DD`. Never tick a
   task whose check you did not run.
6. **Commit** that task alone, citing it: `feat: <title> (T-n, REQ-a)`.
7. Report `k/N tasks done` in one line and continue with the next task, unless the user
   asked to pause or a gate applies.

## Spec first

If the work reveals a requirement the spec does not have — a missing case, a changed
behavior, a constraint nobody wrote down — **stop coding**. Add it to `spec.md` following
the "Changing a spec" rules of `sdd-specify` (the next free ID; IDs never renumber), get
the user's approval if `specify` is gated, add the plan step and the task, then continue.
Code that implements a requirement the spec does not contain is invisible to verification.

## When a check fails

Find the cause before changing anything. If the code is wrong, fix the code. If the task
or the plan is wrong (impossible check, wrong file, missing dependency), fix `tasks.md` or
`plan.md` first and say so — do not quietly change what "done" means.

## Finishing

When every task is ticked, say so and hand over to `sdd-verify`.
