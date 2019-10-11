# Copyright (c) 2019 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# check whether it's an interative shell or return
[[ $- == *i* ]] || return 0

# shellcheck disable=SC2155
export BACON_MAIN_ABS_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
# shellcheck disable=SC2155
export BACON_MAIN_ABS_DIR="$(dirname "$BACON_MAIN_ABS_SRC")"

bacon_load_unit() {
    for unit in "$@"; do
        bacon_load "$unit" || true
    done
}

bacon_load_mod() {
    for d in "$@"; do
        [[ -d $d ]] || continue
        for m in "$d"/*.sh; do
            # shellcheck disable=SC1090,SC2015
            [[ -f $m ]] && source "$m" || true
        done
    done
}

bacon_main_prelude() {
    declare -ga BACON_UNIT=("bacon-precmd" "bacon-prompt")
    declare -ga BACON_LIB_DIR=("$BACON_MAIN_ABS_DIR")
    declare -ga BACON_MOD_BUILTIN_DIR=("$BACON_MAIN_ABS_DIR/../configs")
    declare -ga BACON_MOD_USER_DIR=("$HOME/.bacon" "$HOME/.bash-configs")
}

bacon_main() {
    bacon_export main
    bacon_main_prelude
    bacon_load_unit "${BACON_UNIT[@]}"
    bacon_load_mod "${BACON_MOD_BUILTIN_DIR[@]}"
    bacon_load_mod "${BACON_MOD_USER_DIR[@]}"
}

# shellcheck disable=SC1090
# We must source bacon-utils.sh first for all tools it provide
source "$BACON_MAIN_ABS_DIR/bacon-utils.sh" && bacon_main || return 1

# vim:set ft=sh ts=4 sw=4:
