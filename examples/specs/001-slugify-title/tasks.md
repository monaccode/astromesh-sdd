# Tasks — 001 Slugify title

**Plan:** ./plan.md · **Spec:** ./spec.md

- [x] T-1 — Add `slugify` core: ASCII fold, lowercase, split on separators, join with `-` (REQ-1, REQ-2, REQ-3, REQ-5) — done 2026-10-13
  - files: `textutil.py`, `tests/test_textutil.py`
  - check: `python3 -m unittest discover -s tests -k Slugify` → `OK`, running the
    lowercase, accent, non-ASCII (`世界`, `☃`, `ß`, `Ø`) and separator (`_`, `--`, tab, NBSP) tests;
    then `python3 -m unittest discover -s tests` → `OK`
  - depends: —

- [x] T-2 — Remove punctuation inside words, dropping words left empty (REQ-4) — done 2026-10-13
  - note: dropping empty words moved here from T-3 — `"C++ & Rust"` → `"c-rust"` needs it
  - files: `textutil.py`, `tests/test_textutil.py`
  - check: `python3 -m unittest discover -s tests -k Slugify` → `OK`, including
    `"Don't stop!"` → `"dont-stop"`, `"Hello, world."` → `"hello-world"`,
    `"C++ & Rust"` → `"c-rust"`; then `python3 -m unittest discover -s tests` → `OK`
  - depends: T-1

- [x] T-3 — Keep the first 5 non-empty words, return `""` when none remain (REQ-6, REQ-7) — done 2026-10-13
  - note: the REQ-7 test passed before this task's code (T-2's empty-word drop delivers it); kept as a regression test
  - files: `textutil.py`, `tests/test_textutil.py`
  - check: `python3 -m unittest discover -s tests -k Slugify` → `OK`, including seven words →
    first five, `"a & b 世界 c d e f"` → `"a-b-c-d-e"`, `""` → `""`, `"?!... --- ___"` → `""`;
    then `python3 -m unittest discover -s tests` → `OK`
  - depends: T-2

## Coverage
| Requirement | Tasks |
|---|---|
| REQ-1 | T-1 |
| REQ-2 | T-1 |
| REQ-3 | T-1 |
| REQ-4 | T-2 |
| REQ-5 | T-1 |
| REQ-6 | T-3 |
| REQ-7 | T-3 |
