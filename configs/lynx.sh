#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash lynx &>/dev/null || return 1

export BASH_CONFIG_LYNX_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASH_CONFIG_LYNX_DIR="$(dirname "$BASH_CONFIG_LYNX_SRC")"

lydump() { lynx -dump -display_charset="${2:-utf-8}" "$1"; }

# vim:set ft=sh ts=4 sw=4:
