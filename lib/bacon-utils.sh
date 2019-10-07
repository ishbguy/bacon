#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# shellcheck disable=SC2155
export BACON_UTILS_ABS_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
export BACON_UTILS_ABS_DIR="$(dirname "$BACON_UTILS_ABS_SRC")"

# ANSI 8 colors
declare -gA BACON_ANSI_COLOR
BACON_ANSI_COLOR[black]=30
BACON_ANSI_COLOR[red]=31
BACON_ANSI_COLOR[green]=32
BACON_ANSI_COLOR[yellow]=33
BACON_ANSI_COLOR[blue]=34
BACON_ANSI_COLOR[magenta]=35
BACON_ANSI_COLOR[cyan]=36
BACON_ANSI_COLOR[white]=37
BACON_ANSI_COLOR[default]=39

BACON_ANSI_COLOR[bg_black]=40
BACON_ANSI_COLOR[bg_red]=41
BACON_ANSI_COLOR[bg_green]=42
BACON_ANSI_COLOR[bg_yellow]=43
BACON_ANSI_COLOR[bg_blue]=44
BACON_ANSI_COLOR[bg_magenta]=45
BACON_ANSI_COLOR[bg_cyan]=46
BACON_ANSI_COLOR[bg_white]=47
BACON_ANSI_COLOR[bg_default]=49

# ANSI color set
BACON_ANSI_COLOR[bold]=1
BACON_ANSI_COLOR[dim]=2
BACON_ANSI_COLOR[underline]=4
BACON_ANSI_COLOR[blink]=5
BACON_ANSI_COLOR[invert]=7
BACON_ANSI_COLOR[hidden]=8

# ANSI color reset
BACON_ANSI_COLOR[reset]=0
BACON_ANSI_COLOR[reset_bold]=21
BACON_ANSI_COLOR[reset_dim]=22
BACON_ANSI_COLOR[reset_underline]=24
BACON_ANSI_COLOR[reset_blink]=25
BACON_ANSI_COLOR[reset_invert]=27
BACON_ANSI_COLOR[reset_hidden]=28

bacon_has_map() {
    local -n map="$1"; shift
    [[ -n $1 && -n ${map[$1]} ]]
}

bacon_set_color() {
    local color="${BACON_ANSI_COLOR[default]}"
    bacon_has_map BACON_ANSI_COLOR "$1" && color="${BACON_ANSI_COLOR[$1]}"
    printf '\x1B[%sm' "$(bacon_has_map BACON_ANSI_COLOR "$2" &&
        echo "$color;${BACON_ANSI_COLOR[$2]}" || echo "$color")"
}

bacon_printc() {
    local color=default
    local format
    if bacon_has_map BACON_ANSI_COLOR "$1"; then
        color="$1"; shift
        if bacon_has_map BACON_ANSI_COLOR "$1"; then
            format="$1"; shift
        fi
    fi
    local IFS=' '
    printf "%s%s%s\n" "$(bacon_set_color "$color" "$format")" "$*" "$(bacon_set_color reset)"
}

bacon_puts() {
    local IFS=' '
    printf "%s\n" "$*"
}

bacon_debug() {
    local IFS=' '
    [[ -z $BACON_DEBUG ]] || bacon_puts "DEBUG: $*"
}

bacon_msg() {
    bacon_printc yellow "$@" >&2
}

bacon_warn() {
    bacon_printc red "$@" >&2
    return 1
}

bacon_die() {
    bacon_printc red "$@" >&2
    exit 1
}

bacon_defined() {
    # [[ -v $1 ]]
    declare -p "$1" &>/dev/null
}

bacon_definedf() {
    declare -f "$1" &>/dev/null
}

bacon_typeof() {
    # shellcheck disable=SC2034
    if ! bacon_defined BACON_TYPE; then
        declare -gA BACON_TYPE=()
        BACON_TYPE[-]="normal"
        BACON_TYPE[a]="array"
        BACON_TYPE[A]="map"
        BACON_TYPE[i]="integer"
        BACON_TYPE[l]="lower"
        BACON_TYPE[u]="upper"
        BACON_TYPE[n]="reference"
        BACON_TYPE[x]="export"
        BACON_TYPE[f]="function"
        # BACON_TYPE[r]="readonly"
        # BACON_TYPE[g]="global"
    fi
    [[ $# == 1 && -n $1 ]] || return 1
    if declare -p "$1" &>/dev/null; then
        local IFS=' '
        # shellcheck disable=SC2207
        local -a out=($(declare -p "$1"))
        local type="${out[1]}"
        [[ $type =~ -([-aAilunx]) ]]
        echo "${BACON_TYPE[${BASH_REMATCH[1]}]}"
    elif declare -F "$1" &>/dev/null; then
        echo "function"
    elif type -t "$1" &>/dev/null; then
        type -t "$1"
    else
        return 1
    fi
    return 0
}

bacon_is_sourced() {
    [[ -n ${FUNCNAME[1]} && ${FUNCNAME[1]} != "main" ]]
}

bacon_is_array() {
    mapfile -td ' ' def <<<"$(declare -p "$1" 2>/dev/null)"
    [[ ${def[1]} =~ a ]]
}

bacon_is_map() {
    mapfile -td ' ' def <<<"$(declare -p "$1" 2>/dev/null)"
    [[ ${def[1]} =~ A ]]
}

bacon_has_cmd() {
    command -v "$1" &>/dev/null
}

bacon_is_exist() {
    [[ -e $1 ]] &>/dev/null
}

bacon_ensure() {
    #  shellcheck disable=SC2015
    [[ -z $BACON_NO_ENSURE ]] || return 0
    local cmd="$1"; shift
    local IFS=' '
    # shellcheck disable=SC2207
    local -a info=($(caller 0))
    local info_str="${info[2]}:${info[0]}:${info[1]}"
    if ! (eval "$cmd" &>/dev/null); then
        bacon_die "$info_str: ${FUNCNAME[0]} '$cmd' failed." "$@"
    fi
}

bacon_date_cmp() {
    echo "$(($(date -d "$1" +%s) - $(date -d "$2" +%s)))"
}

bacon_pargs() {
    bacon_ensure "[[ $# -ge 3 ]]" "Need OPTIONS, ARGUMENTS and OPTSTRING"
    bacon_ensure "[[ -n $1 && -n $2 && -n $3 ]]" "Args should not be empty."
    bacon_ensure "bacon_is_map $1 && bacon_is_map $2" "OPTIONS and ARGUMENTS should be map."

    local -n __opt="$1"
    local -n __arg="$2"
    local optstr="$3"
    shift 3

    OPTIND=1
    while getopts "$optstr" opt; do
        [[ $opt == ":" || $opt == "?" ]] && bacon_die "$HELP"
        # shellcheck disable=SC2034
        __opt[$opt]=1
        # shellcheck disable=SC2034
        __arg[$opt]="$OPTARG"
    done
    shift $((OPTIND - 1))
}

bacon_require_base() {
    bacon_ensure "[[ $# -gt 2 ]]" "Not enough args."
    bacon_ensure "bacon_definedf $1" "$1 should be a bacon_defined func."

    local -a miss
    local cmd="$1"
    local msg="$2"
    shift 2
    for obj in "$@"; do
        "$cmd" "$obj" || miss+=("$obj")
    done
    [[ ${#miss[@]} -eq 0 ]] || bacon_die "$msg: ${miss[*]}."
}

bacon_require_var() {
    bacon_require_base bacon_defined "You need to define vars" "$@"
}

bacon_require_func() {
    bacon_require_base bacon_definedf "You need to define funcs" "$@"
}

bacon_require_cmd() {
    bacon_require_base bacon_has_cmd "You need to install cmds" "$@"
}

bacon_require() {
    bacon_require_base bacon_is_exist "No such files or dirs" "$@"
}

bacon_abs_path() {
    readlink -f "$1"
}

bacon_self() {
    bacon_abs_path "${BASH_SOURCE[1]}"
}

bacon_lib() {
    bacon_abs_path "${BASH_SOURCE[0]%/*}"
}

bacon_load() {
    # shellcheck disable=SC2155
    [[ -n $BACON_LIB_PATH ]] || export BACON_LIB_PATH="$(bacon_lib)"
    # shellcheck disable=SC2155
    [[ $BACON_LIB_PATH =~ $(bacon_lib) ]] || export BACON_LIB_PATH="$(bacon_lib):$BACON_LIB_PATH"
    bacon_defined BACON_LOADED || declare -gA BACON_LOADED=()

    [[ $# == 1 && -n $1 ]] || return 1

    local lib="$1"
    while read -r -d ':' dir; do
        # shellcheck disable=SC1090
        if [[ -f $dir/$lib.sh ]]; then
            if ! bacon_has_map BACON_LOADED "$lib"; then
                # shellcheck disable=SC1090,SC2034
                source "$dir/$lib.sh" && BACON_LOADED[$lib]="$dir/$lib.sh"
                return 0
            fi
        fi
    done <<<"$BACON_LIB_PATH:"
    return 1
}

bacon_export() {
    [[ $# == 1 && -n $1 ]] || return 1
    local -u ns="$1"
    local src="$(bacon_abs_path "${BASH_SOURCE[1]}")"
    local dir="$(dirname "$src")"
    
    eval "export BACON_EXPORT_${ns}_ABS_SRC=$src"
    eval "export BACON_EXPORT_${ns}_ABS_DIR=$dir"
}

# vim:set ft=sh ts=4 sw=4:
