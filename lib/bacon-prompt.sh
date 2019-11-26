# Copyright (c) 2019 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

bacon_export prompt

declare -ga BACON_PROMPT_PS1_LAYOUT=()
declare -ga BACON_PROMPT_COUNTERS=()
declare -gA BACON_PROMPT_COLOR=()
declare -gA BACON_PROMPT_CHARS=()

bacon_promptc() {
    local color
    while bacon_has_map BACON_COLOR "$1"; do
        color+="${BACON_COLOR[$1]}"; shift
    done
    color="${color:-${BACON_COLOR[default]}}"
    local IFS=' '
    printf '\[%s\]%s\[\033[00m\]\n' "$color" "$*"
}

bacon_prompt_last_status() {
    local color="${BACON_PROMPT_COLOR[last_fail]:-red}"
    [[ $LAST_STATUS -eq 0 ]] && color="${BACON_PROMPT_COLOR[last_ok]:-green}"
    bacon_promptc "$color" "${BACON_PROMPT_CHARS[last_status]:-&}"
}

bacon_prompt_time() {
    bacon_promptc "${BACON_PROMPT_COLOR[time]:-green}" "${BACON_PROMPT_CHARS[time]:-[\A]}"
}

bacon_prompt_location() {
    bacon_promptc "${BACON_PROMPT_COLOR[location]:-blue}" "${BACON_PROMPT_CHARS[location]:-[\u@\h:\W]}"
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

bacon_prompt_dollar() {
    bacon_promptc "${BACON_PROMPT_COLOR[dollar]:-blue}" "${BACON_PROMPT_CHARS[dollar]:-\$ }"
}

bacon_prompt_ps1() {
    local ps1 layout
    for layout in "${BACON_PROMPT_PS1_LAYOUT[@]}"; do
        bacon_definedf "$layout" && ps1+="$($layout)"
    done
    ps1+="$(bacon_prompt_dollar)"
    echo "$ps1"
}

# vim:set ft=sh ts=4 sw=4:
