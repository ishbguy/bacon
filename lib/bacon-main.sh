# Copyright (c) 2019 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# check whether it's an interative shell or return
[[ $- == *i* ]] || return 0

export BACON_MAIN_ABS_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
export BACON_MAIN_ABS_DIR="$(dirname "$BACON_MAIN_ABS_SRC")"

bacon_init() {
    local BACON_LIB_DIR=("$BACON_MAIN_ABS_DIR")
    for c in "$@"; do
        bacon_load "$c" || true
    done
}

bacon_load_module() {
    for d in "$@"; do
        [[ -d $d ]] || continue
        local BACON_LIB_DIR=("$d")
        for m in "$d"/*.sh; do
            local mod="${m##*/}"; mod="${mod%.sh}"
            bacon_module_start "$m"
            bacon_load "$mod"
            bacon_module_end
        done
    done
}

bacon_configure_defaults() {
    declare -ga BACON_MOD_BUILTIN_DIR=("$BACON_MAIN_ABS_DIR/../configs")
    declare -ga BACON_MOD_USER_DIR=("$HOME/.bacon" "$HOME/.bash-configs")
    BACON_LIB_DIR=("$BACON_MAIN_ABS_DIR")
    BACON_PRECMDS=('export LAST_STATUS=$?' 'bacon_prompt_PS1')
    BACON_PROMPT_PS1_LAYOUT=(
        bacon_prompt_last_status
        bacon_prompt_time
        bacon_prompt_location
        bacon_prompt_counter
    )
    BACON_PROMPT_COUNTERS+=('dirs -p | tail -n +2 | wc -l')
    BACON_PROMPT_COUNTERS+=('jobs -p | wc -l')
    BACON_NO_ENSURE=yes
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
