# 001 — Slugify title

**Status:** approved · **Date:** 2026-10-13

## Problem
Callers of `textutil` who need a URL- or filename-safe identifier from a human title
(e.g. "Café au lait, s'il vous plaît") have no helper for it today and must hand-roll the
conversion, which gives inconsistent results for accents, punctuation and long titles.
The user mandated the entry point: a `slugify(title)` function in `textutil.py`.

## Goals
- Any string title yields a short, predictable, lowercase ASCII slug.
- The same title always yields the same slug.

## Non-goals
- Non-string input (None, numbers, bytes): behavior is unspecified.
- Transliteration of non-Latin scripts (e.g. Cyrillic, CJK); such characters are dropped.
- Uniqueness of slugs or collision handling.
- Configurable word limit or separator.

## Requirements

### REQ-1 — Lowercase output
`slugify(title)` returns the title's letters in lowercase.

**Acceptance**
- Given the title `"Hello World"`, when it is slugified, then the result is `"hello-world"`.

### REQ-2 — Accents stripped to ASCII
Accented letters are replaced by their unaccented ASCII letter.

**Acceptance**
- Given the title `"Café Ñandú"`, when it is slugified, then the result is `"cafe-nandu"`.

### REQ-3 — Characters with no ASCII form are dropped
Characters that have no ASCII form are removed from the result.

**Acceptance**
- Given the title `"Hello 世界 World"`, when it is slugified, then the result is
  `"hello-world"`.
- Given the title `"naïve☃"`, when it is slugified, then the result is `"naive"`.
- Letters with a conventional ASCII spelling but no accent decomposition are dropped, not
  transliterated: given the title `"Straße Øl"`, when it is slugified, then the result is
  `"strae-l"`.

### REQ-4 — Punctuation removed without splitting words
Punctuation characters — every ASCII character that is not a letter, a digit, whitespace,
`-` or `_` — are removed, and removing them does not split a word.

**Acceptance**
- Given the title `"Don't stop!"`, when it is slugified, then the result is `"dont-stop"`.
- Given the title `"Hello, world."`, when it is slugified, then the result is
  `"hello-world"`.
- Given the title `"C++ & Rust"`, when it is slugified, then the result is `"c-rust"`.

### REQ-5 — Only whitespace, `-` and `_` separate words
Runs of whitespace, `-` and `_` separate words, and words are joined by a single hyphen with
no leading or trailing hyphen.

**Acceptance**
- Given the title `"  foo_bar -- baz\tqux  "`, when it is slugified, then the result is
  `"foo-bar-baz-qux"`.

### REQ-6 — At most 5 words
When the title has more than 5 words, only the first 5 are kept; a word that is empty
after removing punctuation and non-ASCII characters does not count toward the limit.

**Acceptance**
- Given the title `"one two three four five six seven"`, when it is slugified, then the
  result is `"one-two-three-four-five"`.
- Given the title `"one two three"`, when it is slugified, then the result is
  `"one-two-three"`.
- Given the title `"a & b 世界 c d e f"`, when it is slugified, then the result is
  `"a-b-c-d-e"`.

### REQ-7 — Empty result for titles with no words
An empty title, or one made only of punctuation and separators, returns an empty string.

**Acceptance**
- Given the title `""`, when it is slugified, then the result is `""`.
- Given the title `"?!... --- ___"`, when it is slugified, then the result is `""`.

## Security
- Data read: only the `title` string passed in. Data written: none; the function returns a
  new string and has no side effects (no files, network or shared state).
- Access: anyone who can import the module can call it; there is no authenticated surface.
- Unauthorized use: not applicable — there is no protected data or privileged operation.

## Open questions
None.

## Changelog
| Date | Change |
|---|---|
| 2026-10-13 | Initial draft (REQ-1…REQ-7). |
| 2026-10-13 | Clarifications resolved: REQ-3 drops `ß æ ø ł` (no transliteration); REQ-4 defines punctuation as all ASCII symbols (`"C++ & Rust"` → `"c-rust"`); REQ-6 excludes words empty after cleaning from the limit. Spec approved. |
