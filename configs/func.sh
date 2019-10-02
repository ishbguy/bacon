#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BASH_CONFIGS_FUNC_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASH_CONFIGS_FUNC_ABS_DIR="$(dirname "$BASH_CONFIGS_FUNC_ABS_SRC")"

################################################################################
# shorthand-functions
################################################################################

#Rewrite the cd cmd which can show me the oldpwd->pwd info
cd() {
    builtin cd "$@"
    local es=$?
    [[ $es -eq 0 ]] && echo "$OLDPWD -> $PWD" >&2
    return $es
}

weather() { curl "http://wttr.in/$1"; }

#Man(): Read the manual by vim
Man() {
    [[ $# -gt 2 || $# -eq 0 ]] && { echo "Man [1-8] page"; return 1; }
    export ManFromShell=1
    vim -c "Man $*" -c "bw 1|set tabstop=8|retab"
    local rv=$?
    unset ManFromShell
    return $rv
}

#This function is used to backup
backup() {
    [[ $# -lt 2 ]] && { echo "backup bk-name bk-paths"; return 1; }
    local bk=$1; shift 
    tar jcvf "${BACKUP_DIR:-/samba}/${bk}-$(date +%Y%m%d).tar.bz2" "$@"
}

# A function quickly markdown something.
mark() {(
    HELP="
    Usage: mark [opt] [date]\n
    -d  date        Open or create a specified date mark file.\n
    -h              Print help message.\n
    "
    #Get current date time.
    Year=`date +%Y`
    Month=`date +%m`
    Day=`date +%d`

    [[ $# -gt 2 ]] && { echo -ne "Argument error.\n"; echo -ne $HELP; return 1; }

    #Atgument and parameter parsing

    OPTIND=1
    while getopts "d:h" OPTION; do
        case $OPTION in
            # Confirm that $OPTARG is a datetime number
            d)  [[ $OPTARG =~ ^[0-9]{8}$ ]] || \
                [[ $OPTARG =~ ^[0-9]{1,4}$ ]] || \
                { echo "$OPTARG invalid."; return 1; }

                # Strip prefix '0'
                while [[ $OPTARG =~ ^0+ ]]; do
                    [[ $OPTARG -eq 0 ]] && \
                        { echo "$OPTARG not a datetime."; return 1; }
                    OPTARG=${OPTARG/0/}
                done

                [[ $OPTARG -gt 10000 ]] && \
                    Year=$(($OPTARG / 10000)) && \
                    OPTARG=$(($OPTARG % 10000))
                [[ $OPTARG -gt 100 ]] && \
                    Month=$(($OPTARG / 100)) && \
                    [[ $Month -lt 10 ]] && \
                    Month="0$Month"
                Day=$(($OPTARG % 100)) && \
                    [[ $Day -lt 10 ]] && \
                    Day="0$Day"
                ;;
            h)  echo -ne $HELP && return 0 ;;
            ?)  echo -ne $HELP && return 2 ;;
        esac
    done

    Dir="$MARK_DIR/${Year}/${Month}"

    [[ -e $Dir ]] || mkdir -p $Dir && vim ${Dir}/$Year$Month$Day.md
)}

# A function quickly write a post
post()
{(
    HELP="
    Usage: post post-name\n
    "

    #Get current date time.
    year=`date +%Y`
    month=`date +%m`
    day=`date +%d`

    [[ $# -ne 1 ]] && { echo -ne "Argument error.\n"; echo -ne $HELP; return 1; }

    #Atgument and parameter parsing
    dir=$POST_DIR
    post_name=$1
    full_post_name=$year-$month-$day-$post_name.md

    [[ -e $dir ]] || mkdir -p $dir && vi $dir/$full_post_name
)}

# tagit: tag a file.
tagit() {(
    HELP="
    Usage: tagit [opt] [file]\n
    -a  tagname     Add a tag class.\n
    -d  tagname     Delete a tag from a file.\n
    -D  tagname     Delete a tag class.\n
    -t  tagname     Tag file with tagname.\n
    -T  tagname     Add a tag class and tag file with tagname.\n
    -l  tagname     List a tag class' files.\n
    -L  filename    List files tags.\n
    -n  tagname     Use with -l to lits tag class' file and numbers.\n
    -h              Print help message.\n
    "
    # OPTS' numbers
    BASE_NUM=0
    ADD_CLS=$((BASE_NUM++))
    DEL_TAG=$((BASE_NUM++))
    DEL_CLS=$((BASE_NUM++))
    ADD_TAG=$((BASE_NUM++))
    ADD_CLS_TAG=$((BASE_NUM++))
    LST_FLS=$((BASE_NUM++))
    LST_TAG=$((BASE_NUM++))
    NUM_FLS=$((BASE_NUM++))

    TAG_HOME=$TAG_DIR
    TAGS=()
    FILES=()
    LAST_OPT=$LST_TAG
    TAG_OPT=$LST_TAG
    TAG_CMD=(
    'mkdir -p $TAG_HOME/$TAG'
    'rm -rf $TAG_HOME/$TAG/$FILE_NAME'
    'rm -rf $TAG_HOME/$TAG'
    'ln -s $FULL_PATH_FILE $TAG_HOME/$TAG/$FILE_NAME'
    'mkdir -p $TAG_HOME/$TAG && ln -s $FULL_PATH_FILE $TAG_HOME/$TAG/$FILE_NAME'
    'echo $TAG && ls $TAG_HOME/$TAG'
    'TAG=`ls $TAG_HOME/*/$FILE_NAME` && TAG=`dirname $TAG` && basename -a $TAG'
    'NUM=(`ls $TAG_HOME/$TAG`) && echo $TAG ${#NUM[@]}'
    )

    OPTIND=1
    while getopts "a:d:D:t:T:l:n:Lh" OPTION; do
        case $OPTION in
            a)  TAG_OPT=$ADD_CLS ;;
            d)  TAG_OPT=$DEL_TAG ;;
            D)  TAG_OPT=$DEL_CLS ;;
            t)  TAG_OPT=$ADD_TAG ;;
            T)  TAG_OPT=$ADD_CLS_TAG ;;
            l)  TAG_OPT=$LST_FLS ;;
            L)  TAG_OPT=$LST_TAG ;;
            n)  TAG_OPT=$NUM_FLS ;;
            h)  echo -ne $HELP && return 0 ;;
            ?)  echo -ne $HELP && return 2 ;;
        esac

        # Return when encoutner different opts.
        if [[ $TAG_OPT -ne $LAST_OPT && $LAST_OPT -ne $LST_TAG ]]; then
            echo "Different options!"
            return 6
        fi
        TAGS+=($OPTARG)
        LAST_OPT=$TAG_OPT
    done

    # Number all tags' files if cmd without argument.
    if [[ $# -eq 0 ]]; then
        for TAG in `ls $TAG_HOME`; do
            eval "${TAG_CMD[$NUM_FLS]}"
        done
        return 0;
    fi

    shift $((OPTIND - 1))
    FILES=($@)

    if [[ $TAG_OPT -eq $DEL_TAG || $TAG_OPT -eq $ADD_TAG \
        || $TAG_OPT -eq $ADD_CLS_TAG || $TAG_OPT -eq $LST_TAG ]]; then
        for FILE in ${FILES[@]}; do
            FULL_PATH_FILE=`realpath $FILE`
            FILE_NAME=`basename $FILE`
            for TAG in ${TAGS[@]}; do
                eval "${TAG_CMD[$TAG_OPT]}"
            done
            if [[ $TAG_OPT -eq $LST_TAG ]]; then
                echo "$FILE_NAME:"
                eval "${TAG_CMD[$TAG_OPT]}"
            fi
        done
    else
        for TAG in ${TAGS[@]}; do
            eval "${TAG_CMD[$TAG_OPT]}"
        done
    fi
)}

# vim:set ft=sh ts=4 sw=4: