# Copyright (c) 2019 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# check whether it's an interative shell or return
[[ $- == *i* ]] || return 0

export BACON_MAIN_ABS_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
export BACON_MAIN_ABS_DIR="$(dirname "$BACON_MAIN_ABS_SRC")"

bacon_init() {
    local BACON_LIB_DIR=("$BACON_MAIN_ABS_DIR")
    for c in "$@"; do
        bacon_load "${c}.sh" || true
    done
}

bacon_configure_defaults() {
    # Configurations for bacon-utils
    BACON_LIB_DIR=("$BACON_MAIN_ABS_DIR")
    BACON_NO_ENSURE="${BACON_NO_ENSURE:-yes}"
    BACON_DEBUG="${BACON_DEBUG:-}"

    # Configurations for bacon-module
    declare -ga BACON_MOD_BUILTIN_DIR=("$BACON_MAIN_ABS_DIR/../configs")
    declare -ga BACON_MOD_USER_DIR=("$HOME/.bacon" "$HOME/.bash-configs")
    BACON_CAP_OFF="${BACON_CAP_OFF:-yes}"

    # Configurations for bacon-precmd
    PROMPT_COMMAND=bacon_precmd
    BACON_PRECMDS=('export LAST_STATUS=$?' 'export PS1="$(bacon_prompt_ps1)"')

    # Configurations for bacon-prompt
    BACON_PROMPT_PS1_LAYOUT=(
        bacon_prompt_last_status
        bacon_prompt_time
        bacon_prompt_location
        bacon_prompt_counter
    )
    BACON_PROMPT_COUNTERS+=('dirs -p | tail -n +2 | wc -l')
    BACON_PROMPT_COUNTERS+=('jobs -p | wc -l')
    export PS4='+ $(basename ${0##+(-)}) line $LINENO: '
}

bacon_main() {
    bacon_require_cmd sed awk diff
    bacon_init 'bacon-module' 'bacon-precmd' 'bacon-prompt'
    bacon_configure_defaults
    bacon_load_module "${BACON_MOD_BUILTIN_DIR[@]}"
    bacon_load_module "${BACON_MOD_USER_DIR[@]}"
}

# shellcheck disable=SC1090
# We must source bacon-utils.sh first for all tools it provide
source "$BACON_MAIN_ABS_DIR/bacon-utils.sh" && bacon_main || return 1

# vim:set ft=sh ts=4 sw=4:
