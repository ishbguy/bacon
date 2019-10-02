# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# check whether it's an interative shell or return
[[ $- == *i* ]] || return 0

export BACON_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BACON_ABS_DIR="$(dirname "$BACON_ABS_SRC")"
export BACON_SUBCONFIGS_DIR="$BACON_ABS_DIR/configs"

# Source global definitions
[[ -e /etc/bashrc ]] && source /etc/bashrc

BACON_UNITS=(
    bacon-utils.sh
    bacon-precmd.sh
    bacon-prompt.sh
)
for unit in "${BACON_UNITS[@]}"; do
    # shellcheck disable=SC1090,SC2015
    [[ -f $BACON_ABS_DIR/lib/$unit ]] && source "$BACON_ABS_DIR/lib/$unit" || true
done

# source sub configs
for cfg in "$BACON_SUBCONFIGS_DIR"/*.sh; do
    # shellcheck disable=SC1090,SC2015
    [[ -f $cfg ]] && source "$cfg" || true
done

# source user's local configs
for cfg in "$HOME"/.bacon/*.sh "$HOME"/.bash-configs/*.sh; do
    # shellcheck disable=SC1090,SC2015
    [[ -f $cfg ]] && source "$cfg" || true
done

# vim:set ft=sh ts=4 sw=4:
