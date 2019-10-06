#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash git &>/dev/null || return 1

export BASH_CONFIG_GIT_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
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

if bacon_defined BACON_PROMPT_PS1_LAYOUT && bacon_definedf bacon_prompt_color; then
    bash_prompt_git_branch() {
        local branch="$(git symbolic-ref --short HEAD 2>/dev/null)"
        local cmp="$(git status 2>/dev/null | grep 'Your branch is' | awk '{print $4,$7,$8}')"
        if [[ -n $cmp ]]; then
            [[ $cmp =~ ahead ]] && branch+="$(echo ":^ $cmp" | awk '{print $1$4}')"
            [[ $cmp =~ behind ]] && branch+="$(echo ":v $cmp" | awk '{print $1$3}')"
        fi
        local status_string="$(git status -s 2>/dev/null | awk '{print $1}' \
            | sort | uniq -c | awk '{print $2$1}')"
        local -a status
        [[ -n $status_string ]] && mapfile -t status <<<"$status_string"
        for s in "${status[@]}"; do
            branch+=":$s"
        done
        [[ -n $branch ]] \
            && bacon_prompt_color ${BACON_PROMPT_COLOR[git]:-magenta} "[$branch]"
    }
    BACON_PROMPT_PS1_LAYOUT+=(bash_prompt_git_branch)
fi

# vim:set ft=sh ts=4 sw=4:
