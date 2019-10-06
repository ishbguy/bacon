#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash wmctrl &>/dev/null || return 1

export BASH_CONFIG_WMCTRL_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
export BASH_CONFIG_WMCTRL_DIR="$(dirname "$BASH_CONFIG_WMCTRL_SRC")"

alias fullscreen='wmctrl -i -r $WINID -b toggle,fullscreen'

# get x window id
[[ -z $WINID && -n $DISPLAY ]] && export WINID=$(wmctrl -l | tail -n1 | awk '{print $1}') || true

# vim:set ft=sh ts=4 sw=4:
