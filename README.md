# Dotfiles

Personal shell, terminal, prompt, and Pi configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package | Managed paths |
| --- | --- |
| `zsh` | `~/.zshrc` |
| `starship` | `~/.config/starship.toml` |
| `pi` | `~/.pi/agent/settings.json` and the local Ghostty integration |
| `ghostty` | `~/.config/ghostty/config.ghostty` |

The Ghostty package is included because the tracked Pi extension uses Ghostty progress, title, and notification protocols.

Pi credentials, model caches, trust decisions, installed npm/git packages, binaries, and sessions are deliberately not tracked.

## Bootstrap

On Arch Linux, install the base tools:

```sh
sudo pacman -S git stow zsh starship zsh-autosuggestions zsh-syntax-highlighting
```

Clone and bootstrap:

```sh
git clone git@github.com:PDmatrix/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap
```

`bootstrap` backs up conflicting managed files under `${XDG_STATE_HOME:-~/.local/state}/dotfiles/backups/`, then runs Stow with `--no-folding`. The latter is important: mutable Pi files must stay outside this repository.

To install only selected packages, pass their names:

```sh
./bootstrap zsh starship
```

## Maintenance

```sh
make check    # dry-run Stow and report conflicts
make restow   # refresh all links after layout changes
make unstow   # remove all managed links
```

Edit files through either the repository path or their symlinked home path, then commit normally.

## Good next additions

Keep additions intentional rather than mirroring all of `~/.config`:

- `~/.gitconfig` (consider separating identity from shared Git behavior)
- `~/.zprofile` for login-shell environment variables
- focused KDE settings such as `plasmanotifyrc`, not the entire mutable Plasma config
- tool configs as they are adopted, such as `ripgrep`, `fd`, `fzf`, `zoxide`, `direnv`, or an editor

Do not add SSH keys, password stores, browser profiles, shell history, or application caches.
