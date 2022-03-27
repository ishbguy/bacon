# Copyright (c) 2019 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

bacon_export prompt

declare -ga BACON_PROMPT_PS1_LAYOUT=()
declare -ga BACON_PROMPT_COUNTERS=()
declare -gA BACON_PROMPT_COLOR=()
declare -gA BACON_PROMPT_INFO=()
declare -g  BACON_PROMPT_FORMAT

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

bacon_prompt_format_expand() {
    local fmt=$1
    local expanded brackets braces squares cmd name color i j k
    for ((i = 0; i < ${#fmt}; i++)); do
        [[ ${fmt:$i:1} != "#" ]] && expanded+="${fmt:$i:1}" && continue
        ((k = i, i++))
        while true; do
        case ${fmt:$i:1} in
        "(")
            ((brackets = 1, i++))
            for ((j = i; j  < ${#fmt}; j++)); do
                case ${fmt:$j:1} in
                    "(") ((brackets++)) ;;
                    ")") ((--brackets)); [[ $brackets -eq 0 ]] && break ;;
                esac
            done
            [[ ${fmt:$j:1} != ")" || $brackets -ne 0 ]] && break
            cmd="${fmt:$i:$((j-i))}"
            expanded+="$(eval "$cmd" 2>/dev/null)"
            ((i = j))
            ;;
        "{")
            ((braces = 1, i++))
            for ((j = i; j  < ${#fmt}; j++)); do
                case ${fmt:$j:1} in
                    "{") ((braces++)) ;;
                    "}") ((--braces)); [[ $braces -eq 0 ]] && break ;;
                esac
            done
            [[ ${fmt:$j:1} != "}" || $braces -ne 0 ]] && break
            name="${fmt:$i:$((j-i))}"
            if [[ -n ${BACON_PROMPT_COLOR[$name]} ]]; then
                # embedded color & style
                expanded+="$(eval "echo '$(bacon_promptc "${BACON_PROMPT_COLOR[$name]}" "${BACON_PROMPT_INFO[$name]}")'" 2>/dev/null)"
            else
                expanded+="$(eval "echo '${BACON_PROMPT_INFO[$name]}'" 2>/dev/null)"
            fi
            ((i = j))
            ;;
        "[")
            ((squares = 1, i++))
            for ((j = i; j  < ${#fmt}; j++)); do
                case ${fmt:$j:1} in
                    "[") ((squares++)) ;;
                    "]") ((--squares)); [[ $squares -eq 0 ]] && break ;;
                esac
            done
            [[ ${fmt:$j:1} != "]" || $squares -ne 0 ]] && break
            color="${fmt:$i:$((j-i))}"
            expanded+="$(eval echo "${BACON_COLOR[$color]}" 2>/dev/null)"
            ((i = j))
            ;;
        *)  expanded+="#${fmt:$i:1}" ;;
        esac
        break
        done
        if [[ $j -eq ${#fmt} ]]; then
            expanded+="${fmt:$k}"
            ((i = ${#fmt}))
        fi
    done
    echo "$expanded"
}

bacon_prompt_ps1() {
    local ps1 fmt
    fmt="$(bacon_prompt_format_expand "${BACON_PROMPT_FORMAT}")"
    fmt="$(bacon_prompt_format_expand "${fmt}")"
    ps1="$(bacon_prompt_format_expand "${fmt}")"
    echo "$ps1"
}

# vim:set ft=sh ts=4 sw=4:
