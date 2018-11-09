#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BASH_CONFIG_ENV_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASH_CONFIG_ENV_DIR="$(dirname "$BASH_CONFIG_ENV_SRC")"

# restore old PATH when re-source the .bashrc file to prevent append duplicated path
[[ -z $OLD_PATH ]] && export OLD_PATH=$PATH
export PATH=$OLD_PATH

export TERM=xterm-256color
export EDITOR=vim
export LYNX_CFG=$HOME/.lynx.cfg
export MARK_DIR=$HOME/doc/mark
export TAG_DIR=$HOME/doc/tag
export GIT_PROJECT_DIR=/samba/project/git
export CFLOWRC=${GIT_PROJECT_DIR}/cflow/src/cflow.rc
export BLOG_DIR=${GIT_PROJECT_DIR}/ishbguy.github.io
export POST_DIR=$BLOG_DIR/_posts

# vim:set ft=sh ts=4 sw=4:
