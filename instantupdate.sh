#!/bin/bash

# instantOS update script that keeps software up to date and fixes common breakages

# each trigger has a version number
# running installtriggers triggername updates to the newest version
# updates are incremental:
# meaning if system is on version n and needs to get updated to version n+10
# all triggers from n+1, n+2 ... n+10 are run consecutively
installtriggers() {
    cd /usr/share/instantupdate/updates/"$1" || return 1
    if ! [ -e /etc/instantupdate/"$1"version ]; then
        sudo mkdir -p /etc/instantupdate
        for i in ./*.sh; do
            sudo bash "$i"
            echo "$i" | grep -o '[0-9]*' | sudo tee /etc/instantupdate/"$1"version
        done
        return
    fi

    CURRENTVERSION="$(sudo cat /etc/instantupdate/"$1"version)"

    if ! [ "$CURRENTVERSION" -eq "$CURRENTVERSION" ]; then
        echo "versioning corrupted, only running last one"
        LASTONE="$(find . | sort -V | tail -1)"
        echo "running update trigger $LASTONE"
        sudo bash "$LASTONE"
        echo "$LASTONE" | grep -o '[0-9]*' | sudo tee /etc/instantupdate/"$1"version
        return
    fi

    COUNTER="$CURRENTVERSION"
    while :; do
        if ! [ -e ./"$COUNTER".sh ]; then
            echo "finished updating to version $COUNTER"
            break
        fi
        echo "running update trigger $COUNTER"
        sudo bash ./"$COUNTER".sh
        COUNTER=$((COUNTER + 1))
        echo "$COUNTER" | grep -o '[0-9]*' | sudo tee /etc/instantupdate/"$1"version
    done

}

if [ -n "$1" ]; then
    case "$1" in
    -h)
        echo "todo: write a help message"
        ;;
    trigger)
        echo 'running installation triggers for newest version'
        echo 'TODO'
        ;;
    esac
fi

if whoami | grep -q '^root$'; then
    echo "please do not run instantupdate as root"
    exit 1
fi

echo "updating instantOS"

if ! checkinternet && ! curl -s instantos.io &>/dev/null; then
    echo "internet is required to upgrade instantOS"
    exit 1
fi

################################################
### scan for issues with package management ####
################################################

if ! grep -q '^[^#]' /etc/pacman.d/mirrorlist; then
    if echo 'your mirrorlist seems to be broken
yould you like to repair it?
leaving it in this state might leave you unable to update' | imenu -C; then
        sudo tee /etc/pacman.d/mirrorlist </usr/share/instantdotfiles/rootconfig/examplemirrors
    fi
fi

if [ -e /etc/pacman.d/instantmirrorlist ] && grep -q '\[instant\]' /etc/pacman.conf; then
    echo "instantos mirrors found"
else
    if imenu -c 'issue with the instantos mirrorlist detected. fix now?'; then
        instantsudo instantutils repo
    fi
fi

if grep '..' /etc/pacman.d/mirrorlist | grep -v '^#' | grep -q '..'; then
    echo "mirrors found"
else
    echo "mirrorlist is empty, repairing..."
    cat /usr/share/instantdotfiles/rootconfig/examplemirrors | sudo tee /etc/pacman.d/mirrorlist
fi

if locale 2>&1 | grep -iq 'cannot set'; then
    echo "locale seems to be broken"
    if echo 'empty locale has been detected
would you like to apply a fix?' | imenu -C 'locale issue'; then
        echo "repairing locale"
        instantarchrun ask asklocale
        instantarchrun run lang/locale
    fi
fi

###########################################
### prevent cache from getting too big ####
###########################################

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

# run manual db update once a week
if idate w manualupdate; then
    sudo pacman -Sy --noconfirm
    # refresh keyring first. pacman will give it priority automatically
    sudo pacman -S --needed archlinux-keyring
    sudo pacman -Syuu --noconfirm
fi

# update shell plugins once a month
if idate m instantshell; then
    instantshell update
fi

instantinstall yay

if command -v yay &>/dev/null; then
    if yay -Ps 2>&1 | grep -qi 'libalpm.*no such'; then
        echo 'updated pacman version, falling back to pacman for upgrading'
        sudo pacman -Syu
    fi
    yay --sudoloop
else
    echo 'yay not working, using pacman update'
    sudo pacman -Syu
fi

instantdotfiles

echo 'updating flatpak'
if command -v flatpak &>/dev/null; then
    flatpak update -y
fi

if idate m applytheming; then
    if ! iconf -i notheming; then
        instantthemes a arc
    fi
fi

# TODO: check if this is really necessary
if idate w instantutilsinstall; then
    sudo bash /usr/share/instantutils/rootinstall.sh
    sudo bash /usr/share/instantdotfiles/rootinstall.sh
    cd /usr/share/instantdotfiles/dotfiles || exit 1
    imosid apply .
fi

instantinstall pacman-contrib

echo "finished updating instantOS"
