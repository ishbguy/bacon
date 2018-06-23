#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BASH_LS_CONFIG_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASH_LS_CONFIG_DIR="$(dirname "$BASH_LS_CONFIG_SRC")"

# Setting the ls colors
[[ -f $BASH_LS_CONFIG_DIR/dircolors ]] && eval "$(dircolors "$BASH_LS_CONFIG_DIR/dircolors")"

# vim:set ft=sh ts=4 sw=4:
