#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BASH_BAG_CONFIG_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASH_BAG_CONFIG_DIR="$(dirname "$BASH_LS_CONFIG_SRC")"

export PROJECTS_DIR=/samba/project
export GIT_PROJECTS_DIR="$PROJECTS_DIR/git"
export BAG_REPO_DIR="$GIT_PROJECTS_DIR/bag"
export BAGS_DIR="$PROJECTS_DIR/bags"

if [[ ! -f $BAG_REPO_DIR/bag.sh ]]; then
    mkdir -p "$BAG_REPO_DIR" \
        && git clone https://github.com/ishbguy/bag "$BAG_REPO_DIR"
fi

if [[ -f $BAG_REPO_DIR/bag.sh ]]; then
    source "$BAG_REPO_DIR/bag.sh"
    [[ -d $BAGS_DIR ]] || mkdir -p "$BAGS_DIR"
    bag base "$BAGS_DIR"
    bag plug "gh:ishbguy/baux"
    bag plug "gh:ishbguy/license"
    bag plug "gh:ishbguy/vim-config"
    bag load
fi

# vim:set ft=sh ts=4 sw=4:
