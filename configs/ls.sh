#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash dircolors &>/dev/null || return 1

export BASH_CONFIG_LS_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
export BASH_CONFIG_LS_DIR="$(dirname "$BASH_CONFIG_LS_SRC")"

# Setting the ls colors
[[ -f $BASH_CONFIG_LS_DIR/dircolors ]] && eval "$(dircolors "$BASH_CONFIG_LS_DIR/dircolors")"

# vim:set ft=sh ts=4 sw=4:
