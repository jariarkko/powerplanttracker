#!/bin/bash

#
# General variable settings
#

TMPDIR=/tmp
BASEDIR=`echo $0 | sed 's%/ppt_flowcalculator.sh%%g'`
DEBUG=0
DEEPDEBUG=0
COUNTRY=all

#
# Remove some files
#

rm -f $TMPDIR/power*.db
rm -f $TMPDIR/hydro*.db

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

rm -f $TMPDIR/power.all.db
touch $TMPDIR/power.all.db

if [ "x$COUNTRY" = xall ]
then
    COUNTRIES=`cut -f2 -d: $COUNTRIESFILE`
    if [ $DEBUG = 1 ]
    then
	echo "ppt_flowcalculator: debug: fetching all countries: $COUNTRIES..." >> /dev/stderr
    fi
else
    if fgrep -e "country:$COUNTRY:" $COUNTRIESFILE > /dev/null
    then
	if [ $DEBUG = 1 ]
	then
	    echo "ppt_flowcalculator: debug: found country $COUNTRY..." >> /dev/stderr
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
	echo "ppt_flowcalculator: debug: processing country $CURRENTCOUNTRY..." >> /dev/stderr
    fi
    COUNTRYSCRIPT=`fgrep -e "country:$CURRENTCOUNTRY:" $COUNTRIESFILE | cut -f3 -d:`
    if [ "x$COUNTRYSCRIPT" = x ]
    then
	echo "ppt_flowcalculator: error: no script found for $CURRENTCOUNTRY -- bailing"
	exit 1
    fi
    if [ $DEBUG = 1 ]
    then
	SCRIPTARGS="--debug"
    else
	SCRIPTARGS="--no-debug"
    fi
    if [ $DEEPDEBUG = 1 ]
    then
	SCRIPTARGS="$SCRIPTARGS --deep-debug"
    else
	SCRIPTARGS="$SCRIPTARGS --no-deep-debug"
    fi
    if [ $DEBUG = 1 ]
    then
	echo "ppt_flowcalculator: debug: running script $COUNTRYSCRIPT with arguments $SCRIPTARGS..." >> /dev/stderr
    fi
    $BASEDIR/$COUNTRYSCRIPT $SCRIPTARGS >> $TMPDIR/hydroandpower.all.db
    
done

#
# Separate databases
#

fgrep hydroplant: $TMPDIR/hydroandpower.all.db > $TMPDIR/hydro.all.db
fgrep production: $TMPDIR/hydroandpower.all.db > $TMPDIR/power.all.db

#
# Calculate flows
#

if [ $DEBUG = 1 ]
then
    echo "ppt_flowcalculator: debug: calculating flows..." >> /dev/stderr
fi

cat $TMPDIR/power.all.db |
    gawk -v basedir=$BASEDIR \
	 -v debug=$DEEPDEBUG \
	 -f $BASEDIR/ppt_common.awk \
	 -f $BASEDIR/ppt_physics.awk > $TMPDIR/flows.db

#
# Statistics
#

HYDRONUM=`cat $TMPDIR/hydro.all.db | wc -l`
POWERNUM=`cat $TMPDIR/power.all.db | wc -l`
NETHEADNUM=`cat $NETHEADFILE | wc -l`
echo "$HYDRONUM hydro power plants"
echo "$POWERNUM power plants with energy production data"
echo "$NETHEADNUM hydro power plants with net head data"

echo ''

gawk 	 -f $BASEDIR/ppt_common.awk \
	 -f $BASEDIR/ppt_display.awk < $TMPDIR/flows.db
