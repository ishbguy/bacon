#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash sdcv &>/dev/null || return 1

export BASH_CONFIG_SDCV_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASH_CONFIG_SDCV_DIR="$(dirname "$BASH_CONFIG_SDCV_SRC")"

# alias for stardict sdcv
alias dict-oxford='sdcv -c -u oxford'
alias dict-king='sdcv -c -u kingsoft-ce'
alias dict-ldec='sdcv -c -u langdao-ec'
alias dict-ldce='sdcv -c -u langdao-ce'
alias dict-ec='sdcv -c -u lazyworm-ec'
alias dict-ce='sdcv -c -u lazyworm-ce'
alias dict-cb='sdcv -c -u stardict-cb'
alias dict='sdcv -c -u stardict-cb'

# vim:set ft=sh ts=4 sw=4:
