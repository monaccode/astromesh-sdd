---
name: sdd-specify
description: Use when the user describes a new feature, change or product idea and no spec exists for it yet, or when a requirement must be added or changed. Writes specs/NNN-slug/spec.md with numbered, testable requirements and marks open questions instead of guessing.
---

# SDD — Specify

The spec says **what** the system must do and **why**. It never says how: no file names,
frameworks or APIs unless the user mandated them. It is the contract the plan, the tasks and
the verification are checked against.

## Step 0 — Load project settings

Before anything else, read these if they exist. Missing files are normal; use the defaults.

1. `.sdd/config.yaml` in the project, else `~/.sdd/config.yaml`. Defaults:
   `specs_dir: specs`, `language: en`, `ids: {requirement: REQ, task: T}`,
   `gates: [specify, plan, tasks]`, `verify_command: ""`,
   `phases: [constitution, specify, plan, tasks, implement, verify]`.
2. Template: `.sdd/templates/spec.md`, else `~/.sdd/templates/spec.md`,
   else `templates/spec.md` next to this file.
3. Extra rules: `.sdd/rules/all.md` and `.sdd/rules/specify.md` (project, then global).
   They add to this skill; when they conflict with it, they win.

Write every artifact in `language`. Use the configured ID prefixes everywhere this skill
says `REQ` or `T`.

## Step 1 — Find or create the feature dir

- If the user points at an existing spec, go to **Changing a spec** below.
- Otherwise the next number `NNN` is the highest three-digit prefix in `specs_dir` plus one
  (start at `001`). The slug is kebab-case, at most 5 words, from the feature title.
  Create `<specs_dir>/NNN-<slug>/`.

## Step 2 — Read context

Read `<specs_dir>/constitution.md` if it exists. Read code only as far as you need to
understand the domain and the current behavior — you are not designing yet.

## Step 3 — Ask, don't invent

Ask at most 3 questions, **one at a time**, and only about things that change scope: who
the user is, what must happen, what is explicitly out. Anything else you do not know goes
into the spec as `[NEEDS CLARIFICATION: <question>]`. Never fill a gap with a plausible
guess; a guess in a spec becomes a requirement nobody asked for.

## Step 4 — Write spec.md

Write `spec.md` from the template.

- Each requirement is `REQ-n`: one sentence, one observable behavior ("the system does X
  when Y"), followed by at least one acceptance criterion in Given / When / Then.
- A requirement that contains "and" usually hides two. Split it.
- List non-goals explicitly. They are what stops scope creep later.

## Step 5 — Self-check

Before the gate, re-read the spec and fix inline:

- Can every `REQ` be tested by someone who did not write it?
- Is any implementation detail leaking in?
- Does anything contradict the constitution or another requirement?
- Is anything ambiguous enough to be built two ways? Make it explicit or mark it
  `[NEEDS CLARIFICATION]`.

## Changing a spec

Requirements change; their IDs do not. When a requirement is added or changed — by the user
or because implementation discovered it:

- A new requirement takes the next free number. IDs never renumber and are never reused,
  because plans, tasks, commits and tests already cite them.
- A changed requirement keeps its ID; rewrite it and note the change.
- A removed requirement stays in place as `~~REQ-4~~ (removed YYYY-MM-DD: <reason>)`.
- Add a row to the spec's Changelog.
- If `plan.md` or `tasks.md` exist, list the steps and tasks that cite the changed IDs so
  they can be updated next.

## Gate

If `specify` is in `gates`: show the user the artifact path and a 3–5 line summary, list any
`[NEEDS CLARIFICATION]` items, and **stop**. Do not start the next phase until the user
approves. If it is not in `gates`, say which phase runs next and continue.
