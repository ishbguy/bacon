#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash systemctl &>/dev/null || return 1

bacon_export systemd

alias scdis='systemctl disable'
alias scen='systemctl enable'
alias ssact='systemctl -l list-units'
alias ssdis='systemctl --state disabled list-unit-files'
alias ssen='systemctl --state enabled list-unit-files'
alias suen='systemctl --user --state enabled list-unit-files'

# vim:set ft=sh ts=4 sw=4:
