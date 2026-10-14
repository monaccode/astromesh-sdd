import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import check  # noqa: E402


def make_skill(root: Path, folder: str, text: str) -> Path:
    d = root / "skills" / folder
    d.mkdir(parents=True)
    (d / "SKILL.md").write_text(text)
    return d


GOOD = "---\nname: sdd-x\ndescription: Use when testing.\n---\n\n# X\n"


class CheckSkill(unittest.TestCase):
    def setUp(self):
        self.root = Path(tempfile.mkdtemp())

    def test_good_skill_passes(self):
        self.assertEqual(check.check_skill(make_skill(self.root, "sdd-x", GOOD)), [])

    def test_name_must_match_folder(self):
        errs = check.check_skill(make_skill(self.root, "sdd-y", GOOD))
        self.assertTrue(any("folder" in e for e in errs))

    def test_bad_name_pattern(self):
        text = GOOD.replace("sdd-x", "sdd--x")
        errs = check.check_skill(make_skill(self.root, "sdd--x", text))
        self.assertTrue(any("pattern" in e for e in errs))

    def test_missing_description(self):
        errs = check.check_skill(make_skill(self.root, "sdd-x", "---\nname: sdd-x\n---\n"))
        self.assertTrue(any("description" in e for e in errs))

    def test_description_too_long(self):
        text = GOOD.replace("Use when testing.", "a" * 1025)
        errs = check.check_skill(make_skill(self.root, "sdd-x", text))
        self.assertTrue(any("1024" in e for e in errs))

    def test_no_frontmatter(self):
        errs = check.check_skill(make_skill(self.root, "sdd-x", "# X\n"))
        self.assertTrue(any("frontmatter" in e for e in errs))

    def test_extra_keys_rejected(self):
        text = GOOD.replace("---\n\n", "license: MIT\n---\n\n")
        errs = check.check_skill(make_skill(self.root, "sdd-x", text))
        self.assertTrue(any("license" in e for e in errs))


if __name__ == "__main__":
    unittest.main()
