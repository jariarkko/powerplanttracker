function convcommas(x) {
    gsub(/,/,".",x);
    return(x);
}

function handlecolname(x) {
    tmpfilein = "/tmp/colname";
    tmpfileout = "/tmp/colname.n";
    printf("%s", x) > tmpfilein;
    close(tmpfilein);
    cmd = sprintf("%s/ppt_normalisecyrillic.sh < %s > %s", basedir, tmpfilein, tmpfileout);
    #printf("cmd = %s...\n", cmd) >> "/dev/stderr";
    system(cmd);
    getline res < tmpfileout;
    close(tmpfileout);
    return(res);
}

function reportone(country,kwhtype) {
    if (debug) printf("found a new KWh entry for %s at %s kwh, nethead = %s\n", colname, colkwh, nethead[colname]) >> "/dev/stderr";
    colkwhclean = colkwh;
    gsub(/[.]/,"",colkwhclean);
    gsub(/,/,".",colkwhclean);
    printf("production:%s:%s:%s:%s:%s\n", country, colname, colkwhclean, kwhtype, nethead[colname]);
}

function trimspaces(s) {
    gsub("^ *","",s);
    gsub(" *$","",s);
    return(s);	
}
