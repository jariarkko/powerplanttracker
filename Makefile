
all:

install:
	./ppt_checkforsoftware.sh gawk
	./ppt_checkforsoftware.sh wget
	./ppt_checkforsoftware.sh pdftotext

wc:
	wc *.sh *.awk

clean:
	rm -f *~
