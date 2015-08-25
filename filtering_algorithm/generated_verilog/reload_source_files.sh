
rm -f *.v
rm -f *.hex
rm -f *.dat

echo "Have you generated the RTL design in ../VivadoHLS/filtering_algorithm_extmem ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
	echo "copying sources from ../VivadoHLS/filtering_algorithm_extmem/solution1/impl/verilog/.";
	cp ../VivadoHLS/filtering_algorithm_extmem/solution1/impl/verilog/*.v .;
	cp ../VivadoHLS/golden_ref/*.hex .;
	cp ../VivadoHLS/golden_ref/*.dat .;
	break;;
        No ) 
	echo "copying sources from golden_ref/."; 
	cp golden_ref/*.v .; 
	cp golden_ref/*.hex .; 
	cp golden_ref/*.dat .;
	break;;
    esac
done
