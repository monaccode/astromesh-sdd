---
name: my-phase
description: Use when <the situation in which an agent should run this phase - be concrete, this is what triggers the skill>.
---

<!--
Template for a custom SDD phase.
1. Copy this folder to skills/<your-phase>/ (or straight into .claude/skills/ or .agents/skills/).
2. Rename the folder and `name` above to the same kebab-case name, e.g. sdd-adr.
3. Add the phase to `phases:` in .sdd/config.yaml, in the order it should run.
4. Install it like any other skill. The `sdd` skill will route to it.
-->

# SDD — My phase

<One paragraph: what this phase is for and what it adds to the cycle.>

## Step 0 — Load project settings

Before anything else, read these if they exist. Missing files are normal; use the defaults.

1. `.sdd/config.yaml` in the project, else `~/.sdd/config.yaml`. Defaults:
   `specs_dir: specs`, `language: en`, `ids: {requirement: REQ, task: T}`,
   `gates: [specify, plan, tasks]`, `verify_command: ""`,
   `phases: [constitution, specify, plan, tasks, implement, verify]`.
2. Extra rules: `.sdd/rules/all.md` and `.sdd/rules/my-phase.md` (project, then global).
   They add to this skill; when they conflict with it, they win.

Write every artifact in `language`. Use the configured ID prefixes everywhere this skill
says `REQ` or `T`.

## What this phase reads and writes

- **Reads:** `<specs_dir>/NNN-<slug>/spec.md` (and whatever else it needs).
- **Writes:** `<specs_dir>/NNN-<slug>/<my-phase>.md` — the `sdd` skill considers this phase
  done when that file exists.

## Steps

1. <first step>
2. <second step>

## Gate

If `my-phase` is in `gates`: show the user the artifact path and a 3–5 line summary, list any
`[NEEDS CLARIFICATION]` items, and **stop**. Do not start the next phase until the user
approves. When they approve, set the artifact's status line to
`**Status:** approved · **Date:** YYYY-MM-DD` and save the file — approval has to live in
the file, so a later session or another agent can see it. If `my-phase` is not in `gates`, set
the status to approved yourself, say which phase runs next and continue.
