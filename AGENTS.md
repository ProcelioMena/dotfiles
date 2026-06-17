# AGENTS.md

Guidance for AI agents (and future sessions) working in this repo.

## What this repo is

Personal macOS (Apple Silicon) dotfiles. It is **not an application** — there is
no build, test, or deploy. It is a small set of config files plus a `Makefile`
that bootstraps a fresh machine. Every file in the repo root is meaningful:

| File         | Role                                                                 |
|--------------|----------------------------------------------------------------------|
| `Makefile`   | The entrypoint. `make setup` provisions a new machine; targets are idempotent. |
| `.zshrc`     | Symlinked to `~/.zshrc`. Oh My Zsh + tooling hooks (asdf, direnv, zoxide, gcloud, aws). |
| `ssh_config` | Symlinked to `~/.ssh/config`. Multiple Git hosts/identities.         |
| `claude_desktop_config.json` | Symlinked to `~/Library/Application Support/Claude/claude_desktop_config.json` (Claude Desktop). Also the source of truth for `claude-mcp`, which registers the same `azure-devops` server with the Claude Code CLI at user scope. Committed with placeholder PAT/org — real values live only in the working tree. |
| `aws_config` | Symlinked to `~/.aws/config` (`aws-config` target). Shared `access` SSO session + `dev`/`qa` profiles. Committed with **placeholder** account IDs and SSO directory ID — real values live only in the working tree. |
| `Brewfile`   | `brew bundle` manifest — all Homebrew packages/casks.                |
| `README.md`  | Human-facing lift-and-shift instructions. Keep it in sync with edits. |
| `.gitignore` | Excludes secrets: `id_*`, `*.pem`.                                   |

## How it fits together (non-obvious details)

- **Symlinks, not copies.** `make symlink` links `.zshrc` and `ssh_config` from
  this repo into `$HOME`. So editing the file here *is* editing the live config.
  Existing non-symlink files are backed up to `*.backup` before linking.
- **`make setup` ordering matters.** Targets run in this order:
  `brew → symlink → ohmyzsh → claude → claude-config → claude-mcp → aws-config → neovim-config → asdf-setup → zsh-plugins`.
  `symlink` must precede `neovim-config` because the Neovim repo is cloned over
  SSH and needs `~/.ssh/config` in place first. Preserve this ordering if you
  touch the `setup` target.
- **Pinned toolchain versions** live at the top of the `Makefile`
  (`TF_VERSION`, `PYTHON_VERSION`, `NODE_VERSION`). To bump a version, edit the
  variable there — and update the "Pinned toolchain versions" list in `README.md`.
- **All `make` targets are idempotent** (guarded by `if [ ! -d ... ]` / `command -v`
  checks). New targets should follow the same pattern and be added to the
  `.PHONY` line and, if part of provisioning, to the `setup` chain.
- **Apple Silicon assumed.** Paths are hardcoded to `/opt/homebrew` (e.g. the
  gcloud SDK source lines in `.zshrc`). Do not change to `/usr/local`.
- **`ssh_config` has three identities**: `github.com` (personal),
  `github.com-work` (work, via `id_ed25519_work`), and `ssh.dev.azure.com`
  (Azure DevOps, via `id_ed25519_ado`, with legacy `ssh-rsa` algorithms enabled).
- **`.zshrc` ends with a project-specific `wbuilder` PATH entry** pointing at
  `~/workspace/wonderful/...`. It is harmless when that directory is absent.

## Working rules for agents

- **Secrets never get committed.** SSH private keys (`id_*`) and `*.pem` are
  gitignored on purpose and are transferred manually. Never add a key, token, or
  credential to a tracked file. Per org policy, warn the user before outputting
  any PII/PHI.
- **Edit the source, expect the symlink.** Changes to `.zshrc`/`ssh_config` take
  effect live via the symlink; no copy step needed. A new shell or
  `source ~/.zshrc` applies `.zshrc` changes.
- **Keep `README.md` in sync.** It documents the `make` steps and pinned
  versions — update it whenever you change the `Makefile` or `Brewfile`.
- **Adding a tool**: add it to `Brewfile`, and wire any shell hook into the
  "Environment & Tooling Hooks" section of `.zshrc`.
- **No test/build/lint exists.** To sanity-check, run the relevant `make`
  target (they're safe to re-run) or `zsh -n .zshrc` to lint the shell syntax.
- This is a single-developer repo on `main`. Commit/push only when asked.
