#!/bin/bash

#
# General variable settings

TMPDIR=/tmp
BASEDIR=`echo $0 | sed 's%/ppt_flowcalculator.sh%%g'`

#
# Set the public sources of information
#

POWERWEBFILE="http://www.eps-snabdevanje.rs/obnovljivi-izvori/Documents/Izvestaj%20garantovanog%20snabdevaca%20za%202017%20godinu%20za%20sajt%20Ogranka%20EPSS.pdf"
HYDROWEBFILE="http://www.mre.gov.rs/doc/registar-121018.html"

#
# Our own databases of information
#

NETHEADFILE=$BASEDIR/ppt_netheads.txt

#
# Get the necessary files from the Internet
#

wget -q -O $TMPDIR/kwh.pdf "$POWERWEBFILE"
wget -q -O $TMPDIR/hydro.html "$HYDROWEBFILE"

#
# Convert format to something that can be processed
#

pdftotext -nopgbrk -fixed 200 $TMPDIR/kwh.pdf $TMPDIR/kwh.txt

#
# Read the data (mostly screen scraping, no JSON/XML available sadly...)
#

(cat $NETHEADFILE;
 cat $TMPDIR/hydro.html) |
    tee $TMPDIR/input.for.hydro.txt |
    gawk -v basedir=$BASEDIR -f $BASEDIR/ppt_common.awk -f $BASEDIR/ppt_parsehydro.awk > $TMPDIR/hydro.db
(cat $TMPDIR/hydro.db;
 cat $TMPDIR/kwh.txt) |
    tee $TMPDIR/input.for.power.txt |
    gawk -v basedir=$BASEDIR -f $BASEDIR/ppt_common.awk -f $BASEDIR/ppt_parsekwh.awk > $TMPDIR/power.db

#
# Statistics
#

HYDRONUM=`cat $TMPDIR/hydro.db | wc -l`
POWERNUM=`cat $TMPDIR/power.db | wc -l`
NETHEADNUM=`cat $NETHEADFILE | wc -l`
echo "$HYDRONUM hydro power plants"
echo "$POWERNUM power plants with energy production data"
echo "$NETHEADNUM hydro power plants with net head data"
