#!/usr/bin/env bash

# shellcheck disable=SC1090
BACON_LIB="$(abspath "$(suitdir)/../lib")"
source "${BACON_LIB}"/bacon-utils.sh
source "${BACON_LIB}"/bacon-module.sh
source "${BACON_LIB}"/bacon-precmd.sh
source "${BACON_LIB}"/bacon-prompt.sh
