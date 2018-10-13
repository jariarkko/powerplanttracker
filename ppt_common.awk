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

function trimspaces(s) {
    gsub("^ *","",s);
    gsub(" *$","",s);
    return(s);	
}
