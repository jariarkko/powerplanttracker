#!/bin/bash

#
# General variable settings
#

TMPDIR=/tmp
BASEDIR=`echo $0 | sed 's%/ppt_fetchdata_finland.sh%%g'`
DEBUG=0
DEEPDEBUG=0

#
# Remove some files
#

rm -f $TMPDIR/*.finland.db

#
# Set the public sources of information
#

HYDROWEBFILE=https://fi.wikipedia.org/wiki/Vesivoimalat_Suomessa

#
# Parse arguments
#

while [ $# -ge 1 ]
do
    case "x$1" in

	x--debug)
	    DEBUG=1;
	    shift;;
	
	x--no-debug)
	    DEBUG=0;
	    DEEPDEBUG=0;
	    shift;;
	
	x--deep-debug)
	    DEBUG=1;
	    DEEPDEBUG=1;
	    shift;;
	
	x--no-deep-debug)
	    DEEPDEBUG=0;
	    shift;;
	
	*)
	    echo "ppt_fetchdata_finland.sh: error: unrecognised option ($1) -- bailing";
	    exit 1;;
	
    esac
    
done

# 
# Get the necessary files from the Internet
#

if [ $DEBUG = 1 ]
then
    echo "ppt_fetchdata_finland: debug: fetching hydro database..." >> /dev/stderr
fi

wget -q -O $TMPDIR/hydro.finland.html "$HYDROWEBFILE"

#
# Read the data (mostly screen scraping, no JSON/XML available sadly...)
#

if [ $DEBUG = 1 ]
then
    echo "ppt_fetchdata_finland: debug: parsing hydro database..." >> /dev/stderr
fi

(cat $TMPDIR/hydro.finland.html) |
    tee $TMPDIR/input.for.hydro.txt |
    gawk -v basedir=$BASEDIR \
	 -v debug=$DEEPDEBUG \
	 -f $BASEDIR/ppt_common.awk \
	 -f $BASEDIR/ppt_parsehydro_finland.awk > $TMPDIR/hydroandpower.finland.db

fgrep hydroplant: $TMPDIR/hydroandpower.finland.db > $TMPDIR/hydro.finland.db
fgrep production: $TMPDIR/hydroandpower.finland.db > $TMPDIR/power.finland.db

#
# Output data
#

(cat $TMPDIR/hydro.finland.db;
 cat $TMPDIR/power.finland.db)

