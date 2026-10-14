# Plan — 001 Slugify title

**Spec:** ./spec.md · **Date:** 2026-10-13

## Approach
Add `slugify(title: str) -> str` to `textutil.py` next to `word_count`. It decomposes the
title with Unicode NFKD, encodes to ASCII ignoring what does not fit (so accents and
characters with no ASCII form vanish), and lowercases it. Then it splits on runs of
whitespace, `-` and `_`, removes every non-`[a-z0-9]` character from each word, drops words
that end up empty, keeps the first 5 and joins them with `-`. Stdlib only (`unicodedata`,
`re`); a prototype of this exact pipeline produced every acceptance example in the spec.

## Decisions
| Decision | Rejected alternative | Why |
|---|---|---|
| NFKD + `encode("ascii", "ignore")` for accent stripping | `python-slugify` / `unidecode` dependency | Spec forbids transliteration (`ß` dropped, not `ss`); the project has no dependencies and stdlib does exactly what REQ-2/REQ-3 ask |
| Split on separators first, then strip punctuation per word | Strip punctuation first, then split | Stripping first would need care to keep separators; splitting first makes REQ-4 (`don't` → `dont`) and REQ-6 (empty words not counted) fall out naturally |
| Whitelist `[a-z0-9]` after ASCII fold | Blacklist `string.punctuation` | REQ-4 defines punctuation as every ASCII non-letter/digit/separator; a whitelist also removes control characters without listing them |

## File map
| Path | Change | Responsibility |
|---|---|---|
| `textutil.py` | modify | add `slugify(title)` |
| `tests/test_textutil.py` | modify | add a `Slugify` test case with the spec's acceptance examples |

## Steps
1. Add `Slugify` tests for lowercase, accent stripping and non-ASCII dropping; run them against a stub `slugify` that returns its input and see them fail on the asserted values (not on import) — REQ-1, REQ-2, REQ-3
2. Implement the ASCII fold + lowercase + split/join core of `slugify` in `textutil.py` — REQ-1, REQ-2, REQ-3, REQ-5
3. Add tests for punctuation removal and separators; implement per-word `[a-z0-9]` filtering and drop words left empty — REQ-4, REQ-5
4. Add tests for the 5-word limit (including empty words not counting) and empty results; implement first-5 — REQ-6, REQ-7
5. Run the full suite (`python3 -m unittest discover -s tests`) — REQ-1…REQ-7

## Risks
| Risk | How we would notice | Mitigation |
|---|---|---|
| NFKD maps compatibility characters to ASCII (`ﬁ` → `fi`, `²` → `2`, fullwidth `Ａ` → `a`) | A reviewer expects them dropped | These do have an ASCII form, so REQ-3 keeps them; no test needed unless the spec changes |
| Non-ASCII whitespace (NBSP, ideographic space) not separating words | `"a b"` giving `"ab"` | NFKD turns NBSP and U+3000 into an ASCII space before splitting; covered by the REQ-5 test |

## Test strategy
| Requirement | How it is verified |
|---|---|
| REQ-1 | unittest: `slugify("Hello World") == "hello-world"` |
| REQ-2 | unittest: `slugify("Café Ñandú") == "cafe-nandu"` |
| REQ-3 | unittest: `"Hello 世界 World"` → `"hello-world"`, `"naïve☃"` → `"naive"`, `"Straße Øl"` → `"strae-l"` |
| REQ-4 | unittest: `"Don't stop!"` → `"dont-stop"`, `"Hello, world."` → `"hello-world"`, `"C++ & Rust"` → `"c-rust"` |
| REQ-5 | unittest: `"  foo_bar -- baz\tqux  "` → `"foo-bar-baz-qux"`, `"a b"` → `"a-b"` |
| REQ-6 | unittest: seven words → first five; three words unchanged; `"a & b 世界 c d e f"` → `"a-b-c-d-e"` |
| REQ-7 | unittest: `""` → `""`, `"?!... --- ___"` → `""` |

## Coverage
| Requirement | Steps |
|---|---|
| REQ-1 | 1, 2, 5 |
| REQ-2 | 1, 2, 5 |
| REQ-3 | 1, 2, 5 |
| REQ-4 | 3, 5 |
| REQ-5 | 2, 3, 5 |
| REQ-6 | 4, 5 |
| REQ-7 | 4, 5 |
