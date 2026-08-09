# Repository guidance

This is a GNU Stow dotfiles repository. Each top-level package mirrors paths relative to `$HOME`; for example, `zsh/.zshrc` links to `~/.zshrc`.

## Rules

- Keep `README.md`, `AGENTS.md`, `Makefile`, and `bootstrap` at the repository root; they are not Stow packages.
- Add a Stow package to both `PACKAGES` in `Makefile` and `default_packages` in `bootstrap`.
- Add Arch Linux system dependencies to `packages.arch`; do not duplicate its package list in the README.
- Always invoke Stow with `--no-folding`. Pi stores mutable credentials, caches, installed packages, and sessions beside managed files, so `~/.pi` and `~/.pi/agent` must remain real directories.
- Never commit credentials, tokens, session transcripts, generated package trees, caches, or machine trust state. In particular, do not track Pi's `auth.json`, `models-store.json`, `trust.json`, `npm/`, `git/`, `bin/`, or `sessions/`.
- Prefer portable shell configuration. Guard optional commands and distro-specific files before using them.
- Run `make check` after changing package layout and `make restow` after adding or removing managed paths.
