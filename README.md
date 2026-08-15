# Dotfiles

Personal dotfiles for Zsh, Atuin, Starship, Ghostty, Herdr, and the Pi coding agent, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Managed configuration

| Stow package | Destination |
| --- | --- |
| `zsh` | `~/.zshrc` |
| `atuin` | `~/.config/atuin/config.toml` |
| `starship` | `~/.config/starship.toml` |
| `ghostty` | `~/.config/ghostty/config.ghostty` |
| `herdr` | `~/.config/herdr/config.toml` |
| `herdr` | `~/.config/herdr/plugins/config/herdr-agent-inbox/config.toml` |
| `pi` | `~/.pi/agent/settings.json` |

The [`herdr-agent-inbox`](https://github.com/douglascorrea/herdr-agent-inbox) plugin adds conversation-derived titles, agent triage, running times, workspace rollups, and resumable chat history to Herdr. Install its runtime with:

```sh
herdr plugin install douglascorrea/herdr-agent-inbox
```

## Installation

Install Git, clone the repository, and run the bootstrap script:

```sh
sudo pacman -S git
git clone git@github.com:PDmatrix/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap
```

On Arch Linux, `bootstrap` reads [`packages.arch`](packages.arch) and installs any missing packages with `pacman` before creating the symlinks. Add new system dependencies to that file instead of duplicating the package list in this README.

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

Only Pi settings are managed. Mutable or sensitive Pi data remains under `~/.pi/agent` and is excluded from the repository, including:

- credentials and authentication state
- model caches and trust decisions
- session history
- installed npm and Git packages
- downloaded binaries and debug logs
