
rm -f *.v
rm -f *.dat

echo "Have you generated the RTL design in ../VivadoHLS/merger ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
	echo "copying sources from ../VivadoHLS/merger/solution1/impl/verilog/.";
	cp ../VivadoHLS/merger/solution1/impl/verilog/*.v .;
	cp ../VivadoHLS/merger/solution1/csim/build/*.dat .;
	cp ../VivadoHLS/merger/solution1/csim/build/*.hex .;
	break;;
        No )
	echo "copying sources from golden_ref/.";
	cp golden_ref/*.v .;
	cp golden_ref/*.dat .;
	cp golden_ref/*.hex .;
	break;;
    esac
done
