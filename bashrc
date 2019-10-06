# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

# shellcheck disable=SC2155
export BACON_BASHRC_ABS_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
export BACON_BASHRC_ABS_DIR="$(dirname "$BACON_BASHRC_ABS_SRC")"

# shellcheck disable=SC1090
source "$BACON_BASHRC_ABS_DIR/lib/bacon-main.sh"

# vim:set ft=sh ts=4 sw=4:
