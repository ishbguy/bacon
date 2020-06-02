#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash jekyll &>/dev/null || return 1

bacon_export jekyll

jekill() { pkill -f jekyll; }
jekyup() {(jekill; cd "${1:-$BLOG_DIR}" && jekyll serve -B)}

# vim:set ft=sh ts=4 sw=4:
