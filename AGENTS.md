# Spec-Driven Development (astromesh-sdd)

This project builds features with Spec-Driven Development. Work flows
**spec → plan → tasks → implement → verify**, and every phase leaves a file. Read those
files to know where a feature stands; never keep its state only in the conversation.
Full skills and templates: https://github.com/monaccode/astromesh-sdd

## Artifacts

```
specs/
  constitution.md          project principles (optional)
  NNN-<slug>/
    spec.md                REQ-n requirements: what and why, testable
    plan.md                decisions, file map, steps citing REQ-n
    tasks.md               T-n checklist, each with a runnable check
    verify.md              REQ → task → evidence; verdict PASS/FAIL
```

Settings, all optional: `.sdd/config.yaml` (`specs_dir`, `language`, `ids`, `gates`,
`verify_command`, `phases`), `.sdd/templates/<name>.md` (replace a template),
`.sdd/rules/all.md` and `.sdd/rules/<phase>.md` (extra rules that win on conflict).
Missing files are normal: defaults are `specs/`, English, `REQ`/`T`, gates after specify,
plan and tasks.

## Where am I?

In the feature dir (the one named, else the highest `NNN`), walk `phases` in order and do
the first phase that is not done: no `spec.md` → specify; no `plan.md` → plan; no
`tasks.md` → tasks; unticked tasks → implement; no `verify.md` → verify; `verify.md`
PASS → done. A gated artifact whose `**Status:**` is not `approved` sends you back to its
gate. `verify.md` FAIL → do its Next actions, then run `sdd-verify` again.

## Phases

**Constitution** (optional, once). Read README, build files, CI; write 5–9 *testable*
principles with a one-line why, plus the real test and lint commands.

**Specify.** Next free `NNN`, kebab slug. Ask at most 3 scope questions, one at a time;
anything else unknown becomes `[NEEDS CLARIFICATION: …]` — never guess. Each `REQ-n` is one
observable behavior with Given/When/Then acceptance. List non-goals. No implementation
details. To change a spec: new requirements take the next free ID; IDs never renumber and
are never reused; removed ones become `~~REQ-n~~ (removed: reason)`; log it in Changelog.

**Plan.** Resolve open questions first. Trace the real code path the change touches.
Write approach, decisions (with the rejected alternative), file map, ordered steps each
citing `REQ-n`, risks, test strategy per requirement, and a coverage table — a requirement
no step cites blocks the plan.

**Tasks.** One reviewable unit per task, tests in the same task as their code:
`- [ ] T-n — title (REQ-a)` with `files:`, `check:` (runnable command → expected),
`depends:`. Mark parallel tasks `[P]`. Coverage table: every requirement appears.

**Implement.** One task at a time: write the test, see it fail for the right reason,
implement the minimum, run the task's check and the suite, tick only on pass
(`— done YYYY-MM-DD`), commit citing `T-n`. A new or changed requirement goes to the spec
first.

**Verify.** Run `verify_command` now and keep the output tail. For each requirement: the
tasks citing it, evidence produced now, ✅ / ⚠️ / ❌. PASS only if the suite passed, every
requirement is ✅ and no task is unticked. Write `verify.md`; on FAIL, list where to go back.

## Rules in every phase

- **Gate:** after each phase in `gates`, show the artifact and stop until the user approves;
  then set its `**Status:**` line to `approved`. Approval lives in the file.
- **Traceability:** every step and task cites a `REQ-n`; uncited requirements and
  unciting tasks are failures.
- **Spec first:** requirements change in `spec.md` before code changes.
- **Evidence:** "done" and ✅ need a check that ran in this session.
