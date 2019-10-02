#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $BACON_INSTALL_SOURCED -eq 1 ]] && return
declare -r BACON_INSTALL_SOURCED=1
declare -r BACON_INSTALL_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
declare -r BACON_INSTALL_ABS_DIR="$(dirname "$BACON_INSTALL_ABS_SRC")"

bacon_install() {
    local -a configs=(bashrc bash_profile bash_logout)
    local date=$(date +%Y%m%d)
    for cfg in "${configs[@]}"; do
        [[ -e $HOME/.$cfg || -L $HOME/.$cfg ]] && mv "$HOME/.$cfg" "$HOME/.$cfg-$date"
        printf 'link %-15s to %s\n' "$cfg" "$HOME/.$cfg"
        ln -s "$BACON_INSTALL_ABS_DIR/../$cfg" "$HOME/.$cfg"
    done
}

[[ ${FUNCNAME[0]} == "main" ]] \
    && bacon_install "$@"

# vim:set ft=sh ts=4 sw=4:
