#! /usr/bin/env bash
# Copyright (c) 2019 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

bacon_export precmd

declare -ga BACON_PRECMD=()
declare -ga BACON_PRECMD_TRAP=()
declare -g  BACON_PRECMD_TRAP_SIG="${BACON_PRECMD_TRAP_SIG:-}"

bacon_precmd_handler() {
    for cmd in "${BACON_PRECMD_TRAP[@]}"; do
        eval "$cmd"
    done
}

bacon_precmd() {
    for cmd in "${BACON_PRECMD[@]}"; do
        eval "$cmd"
    done
    # Trigger a signal to exec precmd can accelerate a task.
    if [[ -n $BACON_PRECMD_TRAP_SIG ]]; then
        trap 'bacon_precmd_handler' "${BACON_PRECMD_TRAP_SIG}"
        kill -"${BACON_PRECMD_TRAP_SIG}" "$BASHPID"
    fi
}

# vim:set ft=sh ts=4 sw=4:
