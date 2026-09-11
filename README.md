# Dotfiles

Cross-platform dotfiles for macOS and Linux servers. Clone once, run bootstrap, get a consistent environment everywhere.

## Quick Start

```bash
git clone https://github.com/YOUR_USER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

Bootstrap will prompt you for:

1. **Git identity** -- name and email (auto-detects credential helper per platform)
2. **Machine role** -- `mac`, `linux-desktop`, or `hpc` (stored locally, not tracked)
3. **Symlinks** -- all `*.symlink` files get linked into `$HOME`
4. **Homebrew** -- installs Homebrew and Brewfile packages (macOS only)
5. **Optional software** -- each prompted individually:
   - Oh My Zsh
   - Vim/Neovim plugins (vim-plug)
   - Starship prompt
   - Rust (via rustup)
   - Bun (includes gemini-cli, codex, ccusage)
   - Claude Code config
   - Codex CLI config
   - opencode config
   - GitHub CLI (gh)
6. **pixi** -- optional, cross-platform

## Updating

After pulling on a machine that is already set up, run `script/link`. It refreshes
the `*.symlink` files and re-runs the claude/codex/opencode config linkers, so new
files in this repo (a new skill, a new config) get linked. It is idempotent,
non-interactive, and installs no packages.

Run `script/update` to update an existing installation. It refreshes symlinks, then
updates whatever it finds installed: Homebrew, rustup and cargo binaries, vim/nvim
plugins, Oh My Zsh, starship (Linux) and pixi. Anything absent is skipped, so it is
safe on every host.

`dot` is narrower and macOS-only: it applies the macOS defaults from
`macos/set-defaults.sh` and runs `brew update` plus the Brewfile. It does not
re-run the optional installers -- use `script/install` for those.

## Repository Structure

```
~/.dotfiles/
├── aliases/           Shell aliases and git aliases (*.symlink)
├── autocompletion/    Shell completion scripts
├── bash/              Bash config (bash_profile, bashrc)
├── bin/               Executables added to $PATH (dot, utilities)
├── claude/            Claude Code config (CLAUDE.md, settings.json)
├── codex/             Codex CLI config (config.toml)
├── opencode/          opencode config (opencode.jsonc, agents, commands)
├── docker/            Docker aliases (*.zsh, auto-sourced)
├── functions/         Autoloaded zsh functions and completions
├── gh/                GitHub CLI installer (Linux; macOS uses Brewfile)
├── git/               Git config, aliases, completion
├── homebrew/          Brewfile and install script
├── hosts/             Role-specific config (mac.sh, linux-desktop.sh, hpc.sh)
├── macos/             macOS defaults and software updates
├── bun/               Bun runtime, gemini-cli, codex, ccusage
├── ruby/              Ruby/RVM config
├── rust/              Rust install via rustup
├── script/            Bootstrap, install, pixi-setup
├── starship/          Starship prompt config
├── system/            Environment, PATH, keys, aliases (*.zsh)
├── tmux/              Tmux configuration
├── vim/               Vim/Neovim config and plugin installer
├── xcode/             Xcode aliases
├── yarn/              Yarn PATH setup
└── zsh/               Zsh config, Oh My Zsh, history, keybindings
```

## How It Works

### Backups

Bootstrap automatically backs up any existing config files before replacing them with symlinks. Backups are stored in a timestamped directory:

```
~/.dotfiles_backup/20260208_143022/
├── .zshrc
├── .vimrc
├── .gitconfig
└── claude/
    └── CLAUDE.md
```

This means running bootstrap on a machine with existing configs is safe -- nothing is lost. Install scripts (Claude Code, Oh My Zsh) use the same backup directory.

### Symlinks

Any file named `*.symlink` gets symlinked to `$HOME/.FILENAME` during bootstrap. For example:

- `zsh/zshrc.symlink` -> `~/.zshrc`
- `vim/vimrc.symlink` -> `~/.vimrc`
- `git/gitconfig.symlink` -> `~/.gitconfig`

### Auto-sourced files

The zsh config (`zshrc.symlink`) automatically sources all `*.zsh` files under
`$DOTFILES` (`~/.dotfiles`). Note `$ZSH` is a different variable -- zshrc points it
at `~/.oh-my-zsh`.

- `path.zsh` -- loaded first (PATH setup)
- `completion.zsh` -- loaded last (after compinit)
- Everything else -- loaded in between

The match is on the exact name `path.zsh`, so a file named `_path.zsh` lands in the
"everything else" pass instead. `system/path.zsh` is the single place that orders
the system prefixes, including Homebrew's.

This means adding a new `*.zsh` file to any topic directory picks it up automatically.

### Install scripts

Each `*/install.sh` is run by `script/install` with an interactive prompt. They handle their own platform detection.

### AI coding tools

Three CLIs are configured here: Claude Code (`claude/`), Codex (`codex/`) and
opencode (`opencode/`). Each has its own `install.sh` that installs the CLI if
missing and symlinks config out of this repo.

Claude Code and opencode share one set of instructions. `claude/CLAUDE.md` is the
single source, linked to both `~/.claude/CLAUDE.md` and
`~/.config/opencode/AGENTS.md`, so the personality and safety rules cannot drift
apart. Edit that one file to change both.

Only config files are linked, never whole tool directories. `~/.codex` is ~945MB
of installed packages, auth tokens and session history, so just `config.toml` is
symlinked out of it. Codex edits that file in place and preserves comments, so
the symlink survives its writes -- but its own bookkeeping (project trust levels,
model migration notices, TUI counters) is written back into the repo and shows up
as diffs. Project trust entries are per-machine; ones whose path is absent on the
current host are inert, so the union across machines is harmless.

opencode's config lives under `$XDG_CONFIG_HOME/opencode` (default
`~/.config/opencode`), not in `$HOME`, so it is linked by `opencode/install.sh`
rather than by the `*.symlink` mechanism. `opencode/opencode.jsonc` restates the
safety rules as tool-enforced permissions (`ask` on commits, pushes and `rm`;
`deny` on `sudo` and host control), so they hold even when the prompt is ignored.
`opencode/agent/` and `opencode/command/` are linked in and ready for custom
agents and slash commands -- see `opencode/README.md`.

No credentials are tracked. Each machine authenticates on its own:
`~/.local/share/opencode/auth.json` for opencode, and the respective login flow
for the others. To use OpenRouter with opencode, set `OR_OPENCODE_API_KEY` in
`~/.secrets/opencode`; the `opencode()` wrapper loads that file in a subshell and
`opencode.jsonc` reads it as `{env:OR_OPENCODE_API_KEY}`, never storing the key.

#### AI_AGENT

`AI_AGENT` marks a shell as agent-driven and names the tool. `hosts/*.sh` check
it to skip slow cluster module loads. It does not gate credentials — see
[Credentials](#credentials).

| Tool | Value | Set by |
|------|-------|--------|
| Claude Code | `claude-code_<version>_agent` | Claude Code itself; its own value wins over any `env` in settings |
| Codex | `codex` | `codex()` wrapper, plus `shell_environment_policy` in `codex/config.toml` |
| opencode | `opencode` | `opencode()` wrapper in `aliases/aliases.symlink` |

The checks test whether `AI_AGENT` is set at all, not for one specific value,
because the tools name themselves differently. Set `AI_AGENT=0` to force the
human path.

Verify from inside an agent session:

```sh
echo "$AI_AGENT"                       # names the tool
env | grep -cE '_(TOKEN|KEY)='         # should print: 0
```

### Machine roles

The `hosts/` directory contains role-specific shell config. During bootstrap you pick a role, which gets written to `host_role` (gitignored). Your shell sources `hosts/<role>.sh` on startup.

Available roles:

| Role | Platform | Purpose |
|------|----------|---------|
| `mac` | macOS | pixi PATH, macOS-specific setup |
| `linux-desktop` | Linux | Wayland/Sway desktop session |
| `hpc` | Linux | HPC cluster paths |

Add new roles by creating a file in `hosts/` and selecting it during bootstrap.

### Per-machine overrides

Non-secret per-machine variables (one-off paths, feature flags, account ids) go
in `~/.localrc`. It is sourced by bash and zsh, inherited by every child
process, and not tracked. See `localrc.symlink.example`.

### Credentials

Credentials go in `~/.secrets/<service>` — one file per service, dir 700, files
600, outside the repo. Nothing exports them, so they are absent from a shell
until asked for:

```sh
secrets                 # every service, into your interactive shell
secrets openrouter      # just that one
```

| File | Used by |
|------|---------|
| `~/.secrets/cloudflare` | `claude-op`, wrangler |
| `~/.secrets/openrouter` | `claude-op` |
| `~/.secrets/opencode` | `opencode()` |
| `~/.secrets/gemini` | `gemini-api` |
| `~/.secrets/pushover` | `bin/push`, which reads the file directly |
| `~/.secrets/github` | nothing — drop it once `gh auth login` is in use |

Each wrapper names only the services its tool needs, so no tool sees another
tool's keys. `claude/settings.json` denies Claude Code read access to `.env` and
`.secrets` files.

## Platform Support

| Feature | macOS | Linux |
|---------|-------|-------|
| Shell config (zsh/bash) | Yes | Yes |
| Vim/Neovim | Yes | Yes |
| Tmux | Yes | Yes |
| Git config | Yes | Yes |
| Starship prompt | Homebrew | curl installer |
| Rust | rustup | rustup |
| pixi | Optional | Optional |
| Homebrew + Brewfile | Yes | -- |
| macOS defaults | Yes | -- |
| Claude Code | Yes | Yes |
| Codex CLI | Yes | Yes |

## Prerequisites

Install these before running bootstrap:

- `git`
- `curl`
- `zsh` (or use bash -- both are configured)
- `vim` or `neovim` (optional, for plugin install)

On macOS, Homebrew handles most dependencies. On Linux, install via your package manager.
