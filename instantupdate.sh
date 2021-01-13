#!/bin/bash

echo "updating instantOS"

if whoami | grep -q '^root$'; then
    echo "please do not run instantupdate as root"
    exit 1
fi
if ! checkinternet && ! curl -s instantos.io; then
    echo "internet is required to upgrade instantOS"
    exit 1
fi

if ! grep -q '^[^#]' /etc/pacman.d/mirrorlist; then
    if echo 'your mirrorlist seems to be broken
yould you like to repair it?
leaving it in this state might leave you unable to update' | imenu -C; then
        sudo tee /etc/pacman.d/mirrorlist </usr/share/instantdotfiles/examplemirrors
    fi
fi
# TODO: auto repair instantOS repos

sudo pacman -Sy --noconfirm
# TODO: only run this once every month
instantshell update

sudo pacman -Syuu --noconfirm
instantinstall yay
command -v yay && yay
instantdotfiles

if ! iconf -i notheming; then
    instantthemes a arc
fi

sudo bash /usr/share/instantutils/rootinstall.sh
sudo bash /usr/share/instantdotfiles/rootinstall.sh
bash /usr/share/instantdotfiles/userinstall.sh

instantinstall pacman-contrib

if grep '..' /etc/pacman.d/mirrorlist | grep -v '^#' | grep -q '..'; then
    echo "mirrors found"
else
    echo "mirrors have been cleared"
    cat /usr/share/instantdotfiles/examplemirrors | sudo tee /etc/pacman.d/mirrorlist
fi

# TODO: install some pacnews

if [ -e ~/.cache/yay ] && ! pgrep yay && ! pgrep pacman; then
    echo "checking cache size"

    CACHESIZE="$(du -sb ~/.cache/yay)"
    if [ "$CACHESIZE" -gt 5000000000 ]; then
        echo "cache pretty big"
        if echo "your yay cache has reached a size larger than 5gb.
Would you like to clean it now?" | imenu -C 'cache warning'; then
            echo "cleaning cache"
            rm -rf ~/.cache/yay
        fi
    fi

fi

PACCACHE="$(pacman -v | grep cache | head -1 | grep -o '/.*')"
if [ -e "$PACCACHE" ] && [ "$(du -sb "$PACCACHE")" -gt 9000000000 ]; then
    echo "pacman cache is pretty big"
    if echo "your pacman cache has reached a size larger than 9gb.
Would you like to clean it now?" | imenu -C 'cache warning'; then
        echo "cleaning pacman cache"
        instantsudo bash -c 'yes | pacman -Scc'
    fi
fi

if locale 2>&1 | grep -iq 'cannot set'; then
    echo "locale seems to be broken"
    if echo 'empty locale has been detected
would you like to apply a fix?' | imenu -C 'locale issue'; then
        echo "repairing locale"
        # TODO

    fi
fi

echo "finished updating instantOS"
