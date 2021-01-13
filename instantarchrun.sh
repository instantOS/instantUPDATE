#!/bin/bash

# tool to run instantARCH modules from a normal installation

if [ -z "$1" ]; then
    echo "usage: instantarchrun ask/run modulename"
    exit
fi

if [ "$(whoami)" = root ]; then
    instantsudo() {
        $@
    }
    INSTANTARCH="$(/root/instantARCH)"
    IROOT="$(/root/instantARCH/config)"
else
    if ! command -v instantsudo &>/dev/null; then
        instantsudo() {
            # TODO: ignore shellcheck warning
            sudo $@
        }
    fi
    IROOT="$(realpath ~/.cache/instantos/iroot)"
    INSTANTARCH="$(realpath ~/.cache/instantos/instantarch)"
fi

checkinstantarch() {
    if ! [ -e "$INSTANTARCH" ]; then
        mkdir -p "${INSTANTARCH%/*}"
        cd "${INSTANTARCH%/*}" || exit 1
        notify-send "fetching instantarch"
        git clone --depth=1 https://github.com/instantos/instantARCH || exit 1
    fi
    cd "$INSTANTARCH" || exit 1
    [ -e "$IROOT" ] && mkdir -p "$IROOT"
    git reset --hard
    git pull
}

checkinstantarch

if [ "$1" = check ]; then
    echo "checked instantARCH installation"
    exit
fi

export INSTANTARCH
export IROOT

instantinstall ripgrep || exit 1

export INSTANTARCH
export IROOT

case "$1" in
"ask")

    if [ -z "$2" ]; then
        echo "usage: instantarchrun ask questionname"
    fi
    if ! rg "$2()" "$INSTANTARCH"/; then
        echo "question $2 not found"
        exit 1
    fi
    echo "asking instantarch question"
    bash -c "source $INSTANTARCH/askutils.sh && $2"
    ;;
"run")
    echo "running instantarch module"
    if [ -z "$2" ]; then
        echo "usage: instantarchrun run modulename"
        exit 1
    fi
    if ! [ -e "$INSTANTARCH/$2.sh" ]; then
        echo "question $2 not found"
        exit 1
    fi
    instantsudo bash -c "instantarchrun check && cd /root/instantARCH && git reset --hard && git pull && ./$2"
    ;;
esac
