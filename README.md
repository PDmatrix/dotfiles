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
| `pi` | `~/.pi/agent/settings.json` |

## Installation

Install Git, clone the repository, and run the bootstrap script:

```sh
sudo pacman -S git
git clone git@github.com:PDmatrix/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap
```

On Arch Linux, `bootstrap` reads [`packages.arch`](packages.arch) and installs only the dependencies belonging to the selected Stow packages. Dependencies marked `@bootstrap` are always installed. Tools distributed outside pacman are listed in [`packages.external`](packages.external); when one is missing, bootstrap prints its installer command for review instead of executing a remote script automatically.

If a managed destination already exists as a regular file, `bootstrap` moves it to a timestamped directory under:

```text
~/.local/state/dotfiles/backups/
```

The script invokes Stow with `--no-folding`, ensuring directories such as `~/.pi/agent` remain real directories while individual managed files are symlinked.

With no arguments, bootstrap uses the `desktop` profile. Use the `server` profile to install the same shell and coding tools without Ghostty:

```sh
./bootstrap --profile desktop
./bootstrap --profile server
```

Specific packages can also be selected directly. They are the only packages whose Arch dependencies will be installed:

```sh
./bootstrap zsh starship
```

Package arguments used with `--profile` are added for that bootstrap run. Bootstrap records the selected profile under `~/.local/state/dotfiles/profile`, so later Make commands use its standard package set automatically. Run `./bootstrap --help` to show the profile contents.

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

Maintenance commands use the profile saved by bootstrap (`desktop` when none has been saved):

```sh
make check     # simulate Stow and report conflicts
make stow      # create links for the active profile
make restow    # refresh links for the active profile
make unstow    # remove links for the active profile
```

Override it for a single invocation when needed, for example `make stow PROFILE=server`.

## Pi data boundaries

Only Pi settings are managed. Mutable or sensitive Pi data remains under `~/.pi/agent` and is excluded from the repository, including:

- credentials and authentication state
- model caches and trust decisions
- session history
- installed npm and Git packages
- downloaded binaries and debug logs
