BEGIN {
    if (debug) printf("begin\n") >> "/dev/stderr";
    FS = ":";
}

/^flow:/ {
    country = $2;
    name = $3;
    yearlykwh = $4;
    kwhstyle = $5;
    nethead = $6;
    averagepowerkw = $7;
    averageflowm3 = $8;
    yearlyflowm3 = $9;

    printf("For hydro power station %s (%s, %s):\n", name, country, kwhstyle);
    printf("\n");
    printf("Yearly power           %14.3f KWh\n", yearlykwh);
    printf("Net head (height)      %14.3f m\n", nethead);
    printf("Average power          %14.3f KW\n", averagepowerkw);
    printf("Average flow           %14.3f m3/s\n", averageflowm3);
    printf("Yearly flow            %14.3f m3\n", yearlyflowm3);
    
    printf("\n");
    
    next;
}

/.*/ {
    printf("ppt_display.awk: error: input record syntax error (%s) -- bailing\n", $0) >> "/dev/stderr";
    exit(1);
}
