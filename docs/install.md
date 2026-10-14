# Installing astromesh-sdd

The seven skills live in [`skills/`](../skills). Installing means putting those folders
where your agent looks for skills. Every path below was checked against the agent's own
documentation on 2026-10-13 (source linked in each section). If an agent moves its folder,
open an issue.

Get the files first:

```bash
git clone https://github.com/monaccode/astromesh-sdd
cd astromesh-sdd
```

## The installer

```bash
./install.sh  [--target T] [--project | --global] [--dir PATH] [--link] [--dry-run] [--init]
.\install.ps1 [-Target T]  [-Global]              [-Dir PATH]  [-Link] [-DryRun]  [-Init]
```

| Option | What it does |
|---|---|
| `--target claude` | Copies the skills to `.claude/skills/` |
| `--target agents` | Copies the skills to `.agents/skills/` (Codex, OpenCode, Kimi Code, Gemini CLI, Copilot) |
| `--target codex`, `opencode`, `kimi`, `gemini`, `copilot` | Same as `agents` |
| `--target agents-md` | Adds the cycle to your project's `AGENTS.md`, between `<!-- astromesh-sdd:start -->` and `<!-- astromesh-sdd:end -->`. The rest of the file is kept |
| `--target all` (default) | All of the above |
| `--project` (default) | Installs into the project at `--dir` (default: the current directory) |
| `--global` | Installs into your home directory for every project. `agents-md` is project-only |
| `--link` | Symlinks to this clone instead of copying, so `git pull` updates the skills. Deleting or moving the clone breaks them |
| `--dry-run` | Prints what would change and changes nothing |
| `--init` | Also creates an example `.sdd/` settings folder. An existing `.sdd/` is never touched |

Running the installer again updates the skills in place. Your `.sdd/` folder and the
parts of `AGENTS.md` outside the marked block are never modified. On Windows, `-Link`
needs Developer Mode (symlink permission); without it, use the default copy mode.
`ASTROMESH_SDD_HOME` overrides the home directory `-Global` installs into.

## Claude Code

**As a plugin** (updates through `/plugin`):

```text
/plugin marketplace add monaccode/astromesh-sdd
/plugin install astromesh-sdd@astromesh
```

Skills are namespaced: `/astromesh-sdd:sdd`, `/astromesh-sdd:sdd-specify`, …

**As plain skills** (short names `/sdd`, `/sdd-specify`):

```bash
./install.sh --target claude --dir ~/my-project     # or --global
```

| | Project | Global |
|---|---|---|
| Path | `.claude/skills/<name>/SKILL.md` | `~/.claude/skills/<name>/SKILL.md` |

**Check it loaded:** type `/sdd` and the skill appears in the list; or run
`claude plugin details astromesh-sdd` for the plugin.
Source: [Claude Code — plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces).

## Codex CLI

```bash
./install.sh --target codex --dir ~/my-project     # or --global
```

| | Project | Global |
|---|---|---|
| Path | `.agents/skills/<name>/SKILL.md` (any folder from the cwd up to the repo root) | `~/.agents/skills/<name>/SKILL.md` |

**Run:** `$sdd`, or `/skills` to pick one. Codex also picks a skill on its own when your
request matches its description.
Source: [Codex — build skills](https://learn.chatgpt.com/docs/build-skills).

## OpenCode

```bash
./install.sh --target opencode --dir ~/my-project     # or --global
```

| | Project | Global |
|---|---|---|
| Path | `.opencode/skills/`, `.claude/skills/` or `.agents/skills/` | `~/.config/opencode/skills/`, `~/.claude/skills/` or `~/.agents/skills/` |

OpenCode also reads `.claude/skills/`, so a Claude Code install already works there.
**Run:** ask for it ("use the sdd skill") or let OpenCode load it when your request
matches. Source: [OpenCode — skills](https://opencode.ai/docs/skills/).

## Kimi Code

```bash
./install.sh --target kimi --dir ~/my-project     # or --global
```

| | Project | Global |
|---|---|---|
| Path | `.kimi-code/skills/` or `.agents/skills/` | `~/.kimi-code/skills/` or `~/.agents/skills/` |

**Run:** `/skill:sdd`, optionally followed by your request (`/skill:sdd-specify add CSV
export`). Kimi also reads a skill on its own when it fits.
Source: [Kimi Code CLI — Agent Skills](https://www.kimi.com/code/docs/en/kimi-code-cli/customization/skills.html).

## Gemini CLI

```bash
./install.sh --target gemini --dir ~/my-project     # or --global
```

| | Project | Global |
|---|---|---|
| Path | `.gemini/skills/` or `.agents/skills/` | `~/.gemini/skills/` or `~/.agents/skills/` |

**Check it loaded:** `/skills list` in a session, or `gemini skills list`. Gemini activates
a skill when your request matches and asks for consent first.
Source: [Gemini CLI — skills](https://geminicli.com/docs/cli/skills/).

## GitHub Copilot

```bash
./install.sh --target copilot --dir ~/my-project     # or --global
```

| | Project | Global |
|---|---|---|
| Path | `.github/skills/`, `.claude/skills/` or `.agents/skills/` | `~/.copilot/skills/` or `~/.agents/skills/` |

Copilot loads a skill when your request matches its description.
Source: [GitHub Copilot — about agent skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills).

## Any other agent

Cursor, Aider, Windsurf and most other agents read `AGENTS.md` in the project root:

```bash
./install.sh --target agents-md --dir ~/my-project
```

That block holds the whole cycle in condensed form. Templates are not included; the agent
writes artifacts from the structure described in the block.

## Updating and uninstalling

- **Update:** `git pull` in the clone, then run the same install command again. With
  `--link`, `git pull` alone is enough.
- **Uninstall:** delete the seven `sdd*` folders from the skills directory you installed
  into, and the marked block from `AGENTS.md`. Claude Code plugin:
  `/plugin uninstall astromesh-sdd@astromesh`.
