#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash git &>/dev/null || return 1

bacon_export git

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

if bacon_defined BACON_PROMPT_PS1_LAYOUT && bacon_definedf bacon_printc; then
    bash_prompt_git_branch() {
        local IFS=$'\n'
        local bstat=($(git status -sb 2>/dev/null))
        # return if current dir is not a git repo
        [[ ${#bstat[@]} == 0 ]] && return 0

        local brch=""
        local -A change=()
        local -A trki=([ahead]="^" [behind]="v")
        IFS=' '; local brchi=(${bstat[0]})

        brch="${brchi[1]//..*/}"
        [[ -n ${brchi[2]} ]] && brch+="${trki[${brchi[2]#[}]}${brchi[3]%]}"
        for c in "${bstat[@]:1}"; do
            c="${c/+( )/}"
            ((++change[${c%% *}]))
        done
        for c in "${!change[@]}"; do
            brch+=":${c}${change[$c]}"
        done
        bacon_printc "${BACON_PROMPT_COLOR[git]:-magenta}" "[$brch]"
    }
    BACON_PROMPT_PS1_LAYOUT+=(bash_prompt_git_branch)
fi

# vim:set ft=sh ts=4 sw=4:
