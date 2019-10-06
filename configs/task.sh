#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash task &>/dev/null || return 1

export BASH_CONFIG_TASK_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
export BASH_CONFIG_TASK_DIR="$(dirname "$BASH_CONFIG_TASK_SRC")"

alias taskP='task all status:pending'
alias taskC='task all status:completed'
alias taskD='task all status:deleted'
alias taskW='task all status:waiting'
alias taskR='task all status:recurring'
alias taskBd='task burndown.daily'
alias taskBw='task burndown.weekly'
alias taskBm='task burndown.monthly'
alias taskA='task active'
alias taskO='task overdue'
alias taskS='task summary'
alias taskT='task timesheet'
alias taskM='task minimal'
alias taskd='task all +TODAY status.not:recurring'
alias taskt='task all +TOMORROW status.not:recurring'
alias taskw='task all +WEEK status.not:recurring'
alias taskm='task all +MONTH status.not:recurring'
alias taskc='task calendar'
alias taskl='task list'

alias vT='vi ~/.taskrc'

if hash rclone &>/dev/null; then
    alias task-push='rclone sync ~/.task onedrive:task'
    alias task-pull='rclone sync onedrive:task ~/.task'
fi

bacon_defined BACON_PROMPT_COUNTERS \
    && BACON_PROMPT_COUNTERS+=('task status:pending count')

# vim:set ft=sh ts=4 sw=4:
