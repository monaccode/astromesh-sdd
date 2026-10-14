# Contributing to astromesh-sdd

Thanks for helping. Issues, questions and pull requests are all welcome.

## Run the checks

```bash
pip install pyyaml                                  # or: uv run --with pyyaml …
python3 -m unittest discover -s tests -p "test_*.py" -v
python3 scripts/check.py .                          # skills, manifests, example config
sh tests/install_test.sh                            # installer, in throwaway dirs
pwsh tests/install_test.ps1                         # Windows installer (needs PowerShell 7)
claude plugin validate --strict .                   # Claude Code plugin + marketplace
```

CI runs all of them on Linux, macOS and Windows.

## Writing or changing a skill

- Frontmatter has only `name` and `description` — the portable subset every agent reads.
  `name` equals the folder name. `description` starts with "Use when…" and says when to
  run the skill, not the steps.
- Every phase skill starts with the shared **Step 0 — Load project settings** block, word
  for word, so `.sdd/` settings work the same in every phase. Phases that can be gated end
  with the shared **Gate** block. `scripts/check.py` enforces the first.
- A template a skill ships must be named in its `SKILL.md`.
- Keep `AGENTS.md` in step: it is the condensed version of the skills for agents without
  skill support.

## Adding a platform

1. Find where the agent loads skills in its **official** docs.
2. If it already reads `.agents/skills/` or `.claude/skills/`, add it as an alias in both
   installers (`install.sh`, `install.ps1`) and to the tests.
3. Add a section to [docs/install.md](docs/install.md) with the paths, how to run a skill,
   how to check it loaded, and the source link.

## Commits and releases

Conventional commits (`feat:`, `fix:`, `docs:`, `ci:`, `chore:`). Add user-visible changes
to `CHANGELOG.md` under `[Unreleased]`. A `vX.Y.Z` tag publishes a GitHub Release with
that version's changelog section.
