#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash ruby &>/dev/null || return 1

export BASH_CONFIG_RUBY_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
export BASH_CONFIG_RUBY_DIR="$(dirname "$BASH_CONFIG_RUBY_SRC")"

export RUBY_BIN="$HOME/.gem/ruby/2.5.0/bin"
export PATH=$PATH:$RUBY_BIN

# vim:set ft=sh ts=4 sw=4:
