#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash git &>/dev/null || return 1

bacon_export bag

export PROJECTS_DIR="$(readlink -f "$BACON_SOURCE_BAG_ABS_DIR/../..")"
export BAG_REPO_DIR="$PROJECTS_DIR/bag"
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
        [[ $# -eq 2 ]] || __bag_warn "Not enough args." || return 1
        local bag_opt="$1"
        local bag_url="${2#*:}"
        local bag_name=$(basename "${bag_url##*:}")

        case $bag_opt in
            install) rclone sync "$bag_url" "$BAG_BASE_DIR/$bag_name" ;;
            update) rclone sync "$bag_url" "$BAG_BASE_DIR/$bag_name" ;;
            *) __bag_warn "No such option: $bag_opt" ;;
        esac
    }
    BAG_DOWNLOADER[rclone]=bag_downloader_rclone
    BAG_DOWNLOADER[rc]=bag_downloader_rclone
fi

[[ -d $BAGS_DIR ]] || mkdir -p "$BAGS_DIR"

bag base "$BAGS_DIR"
bag plug "gh:ishbguy/baux"
bag plug "gh:ishbguy/license"
bag load

# vim:set ft=sh ts=4 sw=4:
