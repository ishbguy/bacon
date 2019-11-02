#! /usr/bin/env bash
# Copyright (c) 2019 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

bacon_export precmd

declare -ga BACON_PRECMDS=()
bacon_precmd() {
    for cmd in "${BACON_PRECMDS[@]}"; do
        eval "$cmd"
    done
}

# vim:set ft=sh ts=4 sw=4:
