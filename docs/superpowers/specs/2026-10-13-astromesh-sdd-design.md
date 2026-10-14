# astromesh-sdd — design

**Date:** 2026-10-13 · **Status:** approved in conversation, pending written review
**Repo:** `monaccode/astromesh-sdd` (public, Apache-2.0)

## Goal

A set of Spec-Driven Development (SDD) skills that work in any coding agent that reads the
open **Agent Skills** format (`SKILL.md` with `name` + `description` frontmatter — see
agentskills.io), packaged at the same time as a **Claude Code plugin**. Each phase of the
cycle leaves a versioned file on disk, so any agent (or person) can pick the work up by
reading the files. Shared with the developer community: English content, Spanish README
mirror, install docs for every supported platform.

**Success criteria**

1. `skills/` installs and loads, unmodified, in Claude Code, Codex CLI, OpenCode, Kimi Code,
   GitHub Copilot and Gemini CLI; agents without skill support get the cycle via `AGENTS.md`.
2. A user can go idea → `spec.md` → `plan.md` → `tasks.md` → code → verification report,
   with every requirement traceable to a task and to evidence.
3. A user can change paths, language, templates, gates and per-phase rules, and add their
   own phases, without editing the shipped skills.
4. CI proves the skill frontmatter, plugin manifests, example config and installers are valid.

**Out of scope:** a CLI or runtime of our own, a hooks/plugin language, subagent
orchestration, telemetry. Add when a real case does not fit the three extension levels.

## 1. The cycle and its artifacts

```
specs/
  constitution.md          project principles (optional, once per repo)
  NNN-<slug>/
    spec.md                REQ-1…  what and why; verifiable acceptance criteria
    plan.md                decisions, files touched, risks; each step cites REQ-n
    tasks.md               T-1…    checklist; each task cites REQ-n and names its check
    verify.md              REQ → task → evidence matrix; uncovered items flagged
```

`NNN` is the next free three-digit number in `specs_dir`; `<slug>` is kebab-case from the
title.

| Skill | Reads | Writes |
|---|---|---|
| `sdd` (index) | which artifacts exist | nothing — explains the cycle, routes to the next phase |
| `sdd-constitution` | the repo | `specs/constitution.md` |
| `sdd-specify` | the user's idea, constitution | `spec.md`; open questions marked `[NEEDS CLARIFICATION]`, never invented |
| `sdd-plan` | approved spec | `plan.md` |
| `sdd-tasks` | approved plan | `tasks.md` |
| `sdd-implement` | `tasks.md` | code; ticks one task at a time, runs its check before ticking |
| `sdd-verify` | all of the above + `verify_command` output | `verify.md` |

**Cross-cutting rules (in every skill):**

- **Human gate** after each phase listed in `gates`: present the artifact, stop, wait for
  approval. Default gates: `specify`, `plan`, `tasks`.
- **Traceability:** every plan step and task cites at least one `REQ-n`; `sdd-verify` fails
  any REQ without a task or without evidence.
- **Spec first:** a new or changed requirement found mid-work goes into `spec.md` (new
  `REQ-n`, never renumber) before code changes.
- **Routing (index skill):** no spec dir → specify; `spec.md` only → plan; `plan.md` → tasks;
  unticked tasks → implement; all ticked → verify.

## 2. Distribution and install

```
astromesh-sdd/
  skills/
    sdd/SKILL.md
    sdd-constitution/{SKILL.md, templates/constitution.md}
    sdd-specify/{SKILL.md, templates/spec.md}
    sdd-plan/{SKILL.md, templates/plan.md}
    sdd-tasks/{SKILL.md, templates/tasks.md}
    sdd-implement/SKILL.md
    sdd-verify/{SKILL.md, templates/verify.md}
  .claude-plugin/plugin.json
  .claude-plugin/marketplace.json
  AGENTS.md
  install.sh  install.ps1
  templates/skill/SKILL.md    mold for user-defined phases (outside skills/ so no platform loads it)
  examples/.sdd/              commented example config, templates and rules
  examples/specs/001-…/       one worked example, fully traced
  docs/install.md  docs/extending.md
  assets/logo-mark.svg  logo.png  icon.png
  README.md  README.es.md  CONTRIBUTING.md  CHANGELOG.md  LICENSE
  .github/workflows/ci.yml  release.yml
```

**Single source of truth:** `skills/`. No per-platform copies, no build step.

**Installer** — `install.sh` (macOS/Linux, POSIX sh) and `install.ps1` (Windows), same flags:

```
install [--target claude|agents|agents-md|all]   default: all
        [--project | --global]   default: --project
        [--link]                 symlink instead of copy
        [--dry-run]              print actions, change nothing
        [--init]                 also write an example .sdd/ into the project
```

Idempotent; never overwrites a user's `.sdd/`. Paths, verified 2026-10-13 against each
platform's official docs (cited in `docs/install.md`):

| Target | Project | Global | Read by |
|---|---|---|---|
| `claude` | `.claude/skills/` | `~/.claude/skills/` | Claude Code (also OpenCode, Copilot) |
| `agents` | `.agents/skills/` | `~/.agents/skills/` | Codex CLI, OpenCode, Kimi Code, Gemini CLI, GitHub Copilot |
| `agents-md` | `AGENTS.md` (marked block) | — | any agent without skill support (Cursor, Aider, …) |

`--target codex|opencode|kimi|gemini|copilot` are accepted as aliases of `agents`, so the
docs can give each platform its own obvious command. `agents-md` inserts or replaces a block
between `<!-- astromesh-sdd:start -->` / `<!-- astromesh-sdd:end -->`, keeping the rest of
the user's `AGENTS.md`.

**Claude Code:** the repo root is both the plugin (`.claude-plugin/plugin.json`, skills
auto-discovered from `skills/`) and a one-plugin marketplace named `astromesh`
(`marketplace.json`, entry `source: "./"`). Install: `/plugin marketplace add
monaccode/astromesh-sdd` then `/plugin install astromesh-sdd@astromesh`; skills run as
`/astromesh-sdd:sdd-specify`. Or `install --target claude` for plain `/sdd-specify`.

**`docs/install.md`:** one section per platform — one-line command, equivalent manual path,
how to invoke a skill there, how to check it loaded — plus "any other agent" via `AGENTS.md`.

**CI:** validate each `SKILL.md` frontmatter (`name` equals folder name, matches
`^[a-z0-9]+(-[a-z0-9]+)*$`, ≤ 64 chars, `description` 1–1024 chars); `claude plugin
validate --strict .`; parse `plugin.json`,
`marketplace.json` and `examples/.sdd/config.yaml`; run `install.sh --dry-run` and a real
install into a temp dir for every target on Linux and macOS, and `install.ps1` on Windows.
**Release:** tag `vX.Y.Z` → GitHub Release with notes from `CHANGELOG.md`.

## 3. README and brand

- **README.md:** logo → one-line pitch → badges (layer first, per the ecosystem badge
  grammar; no hard-coded versions beyond the release badge) → Mermaid **mindmap** of the
  package (phases, artifacts, platforms, extension points) → Mermaid flowchart of the cycle
  with its gates → 30-second quickstart table per platform → link to `docs/install.md` →
  the traced example from `examples/specs/` → customization summary → contributing.
  `README.es.md` mirrors it.
- **Logo:** same visual grammar as `astromesh-okf/assets/logo-mark.svg` (radial glow, orbit
  ellipses with blue gradients `#1e40af` → `#1fb4f2` → `#1d4ed8`). Central object: a
  spec/blueprint sheet with three stepped check marks (spec → plan → tasks). Deliverables:
  `logo-mark.svg`, `logo.png` (mark + wordmark "astromesh sdd"), `icon.png`. Rendered and
  shown to the user before it is final.

## 4. Extension and customization

Three levels; none requires editing shipped skills. Precedence everywhere:
**project `.sdd/` > global `~/.sdd/` > shipped defaults.**

1. **Config — `.sdd/config.yaml`** (optional):
   ```yaml
   specs_dir: specs
   language: en                     # language of generated artifacts
   ids: { requirement: REQ, task: T }
   gates: [specify, plan, tasks]    # [] = autonomous mode
   verify_command: ""               # e.g. "uv run pytest"; empty = ask / infer
   phases: [constitution, specify, plan, tasks, implement, verify]
   ```
2. **Overrides** — `.sdd/templates/<name>.md` replaces the shipped template of the same name;
   `.sdd/rules/<phase>.md` and `.sdd/rules/all.md` add rules to a phase / to every phase.
3. **New phases** — copy `templates/skill/`, install it like any skill, list it in
   `phases:` so the `sdd` index routes to it in order.

Every phase skill opens with the same "Load project settings" step that applies the above.
`docs/extending.md` documents it with three recipes: security section in every spec,
Spanish artifacts, an extra `sdd-adr` phase.

## Testing

Content, not code: correctness is (a) CI validation above, and (b) a manual dogfood run
before v0.1.0 — use the installed skills in Claude Code and at least one other platform to
produce `examples/specs/001-…` end to end, and record which platforms were actually run.

## Open items resolved during implementation

- Platform paths and `marketplace.json` shape: resolved 2026-10-13 (see section 2).
