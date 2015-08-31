
# set workspace if specified
if [ "$2" != "" ]; then
    awb-shell set workspace $2;
fi

WORKSPACE=`awb-shell show workspace | grep 'Workspace directory' | sed -e "s/Workspace directory: //g"`
WORKDIR=$WORKSPACE/build/default;

echo "********************************************";
echo "";
echo "Work space directory: $WORKSPACE";
echo "Build directory: $WORKDIR";
echo "";
echo "********************************************";

MODEL_NAME=`echo $1 | sed -e "s/.apm//g"`;
if [ "$MODEL_NAME" != "" ]; then
    rm -r $WORKDIR/$MODEL_NAME;
fi

rm -f model/*.v
rm -f model/*.dat
rm -f model/*.hex
rm -f model/MyIP.bsv
cp generated_verilog/*.v model/.
cp generated_verilog/*.dat model/.
cp generated_verilog/*.hex model/.
cp wrappers/bluespec/*.bsv model/.

echo " "
echo "***************************************************"
echo "***************************************************"
echo "make sure to include these lines in your mem-perf-common.awb file:"
echo ""
cd model
for f in `ls MyIP.bsv`; do
  echo "%public $f"
done
for f in `ls *.v`; do
  echo "%public $f"
done
for f in `ls *.dat`; do
  echo "%public $f"
done
for f in `ls *.hex`; do
  echo "%public $f"
done
echo ""
cd ..
echo "***************************************************"
echo "***************************************************"
echo " "

awb-shell -- nuke model $1
awb-shell -- configure model $1
awb-shell -- clean model $1
awb-shell -- build model $1
awb-shell -- setup benchmark config/bm/leap/demos.cfx/benchmarks/null.cfg --model $1

rm -f model/*.v
rm -f model/*.dat
rm -f model/*.hex
rm -f model/MyIP.bsv
