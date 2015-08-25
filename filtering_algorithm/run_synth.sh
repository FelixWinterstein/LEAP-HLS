
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

cp generated_verilog/*.dat $WORKDIR/$MODEL_NAME/bm/null/.

awb-shell -- run benchmark config/bm/leap/demos.cfx/benchmarks/null.cfg --model $1
