
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

PWDVAR=`pwd`;
cd $WORKDIR/$MODEL_NAME/bm/null ;
mkdir $MODEL_NAME ;
cd $MODEL_NAME ;
ln -s /dev/null dump.vcd ;
cd $PWDVAR ;
cp generated_verilog/*.dat $WORKDIR/$MODEL_NAME/bm/null/$MODEL_NAME/.
cp generated_verilog/*.dat $WORKDIR/$MODEL_NAME/bm/null/.
cp generated_verilog/*.hex $WORKDIR/$MODEL_NAME/bm/null/$MODEL_NAME/.
awb-shell -- run benchmark config/bm/leap/demos.cfx/benchmarks/null.cfg --model $1
