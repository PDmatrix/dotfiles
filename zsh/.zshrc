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
# Search history using the text already entered as a prefix, then place the
# cursor at the end of the recalled command.
_history-search-backward-end() {
    zle history-beginning-search-backward
    zle end-of-line
}
_history-search-forward-end() {
    zle history-beginning-search-forward
    zle end-of-line
}
zle -N history-search-backward-end _history-search-backward-end
zle -N history-search-forward-end _history-search-forward-end

# Bind both the terminfo and normal cursor sequences because terminals can
# send either one.
bindkey '^[[A' history-search-backward-end
bindkey '^[[B' history-search-forward-end
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" history-search-backward-end
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" history-search-forward-end
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
(( $+commands[bat] )) && alias cat='bat --paging=never --style=plain'
(( $+commands[eza] )) && alias ls='eza -alh'
