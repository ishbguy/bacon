# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BACON_BASH_PROFILE_ABS_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
export BACON_BASH_PROFILE_ABS_DIR="$(dirname "$BACON_BASH_PROFILE_ABS_SRC")"

# Get the aliases and functions
if [[ -f $BACON_BASH_PROFILE_ABS_DIR/bashrc ]]; then
    source "$BACON_BASH_PROFILE_ABS_DIR/bashrc"
fi

# vim:set ft=sh ts=4 sw=4:
