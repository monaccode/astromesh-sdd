# Verification — 001 Slugify title

**Date:** 2026-10-13 · **Command:** `python3 -m unittest discover -s tests` (run with `-v` for per-test results; exit 0) · **Verdict:** PASS

## Command output (tail)
~~~text
test_drops_non_ascii (test_textutil.Slugify.test_drops_non_ascii) ... ok
test_empty_result (test_textutil.Slugify.test_empty_result) ... ok
test_keeps_first_five_words (test_textutil.Slugify.test_keeps_first_five_words) ... ok
test_lowercase (test_textutil.Slugify.test_lowercase) ... ok
test_removes_punctuation (test_textutil.Slugify.test_removes_punctuation) ... ok
test_separators (test_textutil.Slugify.test_separators) ... ok
test_strips_accents (test_textutil.Slugify.test_strips_accents) ... ok
test_counts_words (test_textutil.WordCount.test_counts_words) ... ok

----------------------------------------------------------------------
Ran 8 tests in 0.001s

OK
~~~

## Traceability
| Requirement | Tasks | Evidence | Status |
|---|---|---|---|
| REQ-1 | T-1 | `test_lowercase` passed (`"Hello World"` → `"hello-world"`) | ✅ |
| REQ-2 | T-1 | `test_strips_accents` passed (`"Café Ñandú"` → `"cafe-nandu"`) | ✅ |
| REQ-3 | T-1 | `test_drops_non_ascii` passed (all 3 criteria: `世界`, `☃`, `ß`/`Ø`) | ✅ |
| REQ-4 | T-2 | `test_removes_punctuation` passed (all 3 criteria incl. `"C++ & Rust"` → `"c-rust"`) | ✅ |
| REQ-5 | T-1 | `test_separators` passed (`_`, `--`, tab, edge spaces; plus NBSP) | ✅ |
| REQ-6 | T-3 | `test_keeps_first_five_words` passed (all 3 criteria incl. empty words not counted) | ✅ |
| REQ-7 | T-3 | `test_empty_result` passed (`""` and `"?!... --- ___"` → `""`) | ✅ |

## Findings
- Uncovered requirements: none.
- Tasks without a requirement: none.
- Unticked tasks: none.
- Note: REQ-7's behavior was delivered by T-2 (empty-word drop); its test was added in T-3 and
  passed before T-3's code — recorded in `tasks.md`.

## Next actions
- None — feature is done.
