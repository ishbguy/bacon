#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash dircolors &>/dev/null || return 1

bacon_export ls

# Setting the ls colors
[[ -f $BACON_SOURCE_LS_ABS_DIR/dircolors ]] && eval "$(dircolors "$BACON_SOURCE_LS_ABS_DIR/dircolors")"

# vim:set ft=sh ts=4 sw=4:
