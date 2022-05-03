# Copyright (c) 2019 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

bacon_export prompt

declare -ga BACON_PROMPT_PS1_LAYOUT=()
declare -ga BACON_PROMPT_COUNTERS=()
declare -gA BACON_PROMPT_COLOR=()
declare -gA BACON_PROMPT_INFO=()
declare -g  BACON_PROMPT_FORMAT
declare -g  BACON_PROMPT_THEME
declare -ga BACON_PROMPT_THEME_DIR=()

bacon_promptc() {
    local color
    while bacon_has_map BACON_COLOR "$1"; do
        color+="${BACON_COLOR[$1]}"; shift
    done
    color="${color:-${BACON_COLOR[default]}}"
    local IFS=' '
    printf '\[%s\]%s\[\033[00m\]\n' "$color" "$*"
}

bacon_prompt_counter() {
    local -A counters
    local str='' cnt
    for cnt in "${BACON_PROMPT_COUNTERS[@]}"; do
        # shellcheck disable=SC2155
        local nr="$(eval "$cnt")"
        [[ $nr =~ ^[[:digit:]]+$ && $nr != 0 ]] || continue
        cnt="${cnt// /}"
        for ((len = 1; len <= ${#cnt}; len++)); do
            [[ -z ${counters[${cnt:0:$len}]} ]] || continue
            str+="${cnt:0:$len}$nr"
            counters[${cnt:0:$len}]="$nr"
            break
        done
    done
    [[ -n $str ]] && bacon_promptc "${BACON_PROMPT_COLOR[counter]:-yellow}" "[$str]"
}

bacon_prompt_set_theme() {
    local theme="${1:-$BACON_PROMPT_THEME}"
    for dir in "${BACON_PROMPT_THEME_DIR[@]}"; do
        [[ -f $dir/${theme}.theme ]] || continue
        source "$dir/${theme}.theme" ; return
    done
    local IFS=,
    echo "Fail to set theme [$theme]: Can not find ${theme}.theme in ${BACON_PROMPT_THEME_DIR[*]}."
}

bacon_prompt_format_expand() {
    local fmt=$1 expanded ctx left sp i j k
    local -A pairs=(["("]=")" ["{"]="}" ["["]="]")
    local -A cmds=(["("]="__run" ["{"]="__replace" ["["]="__paint")
    __run() { (eval "$@" 2>/dev/null) || true ; }
    __paint() { echo "${BACON_COLOR[$1]}" ; }
    __replace() {
        if [[ -n ${BACON_PROMPT_COLOR[$1]} ]]; then
            # embedded color & style
            bacon_promptc "${BACON_PROMPT_COLOR[$1]}" "${BACON_PROMPT_INFO[$1]}"
        else
            echo "${BACON_PROMPT_INFO[$1]}"
        fi
    }
    for ((i = 0; i < ${#fmt}; i++)); do
        [[ ${fmt:$i:1} != "#" ]] && expanded+="${fmt:$i:1}" && continue
        ((k = i, ++i)) && left="${fmt:$i:1}"
        # use the while loop to control the case statement
        while true; do case $left in
        "("|"{"|"[")
            for ((sp = 1, i++, j = i; j  < ${#fmt}; j++)); do
                case ${fmt:$j:1} in
                    "$left") ((sp++)) ;;
                    "${pairs[$left]}") ((--sp)); [[ $sp -eq 0 ]] && break ;;
                esac
            done
            [[ ${fmt:$j:1} != "${pairs[$left]}" || $sp -ne 0 ]] && break
            ctx="${fmt:$i:$((j-i))}" && ((i = j))
            expanded+="$(eval "${cmds[$left]}" "$ctx")" ;;
        *)  expanded+="#${fmt:$i:1}" ;;
        esac; break; done
        [[ $j -eq ${#fmt} ]] && ((i = ${#fmt})) && expanded+="${fmt:$k}"
    done
    unset __run __paint __replace
    echo "$expanded"
}

bacon_prompt_ps1() {
    local fmt="${BACON_PROMPT_FORMAT}"
    while [[ $fmt =~ \#[\[\{\(] ]]; do
        fmt="$(bacon_prompt_format_expand "${fmt}")"
    done
    echo "$fmt"
}

# vim:set ft=sh ts=4 sw=4:
