#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash pip &>/dev/null || return 1

bacon_export pip

pip_upgrade() {
    for pkg in $(pip list --outdate --format legacy | awk '{print $1}'); do
        sudo pip install --upgrade "${pkg}"
    done
}

# vim:set ft=sh ts=4 sw=4:
