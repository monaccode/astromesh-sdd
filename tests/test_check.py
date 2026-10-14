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


STEP0 = "## Step 0 — Load project settings\nMissing files are normal.\n"


class CheckContent(unittest.TestCase):
    def setUp(self):
        self.root = Path(tempfile.mkdtemp())

    def test_phase_skill_without_step0_fails(self):
        make_skill(self.root, "sdd-plan", GOOD.replace("sdd-x", "sdd-plan"))
        self.assertTrue(any("Step 0" in e for e in check.check_content(self.root)))

    def test_phase_skill_with_step0_passes(self):
        make_skill(self.root, "sdd-plan", GOOD.replace("sdd-x", "sdd-plan") + STEP0)
        self.assertEqual(check.check_content(self.root), [])

    def test_unreferenced_template_fails(self):
        d = make_skill(self.root, "sdd-plan", GOOD.replace("sdd-x", "sdd-plan") + STEP0)
        (d / "templates").mkdir()
        (d / "templates" / "plan.md").write_text("# Plan\n")
        self.assertTrue(any("plan.md" in e for e in check.check_content(self.root)))

    def test_specify_must_forbid_renumbering(self):
        make_skill(self.root, "sdd-specify", GOOD.replace("sdd-x", "sdd-specify") + STEP0)
        self.assertTrue(any("renumber" in e for e in check.check_content(self.root)))

    def test_index_skill_is_exempt(self):
        make_skill(self.root, "sdd", GOOD.replace("sdd-x", "sdd"))
        self.assertEqual(check.check_content(self.root), [])


class CheckConfig(unittest.TestCase):
    def test_example_config_has_known_keys_only(self):
        root = Path(__file__).resolve().parents[1]
        self.assertEqual(check.check_config(root / "examples/.sdd/config.yaml"), [])

    def test_unknown_key_fails(self):
        p = Path(tempfile.mkdtemp()) / "config.yaml"
        p.write_text("specs_dir: specs\nbogus: 1\n")
        self.assertTrue(any("bogus" in e for e in check.check_config(p)))


REPO = Path(__file__).resolve().parents[1]


class ShippedContent(unittest.TestCase):
    def read(self, rel):
        return (REPO / rel).read_text()

    def test_gated_skills_record_approval_in_the_file(self):
        for phase in ("specify", "plan", "tasks"):
            text = self.read(f"skills/sdd-{phase}/SKILL.md")
            self.assertIn("**Status:** approved", text, phase)
            tmpl = self.read(f"skills/sdd-{phase}/templates/{'spec' if phase == 'specify' else phase}.md")
            self.assertIn("**Status:** draft", tmpl, phase)

    def test_router_follows_phases_order_and_status(self):
        text = self.read("skills/sdd/SKILL.md")
        self.assertIn("first phase in `phases`", text)
        self.assertIn("not `approved`", text)

    def test_router_reverifies_after_fail(self):
        for rel in ("skills/sdd/SKILL.md", "AGENTS.md"):
            self.assertIn("run `sdd-verify` again", self.read(rel), rel)

    def test_agents_md_has_done_state(self):
        self.assertIn("PASS → done", self.read("AGENTS.md"))

    def test_powershell_installer_requires_pwsh7(self):
        self.assertTrue(self.read("install.ps1").startswith("#Requires -Version 7"))


if __name__ == "__main__":
    unittest.main()
