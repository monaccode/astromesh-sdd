---
name: sdd-plan
description: Use when a feature's spec.md is approved and there is no plan.md yet, or the spec changed after planning. Writes plan.md - architecture decisions, files to touch, risks and test strategy - where every step cites the requirements it serves.
---

# SDD — Plan

The plan turns the approved spec into a technical approach: what changes where, which
decisions were made and what was rejected, how each requirement will be proven. It is the
first phase allowed to talk about code.

## Step 0 — Load project settings

Before anything else, read these if they exist. Missing files are normal; use the defaults.

1. `.sdd/config.yaml` in the project, else `~/.sdd/config.yaml`. Defaults:
   `specs_dir: specs`, `language: en`, `ids: {requirement: REQ, task: T}`,
   `gates: [specify, plan, tasks]`, `verify_command: ""`,
   `phases: [constitution, specify, plan, tasks, implement, verify]`.
2. Template: `.sdd/templates/plan.md`, else `~/.sdd/templates/plan.md`,
   else `templates/plan.md` next to this file.
3. Extra rules: `.sdd/rules/all.md` and `.sdd/rules/plan.md` (project, then global).
   They add to this skill; when they conflict with it, they win.

Write every artifact in `language`. Use the configured ID prefixes everywhere this skill
says `REQ` or `T`.

## Step 1 — Preconditions

Read `spec.md` (and `<specs_dir>/constitution.md` if present). If the spec still has
`[NEEDS CLARIFICATION]` items, resolve them with the user first — through `sdd-specify`'s
"Changing a spec" rules — before planning. Planning around an open question bakes in a guess.

If an earlier custom phase left its own artifact in the feature folder (for example
`adr.md`), read it too: the plan must follow it.

## Step 2 — Understand the code it touches

Trace the real flow end to end for the behavior the spec changes: entry point, the
functions and modules on the path, the data they share, the tests that cover them today.
Reuse what exists before proposing anything new.

## Step 3 — Write plan.md

Write `plan.md` from the template:

- **Approach** — 2–4 sentences a newcomer can follow.
- **Decisions** — each with the alternative you rejected and why. A decision with no
  rejected alternative is not a decision; leave it out.
- **File map** — every file to create or modify, with its one responsibility.
- **Steps** — ordered; each cites at least one `REQ-n`.
- **Risks** — each with how you would notice it going wrong.
- **Test strategy** — for every `REQ`, how it will be verified (test type and what it
  asserts).
- Respect every principle in the constitution; if the plan must break one, say so
  explicitly and why, so the user can decide.

## Step 4 — Coverage check

Fill the Coverage table: every requirement in the spec and the steps that cite it. A
requirement with no step is a blocker — add the step or go back to the spec. Removed
requirements (`~~REQ-n~~`) are skipped.

## When the spec changes after planning

Update only the affected steps, decisions and coverage rows; keep the rest. Note the
change at the end of the Approach section with the date.

## Gate

If `plan` is in `gates`: show the user the artifact path and a 3–5 line summary, list any
`[NEEDS CLARIFICATION]` items, and **stop**. Do not start the next phase until the user
approves. When they approve, set the artifact's status line to
`**Status:** approved · **Date:** YYYY-MM-DD` and save the file — approval has to live in
the file, so a later session or another agent can see it. If `plan` is not in `gates`, set
the status to approved yourself, say which phase runs next and continue.
