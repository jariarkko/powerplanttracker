function getstring(what,field) {
    
    while (length(what) > 0 && substr(what,1,length(field)) != field) {
	what = substr(what,2);
    }
    what = substr(what,length(field)+1);
    if (debug) printf("debug: after scan for %s line = %s...\n", field, what) >> "/dev/stderr";
    if (substr(what,1,1) == "\"") what = substr(what,2);
    resu = "";
    while (length(what) > 0 && substr(what,1,1) != "\"") {
	if (substr(what,1,1) == "&") break;
	resu = resu substr(what,1,1);
	what = substr(what,2);
    }
    
    return(resu);
    
}

function checkiffinlandready() {

    if (debug) printf("debug: checking if the entry for %s is ready...\n", colname) >> "/dev/stderr";
    
    if (colname != "" &&
	colpwrnominal > 0 &&
	colkwh > 0 &&
	colnethead > 0) {
	
	nethead[colname] = colnethead;
	reportone("finland","generic");
	colctr = 1;
	colname = "";
	colpwrnominal = 0;
	colkwh = 0;
	colnethead = 0;
	
    }
    
}

BEGIN {
    if (debug) printf("debug: begin...\n") >> "/dev/stderr";
    inrow = 0;
    colctr = 0;
    FS = "[<>:]";
}

/^<td width="135" bgcolor="#63B8FF"><b>Perustaja.omistaja<.b>$/ {
    if (debug) printf("debug: found table start...\n") >> "/dev/stderr";
    inrow = 1;
    next;
}

/^<.td><.tr>$/ {
    colctr = 0;
    next;
}

/^<script>/ {
    next;
}

/^<.td>$/ {
    next;
}

/^<tr>$/ {
    colctr = 1;
    next;
}

/^<td>$/ {
    next;
}

/^<td>.Koski.*$/ {
    next;
}

/^<td>[A-Z].*$/ {
    next;
}

/^<.td><.tr><.tbody>/ {
    inrow =0;
    next;
}
 
/^<td>[0-9,]+.*$/ {
    if (inrow) {
	if (colctr == 2) {
	    colpwrnominal = convcommas($3);
	} else if (colctr == 3) {
	    colkwh = 1000.0 * convcommas($3);
	} else if (colctr == 4) {
	    colnethead = convcommas($3);
	    checkiffinlandready();
	}
    }
    colctr++;
    next;
}

/^<td>.*title=.*$/ {
    if (inrow) {
	if (debug) printf("debug: looking at title line %s...\n", $0) >> "/dev/stderr";
	if (colctr == 1) {
	    colname = tolower(getstring($0,"title="));
	    if (debug) printf("debug: found entry for %s...\n", colname) >> "/dev/stderr";
	}
    }
    colctr++;
    next;
}

/.*/ {
    if (inrow) {
	if (debug) printf("debug: ending table due to line %s...\n", $0) >> "/dev/stderr";
	inrow = 0;
	next;
    o}
}
