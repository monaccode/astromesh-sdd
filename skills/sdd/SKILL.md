---
name: sdd
description: Use when starting or resuming any feature with Spec-Driven Development, or when unsure which SDD phase comes next. Explains the cycle and routes to sdd-specify, sdd-plan, sdd-tasks, sdd-implement or sdd-verify based on which files exist.
---

# Spec-Driven Development (SDD)

Work flows **spec → plan → tasks → implement → verify**. Every phase leaves a file on disk.
Those files are the shared memory between sessions, people and agents: anyone — you in a
fresh session, a teammate, a different coding agent — can pick the work up by reading them.
Never keep the state of a feature only in the conversation.

## Artifacts

```
specs/
  constitution.md          project principles (optional, once per repo)
  NNN-<slug>/
    spec.md                REQ-1…  what and why; verifiable acceptance criteria
    plan.md                decisions, files touched, risks; each step cites REQ-n
    tasks.md               T-1…    checklist; each task cites REQ-n and names its check
    verify.md              REQ → task → evidence matrix; uncovered items flagged
```

`specs/` and the `REQ`/`T` prefixes are defaults; `.sdd/config.yaml` can change them.

## Where am I? (routing)

1. Read `.sdd/config.yaml` (project, else `~/.sdd/config.yaml`) for `specs_dir` and
   `phases`. Missing file = defaults: `specs_dir: specs`,
   `phases: [constitution, specify, plan, tasks, implement, verify]`.
2. Pick the feature dir: the one the user names, else the highest `NNN-*` in `specs_dir`.
3. Route by what exists in that dir:

| State | Next skill |
|---|---|
| no feature dir (or the user describes something new) | `sdd-specify` |
| `spec.md` only | `sdd-plan` |
| `plan.md`, no `tasks.md` | `sdd-tasks` |
| `tasks.md` with any `- [ ]` | `sdd-implement` |
| every task ticked, no `verify.md` | `sdd-verify` |
| `verify.md` with verdict PASS | done — tell the user |
| `verify.md` with verdict FAIL | follow its "Next actions" |

`constitution` is optional: suggest `sdd-constitution` once if `<specs_dir>/constitution.md`
does not exist, but do not block on it.

**Custom phases.** If `phases` lists a phase that is not one of the six above, a skill
named `sdd-<phase>` (or `<phase>`) handles it. Route through `phases` in list order; a custom
phase is done when the file its skill says it writes exists in the feature dir.

Tell the user where the feature stands (one line), then use the next skill.

## Rules that hold in every phase

**Human gate.** After each phase listed in `gates` (default `specify`, `plan`, `tasks`),
show the artifact and stop until the user approves. Approval of one phase is not approval
of the next.

**Traceability.** Every plan step and every task cites at least one `REQ-n`. A requirement
nobody cites is not going to be built; a task citing nothing is scope creep. `sdd-verify`
fails both.

**Spec first.** When work reveals a new or changed requirement, it goes into `spec.md` as a
new `REQ-n` before any code changes. IDs are permanent: never renumber, never reuse.

**One task at a time.** Implement a task, run its check, tick it, commit. Then the next.

## Customizing

- `.sdd/config.yaml` — paths, language, ID prefixes, gates, verify command, phase order.
- `.sdd/templates/<name>.md` — replace any shipped template.
- `.sdd/rules/all.md`, `.sdd/rules/<phase>.md` — add your own rules to every phase or one.
- Guide: https://github.com/monaccode/astromesh-sdd/blob/main/docs/extending.md
