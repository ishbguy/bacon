#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BASH_PRECMD_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASH_PRECMD_ABS_DIR="$(dirname "$BASH_PRECMD_ABS_SRC")"

declare -ga BASH_PRECMDS=('export LAST_STATUS=$?')
bash_precmd() {
    for cmd in "${BASH_PRECMDS[@]}"; do
        eval "$cmd"
    done
}

PROMPT_COMMAND=bash_precmd

# vim:set ft=sh ts=4 sw=4:
