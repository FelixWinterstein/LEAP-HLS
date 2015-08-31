all:
	rm -f *.v
	rm -f *.hex
	rm -fR obj
	cp ../generated_verilog/*.v .
	cp ../generated_verilog/*.hex .
	cp ../wrappers/bluespec/*.bsv .
	mkdir obj
	# compile it
	bsc -u -verilog \
		-vdir obj -bdir obj -simdir obj -p .:obj:+ \
	  	-unspecified-to 0 TB.bsv

	make run

run:
	# run it
	bsc -vsim iverilog -e mkTB -o obj/mkTB.exe *.v obj/*.v
	obj/mkTB.exe

clean:
	rm -f MyIP.bsv
	rm -f *.v
	rm -f *.hex
	rm -fR obj
