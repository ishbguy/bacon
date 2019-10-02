#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BASH_UTILS_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASH_UTILS_ABS_DIR="$(dirname "$BASH_UTILS_ABS_SRC")"

# ANSI 8 colors
declare -gA BASH_ANSI_COLOR
BASH_ANSI_COLOR[black]=30
BASH_ANSI_COLOR[red]=31
BASH_ANSI_COLOR[green]=32
BASH_ANSI_COLOR[yellow]=33
BASH_ANSI_COLOR[blue]=34
BASH_ANSI_COLOR[magenta]=35
BASH_ANSI_COLOR[cyan]=36
BASH_ANSI_COLOR[white]=37
BASH_ANSI_COLOR[default]=39

BASH_ANSI_COLOR[bg_black]=40
BASH_ANSI_COLOR[bg_red]=41
BASH_ANSI_COLOR[bg_green]=42
BASH_ANSI_COLOR[bg_yellow]=43
BASH_ANSI_COLOR[bg_blue]=44
BASH_ANSI_COLOR[bg_magenta]=45
BASH_ANSI_COLOR[bg_cyan]=46
BASH_ANSI_COLOR[bg_white]=47
BASH_ANSI_COLOR[bg_default]=49

# ANSI color set
BASH_ANSI_COLOR[bold]=1
BASH_ANSI_COLOR[dim]=2
BASH_ANSI_COLOR[underline]=4
BASH_ANSI_COLOR[blink]=5
BASH_ANSI_COLOR[invert]=7
BASH_ANSI_COLOR[hidden]=8

# ANSI color reset
BASH_ANSI_COLOR[reset]=0
BASH_ANSI_COLOR[reset_bold]=21
BASH_ANSI_COLOR[reset_dim]=22
BASH_ANSI_COLOR[reset_underline]=24
BASH_ANSI_COLOR[reset_blink]=25
BASH_ANSI_COLOR[reset_invert]=27
BASH_ANSI_COLOR[reset_hidden]=28

has_map() {
    local -n map="$1"
    shift
    [[ -n $1 && -n ${map[$1]} ]]
}

set_color() {
    local color="${BASH_ANSI_COLOR[default]}"
    has_map BASH_ANSI_COLOR "$1" && color="${BASH_ANSI_COLOR[$1]}"
    printf '\x1B[%sm' "$(has_map BASH_ANSI_COLOR "$2" &&
        echo "$color;${BASH_ANSI_COLOR[$2]}" || echo "$color")"
}

color_echo() {
    local color=default
    local format
    if has_map BASH_ANSI_COLOR "$1"; then
        color="$1"
        shift
        has_map BASH_ANSI_COLOR "$1" && {
            format="$1"
            shift
        }
    fi
    set_color "$color" "$format"
    echo -ne "$@"
    set_color reset
    echo
}

msg() {
    color_echo yellow "$@" >&2
}

warn() {
    color_echo red "$@" >&2
    return 1
}

die() {
    color_echo red "$@" >&2
    exit 1
}

defined() {
    [[ -v $1 ]]
}

definedf() {
    declare -f "$1" &>/dev/null
}

is_sourced() {
    [[ -n ${FUNCNAME[1]} && ${FUNCNAME[1]} != "main" ]]
}

is_array() {
    mapfile -td ' ' def <<<"$(declare -p "$1" 2>/dev/null)"
    [[ ${def[1]} =~ a ]]
}

is_map() {
    mapfile -td ' ' def <<<"$(declare -p "$1" 2>/dev/null)"
    [[ ${def[1]} =~ A ]]
}

has_tool() {
    command -v "$1" &>/dev/null
}

ensure() {
    local cmd="$1"
    shift
    local -a info=($(caller 0))
    local info_str="${info[2]}:${info[0]}:${info[1]}"
    if ! (eval "$cmd" &>/dev/null); then
        die "$info_str: ${FUNCNAME[0]} '$cmd' failed." "$@"
    fi
}

date_cmp() {
    echo "$(($(date -d "$1" +%s) - $(date -d "$2" +%s)))"
}

pargs() {
    ensure "[[ $# -ge 3 ]]" "Need OPTIONS, ARGUMENTS and OPTSTRING"
    ensure "[[ -n $1 && -n $2 && -n $3 ]]" "Args should not be empty."
    ensure "is_map $1 && is_map $2" "OPTIONS and ARGUMENTS should be map."

    local -n __opt="$1"
    local -n __arg="$2"
    local optstr="$3"
    shift 3

    OPTIND=1
    while getopts "$optstr" opt; do
        [[ $opt == ":" || $opt == "?" ]] && die "$HELP"
        __opt[$opt]=1
        __arg[$opt]="$OPTARG"
    done
    shift $((OPTIND - 1))
}

chkobj() {
    ensure "[[ $# -gt 2 ]]" "Not enough args."
    ensure "definedf $1" "$1 should be a defined func."

    local -a miss
    local cmd="$1"
    local msg="$2"
    shift 2
    for obj in "$@"; do
        "$cmd" "$obj" || miss+=("$obj")
    done
    [[ ${#miss[@]} -eq 0 ]] || die "$msg: ${miss[*]}."
}

chkvar() {
    chkobj defined "You need to define vars" "$@"
}

chkfunc() {
    chkobj definedf "You need to define funcs" "$@"
}

chktool() {
    chkobj has_tool "You need to install tools" "$@"
}

# vim:set ft=sh ts=4 sw=4:
