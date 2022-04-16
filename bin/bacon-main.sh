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
export_ps1() { export PS1="$*" && unset ps1_running ; }
bacon_prompt() {
    case $BACON_PROMPT_TYPE in
        normal) export PS1="$(bacon_prompt_ps1)" ;;
        async) [[ -n $ps1_running ]] && return || {
            bacon_async_run -c export_ps1 bacon_prompt_ps1
            export ps1_running=true
        } ;;
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
    BACON_PROMPT_THEME_DIR=("$BACON_MAIN_ABS_DIR/../themes" "$HOME/.bacon/themes")
    BACON_PROMPT_TYPE=normal
    BACON_PROMPT_FORMAT='[\A][\u@\h:\W]\$ '
    BACON_PROMPT_THEME=default
    bacon_prompt_set_theme "$BACON_PROMPT_THEME"
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
