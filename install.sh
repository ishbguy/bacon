#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# source guard
[[ $INSTALL_SOURCED -eq 1 ]] && return
declare -r INSTALL_SOURCED=1
declare -r INSTALL_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
declare -r INSTALL_ABS_DIR="$(dirname "$INSTALL_ABS_SRC")"

install() {
    local -a configs=(bashrc bash_profile bash_logout)
    local date=$(date +%Y%m%d)
    for cfg in "${configs[@]}"; do
        [[ -f $HOME/.$cfg ]] && mv "$HOME/.$cfg" "$HOME/.$cfg-$date"
        printf 'link %-15s to %s\n' "$cfg" "$HOME/.$cfg"
        ln -s "$INSTALL_ABS_DIR/$cfg" "$HOME/.$cfg"
    done
}

[[ ${FUNCNAME[0]} == "main" ]] \
    && install "$@"

# vim:set ft=sh ts=4 sw=4:
