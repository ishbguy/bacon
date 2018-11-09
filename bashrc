# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BASHRC_ABS_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASHRC_ABS_DIR="$(dirname "$BASHRC_ABS_SRC")"
export BASHRC_SUBCONFIGS_DIR="$BASHRC_ABS_DIR/configs"

# Source global definitions
[[ -f /etc/bashrc ]] && source /etc/bashrc

[[ -f $BASHRC_ABS_DIR/bash-alias ]] && source "$BASHRC_ABS_DIR/bash-alias"
[[ -f $BASHRC_ABS_DIR/bash-functions ]] && source "$BASHRC_ABS_DIR/bash-functions"
[[ -f $BASHRC_ABS_DIR/bash-precmd ]] && source "$BASHRC_ABS_DIR/bash-precmd"
[[ -f $BASHRC_ABS_DIR/bash-prompt ]] && source "$BASHRC_ABS_DIR/bash-prompt"

# source sub configs
for cfg in "$BASHRC_SUBCONFIGS_DIR"/*.sh; do
    [[ -f $cfg ]] && source "$cfg"
done

return 0

# vim:set ft=sh ts=4 sw=4:
