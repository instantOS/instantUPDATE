#!/bin/bash

source /share/instantupdate/utils/iadm_utils.sh

if [ -z "$1" ]; then
    update_dotfiles
fi
