#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash git &>/dev/null || return 1

bacon_export git

if bacon_defined BACON_PROMPT_PS1_LAYOUT && bacon_definedf bacon_promptc; then
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
        # check whether the local repo is different from remote tracked repo
        [[ -n ${brchi[2]} && ${brchi[*]:2} =~ '[' ]] && brch+="${trki[${brchi[2]#[}]}${brchi[3]%]}"
        local c
        local tmp=()
        for c in "${bstat[@]:1}"; do
            # prevent special chars to be expand
            c="${c//\?\?/'\?'}"; c="${c//\!/'!'}"
            tmp=($c)
            ((++change[${tmp[0]}]))
        done
        for c in "${!change[@]}"; do
            brch+=":${c}${change[$c]}"
        done
        bacon_promptc "${BACON_PROMPT_COLOR[git]:-magenta}" "[$brch]"
    }
    BACON_PROMPT_PS1_LAYOUT+=(bash_prompt_git_branch)
fi

# vim:set ft=sh ts=4 sw=4:
