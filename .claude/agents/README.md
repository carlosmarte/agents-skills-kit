# `.claude/agents/` — Claude Code Runtime Wrappers

This directory is the Claude Code agent-discovery surface for this repo. Each `*.md` file here is a thin runtime wrapper that points at the canonical `SKILL.md` for its agent.

It is **not a duplicate** of `.agents/skills/`. The two directories serve different roles:

| Directory | Purpose | Audience |
|---|---|---|
| `.agents/skills/<slug>/SKILL.md` | Canonical, runtime-neutral skill content per [`agentskills.io`](../../agentskills.io.md) spec. Validated, linted, audited, dep-resolved by the `skills-ref` toolkit. | Any agent runtime (Claude Code, future SDK agents, automation pipelines). |
| `.claude/agents/<name>.md` | Thin Claude-Code-specific agent shell. Frontmatter (`name`, `description`, `tools`) is consumed by Claude Code's agent-discovery; body points at the underlying `SKILL.md` for full operating instructions. | Claude Code runtime only. |

## Why both?

The `agentskills.io` spec is provider-neutral and prescribes a fixed frontmatter shape (`name`, `description`, `tier`, `license`, `compatibility`, `metadata`, `allowed-tools`, `dependencies` — see [§3.1](../../agentskills.io.md#31-yaml-frontmatter-fields)). Claude Code's agent-discovery has its own frontmatter expectations (`name`, `description`, `tools`) that don't perfectly align — for example, Claude Code's `tools` field is a comma-list of allow-listed harness tools, not a free-form list of skill capabilities.

Rather than mutate the spec-compliant `SKILL.md` to fit one runtime's contract, the toolkit keeps the canonical content untouched and adds a **runtime adapter** at `.claude/agents/`. Future runtimes (e.g., a Continue.dev adapter, an OpenAI Assistants adapter) would live as sibling top-level directories under whatever convention each runtime uses.

## Why this path and not `.agents/claude/`?

`.claude/agents/` is the canonical discovery path used by the Claude Code harness, matching the global `~/.claude/agents/` convention. An earlier layout of this repo tracked the wrappers at `.agents/claude/` with a `.claude/agents → ../.agents/claude` symlink for runtime visibility. The two-path setup with a symlink worked but was confusing — every contributor had to know which path was canonical and which was the indirection. The single tracked location at `.claude/agents/` removes that ambiguity: fresh clones immediately have a working Claude Code agent surface with no symlink resolution and no setup step.

## Wrapper structure

Each wrapper is ≤30 lines:

```markdown
---
name: agent-skill-creator
description: <one-line, ≤200 chars, Claude-Code-style>
tools: Read, Write, Edit, Bash, Glob, Grep
---

You are the <Agent Name>. Your full operating instructions live at
`.agents/skills/<slug>/SKILL.md`. When invoked:

1. Read that SKILL.md to load full instructions.
2. <Runtime-specific reminders — what to ask, what to default, what to skip.>
3. Report results in the Output format described in the SKILL.md.
```

## Maintenance rules

- **Add a wrapper when adding a new skill.** Every `.agents/skills/<slug>/SKILL.md` that should be invocable from Claude Code needs a corresponding `.claude/agents/<slug>.md` (without the tier prefix, by Claude Code convention).
- **Keep wrappers thin.** Operating instructions belong in `SKILL.md`. The wrapper's only job is: route the agent invocation to the right `SKILL.md`.
- **Update wrappers when `SKILL.md` paths change.** The relocation of packages/fixtures/scripts into `agent-skill-kit-commons` did not change the `.agents/skills/<slug>/SKILL.md` paths for the existing agents, so wrapper bodies stayed valid.

## Not (currently) in scope

- **Auto-generating wrappers from frontmatter.** Plausible future improvement: a `skills-ref scaffold claude-wrapper <slug>` verb that derives the wrapper from the SKILL.md frontmatter, eliminating the small duplication. Out of scope for the current commons-restructure work.
- **Other-runtime adapters.** No `.openai/`, `.continue/`, etc. yet. Add only when there's a real consumer.
