#!/bin/bash

#
# General variable settings

TMPDIR=/tmp
BASEDIR=`echo $0 | sed 's%/ppt_flowcalculator.sh%%g'`
DEBUG=0
DEEPDEBUG=0
COUNTRY=all

#
# Set the public sources of information
#

POWERWEBFILE="http://www.eps-snabdevanje.rs/obnovljivi-izvori/Documents/Izvestaj%20garantovanog%20snabdevaca%20za%202017%20godinu%20za%20sajt%20Ogranka%20EPSS.pdf"
HYDROWEBFILE="http://www.mre.gov.rs/doc/registar-121018.html"

#
# Our own databases of information
#

NETHEADFILE=$BASEDIR/ppt_netheads.txt
COUNTRIESFILE=$BASEDIR/ppt_countries.txt

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
	
	x--country)
	    shift;
	    COUNTRY="$1";
	    shift;;
	
	*)
	    echo "ppt_flowcalculator.sh: error: unrecognised option ($1) -- bailing";
	    exit 1;;
	
    esac
    
done

#
# Determine what countries to look at
#

if [ "x$COUNTRY" = xall ]
then
    COUNTRIES=`cut -f2 -d: $COUNTRIESFILE`
    if [ $DEBUG = 1 ]
    then
	echo "ppt_flowcalculator: debug: fetching all countries: $COUNTRIES..."
    fi
else
    if fgrep -e "country:$COUNTRY:" $COUNTRIESFILE > /dev/null
    then
	if [ $DEBUG = 1 ]
	then
	    echo "ppt_flowcalculator: debug: found country $COUNTRY..."
	fi
    else
	echo "ppt_flowcalculator.sh: error: unsupported country ($COUNTRY) -- bailing"
	exit 1
    fi
    COUNTRIES=$COUNTRY
fi

for CURRENTCOUNTRY in $COUNTRIES
do
    if [ $DEBUG = 1 ]
    then
	echo "ppt_flowcalculator: debug: processing country $CURRENTCOUNTRY..."
    fi
done

# 
# Get the necessary files from the Internet
#

if [ $DEBUG = 1 ]
then
    echo "ppt_flowcalculator: debug: fetching hydro database..."
fi

wget -q -O $TMPDIR/hydro.html "$HYDROWEBFILE"

if [ $DEBUG = 1 ]
then
    echo "ppt_flowcalculator: debug: fetching power production database..."
fi

wget -q -O $TMPDIR/kwh.pdf "$POWERWEBFILE"

#
# Convert format to something that can be processed
#

pdftotext -nopgbrk -fixed 200 $TMPDIR/kwh.pdf $TMPDIR/kwh.txt

#
# Read the data (mostly screen scraping, no JSON/XML available sadly...)
#

if [ $DEBUG = 1 ]
then
    echo "ppt_flowcalculator: debug: parsing hydro database..."
fi

(cat $NETHEADFILE;
 cat $TMPDIR/hydro.html) |
    tee $TMPDIR/input.for.hydro.txt |
    gawk -v basedir=$BASEDIR \
	 -v debug=$DEEPDEBUG \
	 -f $BASEDIR/ppt_common.awk \
	 -f $BASEDIR/ppt_parsehydro.awk > $TMPDIR/hydro.db

if [ $DEBUG = 1 ]
then
    echo "ppt_flowcalculator: debug: parsing power production database..."
fi

(cat $TMPDIR/hydro.db;
 cat $TMPDIR/kwh.txt) |
    tee $TMPDIR/input.for.power.txt |
    gawk -v basedir=$BASEDIR \
	 -v debug=$DEEPDEBUG \
	 -f $BASEDIR/ppt_common.awk \
	 -f $BASEDIR/ppt_parsekwh.awk > $TMPDIR/power.db

#
# Calculate flows
#

if [ $DEBUG = 1 ]
then
    echo "ppt_flowcalculator: debug: calculating flows..."
fi

cat $TMPDIR/power.db |
    gawk -v basedir=$BASEDIR \
	 -v debug=$DEEPDEBUG \
	 -f $BASEDIR/ppt_common.awk \
	 -f $BASEDIR/ppt_physics.awk > $TMPDIR/flows.db

#
# Statistics
#

HYDRONUM=`cat $TMPDIR/hydro.db | wc -l`
POWERNUM=`cat $TMPDIR/power.db | wc -l`
NETHEADNUM=`cat $NETHEADFILE | wc -l`
echo "$HYDRONUM hydro power plants"
echo "$POWERNUM power plants with energy production data"
echo "$NETHEADNUM hydro power plants with net head data"

echo ''

gawk 	 -f $BASEDIR/ppt_common.awk \
	 -f $BASEDIR/ppt_display.awk < $TMPDIR/flows.db
