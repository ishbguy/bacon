#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BACON_UTILS_ABS_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
export BACON_UTILS_ABS_DIR="$(dirname "$BACON_UTILS_ABS_SRC")"

# global variable interfaces
declare -g  BACON_NO_ENSURE=""
declare -g  BACON_DEBUG=""
declare -ga BACON_LIB_DIR=()
declare -gA BACON_COLOR=()

bacon_has_map() {
    local -n map="$1"; shift
    [[ -n $1 && -n ${map[$1]} ]]
}

# bacon_color_init [ --setaf | --setab | --misc  ] var
# Assigns the selected set of escape mappings to the given associative array names.
bacon_color_init() {
    local -a fg_clrs bg_clrs msc
    fg_clrs=(black red green yellow blue magenta cyan grey darkgrey ltred ltgreen ltyellow ltblue ltmagenta ltcyan white)
    bg_clrs=($(IFS=,; eval "echo bg_{${fg_clrs[*]}}"))
    msc=(sgr0 bold dim smul blink rev invis)
    while ! ${2:+false}; do
        case ${1#--} in
            setaf)
                for x in "${!fg_clrs[@]}"; do
                    eval "$2"'[${fg_clrs[x]}]=$(tput "${1#--}" "$x")'
                done
                eval "$2[default]=[39m"
                ;;
            setab)
                for x in "${!bg_clrs[@]}"; do
                    eval "$2"'[${bg_clrs[x]}]=$(tput "${1#--}" "$x")'
                done
                eval "$2[bg_default]=[49m"
                ;;
            misc)
                for x in "${msc[@]}"; do
                    eval "$2"'[$x]=$(tput "$x")'
                done
                eval "$2[reset]=[0m"
                eval "$2[none]=[0m"
                ;;
            *)
                return 1
        esac
        shift 2
    done
}
bacon_color_init --setaf BACON_COLOR --setab BACON_COLOR --misc BACON_COLOR

bacon_set_color() {
    local color
    for c in "$@"; do
        bacon_has_map BACON_COLOR "$c" && color+="${BACON_COLOR[$c]}"
    done
    printf '%s' "$color"
}

bacon_printc() {
    local color=${BACON_COLOR[default]}
    if bacon_has_map BACON_COLOR "$1"; then
        color="${BACON_COLOR[$1]}"; shift
        if bacon_has_map BACON_COLOR "$1"; then
            color+="${BACON_COLOR[$1]}"; shift
        fi
    fi
    local IFS=' '
    printf "${color}%s${BACON_COLOR[reset]}\n" "$*"
}

bacon_puts() {
    local IFS=' '
    printf "%s\n" "$*"
}

bacon_debug() {
    [[ -z $BACON_DEBUG ]] || bacon_puts "[DEBUG]" "$@" >&2
}

bacon_info() {
    bacon_printc yellow  "[INFO]" "$@" >&2
}

bacon_warn() {
    bacon_printc red "[WARN]" "$@" >&2
    return 1
}

bacon_die() {
    bacon_printc red "[ERROR]" "$@" >&2
    exit 1
}

bacon_defined() {
    local usage="Usage: ${FUNCNAME[0]} <var-name>"
    bacon_ensure "[[ $# == 1 && -n $1 ]]" "$usage"
    declare -p "$1" &>/dev/null
}

bacon_definedf() {
    local usage="Usage: ${FUNCNAME[0]} <func-name>"
    bacon_ensure "[[ $# == 1 && -n $1 ]]" "$usage"
    declare -f "$1" &>/dev/null
}

bacon_typeof() {
    local usage="Usage: ${FUNCNAME[0]} <string>"
    bacon_ensure "[[ $# == 1 && -n $1 ]]" "$usage"
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
    # [[ $# == 1 && -n $1 ]] || return 1
    if declare -p "$1" &>/dev/null; then
        local IFS=' '
        # shellcheck disable=SC2207
        local -a out=($(declare -p "$1"))
        local type="${out[1]}"
        [[ $type =~ -([-aAilunx]) ]]
        echo "${BACON_TYPE[${BASH_REMATCH[1]}]}"
    elif declare -F "$1" &>/dev/null; then
        echo "function"
        # check for alias, keyword, builtin and file|cmd
    elif type -t "$1" &>/dev/null; then
        type -t "$1"
    else
        return 1
    fi
    return 0
}

bacon_tmpfd() {
    basename <(:)
}

bacon_is_running() {
    ps -p "$1" &>/dev/null
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

bacon_datecmp() {
    echo "$(($(date -d "$1" +%s) - $(date -d "$2" +%s)))"
}

bacon_encode() {
    if [[ $# == 0 ]]; then
        sed -r 's/[^[:alnum:]]/_/g'
    else
        local IFS=' '
        echo "${*//[^[:alnum:]]/_}"
    fi
}

bacon_tolower() {
    if [[ $# == 0 ]]; then
        tr '[:upper:]' '[:lower:]'
    else
        local IFS=' '
        echo "${*,,}"
    fi
}

bacon_toupper() {
    if [[ $# == 0 ]]; then
        tr '[:lower:]' '[:upper:]'
    else
        local IFS=' '
        echo "${*^^}"
    fi
}

bacon_pargs() {
    local usage="Usage: ${FUNCNAME[0]} <opt-map> <arg-map> <optstring> [args...]"
    bacon_ensure "[[ $# -ge 3 ]]" "$usage"
    bacon_ensure "[[ -n $1 && -n $2 && -n $3 ]]" "$usage"
    bacon_ensure "bacon_is_map $1 && bacon_is_map $2" "$usage"

    local -n __opt="$1"
    local -n __arg="$2"
    local optstr="$3"
    shift 3

    OPTIND=1
    while getopts "$optstr" opt; do
        if [[ $opt == ":" || $opt == "?" ]]; then
            # the HELP must be initialized by caller
            bacon_warn "$HELP" || return 1
        fi
        # shellcheck disable=SC2034
        __opt[$opt]=1
        # shellcheck disable=SC2034
        __arg[$opt]="$OPTARG"
    done
}

bacon_popts() {
    local usage="Usage: ${FUNCNAME[0]} <opt-map> <arg-map> <remain-args-array> <optstr-map> [args...]"
    bacon_ensure "[[ $# -ge 4 ]]" "$usage"
    bacon_ensure "bacon_is_map $1 && bacon_is_map $2 && bacon_is_map $4" "$usage"
    bacon_ensure "bacon_is_array $3" "$usage"

    local -n __opts="$1"
    local -n __args="$2"
    local -n __rargs="$3"
    local -n __optstr="$4"
    shift 4
    local -a soa=() loa=()
    local -A som=() lom=()
    local sos los tmp m n

    # construct optstrings
    for o in "${!__optstr[@]}"; do
        if [[ $o =~ ^(:)?([a-zA-Z0-9]([^|]*)?)$ ]]; then
            n="${BASH_REMATCH[1]}"; m="${BASH_REMATCH[2]}"
            if [[ $m =~ ^[a-zA-Z0-9]$ ]]; then
                soa+=("$m$n"); som["$m"]="x$n"
            else
                loa+=("$m$n"); lom["$m"]="x$n"
            fi
        elif [[ $o =~ ^(:)?([a-zA-Z0-9])\|([a-zA-Z0-9].*)$ ]]; then
            soa+=("${BASH_REMATCH[2]}${BASH_REMATCH[1]}")
            som["${BASH_REMATCH[2]}"]="x${BASH_REMATCH[1]}"
            loa+=("${BASH_REMATCH[3]}${BASH_REMATCH[1]}")
            lom["${BASH_REMATCH[3]}"]="x${BASH_REMATCH[1]}"
        fi
    done
    sos="$(IFS= ; echo "${soa[*]}")"
    los="$(IFS=,; echo "${loa[*]}")"

    # parse options
    tmp="$(getopt -o "$sos" --long "$los" -- "$@")"
    [[ $? == 0 ]] || bacon_warn "getopt error..." || return 1
    # quote tmp for prevent eating empty string
    eval set -- "$tmp"
    while true; do
        if [[ $1 =~ ^--?([a-zA-Z].*)$ ]]; then
            if [[ -n "${som[${BASH_REMATCH[1]}]}" || -n "${lom[${BASH_REMATCH[1]}]}" ]]; then
                if [[ "${som[${BASH_REMATCH[1]}]}" != "x" && "${lom[${BASH_REMATCH[1]}]}" != "x" ]]; then
                    __opts[${BASH_REMATCH[1]}]=1
                    __args[${BASH_REMATCH[1]}]="$2"
                    shift 2; continue
                else
                    __opts[${BASH_REMATCH[1]}]=1
                    shift; continue
                fi
            fi
        elif [[ $1 == '--' ]]; then
            shift; break
        else
            bacon_warn "Internal error..." || return 1
        fi
    done
    __rargs=("$@")
}

bacon_require_base() {
    local usage="Usage: ${FUNCNAME[0]} <func> <msg> [args...]"
    bacon_ensure "[[ $# -gt 2 ]]" "$usage"
    bacon_ensure "bacon_definedf $1" "$usage"

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

bacon_abspath() {
    readlink -f "$1"
}

bacon_self() {
    bacon_abspath "${BASH_SOURCE[1]}"
}

bacon_lib() {
    bacon_abspath "${BASH_SOURCE[0]%/*}"
}

bacon_load() {
    local usage="Usage: ${FUNCNAME[0]} <filename>"
    bacon_ensure "[[ $# == 1 && -n $1 ]]" "$usage"

    # shellcheck disable=SC2155
    bacon_defined __BACON_LOADED_FILE || declare -gA __BACON_LOADED_FILE=()

    local dir
    for dir in "${BACON_LIB_DIR[@]}"; do
        # shellcheck disable=SC1090,SC2034
        if [[ -f $dir/$1 ]]; then
            if ! bacon_has_map __BACON_LOADED_FILE "$dir/$1"; then
                source "$dir/$1" && __BACON_LOADED_FILE["$dir/$1"]="$dir/$1"
                return 0
            fi
        fi
    done
    return 1
}

bacon_push() {
    local usage="Usage: ${FUNCNAME[0]} <array> [args..]"
    bacon_ensure "(($# >= 2))" "$usage"
    bacon_ensure "[[ $(bacon_typeof "$1") == array ]]" "$usage"

    local -n __array=$1; shift
    __array+=("$@")
}

bacon_pop() {
    local usage="Usage: ${FUNCNAME[0]} <array>"
    bacon_ensure "(($# == 1))" "$usage"
    bacon_ensure "[[ $(bacon_typeof "$1") == array ]]" "$usage"

    local -n __array=$1; shift
    local last=""
    [[ ${#__array[@]} == 0 ]] && return 1
    last="${__array[$((${#__array[@]}-1))]}"
    __array=("${__array[@]:0:$((${#__array[@]}-1))}")
    echo "$last"
}

bacon_unshift() {
    local usage="Usage: ${FUNCNAME[0]} <array> [args..]"
    bacon_ensure "(($# >= 2))" "$usage"
    bacon_ensure "[[ $(bacon_typeof "$1") == array ]]" "$usage"

    local -n __array=$1; shift
    __array=("$@" "${__array[@]}")
}

bacon_shift() {
    local usage="Usage: ${FUNCNAME[0]} <array>"
    bacon_ensure "(($# == 1))" "$usage"
    bacon_ensure "[[ $(bacon_typeof "$1") == array ]]" "$usage"

    local -n __array=$1; shift
    local last=""
    [[ ${#__array[@]} == 0 ]] && return 1
    last="${__array[0]}"
    __array=("${__array[@]:1}")
    echo "$last"
}

bacon_filter() {
    local usage="Usage: ${FUNCNAME[0]} <out-array> <pattern> <args...>"
    bacon_ensure "(($# >= 2))" "$usage"
    bacon_ensure "[[ $(bacon_typeof "$1") == array ]]" "$usage"

    local -n __array="$1"
    local p="$2"
    shift 2
    for arg in "$@"; do
        [[ $arg =~ $p ]] && __array+=("$arg") || true
    done
}

bacon_map() {
    local usage="Usage: ${FUNCNAME[0]} <out> <func> <args...>"
    bacon_ensure "(($# >= 2))" "$usage"
    bacon_ensure "[[ $(bacon_typeof "$1") == array ]]" "$usage"
    bacon_ensure "[[ $(bacon_typeof "$2") == function ]]" "$usage"

    local -n __array="$1"
    local func="$2"
    shift 2
    __array+=("$@")
    for i in "${__array[@]}"; do
        "$func" "__array[$i]"
    done
}

# alias @export='bacon_export || return 0'
bacon_export() {
    local src="$(bacon_abspath "${BASH_SOURCE[1]}")"
    local dir="$(dirname "$src")"
    local -u ns="${1:-$(basename "$src" .sh | bacon_encode)}"

    # source export guard
    # eval "[[ -z \$BACON_SOURCE_${ns}_ABS_SRC ]]" || return 1

    eval "export BACON_SOURCE_${ns}_ABS_SRC=$src"
    eval "export BACON_SOURCE_${ns}_ABS_DIR=$dir"
}

bacon_addprefix() {
    local usage="Usage: ${FUNCNAME[0]} <prefix> [args..]"
    bacon_ensure "(($# >=1 ))" "$usage"

    local p=$1; shift
    [[ $# == 0 ]] && return 0
    case $p in
        [\(\)]) p="\\$p" ;;
        [\<\>]) p="\\$p" ;;
        \") p='\"' ;;
        \') p="\\'" ;;
    esac
    local IFS=,
    if [[ $# == 1 ]]; then
        echo "${p}$1"
    else
        eval echo "${p}{$*}"
    fi
}

bacon_addsuffix() {
    local usage="Usage: ${FUNCNAME[0]} <suffix> [args..]"
    bacon_ensure "(($# >=1 ))" "$usage"

    local s=$1; shift
    [[ $# == 0 ]] && return 0
    case $s in
        [\(\)]) s="\\$s" ;;
        [\<\>]) s="\\$s" ;;
        \") s='\"' ;;
        \') s="\\'" ;;
    esac
    local IFS=,
    if [[ $# == 1 ]]; then
        echo "$1${s}"
    else
        eval echo "{$*}${s}"
    fi
}

bacon_wrap() {
    local usage="Usage: ${FUNCNAME[0]} <suffix> [args..]"
    bacon_ensure "(($# >=1 ))" "$usage"

    local w=$1; shift
    local w1 w2
    case $w in
        [\(\)]) w1='\('; w2='\)' ;;
        [\{\}]) w1='{'; w2='}' ;;
        [\[\]]) w1='['; w2=']' ;;
        [\<\>]) w1='\<'; w2='\>' ;;
        \") w1='\"'; w2='\"' ;;
        \') w1="\\'"; w2="\\'" ;;
        *) w1="$w"; w2="$w" ;;
    esac
    [[ $# == 0 ]] && return 0
    local IFS=,
    if [[ $# == 1 ]]; then
        echo "${w1}$1${w2}"
    else
        eval echo "${w1}{$*}${w2}"
    fi
}

# vim:set ft=sh ts=4 sw=4:
