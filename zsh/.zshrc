# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob notify
bindkey -e

# Bind terminal navigation keys using the active terminal's terminfo entries.
# Ghostty sends Delete as ESC [ 3 ~, which Zsh does not bind by default.
[[ -n "${terminfo[kdch1]}" ]] && bindkey "${terminfo[kdch1]}" delete-char
[[ -n "${terminfo[khome]}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n "${terminfo[kend]}" ]] && bindkey "${terminfo[kend]}" end-of-line
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "${HOME}/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

[[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

(( $+commands[starship] )) && eval "$(starship init zsh)"

# Pi
export PATH="${HOME}/.local/share/pi-node/current/bin:$PATH"

# Add ~/.local/bin to PATH
if [ -d "${HOME}/.local/bin" ] && [[ ":${PATH}:" != *":${HOME}/.local/bin:"* ]]; then
    PATH="${HOME}/.local/bin:${PATH}"
fi

alias gs='git status'
