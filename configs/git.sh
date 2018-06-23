#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash git &>/dev/null || return 1

export BASH_CONFIG_GIT_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASH_CONFIG_GIT_DIR="$(dirname "$BASH_CONFIG_GIT_SRC")"

#alias for git
alias gadd='git add'
alias gbranch='git branch'
alias gcheckout='git checkout'
alias gclone='git clone'
alias gcommit='git commit'
alias gconfig='git config'
alias gdiff='git diff'
alias gfetch='git fetch'
alias ggrep='git grep'
alias ghelp='git help'
alias ginit='git init'
alias glog='git log --graph --color --decorate -M --pretty=medium'
alias gmerge='git merge'
alias gpull='git pull'
alias gshow='git show'
alias gstatus='git status'
alias gtag='git tag'

alias git_set_head_to='git reset --soft'
alias git_set_headindex_to='git reset --mixed'
alias git_set_all_to='git reset --hard'
alias git_set_index_eq_to='git reset --merge'
alias git_clean_index='git reset --keep'

alias git_undo_commit='git reset --soft HEAD^'
alias git_redo_commit='git commit -a -c ORIG_HEAD'
alias git_fix_commit='git commit -a --amend'
alias git_rollback_soft='git checkout'
alias git_rollback_hard='git reset --hard'
alias git_undo_index_file='git reset --'
alias git_undo_index_all='git reset'
alias git_undo_changed_file='git checkout --'
alias git_merge_modified='git pull && git reset --merge ORIG_HEAD'
alias git_merge_work='git pull && git reset --merge ORIG_HEAD'

github() { git clone "https://github.com/$1"; }

# vim:set ft=sh ts=4 sw=4:
