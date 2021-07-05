#!/bin/bash

# fix pamac version after a pacman update broke it

pamac --version && exit

if pacman -Qi instantdepend; then
    export INSTALLINSTANTDEPEND=true
    sudo pacman -R instantdepend --noconfirm
fi

if pamac 2>&1 | grep -iq "libalpm.*no such"; then
    echo 'outdated pamac, preventing file system conflicts'
    sudo pacman -Sy
    sudo pacman -R pamac-all --noconfirm
    sudo pacman -R archlinux-appstream-data --noconfirm
    sudo pacman -S pamac-all --noconfirm
fi

if [ -n "$INSTALLINSTANTDEPEND" ]; then
    sudo pacman -S instantdepend --noconfirm
fi
