# Copyright (c) 2019 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# check whether it's an interative shell or return
[[ $- == *i* ]] || return 0

# shellcheck disable=SC2155
export BACON_MAIN_ABS_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
# shellcheck disable=SC2155
export BACON_MAIN_ABS_DIR="$(dirname "$BACON_MAIN_ABS_SRC")"

bacon_main() {
    bacon_export main

    declare -ga BACON_UNIT=(
        bacon-precmd
        bacon-prompt
    )
    bacon_load_unit "${BACON_UNIT[@]}"

    export BACON_BUILTIN_CONFIG_DIR="$BACON_MAIN_ABS_DIR/../configs"
    bacon_load_config "$BACON_BUILTIN_CONFIG_DIR"

    export BACON_CUSTOM_CONFIG_PATH="$HOME/.bacon:$HOME/.bash-configs"
    bacon_load_config "$HOME/.bacon" "$HOME/.bash-configs"
}

bacon_load_unit() {
    for unit in "$@"; do
        bacon_load "$unit" || true
    done
}

bacon_load_config() {
    for d in "$@"; do
        [[ -d $d ]] || continue
        for cfg in "$d"/*.sh; do
            # shellcheck disable=SC1090,SC2015
            [[ -f $cfg ]] && source "$cfg" || true
        done
    done
}

# shellcheck disable=SC1090
# We must source bacon-utils.sh first for all tools it provide
source "$BACON_MAIN_ABS_DIR/bacon-utils.sh" && bacon_main || return 1

# vim:set ft=sh ts=4 sw=4:
