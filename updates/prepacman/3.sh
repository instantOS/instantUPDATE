#!/bin/bash

# libxft-bgra is libxft patched with support for emojis and glyphs.
# This has been merged now and the patch is no longer required

if pacman -Qi libxft-bgra; then
	echo 'replacing libxft-bgra with libxft'
	yes | sudo pacman -S libxft
fi
