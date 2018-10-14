BEGIN {
    if (debug) printf("begin\n") >> "/dev/stderr";
    FS = ":";
}

/^flow:/ {
    country = $2;
    name = $3;
    yearlykwh = $4;
    nethead = $5;
    averagepowerkw = $6;
    averageflowm3 = $7;
    yearlyflowm3 = $8;

    printf("For hydro power station %s (%s):\n", name, country);
    printf("\n");
    printf("Yearly power           %12.3f KWh\n", yearlykwh);
    printf("Net head (height)      %12.3f m\n", nethead);
    printf("Average power          %12.3f KW\n", averagepowerkw);
    printf("Average flow           %12.3f m3/s\n", averageflowm3);
    printf("Yearly flow            %12.3f m3\n", yearlyflowm3);
    
    printf("\n");
    
    next;
}

/.*/ {
    printf("ppt_display.awk: error: input record syntax error (%s) -- bailing\n", $0) >> "/dev/stderr";
    exit(1);
}
