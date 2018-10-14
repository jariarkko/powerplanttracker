#!/bin/bash

SOFTWARE="$1"

if which "$SOFTWARE" > /dev/null
then
    # success
    exit 0
else
    echo "error: please install $SOFTWARE first";
    exit 1;
fi
