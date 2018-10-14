
Introduction
------------

The Power Plant Tracker (PPT) tracks hydro power station power outputs and flows. It pulls public data about power station yearly power outputs and the vertical drop in those stations, and calculates the composite and average water flows that were needed to achieve those power levels.

This can be used to understand the use of water in various smaller and larger power stations, and to track the amount of water left for natural flow, for irrigation, fish and the rest of the natural river ecosystems. Or beauty of nature!

Why does this matter? Obviously, hydro power is good for minimising carbon dioxide production. However, if no water is left for the natural water pathways at all, this will slowly destroy the river ecosystems. An example from Croatia:

Now:

![current](https://bankwatch.org/wp-content/uploads/2018/03/dabrova-dolina-croatia-why-not-build-small-hydropower10-1024x768.jpg)

Before:

![past](https://bankwatch.org/wp-content/uploads/2018/03/dabrova-dolina-croatia-why-not-build-small-hydropower-2.jpg)

Usage
----

To install, do

    git clone https://github.com/jariarkko/powerplanttracker.git
    cd powerplanttracker
    sudo make install

To use the tracker, give the following command:

    ppt_flowcalculator.sh

The following options can also be used as needed

    --debug
    --no-debug

Turns on or off high-level debugging. The default is off

    --deep-debug
    --no-deep-debug

Turns on or off detailed debugging. The default is off

    --country somecountry

Sets the country to look at, or "all" to look at data from all available countries. The default is "all".

The results will look something like this:

     138 hydro power plants
     211 power plants with energy production data
       1 hydro power plants with net head data

     For hydro power station црквине:
     
     Yearly power           2951585.600 KWh
     Net head (height)           60.900 m
     Average power              336.939 KW
     Average flow                 1.128 m3/s
     Yearly flow           35571450.867 m3


Supported government data sources
---------------------------------

Currently, the software supports only Serbian government data sources.

Contributors
------------

The contributors to this software and the data sources are Jari Arkko and Igor Vejnovic. The work was done in the Descon hackathon event in October 2018.
