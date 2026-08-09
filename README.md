# Dotfiles

Personal dotfiles for Zsh, Starship, Ghostty, and the Pi coding agent, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Managed configuration

| Stow package | Destination |
| --- | --- |
| `zsh` | `~/.zshrc` |
| `starship` | `~/.config/starship.toml` |
| `ghostty` | `~/.config/ghostty/config.ghostty` |
| `pi` | `~/.pi/agent/settings.json` |
| `pi` | `~/.pi/agent/extensions/ghostty-integration/` |

The Pi Ghostty integration provides terminal-title updates, native progress indication, and completion notifications. Its implementation and configuration are documented in [`pi/.pi/agent/extensions/ghostty-integration/README.md`](pi/.pi/agent/extensions/ghostty-integration/README.md).

## Installation

Install the required packages on Arch Linux:

```sh
sudo pacman -S git stow zsh starship ghostty bat eza zsh-autosuggestions zsh-syntax-highlighting
```

Clone the repository and create the symlinks:

```sh
git clone git@github.com:PDmatrix/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap
```

If a managed destination already exists as a regular file, `bootstrap` moves it to a timestamped directory under:

```text
~/.local/state/dotfiles/backups/
```

The script invokes Stow with `--no-folding`, ensuring directories such as `~/.pi/agent` remain real directories while individual managed files are symlinked.

Specific packages can be installed by passing their names:

```sh
./bootstrap zsh starship
```

## Usage

Managed files can be edited through their normal paths or directly in the repository. Both paths refer to the same file:

```sh
$EDITOR ~/.zshrc
$EDITOR ~/dotfiles/zsh/.zshrc
```

After pulling changes that add, remove, or relocate managed files, refresh the links:

```sh
git pull
make restow
```

Available maintenance commands:

```sh
make check    # simulate Stow and report conflicts
make restow   # recreate links for all packages
make unstow   # remove links for all packages
```

## Pi data boundaries

Only Pi settings and the local Ghostty extension are managed. Mutable or sensitive Pi data remains under `~/.pi/agent` and is excluded from the repository, including:

- credentials and authentication state
- model caches and trust decisions
- session history
- installed npm and Git packages
- downloaded binaries and debug logs
