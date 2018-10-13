
Introduction
------------

The Power Plant Tracker (PPT) tracks hydro power station power outputs and flows. It pulls public data about power station yearly power outputs and the vertical drop in those stations, and calculates the composite and average water flows that were needed to achieve those power levels.


Usage
----

To install, do

    git clone https://github.com/jariarkko/powerplanttracker.git
    cd powerplanttracker
    sudo make install

To use the tracker, give the following command:

    ppt_flowcalculator.sh

The results will look something like this:

     138 hydro power plants
     211 power plants with energy production data
       1 hydro power plants with net head data
       
Contributors
------------

The contributors to this software and the data sources are Jari Arkko and Igor Vejnovic.
