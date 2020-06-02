#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash wmctrl &>/dev/null || return 1

bacon_export wmctrl

alias fullscreen='wmctrl -i -r $WINID -b toggle,fullscreen'

# get x window id
[[ -z $WINID && -n $DISPLAY ]] && export WINID=$(wmctrl -l | tail -n1 | awk '{print $1}') || true

# vim:set ft=sh ts=4 sw=4:
