#!/usr/bin/env bash
# Copyright (c) 2019 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

bacon_export async

declare -g  BACON_ASYNC_PPID="$BASHPID"
declare -g  BACON_ASYNC_MQ_FIFO="${BACON_ASYNC_MQ_FIFO:-}"
declare -g  BACON_ASYNC_MQ
declare -gA BACON_ASYNC_JQ=()
declare -gA BACON_ASYNC_JM=()
declare -gA BACON_ASYNC_RUN=()
declare -gA BACON_ASYNC_CALLBACK=()
declare -gA BACON_ASYNC_ANON_CALLBACK=()
declare -g  BACON_ASYNC_SIG="${BACON_ASYNC_SIG:-}"

_isempty() {
    ! read -t 0 -ru "$1" &>/dev/null
}

bacon_async_mq_init() {
    local tmpfd="$(bacon_tmpfd)"
    BACON_ASYNC_MQ_FIFO="${BACON_ASYNC_MQ_FIFO:-/tmp/bacon-async-mq-$RANDOM-$RANDOM-$RANDOM.fifo}"
    # ensure tmp fifo is available
    [[ -p $BACON_ASYNC_MQ_FIFO ]] || {
        rm -rf "${BACON_ASYNC_MQ_FIFO}" && mkfifo "$BACON_ASYNC_MQ_FIFO" 
    } || return 1
    # remove fifo and keep opened fd
    eval "exec $tmpfd<>$BACON_ASYNC_MQ_FIFO" && BACON_ASYNC_MQ="$tmpfd"
    rm -rf "${BACON_ASYNC_MQ_FIFO}"
}

bacon_async_add() {
    [[ $# == 2 || $# == 3 ]] && [[ -n $1 ]] || return 1
    local job run callback
    job="$1" run="$2" callback="$3"
    [[ -n $run ]] && BACON_ASYNC_RUN[$job]="$run"
    [[ -n $callback ]] && BACON_ASYNC_CALLBACK[$job]="$callback"
    return 0
}

bacon_async_del() {
    [[ $# == 1 ]] || return 1
    local jobs=()
    [[ $# == 0 ]] && jobs=("${!BACON_ASYNC_RUN[@]}") || jobs=("$@")
    for j in "${jobs[@]}"; do
        [[ -n $j && -n ${BACON_ASYNC_RUN[$j]} ]] && unset BACON_ASYNC_RUN["$j"]
        [[ -n $j && -n ${BACON_ASYNC_CALLBACK[$j]} ]] && unset BACON_ASYNC_CALLBACK["$j"]
    done
}

bacon_async_run() {
    [[ -n $BACON_ASYNC_MQ ]] || bacon_async_mq_init || return 1

    # parse options
    local HELP="Usage: ${FUNCNAME[0]} [-j|-c] [string] <cmds>"
    local -A opts=() args=()
    bacon_pargs opts args 'j:c:' "$@"
    shift $((OPTIND - 1))
    local cmd="$*"

    [[ -n ${args[j]} ]] || args[j]="J-$RANDOM-$RANDOM-$RANDOM"
    [[ -z ${BACON_ASYNC_JQ[${args[j]}]} && -z ${BACON_ASYNC_ANON_CALLBACK[${args[j]}]} ]] || return 0;
    [[ -n ${args[c]} && -z ${BACON_ASYNC_RUN[${args[j]}]} ]] && BACON_ASYNC_ANON_CALLBACK["${args[j]}"]="${args[c]}"

    { {
        local IFS=$'\n'
        output=($(eval "$cmd" 2>&1))
        IFS=' '
        eval 'echo "${BASHPID}:${output[*]}"' >&"$BACON_ASYNC_MQ"
        # remind parent shell that the job is finished
        if [[ -n $BACON_ASYNC_SIG ]] && bacon_is_running "$BACON_ASYNC_PPID"; then
            kill -"${BACON_ASYNC_SIG}" "$BACON_ASYNC_PPID";
        fi
    }& } &>/dev/null && BACON_ASYNC_JQ["${args[j]}"]="$!" && BACON_ASYNC_JM["$!"]="${args[j]}"

    # disown job if current shell is insteractive
    [[ $- != *i* ]] || disown $!
}

bacon_async_start() {
    [[ -n $BACON_ASYNC_MQ ]] || bacon_async_mq_init || return 1
    local jobs=()
    [[ $# == 0 ]] && jobs=("${!BACON_ASYNC_RUN[@]}") || jobs=("$@")
    for j in "${jobs[@]}"; do
        if [[ -n ${BACON_ASYNC_RUN[$j]} ]]; then
            bacon_async_run -j "$j" "${BACON_ASYNC_RUN[$j]}"
        fi
    done
}

bacon_async_stop() {
    local jobs=()
    [[ $# == 0 ]] && jobs=("${!BACON_ASYNC_JQ[@]}") || jobs=("$@")
    for j in "${jobs[@]}"; do
        if [[ -n ${BACON_ASYNC_JQ[$j]} ]] && bacon_is_running "${BACON_ASYNC_JQ[$j]}"; then
            kill -9 "${BACON_ASYNC_JQ[$j]}" && \
                unset BACON_ASYNC_JM["${BACON_ASYNC_JQ[$j]}"] && unset BACON_ASYNC_JQ["$j"]
        fi
    done
}

bacon_async_wait() {
    local pids=() runs=()
    [[ $# == 0 ]] && pids=("${BACON_ASYNC_JQ[@]}") || pids=("$@")
    for p in "${pids[@]}"; do
        [[ -n $p && $p =~ [0-9]+ ]] && bacon_is_running "$p" && runs+=("$p")
    done
    wait "${runs[@]}" || echo "Terminated by SIG$(kill -l $?) signal."
}

bacon_async_callback() {
    [[ $# -ge 1 && $1 =~ [0-9]+ ]] || return 1
    local pid input
    pid="$1"; shift; input="$*"
    if [[ -n ${BACON_ASYNC_JM[$pid]} && -n ${BACON_ASYNC_CALLBACK[${BACON_ASYNC_JM[$pid]}]} ]]; then
        eval "${BACON_ASYNC_CALLBACK[${BACON_ASYNC_JM[$pid]}]} '$input'"
    elif [[ -n ${BACON_ASYNC_JM[$pid]} && -n ${BACON_ASYNC_ANON_CALLBACK[${BACON_ASYNC_JM[$pid]}]} ]]; then
        # anonymous callback function
        eval "${BACON_ASYNC_ANON_CALLBACK[${BACON_ASYNC_JM[$pid]}]} '$input'"
        unset BACON_ASYNC_ANON_CALLBACK["${BACON_ASYNC_JM[$pid]}"]
    fi
}

bacon_async_reap() {
    [[ -n $BACON_ASYNC_MQ ]] || bacon_async_mq_init || return 1
    local msg pid output
    if ! _isempty "$BACON_ASYNC_MQ"; then
        read -ru "$BACON_ASYNC_MQ" msg
        pid="${msg%%:*}" output="${msg#*:}"
        if [[ -n $pid && -n ${BACON_ASYNC_JM[$pid]} ]]; then
            bacon_async_callback "$pid" "$output"
            unset BACON_ASYNC_JQ["${BACON_ASYNC_JM[$pid]}"] && unset BACON_ASYNC_JM["$pid"]
        fi
    fi
}

bacon_async_handler() {
    [[ -n $BACON_ASYNC_MQ ]] || bacon_async_mq_init || return 1
    if ! _isempty "$BACON_ASYNC_MQ"; then
        while ! _isempty "$BACON_ASYNC_MQ"; do bacon_async_reap; done
    else
        bacon_async_start "${!BACON_ASYNC_RUN[@]}"
    fi
}

bacon_async_trap() {
    if [[ -n $1 ]]; then
        if [[ -n $BACON_ASYNC_SIG ]]; then
            trap - "$BACON_ASYNC_SIG" || return 1
        fi
        trap bacon_async_handler "$1" && BACON_ASYNC_SIG="$1"
    else
        [[ -n $BACON_ASYNC_SIG ]] && trap - "$BACON_ASYNC_SIG" && BACON_ASYNC_SIG=""
    fi
}

# vim:set ft=sh ts=4 sw=4:
