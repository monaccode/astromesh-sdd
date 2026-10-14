"""Validate astromesh-sdd: skill frontmatter, manifests, example config."""

import json
import re
import sys
from pathlib import Path

NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
ALLOWED_KEYS = {"name", "description"}


def parse_frontmatter(text: str) -> dict[str, str] | None:
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---", 4)
    if end == -1:
        return None
    out = {}
    for line in text[4:end].splitlines():
        if line.strip():
            key, _, value = line.partition(":")
            out[key.strip()] = value.strip().strip('"')
    return out


def check_skill(d: Path) -> list[str]:
    p = d / "SKILL.md"
    fm = parse_frontmatter(p.read_text())
    if fm is None:
        return [f"ERROR {p}: missing YAML frontmatter"]
    errs = []
    name, desc = fm.get("name", ""), fm.get("description", "")
    if name != d.name:
        errs.append(f"ERROR {p}: name '{name}' must equal folder '{d.name}'")
    if not NAME_RE.match(name) or len(name) > 64:
        errs.append(f"ERROR {p}: name '{name}' must match pattern {NAME_RE.pattern}, <= 64 chars")
    if not 1 <= len(desc) <= 1024:
        errs.append(f"ERROR {p}: description must be 1-1024 chars (got {len(desc)})")
    for key in sorted(set(fm) - ALLOWED_KEYS):
        errs.append(f"ERROR {p}: key '{key}' is not portable; use only name, description")
    return errs


NO_RENUMBER_SKILLS = {"sdd-specify", "sdd-implement"}
STEP0 = "## Step 0 — Load project settings"


def check_content(root: Path) -> list[str]:
    errs = []
    for p in sorted((root / "skills").glob("sdd-*/SKILL.md")):
        text, name = p.read_text(), p.parent.name
        if STEP0 not in text or "Missing files are normal" not in text:
            errs.append(f"ERROR {p}: missing the shared 'Step 0 — Load project settings' block")
        for t in sorted((p.parent / "templates").glob("*.md")):
            if t.name not in text:
                errs.append(f"ERROR {p}: template {t.name} is never referenced")
        if name in NO_RENUMBER_SKILLS and "never renumber" not in text:
            errs.append(f"ERROR {p}: must state that IDs never renumber")
    return errs


CONFIG_KEYS = {"specs_dir", "language", "ids", "gates", "verify_command", "phases"}


def check_config(p: Path) -> list[str]:
    import yaml  # only this check needs PyYAML

    data = yaml.safe_load(p.read_text()) or {}
    if not isinstance(data, dict):
        return [f"ERROR {p}: must be a mapping"]
    return [f"ERROR {p}: unknown key '{k}'" for k in sorted(set(data) - CONFIG_KEYS)]


def check_repo(root: Path) -> list[str]:
    errs = []
    skills = sorted(p.parent for p in (root / "skills").glob("*/SKILL.md"))
    if not skills:
        errs.append(f"ERROR {root / 'skills'}: no skills found")
    for d in skills:
        errs += check_skill(d)
    errs += check_content(root)
    errs += check_skill(root / "templates" / "my-phase")
    errs += check_config(root / "examples" / ".sdd" / "config.yaml")
    for rel in (".claude-plugin/plugin.json", ".claude-plugin/marketplace.json"):
        try:
            json.loads((root / rel).read_text())
        except (OSError, ValueError) as e:
            errs.append(f"ERROR {rel}: {e}")
    return errs


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
    errs = check_repo(root)
    for e in errs:
        print(e)
    if not errs:
        print(f"ok: {len(list((root / 'skills').glob('*/SKILL.md')))} skills")
    return 1 if errs else 0


if __name__ == "__main__":
    sys.exit(main())
