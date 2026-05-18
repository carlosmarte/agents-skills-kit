# agents-skills-kit

Polyglot toolkit for authoring, validating, and distributing **Agent Skills** — the SKILL.md-based
format described in [`agentskills.io.md`](agentskills.io.md). Skills live under `.agents/skills/`
so the layout is runtime-neutral: any agent loader that reads structured markdown + YAML
frontmatter (Claude Code, GitHub Copilot custom chat modes, Cursor, Continue, raw prompt
templates, …) can consume them.

Each skill ships its own `SKILL.md` with `Inspect → Validate → Audit → Lint → Emit → Optimize`
responsibilities scoped to its concern. The runtime CLI (`skills-ref`) has parity-tested mjs and
py implementations under [`agent-skill-kit-commons`](.agents/skills/agent-skill-kit-commons/).

## Install with `npx skills`

The fastest path. Uses the open [`skills`](https://github.com/vercel-labs/skills) CLI
(supports Claude Code, OpenCode, Codex, Cursor, Continue, and 50+ other agents). It already
knows how to find skills under `.agents/skills/`, so no extra config is needed.

### Install everything

```sh
# project-scoped: drops skills under ./<agent>/skills/ for the agents detected in this repo
npx skills add carlosmarte/agents-skills-kit

# user-scoped: drops skills under ~/<agent>/skills/ (available across every project)
npx skills add carlosmarte/agents-skills-kit -g
```

### Preview before installing

```sh
npx skills add carlosmarte/agents-skills-kit --list
```

### Install one skill at a time

Each row shows the exact command to add just that skill globally to Claude Code. Drop the
`-g` for project scope, change `-a claude-code` for a different agent, add `-y` for CI.

| Skill | Install command |
| ----- | --------------- |
| [`agent-skill-kit-commons`](.agents/skills/agent-skill-kit-commons/SKILL.md) | `npx skills add carlosmarte/agents-skills-kit --skill agent-skill-kit-commons -g -a claude-code` |
| [`agent-skill-kit-validator`](.agents/skills/agent-skill-kit-validator/SKILL.md) | `npx skills add carlosmarte/agents-skills-kit --skill agent-skill-kit-validator -g -a claude-code` |
| [`agent-skill-kit-creator`](.agents/skills/agent-skill-kit-creator/SKILL.md) | `npx skills add carlosmarte/agents-skills-kit --skill agent-skill-kit-creator -g -a claude-code` |
| [`agent-skill-kit-discoverability-linter`](.agents/skills/agent-skill-kit-discoverability-linter/SKILL.md) | `npx skills add carlosmarte/agents-skills-kit --skill agent-skill-kit-discoverability-linter -g -a claude-code` |
| [`agent-skill-kit-description-optimizer`](.agents/skills/agent-skill-kit-description-optimizer/SKILL.md) | `npx skills add carlosmarte/agents-skills-kit --skill agent-skill-kit-description-optimizer -g -a claude-code` |
| [`agent-skill-kit-security-auditor`](.agents/skills/agent-skill-kit-security-auditor/SKILL.md) | `npx skills add carlosmarte/agents-skills-kit --skill agent-skill-kit-security-auditor -g -a claude-code` |
| [`agent-skill-kit-dependency-resolver`](.agents/skills/agent-skill-kit-dependency-resolver/SKILL.md) | `npx skills add carlosmarte/agents-skills-kit --skill agent-skill-kit-dependency-resolver -g -a claude-code` |
| [`agent-skill-kit-prompt-emitter`](.agents/skills/agent-skill-kit-prompt-emitter/SKILL.md) | `npx skills add carlosmarte/agents-skills-kit --skill agent-skill-kit-prompt-emitter -g -a claude-code` |
| [`agent-skill-kit-ci-integrator`](.agents/skills/agent-skill-kit-ci-integrator/SKILL.md) | `npx skills add carlosmarte/agents-skills-kit --skill agent-skill-kit-ci-integrator -g -a claude-code` |

> **Tip:** Most kit skills depend on [`agent-skill-kit-commons`](.agents/skills/agent-skill-kit-commons/SKILL.md)
> (it holds the runtime `skills-ref` packages, fixtures, and parity harness). If you install
> one of the validator/linter/auditor/etc. skills individually, add `agent-skill-kit-commons`
> alongside it: `--skill agent-skill-kit-commons --skill agent-skill-kit-validator`.

### Combining skills, agents, and scope

```sh
# install validator + commons globally to Claude Code (non-interactive)
npx skills add carlosmarte/agents-skills-kit \
  --skill agent-skill-kit-commons --skill agent-skill-kit-validator \
  -g -a claude-code -y

# install everything, but only into Cursor (project scope)
npx skills add carlosmarte/agents-skills-kit --skill '*' -a cursor

# install across all detected agents
npx skills add carlosmarte/agents-skills-kit --all
```

### Manage installed skills

```sh
npx skills list                                       # show what's installed
npx skills update agent-skill-kit-validator           # pull latest version of one skill
npx skills update -g                                  # update all global skills
npx skills remove agent-skill-kit-prompt-emitter      # uninstall one
```

Full CLI reference: [vercel-labs/skills](https://github.com/vercel-labs/skills).

## Alternative: one-shot install via curl

If you'd rather clone the whole kit once and symlink every skill into `~/.claude/skills/`
(no per-skill picking, no Node required on the install path), use the bundled installer:

```sh
curl -fsSL https://raw.githubusercontent.com/carlosmarte/agents-skills-kit/main/install.sh | bash
```

```sh
wget -qO- https://raw.githubusercontent.com/carlosmarte/agents-skills-kit/main/install.sh | bash
```

The installer clones the repo into `~/.agents-skills-kit` and creates one symlink per skill in
`~/.claude/skills/<name>`. Re-running fast-forwards the checkout and refreshes the symlinks —
it is fully idempotent.

Pass flags after `-s --` to customize:

```sh
# install + run skills-ref validate over the linked skills immediately
curl -fsSL https://raw.githubusercontent.com/carlosmarte/agents-skills-kit/main/install.sh | bash -s -- --run

# install to a different checkout location
curl -fsSL https://raw.githubusercontent.com/carlosmarte/agents-skills-kit/main/install.sh | bash -s -- --prefix="$HOME/code/agents-skills-kit"

# pin to a specific tag / branch / commit
curl -fsSL https://raw.githubusercontent.com/carlosmarte/agents-skills-kit/main/install.sh | bash -s -- --ref=v0.1.0

# point the symlinks at a non-default loader directory
curl -fsSL https://raw.githubusercontent.com/carlosmarte/agents-skills-kit/main/install.sh | bash -s -- --link-dir="$HOME/.config/agents/skills"
```

Equivalent env vars: `AGENTS_SKILLS_KIT_HOME`, `AGENTS_SKILLS_KIT_REF`,
`AGENTS_SKILLS_KIT_LINK_DIR`, `AGENTS_SKILLS_KIT_RUN=1`, `AGENTS_SKILLS_KIT_REPO`.

Inspect state at any time with `bash install.sh --status` (from a local checkout). After
install, set up the `skills-ref` CLI (Node + Python twins) by running `make install` inside
the checkout — see [Makefile targets](#makefile-targets) below.

### Which install path should I use?

| Scenario | Use |
| -------- | --- |
| You want one or two skills, possibly across multiple agents (Claude Code + Cursor + …) | `npx skills` |
| You're on a machine without Node, or want a hermetic clone-and-symlink with no npx cache | `curl … install.sh \| bash` |
| You need the local `make ci` / `make parity` / `skills-ref` CLI dev loop (twin packages) | `curl … install.sh \| bash`, then `make install` |
| You're writing CI for a downstream repo that consumes specific skills | `npx skills add … --skill … -y` |

## Skills

| Skill | Purpose |
| ----- | ------- |
| [`agent-skill-kit-commons`](.agents/skills/agent-skill-kit-commons/SKILL.md) | Runtime packages (mjs + py), canonical fixtures, parity scripts, closure-walk examples. Other skills depend on this one. |
| [`agent-skill-kit-validator`](.agents/skills/agent-skill-kit-validator/SKILL.md) | Validate `SKILL.md` frontmatter against the spec — name/description rules, tier enum, dependency direction. |
| [`agent-skill-kit-creator`](.agents/skills/agent-skill-kit-creator/SKILL.md) | Scaffold a new skill directory with frontmatter, body skeleton, and standard optional dirs. |
| [`agent-skill-kit-discoverability-linter`](.agents/skills/agent-skill-kit-discoverability-linter/SKILL.md) | Score a skill's `description` for trigger-keyword density and clarity. |
| [`agent-skill-kit-description-optimizer`](.agents/skills/agent-skill-kit-description-optimizer/SKILL.md) | Deterministic rewriter that boosts a description's discoverability score. |
| [`agent-skill-kit-security-auditor`](.agents/skills/agent-skill-kit-security-auditor/SKILL.md) | Scan SKILL.md and bundled scripts for prompt-injection markers and unsafe patterns. |
| [`agent-skill-kit-dependency-resolver`](.agents/skills/agent-skill-kit-dependency-resolver/SKILL.md) | Build the skill dependency graph, detect cycles, enforce tier-direction rules. |
| [`agent-skill-kit-prompt-emitter`](.agents/skills/agent-skill-kit-prompt-emitter/SKILL.md) | Emit the `<available_skills>` XML block consumed by LLMs at startup (~100 tokens / skill). |
| [`agent-skill-kit-ci-integrator`](.agents/skills/agent-skill-kit-ci-integrator/SKILL.md) | GitHub Actions workflow + pre-commit hook templates that wire the above into CI. |

## File shape

Every `SKILL.md` follows the contract defined in [`agentskills.io.md`](agentskills.io.md):

```markdown
---
name: <kebab-case>            # 1–64 chars, must match directory name
description: <when + what>     # ≤ 1024 chars, trigger-keyword rich
tier: org | team | app | project
license: <SPDX or path>        # optional
compatibility: <env>           # optional
metadata: { ... }              # optional
dependencies:                  # optional, tier-direction validated
  - other-skill@^1.0.0
---

# Title

Why → When to invoke → Inspect → Edit → Validate → Audit → Examples
```

Tier governs dependency direction (`project → app → team → org`); inversions are rejected by
the validator. See [§3.3 of the spec](agentskills.io.md) for the full rules.

## Loading these into an agent runtime

### Claude Code

The curl install above already symlinks every skill into `~/.claude/skills/<name>`. If you
prefer to wire them manually from a local checkout:

```bash
REPO="$(pwd)"
for d in "$REPO"/.agents/skills/*/; do
  name=$(basename "$d")
  ln -sf "$d" "$HOME/.claude/skills/$name"
done
```

### GitHub Copilot (VSCode custom chat modes)

Each `SKILL.md` is already in the right shape — copy or symlink into
`.github/chatmodes/<name>.chatmode.md` of the consuming repo, or into VSCode's global
`User/prompts/` directory.

### Other runtimes / raw prompts

`cat .agents/skills/<name>/SKILL.md` and feed it as a system prompt. Frontmatter is plain YAML;
body is plain Markdown.

## Makefile targets

From the repo root:

| Target | What it does |
| ------ | ------------ |
| `make install` | Install both runtime packages (`packages/mjs` via npm, `packages/py` via uv). |
| `make ci` | Run lint + tests for both runtimes. |
| `make parity` | Run all parity scripts (mjs ↔ py output equality on validate/audit/deps/registry/lint/prompt/properties/optimize/parser-naming). |
| `make validate-suite` | Validate every skill under `.agents/skills/`. |
| `make audit-suite` | Run the security auditor over `.agents/skills/`. |
| `make deps-suite` | Resolve the dependency graph for `.agents/skills/`. |
| `make lint-suite` | Run the discoverability linter over `.agents/skills/`. |
| `make prompt-suite` | Emit `<available_skills>` XML for `.agents/skills/`. |
| `make properties-suite` | Emit canonical-JSON frontmatter for `.agents/skills/`. |
| `make clean` | Remove per-package build artifacts. |

## Conventions

- **Skill name = directory name.** Validators reject mismatches.
- **Tier direction is enforced.** `org` cannot depend on `team`, `team` cannot depend on `app`,
  etc. The resolver fails closed on conflicts and inversions.
- **Fixtures are shared.** The mjs and py twins read the same fixture tree under
  `agent-skill-kit-commons/fixtures/` so parity tests stay honest.
- **`<REPO>` placeholder.** Test inputs whose expected output encodes an absolute path use the
  `<REPO>` token so fixtures are location-independent.

## Decision guide — which skill to use when

- **Authoring a new skill from scratch** → `agent-skill-kit-creator`, then
  `agent-skill-kit-validator` to confirm the frontmatter is well-formed.
- **Editing an existing description and want to make it more discoverable** →
  `agent-skill-kit-discoverability-linter` to score, `agent-skill-kit-description-optimizer`
  to rewrite.
- **Wiring CI for a repo full of skills** → `agent-skill-kit-ci-integrator` for the workflow
  templates, then add `make ci` and `make parity` as required checks.
- **Suspect a SKILL.md or bundled script contains a prompt-injection vector** →
  `agent-skill-kit-security-auditor`.
- **Builder needs the LLM-facing `<available_skills>` block** →
  `agent-skill-kit-prompt-emitter`.
- **Refactoring a multi-skill repo and want to confirm dependencies stay tier-correct** →
  `agent-skill-kit-dependency-resolver`.

## License

[MIT](LICENSE).
