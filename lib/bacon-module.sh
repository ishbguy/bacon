#!/usr/bin/env bash
# Copyright (c) 2019 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

bacon_export module

declare -g  BACON_CAP_OFF=''
declare -gA BACON_MODULE=()

bacon_cap_alias() {
    # alias -p | sed -r 's/=.*//g' | awk '{print $2}' | sort -d
    alias -p | awk 'BEGIN { PROCINFO["sorted_in"] = "@ind_str_asc" }
                    /^alias/ { gsub(/=.*/, "", $2); alias[$2]=1 }
                    END { for (k in alias) print k }'
}

bacon_cap_funcs() {
    # declare -F | awk '{print $3}' | sort -d
    declare -F | awk 'BEGIN { PROCINFO["sorted_in"] = "@ind_str_asc" }
                     /^declare/ { gsub(/=.*/, "", $3); funcs[$3]=1 }
                     END { for (k in funcs) print k }'
}

bacon_cap_vars() {
    # declare -p | grep -E '^declare' | sed -r 's/=.*//g' | awk '{print $3}' | sort -d
    declare -p | awk 'BEGIN { PROCINFO["sorted_in"] = "@ind_str_asc" }
                     /^declare/ { gsub(/=.*/, "", $3); vars[$3]=1 }
                     END { for (k in vars) print k }'
}

bacon_diff() {
    diff <(echo "$1") <(echo "$2") | awk '/^>/ {print $2}'
}

alias @start='bacon_cap_start'
bacon_cap_start() {
    [[ -z $BACON_CAP_OFF ]] || return 0
    declare -g BACON_MODULE_TMP=$1
    declare -g BACON_MODULE_TMP_ENCODE="$(basename "$BACON_MODULE_TMP" .sh | bacon_encode | bacon_toupper)"
    declare -g BEFORE_ALIAS="$(bacon_cap_alias)"
    declare -g BEFORE_FUNCS="$(bacon_cap_funcs)"
    declare -g BEFORE_VARS="$(bacon_cap_vars)"

    BACON_MODULE[$(basename "$BACON_MODULE_TMP" .sh)]="$BACON_MODULE_TMP_ENCODE"
}

alias @end='bacon_cap_end'
bacon_cap_end() {
    [[ -z $BACON_CAP_OFF ]] || return 0
    set -- "$BEFORE_VARS"
    unset BEFORE_VARS
    declare -g AFTER_VARS="$(bacon_cap_vars)"
    declare -g AFTER_FUNCS="$(bacon_cap_funcs)"
    declare -g AFTER_ALIAS="$(bacon_cap_alias)"
    eval "declare -ga BACON_MODULE_${BACON_MODULE_TMP_ENCODE}_ALIAS=($(bacon_diff "$BEFORE_ALIAS" "$AFTER_ALIAS"))"
    eval "declare -ga BACON_MODULE_${BACON_MODULE_TMP_ENCODE}_FUNCS=($(bacon_diff "$BEFORE_FUNCS" "$AFTER_FUNCS"))"
    eval "declare -ga BACON_MODULE_${BACON_MODULE_TMP_ENCODE}_VARS=($(IFS=$'\n'; bacon_diff "$*" "$AFTER_VARS"))"
    unset BEFORE_ALIAS AFTER_ALIAS BEFORE_FUNCS AFTER_FUNCS BEFORE_VARS AFTER_VARS BACON_MODULE_TMP BACON_MODULE_TMP_ENCODE
}

bacon_load_module() {
    local d m
    for d in "$@"; do
        [[ -d $d ]] || continue
        local BACON_LIB_DIR=("$d")
        for m in "$d"/*.sh; do
            [[ -f $m ]] || continue
            local mod="${m##*/}"; mod="${mod%.sh}"
            bacon_cap_start "$mod"
            bacon_load "${m##*/}"
            bacon_cap_end
        done
        for m in "$d"/**/*.sh; do
            [[ -f $m ]] || continue
            local mod="${m##*/}"; mod="${mod%.sh}"
            local dir="$(dirname "$m")"; dir="${dir##*/}"
            # dir name must match mod name
            [[ "x$mod" == "x$dir" ]] || continue
            bacon_cap_start "$mod"
            bacon_load "$dir/$mod.sh"
            bacon_cap_end
            # update PATH
            [[ -d $d/$dir/bin ]] && export PATH="$PATH:$(bacon_abspath "$d/$dir/bin")" || true
        done
    done
}

# vim:set ft=sh ts=4 sw=4:
