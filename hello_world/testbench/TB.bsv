/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: MyIP.bsv
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

//import StmtFSM::*;
import FIFO::*;
import FIFOF::*;
import RegFile::*;

import MyIP::*;
import simulated_memory::*;

typedef Bit#(32) TD;
typedef Bit#(32) TA;


typedef 2 MEM_LATENCY;  // shouldn't be less than 1

typedef enum
{
    STATE_idle,
    STATE_start,
    STATE_processing,
    STATE_reading,
    STATE_finished,
    STATE_done
}
STATE
    deriving (Bits, Eq);



(* synthesize *)
module mkTB();

    // here is the IP
    MY_IP_WITH_MEM_BUS_IFC#(TD,TA) hello_world_wrapper <- mkMyIPWithMemBus;

    // instantiate simulated memories
    PRIVATESP_IFC#(TA,TD) memory0 <- mkSimulatedMemory(hello_world_wrapper.busPort0, 0);
    PRIVATESP_IFC#(TA,TD) memory1 <- mkSimulatedMemory(hello_world_wrapper.busPort1, 1);

    // fsm and stats
    Reg#(STATE) state <- mkReg(STATE_idle);
    Reg#(UInt#(32)) cycleCounter <- mkReg(0);
    Reg#(UInt#(32)) startCycle <- mkReg(0);
    Reg#(UInt#(32)) endCycle <- mkReg(0);


    /* FSM */


    // testbench starts here
    rule idle (STATE_idle == state);
        state <= STATE_start;
    endrule


    rule start (STATE_start == state);
        $display("Start HLS core");
        startCycle <= cycleCounter;
        hello_world_wrapper.start();
        state <= STATE_processing;        
    endrule    


    rule processing (STATE_processing == state);

        if ( hello_world_wrapper.ipDone() ) 
        begin
            endCycle <= cycleCounter; 
            $display("[%d] Done: %d cycles",cycleCounter,cycleCounter-startCycle);
            state <= STATE_done;    
        end                
        
    endrule 

    rule done (STATE_done == state);
        $finish(1);     
    endrule  




    // ====================================================================
    //
    // stats.
    //
    // ====================================================================/

    
    (* fire_when_enabled *)
    rule cycle_count (True);
        cycleCounter <= cycleCounter + 1;
    endrule
    


endmodule
