#! /usr/bin/env bash
# Copyright (c) 2018 Herbert Shen <ishbguy@hotmail.com> All Rights Reserved.
# Released under the terms of the MIT License.

hash pdbedit &>/dev/null || return 1

bacon_export samba

#mysmbadd(): SMB user add.
mysmbadd() {(
    if [[ $# -ne 1 ]]; then
        echo "mysmbadd smbuser"
        return 1
    fi

    #Add the system user for smb user
    echo "Add user to system: $1 ..." && \
    sudo useradd -m -G mysmb $1 && \
    echo "Add password for $1..." && \
    sudo passwd $1 && \
    echo "Add smb user: $1 ..." && \
    sudo pdbedit -a -u $1 && \
    echo "Finished."
    return 0
)}

#mysmbdel(): Delete smb user.
mysmbdel() {(
    if [[ $# -ne 1 ]]; then
        echo "mysmbdel smbuser"
        return 1
    fi

    echo "Delete smb user: $1" && \
    sudo pdbedit -x -u $1 && \
    echo "Delete system user: $1" && \
    sudo userdel -r $1 && \
    echo "Finished."

    return 0
)}

# vim:set ft=sh ts=4 sw=4:
