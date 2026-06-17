# dotfiles

Personal macOS (Apple Silicon) development environment. Bootstraps Homebrew
packages, Oh My Zsh, Claude Code, Neovim config, asdf toolchains, and symlinks
shell + SSH config into place.

## Lift-and-shift to a new MacBook

### Prerequisites (do these first — `make setup` depends on them)

1. **Install Homebrew** (if not already present):
   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Copy your SSH private keys** into `~/.ssh/` and lock down permissions.
   These keys are **intentionally not stored in this repo** (`.gitignore`
   excludes `id_*` and `*.pem`), so they must be transferred manually from the
   old machine (or freshly generated and re-registered with GitHub / Azure
   DevOps). `ssh_config` references:
   - `~/.ssh/id_ed25519_work` — GitHub (work)
   - `~/.ssh/id_ed25519_ado` — Azure DevOps
   - plus a key with access to `git@github.com:ProcelioMena/nvim.git` (needed
     for the Neovim config clone during setup)

   ```sh
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_ed25519_*
   ```

### Run setup

```sh
git clone <this-repo> ~/workspace/dotfiles
cd ~/workspace/dotfiles
make setup
```

`make setup` runs, in order:

| Step            | What it does                                              |
|-----------------|-----------------------------------------------------------|
| `brew`          | `brew bundle` — installs everything in the `Brewfile`     |
| `symlink`       | Symlinks `.zshrc` → `~/.zshrc` and `ssh_config` → `~/.ssh/config` (backs up existing files) |
| `ohmyzsh`       | Installs Oh My Zsh if missing                             |
| `claude`        | Installs the Claude Code native binary if missing         |
| `neovim-config` | Clones (or pulls) the Neovim config over SSH              |
| `asdf-setup`    | Adds asdf plugins and installs/pins the pinned toolchains |
| `zsh-plugins`   | Installs `zsh-autosuggestions` and `zsh-syntax-highlighting` |

Individual targets can also be run on their own, e.g. `make symlink` or
`make brew`.

## Pinned toolchain versions

Defined at the top of the `Makefile`:

- Terraform — `1.9.5`
- Python — `3.11.9`
- Node — `22.11.0`

## Notes

- Assumes Apple Silicon (`.zshrc` sources tooling from `/opt/homebrew`).
- `.zshrc` includes a project-specific PATH entry (`wbuilder`) that is harmless
  if the referenced directory does not exist.
