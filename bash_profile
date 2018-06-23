# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

export BASH_PROFILE_ABS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# Get the aliases and functions
if [[ -f $BASH_PROFILE_ABS_DIR/bashrc ]]; then
    source "$BASH_PROFILE_ABS_DIR/bashrc"
fi

# vim:set ft=sh ts=4 sw=4:
