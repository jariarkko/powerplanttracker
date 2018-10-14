#!/bin/bash

#
# General variable settings
#

TMPDIR=/tmp
BASEDIR=`echo $0 | sed 's%/ppt_fetchdata_serbia.sh%%g'`
DEBUG=0
DEEPDEBUG=0

#
# Remove some files
#

rm -f $TMPDIR/*.serbia.db

#
# Set the public sources of information
#

POWERYEAR=2017
POWERWEBFILE="http://www.eps-snabdevanje.rs/obnovljivi-izvori/Documents/Izvestaj%20garantovanog%20snabdevaca%20za%20${POWERYEAR}%20godinu%20za%20sajt%20Ogranka%20EPSS.pdf"
HYDROWEBFILE="http://www.mre.gov.rs/doc/registar-121018.html"

#
# Our own databases of information
#

NETHEADFILE=$BASEDIR/ppt_netheads.txt

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
	    echo "ppt_fetchdata_serbia.sh: error: unrecognised option ($1) -- bailing";
	    exit 1;;
	
    esac
    
done

# 
# Get the necessary files from the Internet
#

if [ $DEBUG = 1 ]
then
    echo "ppt_fetchdata_serbia: debug: fetching hydro database..." >> /dev/stderr
fi

wget -q -O $TMPDIR/hydro.serbia.html "$HYDROWEBFILE"

if [ $DEBUG = 1 ]
then
    echo "ppt_fetchdata_serbia: debug: fetching power production database..." >> /dev/stderr
fi

wget -q -O $TMPDIR/kwh.serbia.pdf "$POWERWEBFILE"

#
# Convert format to something that can be processed
#

pdftotext -nopgbrk -fixed 200 $TMPDIR/kwh.serbia.pdf $TMPDIR/kwh.serbia.txt

#
# Read the data (mostly screen scraping, no JSON/XML available sadly...)
#

if [ $DEBUG = 1 ]
then
    echo "ppt_fetchdata_serbia: debug: parsing hydro database..." >> /dev/stderr
fi

(cat $NETHEADFILE;
 cat $TMPDIR/hydro.serbia.html) |
    tee $TMPDIR/input.for.hydro.txt |
    gawk -v basedir=$BASEDIR \
	 -v debug=$DEEPDEBUG \
	 -f $BASEDIR/ppt_common.awk \
	 -f $BASEDIR/ppt_parsehydro_serbia.awk > $TMPDIR/hydro.serbia.db

if [ $DEBUG = 1 ]
then
    echo "ppt_fetchdata_serbia: debug: parsing power production database..." >> /dev/stderr
fi

(cat $TMPDIR/hydro.serbia.db;
 cat $TMPDIR/kwh.serbia.txt) |
    tee $TMPDIR/input.for.power.txt |
    gawk -v basedir=$BASEDIR \
	 -v debug=$DEEPDEBUG \
	 -v year=$POWERYEAR \
	 -f $BASEDIR/ppt_common.awk \
	 -f $BASEDIR/ppt_parsekwh_serbia.awk > $TMPDIR/power.serbia.db

#
# Output data
#

(cat $TMPDIR/hydro.serbia.db
 cat $TMPDIR/power.serbia.db)

