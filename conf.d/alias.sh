#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

bacon_export alias

# User specific aliases and functions
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias la='ls --color=auto -A'
alias ll='ls --color=auto -lhA'
alias ls='ls --color=auto'
alias grep='grep --color'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
alias vi='vim'
alias df='df -Th'
alias du='du -sh'
alias co='cd ~-'

#Alias for quick config.
alias sb='source ~/.bashrc' 
alias vb='vi ~/.bashrc'

#Alias for job control.
alias job='jobs -l'
alias po='popd'
alias pp='pushd +1'
alias pu='pushd'

# vim:set ft=sh ts=4 sw=4:
