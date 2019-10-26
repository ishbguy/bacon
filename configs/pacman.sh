#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash pacman &>/dev/null || return 1

bacon_export pacman

alias pacman='pacman --color=auto'

# vim:set ft=sh ts=4 sw=4:
