#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BACON_PRECMD_ABS_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
export BACON_PRECMD_ABS_DIR="$(dirname "$BACON_PRECMD_ABS_SRC")"

declare -ga BACON_PRECMDS=('export LAST_STATUS=$?')
bacon_precmd() {
    for cmd in "${BACON_PRECMDS[@]}"; do
        eval "$cmd"
    done
}

PROMPT_COMMAND=bacon_precmd

# vim:set ft=sh ts=4 sw=4:
