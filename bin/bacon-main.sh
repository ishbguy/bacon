# Copyright (c) 2019 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# check whether it's an interative shell or return
[[ $- == *i* ]] || return 0

export BACON_MAIN_ABS_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
export BACON_MAIN_ABS_DIR="$(dirname "$BACON_MAIN_ABS_SRC")"
export BACON_CORE_ABS_DIR="$(readlink -f "$BACON_MAIN_ABS_DIR/../lib")"

bacon_init() {
    local BACON_LIB_DIR=("$BACON_CORE_ABS_DIR")
    local c
    for c in "$@"; do
        bacon_load "${c}.sh" || true
    done
}
jobs_count() { echo "$BACON_JOBS"; }
export_ps1() { export PS1="$*"; }
bacon_prompt() {
    case $BACON_PROMPT_TYPE in
        normal) export PS1="$(bacon_prompt_ps1)" ;;
        async)  bacon_async_run -c export_ps1 bacon_prompt_ps1 ;;
        *)      export PS1='[\A][\u@\h:\W]\$ ';;
    esac
}

bacon_configure_defaults() {
    # for bacon-utils
    BACON_LIB_DIR=("$BACON_CORE_ABS_DIR")
    BACON_NO_ENSURE="${BACON_NO_ENSURE:-yes}"
    BACON_DEBUG="${BACON_DEBUG:-}"

    # for bacon-module
    declare -ga BACON_MOD_BUILTIN_DIR=("$BACON_MAIN_ABS_DIR/../conf.d")
    declare -ga BACON_MOD_USER_DIR=("$HOME/.bacon" "$HOME/.bash-configs")
    BACON_CAP_OFF="${BACON_CAP_OFF:-yes}"

    # for bacon-async
    bacon_async_trap SIGUSR2

    # for bacon-precmd
    PROMPT_COMMAND=bacon_precmd
    BACON_PRECMD+=('export LAST_STATUS=$?')
    BACON_PRECMD+=('export BACON_JOBS="$(jobs -p | wc -l)"')
    BACON_PRECMD+=('bacon_prompt')

    # for bacon-prompt
    BACON_PROMPT_TYPE=normal
    BACON_PROMPT_INFO[status]='#([[ $LAST_STATUS -eq 0 ]] && echo "#[green]" || echo "#[red]")&'
    BACON_PROMPT_COLOR[status]='default'
    BACON_PROMPT_INFO[time]='[\A]'
    BACON_PROMPT_COLOR[time]='green'
    BACON_PROMPT_INFO[location]='[\u@\h:\W]'
    BACON_PROMPT_COLOR[location]='blue'
    BACON_PROMPT_INFO[counters]='#(bacon_prompt_counter)'
    BACON_PROMPT_COLOR[counters]='yellow'
    BACON_PROMPT_INFO[umark]='\$'
    BACON_PROMPT_COLOR[umark]='blue'
    BACON_PROMPT_INFO[space]=' '
    BACON_PROMPT_COLOR[space]='default'
    BACON_PROMPT_INFO[newline]='\n'
    BACON_PROMPT_COLOR[newline]='default'
    BACON_PROMPT_FORMAT='#{status}#{time}#{location}#{counters}#{umark}#{space}'
    BACON_PROMPT_COUNTERS+=('dirs -p | tail -n +2 | wc -l')
    BACON_PROMPT_COUNTERS+=('jobs_count')
    export PS4='+ $(basename ${0##+(-)}) line $LINENO: '
}

bacon_main() {
    bacon_require_cmd sed awk diff
    bacon_init 'bacon-async' 'bacon-module' 'bacon-precmd' 'bacon-prompt'
    bacon_configure_defaults
    bacon_load_module "${BACON_MOD_BUILTIN_DIR[@]}"
    bacon_load_module "${BACON_MOD_USER_DIR[@]}"
}

# shellcheck disable=SC1090
# We must source bacon-utils.sh first for all tools it provide
source "$BACON_CORE_ABS_DIR/bacon-utils.sh" && bacon_main || return 1

# vim:set ft=sh ts=4 sw=4:
