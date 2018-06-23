#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash tmux &>/dev/null || return 1

export BASH_CONFIG_TMUX_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASH_CONFIG_TMUX_DIR="$(dirname "$BASH_CONFIG_TMUX_SRC")"

#alias for tmux
alias tmx='tmux'
alias tmxn='tmux new-session'
alias tmxl='tmux list-sessions'
alias tmxa='tmux attach-session'
alias tmxk='tmux kill-session'
alias tmxc='tmux capture-pane'

# Some functions for tmux
tma() { tmux attach-session "$1"; }
tmd() {
    tmux new-session -s "${1:-Dev}" -n "${2:-Coding}" \
        -c ~/exer -d \; split-window -c ~/doc -h -d \; attach
}

if hash mutt &>/dev/null && hash offlineimap &>/dev/null; then
    tmm() {
        tmux new-session -s "${1:-Com}" -n "${2:-Mutt}" \
            -c ~/.mutt/attach/ -d 'mutt' \; \
            new-window -n Offlineimap -c ~/.mail/hotmail 'offlineimap' \; attach
    }
fi

# vim:set ft=sh ts=4 sw=4:
