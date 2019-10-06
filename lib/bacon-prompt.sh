# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BACON_PROMPT_ABS_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
export BACON_PROMPT_ABS_DIR="$(dirname "$BACON_PROMPT_ABS_SRC")"

# declare -p BACON_PRECMDS &>/dev/null || return 1
# declare -p BACON_ANSI_COLOR &>/dev/null || return 1

declare -ga BACON_PROMPT_PS1_LAYOUT=()
declare -ga BACON_PROMPT_COUNTERS=()
declare -gA BACON_PROMPT_COLOR=()
declare -gA BACON_PROMPT_CHARS=()

bacon_prompt_color() {
    local color="${BACON_ANSI_COLOR[default]}"
    if bacon_has_map BACON_ANSI_COLOR "$1"; then
        color="${BACON_ANSI_COLOR[$1]}"; shift;
        bacon_has_map BACON_ANSI_COLOR "$1" \
            && { color="$color;${BACON_ANSI_COLOR[$1]}"; shift; }
    fi
    color="\\[\\033[${color}m\\]"
    printf '%s%s%s\n' "$color" "$*" '\[\033[00m\]'
}

bacon_prompt_last_status() {
    local color="${BACON_PROMPT_COLOR[last_fail]:-red}"
    [[ $LAST_STATUS -eq 0 ]] && color="${BACON_PROMPT_COLOR[last_ok]:-green}"
    bacon_prompt_color $color "${BACON_PROMPT_CHARS[last_status]:-&}"
}

bacon_prompt_time() {
    bacon_prompt_color ${BACON_PROMPT_COLOR[time]:-green} \
        "${BACON_PROMPT_CHARS[time]:-[\A]}"
}

bacon_prompt_location() {
    bacon_prompt_color ${BACON_PROMPT_COLOR[location]:-blue} \
        "${BACON_PROMPT_CHARS[location]:-[\u@\h:\W]}"
}

BACON_PROMPT_COUNTERS+=('dirs -p | tail -n +2 | wc -l')
BACON_PROMPT_COUNTERS+=('jobs -p | wc -l')
bacon_prompt_counter() {
    local -A counters
    local str=''
    for cnt in "${BACON_PROMPT_COUNTERS[@]}"; do
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
    [[ -n $str ]] && bacon_prompt_color ${BACON_PROMPT_COLOR[counter]:-yellow} "[$str]"
}

bacon_prompt_dollar() {
    bacon_prompt_color ${BACON_PROMPT_COLOR[dollar]:-blue} \
        "${BACON_PROMPT_CHARS[dollar]:-\$ }"
}

BACON_PROMPT_PS1_LAYOUT=(
    bacon_prompt_last_status
    bacon_prompt_time
    bacon_prompt_location
    bacon_prompt_counter
)
bacon_prompt_PS1() {
    PS1=
    for layout in "${BACON_PROMPT_PS1_LAYOUT[@]}"; do
        bacon_definedf "$layout" && PS1+="$($layout)"
    done
    PS1+="$(bacon_prompt_dollar)"
    export PS1
}

BACON_PRECMDS+=('bacon_prompt_PS1')

export PS4='+ $(basename ${0##+(-)}) line $LINENO: '

# vim:set ft=sh ts=4 sw=4:
