BEGIN {
  inrow = 0;
  FS = "[<>:]";
}

/table id="tabela_solar"/ {
  exit(0);
}

/^nethead:/ {
  name = $2;
  val = $3;
  nethead[name] = val;
  #printf("installed nethead for %s as %s\n", name, val) >> "/dev/stderr";
  next;
}
    
/^	<tr>$/ {
  inrow = 1;
  colno = 1;
  colname = "";
  rownum = 0;
  colmaxkwh = 0;
  next;
}

/^<.tr>$/ {
  if (inrow && colname != "" && rownum > 0 && colmaxkwh > 0) {
      #printf("looking for nethead for %s: %s\n", colname, nethead[colname]) >> "/dev/stderr";
      if (nethead[colname] != "") netheadinfo = nethead[name];
      else netheadinfo = "";
      printf("hydroplant:%s:%s:%s:%s\n",rownum,colname,colmaxkwh,netheadinfo);
  }
  inrow = 0;
  colno = 0;
  next;
}

/^<td>[0-9]+<.td>$/ {
  if (inrow && (colno == 1 || colno == 6)) {
    if (colno == 1) rownum = $3;
    else if (colno == 6) colmaxkwh = $3;
    else {
      inrow = 0;
      next;
    }
    colno++;
  }
  next;
}

/^<td>[0-9]+[.][0-9]+<.td>$/ {
  if (inrow && colno == 6) {
    if (colno == 6) colmaxkwh = $3;
    else {
      inrow = 0;
      next;
    }
    colno++;
  }
  next;
}

/^<td><a href.*/ {
  if (inrow) {
    colno++;
  }
  next;
}

/^<td>[0-9]+[.][0-9]+[.][0-9]+<.td>$/ {
  if (inrow) {
    colno++;
  }
  next;
}

/^<td>/ {
  if (inrow) {
    if (colno == 5) {
	#printf("handling colname %s...\n", $3) >> "/dev/stderr";
	colname = handlecolname($3);
	#printf("result = %s\n", colname) >> "/dev/stderr";
    }
    colno++;
  }
  next;
}

/.*/ {
  inrow = 0;
  next;
}
