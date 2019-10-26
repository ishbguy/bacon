#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash tmux &>/dev/null || return 1

bacon_export tmux

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

bacon_defined BACON_PROMPT_COUNTERS \
    && BACON_PROMPT_COUNTERS+=('tmux list-sessions 2>/dev/null | grep -v ^no | wc -l')

# vim:set ft=sh ts=4 sw=4:
