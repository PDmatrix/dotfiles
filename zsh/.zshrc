# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# Append commands immediately and import commands written by other Zsh sessions.
# This keeps history shared across terminal tabs instead of only merging on exit.
setopt autocd extendedglob notify share_history
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

if (( $+commands[atuin] )); then
    # Keep Atuin's interactive selector on Ctrl-R, but make Up/Down cycle
    # directly through its local database like normal shell history.
    eval "$(atuin init zsh --disable-ai --disable-up-arrow)"

    typeset -g _atuin_history_query=''
    typeset -g _atuin_history_original_buffer=''
    typeset -g _atuin_history_current_buffer=''
    typeset -gi _atuin_history_offset=-1

    _atuin-history-fetch() {
        local result
        result=$(atuin search --cmd-only --limit 1 \
            --offset "${_atuin_history_offset}" \
            --filter-mode global --search-mode prefix -- \
            "${_atuin_history_query}" 2>/dev/null) || return 1
        [[ -n "${result}" ]] || return 1

        BUFFER=${result}
        CURSOR=${#BUFFER}
        _atuin_history_current_buffer=${BUFFER}
    }

    _atuin-history-up() {
        if [[ ${BUFFER} != ${_atuin_history_current_buffer} || ${_atuin_history_offset} -lt 0 ]]; then
            _atuin_history_query=${BUFFER}
            _atuin_history_original_buffer=${BUFFER}
            _atuin_history_offset=0
        else
            (( ++_atuin_history_offset ))
        fi

        if ! _atuin-history-fetch; then
            (( _atuin_history_offset > 0 )) && (( --_atuin_history_offset ))
            zle .beep
        fi
    }

    _atuin-history-down() {
        if [[ ${BUFFER} != ${_atuin_history_current_buffer} || ${_atuin_history_offset} -lt 0 ]]; then
            _atuin_history_offset=-1
            zle .down-line-or-history
        elif (( _atuin_history_offset == 0 )); then
            BUFFER=${_atuin_history_original_buffer}
            CURSOR=${#BUFFER}
            _atuin_history_current_buffer=''
            _atuin_history_offset=-1
        else
            (( --_atuin_history_offset ))
            _atuin-history-fetch || zle .beep
        fi
    }

    zle -N atuin-history-up _atuin-history-up
    zle -N atuin-history-down _atuin-history-down
    ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(atuin-history-up atuin-history-down)
    bindkey '^[[A' atuin-history-up
    bindkey '^[[B' atuin-history-down
    [[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" atuin-history-up
    [[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" atuin-history-down
else
    # Retain normal Zsh history navigation when Atuin is unavailable.
    bindkey '^[[A' up-line-or-history
    bindkey '^[[B' down-line-or-history
    [[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-history
    [[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-history
fi

(( $+commands[starship] )) && eval "$(starship init zsh)"

# Pi
export POWERLINE_NERD_FONTS=1
export PATH="${HOME}/.local/share/pi-node/current/bin:$PATH"

# Add ~/.local/bin to PATH
if [ -d "${HOME}/.local/bin" ] && [[ ":${PATH}:" != *":${HOME}/.local/bin:"* ]]; then
    PATH="${HOME}/.local/bin:${PATH}"
fi

alias gs='git status'
(( $+commands[bat] )) && alias cat='bat --paging=never --style=plain'
(( $+commands[eza] )) && alias ls='eza -alh'
