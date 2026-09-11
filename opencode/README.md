# opencode config

Global opencode configuration, symlinked into `$XDG_CONFIG_HOME/opencode`
(default `~/.config/opencode`) by `install.sh`.

| Repo path            | Linked to                        | Purpose                       |
| -------------------- | -------------------------------- | ----------------------------- |
| `opencode.jsonc`     | `~/.config/opencode/opencode.jsonc` | Settings and permissions   |
| `../claude/CLAUDE.md`| `~/.config/opencode/AGENTS.md`   | Global instructions           |
| `agent/`             | `~/.config/opencode/agent`       | Custom agents (`*.md`)        |
| `command/`           | `~/.config/opencode/command`     | Custom slash commands (`*.md`)|

Global instructions are a symlink to `../claude/CLAUDE.md` so the personality
and safety rules stay in one place across both tools. Anything added there
applies to opencode too.

## Credentials

Auth tokens live in `~/.local/share/opencode/auth.json` and are deliberately
**not** tracked. Run `opencode auth login` per machine.

For OpenRouter, `opencode.jsonc` reads the key from the environment rather than
storing it:

```jsonc
"provider": { "openrouter": { "options": { "apiKey": "{env:OR_OPENCODE_API_KEY}" } } }
```

Set `OR_OPENCODE_API_KEY` in `~/.secrets/opencode`. The `opencode()` wrapper is
a subshell running `secrets opencode`, so opencode's environment gets that one
key and nothing else. It resolves to `""` when unset, so opencode still starts.

`OR_OPENCODE_API_KEY` is separate from `OR_API_KEY`, which `claude-op` uses for
Claude Code via Cloudflare AI Gateway.

## AI_AGENT

opencode has no `env` key in its config, so the `opencode()` wrapper in
`aliases/aliases.symlink` sets `AI_AGENT=opencode`. That makes `hosts/*.sh` skip
slow cluster init in opencode's shells. Launching the binary directly, bypassing
the wrapper, skips this and also skips loading `~/.secrets/opencode`, so
opencode starts without its OpenRouter key.

## Adding an agent

Every `*.md` in `agent/` is loaded as an agent named after the file — including
a file called `README.md`, which is why docs live here instead of in there.

```markdown
---
description: When this agent should be used.
mode: subagent          # or "primary"
model: anthropic/claude-opus-4-5
tools:
  write: false
  edit: false
  bash: true
---

System prompt body in plain markdown.
```

`mode: primary` agents are selectable with Tab in the TUI; `mode: subagent`
agents are only invoked by another agent via the task tool.

Claude Code agents in `../claude/agents/` are **not** drop-in compatible: opencode
takes `tools` as a boolean map of lowercase names (`read`, `write`, `edit`,
`bash`, `grep`, `glob`, `webfetch`), not a comma-separated `tools:` string, and
has no `name:` field. Translate the frontmatter when porting one.

## Adding a command

Every `*.md` in `command/` becomes `/<filename>`. `$ARGUMENTS` interpolates
everything after the command name, `$1`/`$2` positionally; a line starting with
`!` runs a shell command and injects its output, and `@path` injects a file.

## Verifying

```sh
opencode debug paths      # where opencode actually reads from
opencode debug config     # fully resolved config, including agents and commands
opencode agent list       # agents opencode loaded
```
