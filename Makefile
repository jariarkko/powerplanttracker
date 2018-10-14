
all:

install:
	./ppt_checkforsoftware.sh gawk 
	./ppt_checkforsoftware.sh wget
	./ppt_checkforsoftware.sh pdftotext "poppler"

#	./ppt_checkforsoftware.sh textutil
#	./ppt_checkforsoftware.sh py_xls2html "python-excelerator w3m"

wc:
	wc *.sh *.awk

clean:
	rm -f *~
