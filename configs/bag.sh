#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash git &>/dev/null || return 1

export BASH_CONFIG_BAG_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASH_CONFIG_BAG_DIR="$(dirname "$BASH_LS_CONFIG_SRC")"

export PROJECTS_DIR=/samba/project
export GIT_PROJECTS_DIR="$PROJECTS_DIR/git"
export BAG_REPO_DIR="$GIT_PROJECTS_DIR/bag"
export BAGS_DIR="$PROJECTS_DIR/bags"

if [[ ! -f $BAG_REPO_DIR/bag.sh ]]; then
    mkdir -p "$BAG_REPO_DIR" \
        && git clone https://github.com/ishbguy/bag "$BAG_REPO_DIR"
fi

[[ -f $BAG_REPO_DIR/bag.sh ]] \
    || { printf 'Failed to download %s\n' '/ishbguy/bag'; return 1; }

source "$BAG_REPO_DIR/bag.sh"

# add rclone downloader
if hash rclone &>/dev/null; then
    bag_downloader_rclone() {
        local bag_url="${1#*:}"
        local bag_name=$(basename "$bag_url")
        local base_dir="$2"

        printf 'rclone sync %s %s' "$bag_url" "$base_dir/$bag_name\n"
        rclone sync "$bag_url" "$base_dir/$bag_name" &>/dev/null
    }
    BAG_DOWNLOADER[rclone]=bag_downloader_rclone
    BAG_DOWNLOADER[rc]=bag_downloader_rclone
fi

[[ -d $BAGS_DIR ]] || mkdir -p "$BAGS_DIR"

bag base "$BAGS_DIR"
bag plug "gh:ishbguy/baux"
bag plug "gh:ishbguy/license"
bag plug "gh:ishbguy/vim-config"
bag load

# vim:set ft=sh ts=4 sw=4:
