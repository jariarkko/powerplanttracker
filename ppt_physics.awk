function doflow(powerinkwh,neth) {
    return(17);
}

BEGIN {
    #printf("begin\n") >> "/dev/stderr";
    FS = ":";
}

/^production:/ {
    name = $2;
    kwh = $3;
    nethead = $4;

    if (nethead != "") {
	flow = doflow(kwh,nethead);
	printf("flow:%s:%f:%f:%f\n", name, kwh, nethead, flow) >> "/dev/stderr";
    }
    next;
}

/.*/ {
    printf("ppt_physics.awk: error: input record syntax error (%s) -- bailing\n", $0) >> "/dev/stderr";
    exit(1);
}
