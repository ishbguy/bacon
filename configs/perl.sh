#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash perl &>/dev/null || return 1

export BASH_CONFIG_PERL_SRC="$(realpath "${BASH_SOURCE[0]}")"
export BASH_CONFIG_PERL_DIR="$(dirname "$BASH_CONFIG_PERL_SRC")"

export PATH="$HOME/perl5/bin${PATH:+:${PATH}}"

export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_MB_OPT="--install_base \"$HOME/perl5\""
export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"
# export HARNESS_PERL_SWITCHES=-MDevel::Cover

# vim:set ft=sh ts=4 sw=4:
