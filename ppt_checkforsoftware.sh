#!/bin/bash

SOFTWARE="$1"
HINT="$2"

if which "$SOFTWARE" > /dev/null
then
    # success
    exit 0
else
    echo "error: please install $SOFTWARE first";
    if [ "x$HINT" = x ]
    then
	echo "error: try apt-get install $SOFTWARE or port install $SOFTWARE, depending on your platform"
    else
	echo "error: try apt-get install $HINT or port install $HINT, depending on your platform"
    fi
    exit 1;
fi
