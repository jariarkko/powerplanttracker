BEGIN {
    if (debug) printf("begin\n") >> "/dev/stderr";
    FS = ":";
}

/^flow:/ {
    name = $2;
    yearlykwh = $3;
    nethead = $4;
    averagepowerkw = $5;
    averageflowm3 = $6;
    yearlyflowm3 = $7;

    printf("For hydro power station %s:\n", name);
    printf("\n");
    printf("Yearly power           %12.3f KWh\n", yearlykwh);
    printf("Net head (height)      %12.3f m\n", nethead);
    printf("Average power          %12.3f KW\n", averagepowerkw);
    printf("Average flow           %12.3f m3/s\n", averageflowm3);
    printf("Yearly flow            %12.3f m3/s\n", yearlyflowm3);
    
    printf("\n");
    
    next;
}

/.*/ {
    printf("ppt_display.awk: error: input record syntax error (%s) -- bailing\n", $0) >> "/dev/stderr";
    exit(1);
}
