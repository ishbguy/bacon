#!/usr/bin/env bash
# Copyright (c) 2019 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BACON_MODULE_ABS_SRC="$(bacon_abs_path "${BASH_SOURCE[0]}")"
export BACON_MODULE_ABS_DIR="$(dirname "$BACON_MODULE_ABS_SRC")"

declare -gA BACON_MODULE=()

bacon_encode_base() {
    basename "$1" .sh | sed -r 's/[^0-9a-zA-Z]/_/g' | tr '[:lower:]' '[:upper:]'
}

bacon_get_alias() {
    # alias -p | sed -r 's/=.*//g' | awk '{print $2}' | sort -d
    alias -p | awk 'BEGIN { PROCINFO["sorted_in"] = "@ind_str_asc" }
                    /^alias/ { gsub(/=.*/, "", $2); alias[$2]=1 }
                    END { for (k in alias) print k }'
}

bacon_get_funcs() {
    # declare -F | awk '{print $3}' | sort -d
    declare -F | awk 'BEGIN { PROCINFO["sorted_in"] = "@ind_str_asc" }
                     /^declare/ { gsub(/=.*/, "", $3); funcs[$3]=1 }
                     END { for (k in funcs) print k }'
}

bacon_get_vars() {
    # declare -p | grep -E '^declare' | sed -r 's/=.*//g' | awk '{print $3}' | sort -d
    declare -p | awk 'BEGIN { PROCINFO["sorted_in"] = "@ind_str_asc" }
                     /^declare/ { gsub(/=.*/, "", $3); vars[$3]=1 }
                     END { for (k in vars) print k }'
}

bacon_diff() {
    diff <(echo "$1") <(echo "$2") | awk '/^>/ {print $2}'
}

alias @start='bacon_module_start'
bacon_module_start() {
    declare -g BACON_MODULE_TMP=$1
    declare -g BACON_MODULE_TMP_ENCODE="$(bacon_encode_base "$BACON_MODULE_TMP")"
    declare -g BEFORE_ALIAS="$(bacon_get_alias)"
    declare -g BEFORE_FUNCS="$(bacon_get_funcs)"
    declare -g BEFORE_VARS="$(bacon_get_vars)"

    BACON_MODULE[$(basename "$BACON_MODULE_TMP" .sh)]="$BACON_MODULE_TMP_ENCODE"
    
}

alias @end='bacon_module_end'
bacon_module_end() {
    set -- "$BEFORE_VARS"
    unset BEFORE_VARS
    declare -g AFTER_VARS="$(bacon_get_vars)"
    declare -g AFTER_FUNCS="$(bacon_get_funcs)"
    declare -g AFTER_ALIAS="$(bacon_get_alias)"
    eval "declare -ga BACON_MODULE_${BACON_MODULE_TMP_ENCODE}_ALIAS=($(bacon_diff "$BEFORE_ALIAS" "$AFTER_ALIAS"))"
    eval "declare -ga BACON_MODULE_${BACON_MODULE_TMP_ENCODE}_FUNCS=($(bacon_diff "$BEFORE_FUNCS" "$AFTER_FUNCS"))"
    eval "declare -ga BACON_MODULE_${BACON_MODULE_TMP_ENCODE}_VARS=($(IFS=$'\n'; bacon_diff "$*" "$AFTER_VARS"))"
    unset BEFORE_ALIAS AFTER_ALIAS BEFORE_FUNCS AFTER_FUNCS BEFORE_VARS AFTER_VARS BACON_MODULE_TMP BACON_MODULE_TMP_ENCODE
}

# vim:set ft=sh ts=4 sw=4:
