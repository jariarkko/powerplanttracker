function doflow(powerinkwh,neth) {
    
    #
    # From https://energypedia.info/wiki/Hydro_Power_Basics:
    #
    #   Power [W] = Net head [m] x Flow [ l/s] x 9.81 [m/s²] (est. gravity constant) x 0.5 (turbine efficiency)
    #
    # So therefore we can turn this into
    #
    #   Flow [ l/s] = Power [W] / (Net head [m] x 9.81 [m/s²] x 0.5)
    #
    # And that's for instantaneous flow and power. When we have a yearly power, we can
    # calculate average l/s flow:
    #
    #   Average power [Wh] = (Yearly Power [Wh] / 365 * 24)
    #   Average flow [ l/s ] = Average power [Wh] / (Net head [m] x 9.81 [m/s²] x 0.5)
    #
    # And then the total yearly flow is:
    #
    #   Yearly flow  [ l ] = Average flow [ l/s ] * 365 * 86400
    #
    
    g = 9.81;
    eff = 0.5;
    hoursinyear = 365 * 24;
    secondsinyear = 365 * 86400;
    power = powerinkwh * 1000.0;
    averagepower = (power / hoursinyear);
    averagepowerkw = averagepower / 1000;
    averageflow = averagepower / (neth * g * eff);
    averageflowm3 = averageflow / 1000;
    yearlyflow = averageflow * secondsinyear;
    yearlyflowm3 = yearlyflow / 1000;
    return(sprintf("%.3f:%.3f:%.3f",
	           averagepowerkw,
	           averageflowm3,
	           yearlyflowm3));
}

BEGIN {
    if (debug) printf("begin\n") >> "/dev/stderr";
    FS = ":";
}

/^production:/ {
    name = $2;
    kwh = $3;
    nethead = $4;

    if (debug) printf("got power entry for %s...\n", name) >> "/dev/stderr";
    
    if (nethead != "") {
	flow = doflow(kwh,nethead);
	if (debug) printf("calculation for %s from %f is %f\n", name, nethead, flow) >> "/dev/stderr";
	printf("flow:%s:%f:%f:%s\n", name, kwh, nethead, flow);
    }
    next;
}

/.*/ {
    printf("ppt_physics.awk: error: input record syntax error (%s) -- bailing\n", $0) >> "/dev/stderr";
    exit(1);
}
