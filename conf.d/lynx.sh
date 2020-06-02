#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash lynx &>/dev/null || return 1

bacon_export lynx

lydump() { lynx -dump -display_charset="${2:-utf-8}" "$1"; }

# vim:set ft=sh ts=4 sw=4:
