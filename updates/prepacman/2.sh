#!/bin/bash

if pacman -Qi pamac-all; then
    echo 'replacing pamac-all with pamac-nosnap'
    sudo pacman -Sy
    sudo pacman -R pamac-all libpamac-full --noconfirm
    sudo pacman -S pamac-nosnap --noconfirm
fi
