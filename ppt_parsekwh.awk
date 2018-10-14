function reportone() {
    if (debug) printf("found a new KWh entry for %s at %s kwh, nethead = %s\n", colname, colkwh, nethead[colname]) >> "/dev/stderr";
    colkwhclean = colkwh;
    gsub(/[.]/,"",colkwhclean);
    gsub(/,/,".",colkwhclean);
    printf("production:%s:%s:%s\n", colname, colkwhclean, nethead[colname]);
}

function checkifready() {
    if (numfieldctr == 5 && seennamefield && seencompanyfield) {
	reportone();
	colname = "";
	colkwh = "";
	colcompany = "";
	numfieldctr = 1;
	seencompanyfield = 0;
	seennamefield = 0;
    }
}

BEGIN {
    #printf("begin\n") >> "/dev/stderr";
    intable = 0;
    ignorectr = 0;
    FS = "[<>:]";
    specialnames["PROKUPLJE"] = 1;
    specialnames["ЖУПАЊ ДОО БЕОГРАД"] = 1;
    specialnames["БАЈНА БАШТА"] = 1;
    specialnames["ЕНЕРГИЈЕ Д.О.О. ДАРКОВЦЕ"] = 1;
    specialnames["ИЗВОРА ЕНЕРГИЈЕ- ЦЕНТРАЛА, БЕОГРАД"] = 1;
    notspecialnames["МЕЗДРЕЈА"] = 1;
}

/^hydroplant:/ {
    name = $3;
    netheadval = $5;
    nethead[name] = netheadval;
    if (debug) printf("installed nethead for %s as %s (maxpower %s)\n", name, netheadval, $4) >> "/dev/stderr";
    next;
}
    
/^НАЗИВ ПОВЛАШЋЕНОГ.ПРИВРЕМЕНО ПОВЛАШЋЕНОГ ПРОИЗВОЂАЧА$/ {
    #printf("begin table\n") >> "/dev/stderr";
    intable = 1;
    seencompanyfield = 0;
    seennamefield = 0;
    numfieldctr = 1;
    next;
}

/^ НАЗИВ ЕЛЕКТРАНЕ$/ {
    next;
}

/^  ЕНЕРГИЈЕ$/ {
    next;
}

/^  [(] kWh [)]$/ {
    next;
}

/^  [(] kWh [)]$/ {
    next;
}

/^  [(] дин [)]$/ {
    next;
}

/^  [(] дин [)]$/ {
    next;
}

/^  [0-9]+[.0-9]*,[0-9][0-9]+$/ {
    if (intable) {
	checkifready();
	if (numfieldctr == 1) {
	    colkwh = trimspaces($0);
	    #printf("readkwh: read a kwh field: %s\n", colkwh) >> "/dev/stderr";
	} else if (numfieldctr >= 2 && numfieldctr <= 4) {
	    #printf("readkwh: skipping a number (%uth)\n", numfieldctr) >> "/dev/stderr";
	    # ok
	} else {
	    # something is wrong
	    intable = 0;
	    printf("readkwh: something wrong with number (%uth): %s\n", numfieldctr, $0) >> "/dev/stderr";
	}
	numfieldctr++;
    }
    next;
}

#/^ЖУПАЊ ДОО БЕОГРАД$/ {
#    if (intable && seencompanyfield) {
#	companynameadd = trimspaces($0);
#	colcompany = colcompany " " companynameadd;
#	next;
#    } else {
#	# something is wrong
#	printf("readkwh: error: special name 1 in unexpected place (%s) -- bailing\n", $0) >> "/dev/stderr";
#	intable = 0;
#	next;
#    }
#}
#
#/^БАЈНА БАШТА$/ {
#    if (intable && seencompanyfield) {
#	companynameadd = trimspaces($0);
#	colcompany = colcompany " " companynameadd;
#	next;
#    } else {
#	# something is wrong
#	printf("readkwh: error: special name 2 in unexpected place (%s) -- bailing\n", $0) >> "/dev/stderr";
#	intable = 0;
#	next;
#    }
#}

/^ .*$/ {
    if (intable) {
	if (seennamefield == 0) {
	    colname = handlecolname(trimspaces($0));
	    seennamefield = 1;
	    #printf("readkwh: read a name field (%s)\n", colname) >> "/dev/stderr";
	    next;
	} else if (seennamefield == 1) {
	    colnameadd = trimspaces($0);
	    if (notspecialnames[colnameadd] == 1) {
		checkifready();
		colname = handlecolname(trimspaces($0));
		seennamefield = 1;
		#printf("readkwh: read a non-special name field (%s)\n", colname) >> "/dev/stderr";
	    } else {
		colname = handlecolname(colname " " colnameadd);
		#printf("readkwh: read more for a name field (%s)\n", colname) >> "/dev/stderr";
	    }
	    next;
	} else {
	    # something is wrong
	    printf("readkwh: error: name in unexpected place (%s) -- bailing\n", $0) >> "/dev/stderr";
	    intable = 0;
	    next;
	}
    }
}

/^.*$/ {
    thisline = substr($0,1,length($0));
    if (specialnames[thisline] && intable && seencompanyfield) {
	companynameadd = trimspaces($0);
	colcompany = colcompany " " companynameadd;
	next;
    } else if (intable) {
	checkifready();
	if (seencompanyfield == 0) {
	    colcompany = trimspaces($0);
	    seencompanyfield = 1;
	    #printf("readkwh: read a company field (%s)\n", colcompany) >> "/dev/stderr";
	    next;
	} else {
	    # something is wrong
	    printf("readkwh: error: company name in unexpected place (%s) -- bailing\n", $0) >> "/dev/stderr";
	    intable = 0;
	    next;
	}
    }
}

/.*/ {
    if (ignorectr++ < 70) {
	#printf("ignore: %s\n", $0) >> "/dev/stderr";
    }
    intable = 0;
    next;
}

END {
    if (intable) {
	checkifready();
    }
}
