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

bacon_defined BACON_PROMPT_COUNTERS \
    && BACON_PROMPT_COUNTERS+=('tmux list-sessions 2>/dev/null | grep -v ^no | wc -l')

# vim:set ft=sh ts=4 sw=4:
