# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BASHRC_ABS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
export BASHRC_PLUGINS_DIR="$BASHRC_ABS_DIR/plugins"

[[ -f $BASHRC_ABS_DIR/bash-alias ]] && source "$BASHRC_ABS_DIR/bash-alias"
[[ -f $BASHRC_ABS_DIR/bash-export-vars ]] && source "$BASHRC_ABS_DIR/bash-export-vars"
[[ -f $BASHRC_ABS_DIR/bash-precmd ]] && source "$BASHRC_ABS_DIR/bash-precmd"

# Source my own function
[[ -f $BASHRC_ABS_DIR/lib.sh ]] && source "$BASHRC_ABS_DIR/lib.sh"

# Source global definitions
[[ -f /etc/bashrc ]] && source /etc/bashrc

#Setting the ls colors

[[ -r $BASHRC_ABS_DIR/dircolors ]] && eval "$(dircolors "$BASHRC_ABS_DIR/dircolors")"

# vim:set ft=sh ts=4 sw=4:
