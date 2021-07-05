#!/bin/bash

# a past version of instantarch accidentally gave wheel password free sudo

if grep '^[^#]' /etc/sudoers | grep -iq 'nopasswd'; then
    echo "removing password free sudo"
    sed -i '/wheel.*NOPASSWD/s/^/# /g' /etc/sudoers
fi
