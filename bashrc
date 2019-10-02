# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# check whether it's an interative shell or return
[[ $- == *i* ]] || return 0

export BASHRC_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASHRC_ABS_DIR="$(dirname "$BASHRC_ABS_SRC")"
export BASHRC_SUBCONFIGS_DIR="$BASHRC_ABS_DIR/configs"

# Source global definitions
[[ -e /etc/bashrc ]] && source /etc/bashrc

BASHRC_UNITS=(
    bacon-utils.sh
    bacon-precmd.sh
    bacon-prompt.sh
)
for unit in "${BASHRC_UNITS[@]}"; do
    # shellcheck disable=SC1090,SC2015
    [[ -f $BASHRC_ABS_DIR/lib/$unit ]] && source "$BASHRC_ABS_DIR/lib/$unit" || true
done

# source sub configs
for cfg in "$BASHRC_SUBCONFIGS_DIR"/*.sh; do
    # shellcheck disable=SC1090,SC2015
    [[ -f $cfg ]] && source "$cfg" || true
done

# source user's local configs
for cfg in "$HOME"/.bacon/*.sh "$HOME"/.bash-configs/*.sh; do
    # shellcheck disable=SC1090,SC2015
    [[ -f $cfg ]] && source "$cfg" || true
done

# vim:set ft=sh ts=4 sw=4:
