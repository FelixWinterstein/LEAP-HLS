
rm -f *.v

echo "Have you generated the RTL design in ../VivadoHLS/hello_world ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
	echo "copying sources from ../VivadoHLS/hello_world/solution1/impl/verilog/.";
	cp ../VivadoHLS/hello_world/solution1/impl/verilog/*.v .;
        echo "copying initialization files from ../VivadoHLS/hello_world/solution1/csim/build/.";
        cp ../VivadoHLS/hello_world/solution1/csim/build/*.{hex,dat} .;
	break;;

        No )
	echo "copying sources from golden_ref/.";
	cp golden_ref/*.v .;
        echo "copying initialization files from golden_ref/..";
        cp golden_ref/*.{hex,dat} .;
	break;;
    esac
done
