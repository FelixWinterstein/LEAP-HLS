/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: privateSPInterface.bsv
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

import FIFO::*;
import RegFile::*;
import LFSR::*;

import MyIP::*;
import simulated_memory::*;

typedef Bit#(32) TD_io;
typedef Bit#(64) TD_bus;
typedef Bit#(32) TA;

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


typedef enum
{
    MEMSTATE_idle,
    MEMSTATE_busy
}
MEMSTATE
    deriving (Bits, Eq);


(* synthesize *)
module mkTB();

    // here is the IP
    MY_IP_WITH_BUNDLES_IFC#(TD_bus, TA, TD_io) merger_top_wrapper <- mkMyIPWithBundles;

    // instantiate simulated memories
    PRIVATESP_IFC#(TA,TA) memory0 <- mkSimulatedMemory(merger_top_wrapper.busPort0, 0);
    PRIVATESP_IFC#(TA,TA) memory1 <- mkSimulatedMemory(merger_top_wrapper.busPort1, 1);
    PRIVATESP_IFC#(TA,TA) memory2 <- mkSimulatedMemory(merger_top_wrapper.busPort2, 2);
    PRIVATESP_IFC#(TA,TA) memory3 <- mkSimulatedMemory(merger_top_wrapper.busPort3, 3);
    PRIVATESP_IFC#(TA,TD_bus) memory4 <- mkSimulatedMemory(merger_top_wrapper.busPort4, 4);
    PRIVATESP_IFC#(TA,TD_bus) memory5 <- mkSimulatedMemory(merger_top_wrapper.busPort5, 5);
    PRIVATESP_IFC#(TA,TD_bus) memory6 <- mkSimulatedMemory(merger_top_wrapper.busPort6, 6);
    PRIVATESP_IFC#(TA,TD_bus) memory7 <- mkSimulatedMemory(merger_top_wrapper.busPort7, 7);
    

    // random number generators
    LFSR#(Bit#(16)) lfsr0 <- mkLFSR_16 ;
    LFSR#(Bit#(16)) lfsr1 <- mkLFSR_16 ;
    LFSR#(Bit#(16)) lfsr2 <- mkLFSR_16 ;
    LFSR#(Bit#(16)) lfsr3 <- mkLFSR_16 ;

   
    Reg#(STATE) state <- mkReg(STATE_idle);
    Reg#(UInt#(32)) cycleCounter <- mkReg(0);
    Reg#(UInt#(32)) startCycle <- mkReg(0);
    Reg#(UInt#(32)) endCycle <- mkReg(0);   

    // number of inputs per channel
    Reg#(TA) n <- mkReg(64);

    /* FSM */

    rule idle (STATE_idle == state);
        state <= STATE_start;        
    endrule


    rule start (STATE_start == state);
        lfsr0.seed('h10);
        lfsr1.seed('h11);
        lfsr2.seed('h12);
        lfsr3.seed('h13);
        $display("[%d] Start",cycleCounter);
        startCycle <= cycleCounter;
        merger_top_wrapper.start();
        state <= STATE_processing;        
    endrule    


    rule processing (STATE_processing == state);

        merger_top_wrapper.fifoInPort0.enDataIn();
        merger_top_wrapper.fifoInPort1.enDataIn();
        merger_top_wrapper.fifoInPort2.enDataIn();
        merger_top_wrapper.fifoInPort3.enDataIn();
        merger_top_wrapper.fifoOutPort0.enDataOut();

        if ( merger_top_wrapper.ipDone() ) 
        begin
            $display("[%d] Done: %d cycles",cycleCounter,cycleCounter-startCycle);
            state <= STATE_done;    
        end                
        
    endrule 

    (* fire_when_enabled *)
    rule setN ( True );
        merger_top_wrapper.setN(n);
    endrule

    rule done (STATE_done == state);
        $finish(1);     
    endrule  



    // ====================================================================
    //
    // core FIFOs (input/output).
    //
    // ====================================================================

    rule data_in0 (True);
        merger_top_wrapper.fifoInPort0.data_in( zeroExtend(lfsr0.value));
        lfsr0.next;
        //$display("data_in0");    
    endrule 

    rule data_in1 (True);
        merger_top_wrapper.fifoInPort1.data_in( zeroExtend(lfsr1.value));
        lfsr1.next;
        //$display("data_in1");         
    endrule 

    rule data_in2 (True);
        merger_top_wrapper.fifoInPort2.data_in( zeroExtend(lfsr2.value));
        lfsr2.next;
        //$display("data_in2");         
    endrule 

    rule data_in3 (True);
        merger_top_wrapper.fifoInPort3.data_in( zeroExtend(lfsr3.value));
        lfsr3.next;
        //$display("data_in3");         
    endrule 

    rule data_out (True);        
        TD_io a = merger_top_wrapper.fifoOutPort0.data_out();
        $display("[%d] data_out: %d",cycleCounter,a);
    endrule 


    // ====================================================================
    //
    // Stats.
    //
    // ====================================================================

    
    (* fire_when_enabled *)
    rule cycle_count (True);
        cycleCounter <= cycleCounter + 1;
    endrule



endmodule
