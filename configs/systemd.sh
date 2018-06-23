#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash systemctl &>/dev/null || return 1

export BASH_CONFIG_SYSTEMD_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASH_CONFIG_SYSTEMD_DIR="$(dirname "$BASH_CONFIG_SYSTEMD_SRC")"

alias scdis='systemctl disable'
alias scen='systemctl enable'
alias ssact='systemctl -l list-units'
alias ssdis='systemctl --state disabled list-unit-files'
alias ssen='systemctl --state enabled list-unit-files'
alias suen='systemctl --user --state enabled list-unit-files'

# vim:set ft=sh ts=4 sw=4:
