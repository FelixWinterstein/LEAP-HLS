/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: TB.bsv
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

//import StmtFSM::*;
import FIFO::*;
import FIFOF::*;
import RegFile::*;
import LFSR::*;

import MyIP::*;
typedef Bit#(400) TD_in1;
typedef Bit#(32) TD_in2;
typedef Bit#(8) TD_in3;
typedef Bit#(48) TD_in4;
typedef Bit#(48) TD_out1;
typedef Bit#(32) TD_out2;
typedef Bit#(512) TD_bus0;
typedef Bit#(8) TD_bus1;
typedef Bit#(96) TD_bus2;
typedef Bit#(64) TD_bus3;
typedef Bit#(32) TD_bus4;
typedef Bit#(32) TA;


typedef 2 READ_MEM_LATENCY; 
typedef 2 WRITE_MEM_LATENCY;

//`define RANDOM_LATENCY
`define MEM_REGION_SIZE 8*32768
`define N 128
`define K 4
`define P 4
//`define REDUCE_PAR_TO_1
//`define REDUCE_PAR_TO_2
//`define CENTRE_BUFFER_ONCHIP

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
    MyIP#(TD_in1, TD_in2, TD_in3, TD_in4, TD_out1, TD_out2, TD_bus0, TD_bus1, TD_bus2, TD_bus3, TD_bus4, TA) filtering_algorithm_top_wrapper <- mkMyIP; 
    
    RegFile#(TA,TD_bus0) memory0_0 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    RegFile#(TA,TD_bus1) memory0_1 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    RegFile#(TA,TD_bus2) memory0_2 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    `ifndef CENTRE_BUFFER_ONCHIP
    RegFile#(TA,TD_bus3) memory0_3 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    `endif
    RegFile#(TA,TD_bus4) memory0_4 <- mkRegFileLoad("freelist_initialization.hex",0,1023);

    `ifndef REDUCE_PAR_TO_1
    RegFile#(TA,TD_bus0) memory1_0 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    RegFile#(TA,TD_bus1) memory1_1 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    RegFile#(TA,TD_bus2) memory1_2 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    `ifndef CENTRE_BUFFER_ONCHIP
    RegFile#(TA,TD_bus3) memory1_3 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    `endif
    RegFile#(TA,TD_bus4) memory1_4 <- mkRegFileLoad("freelist_initialization.hex",0,1023);

    `ifndef REDUCE_PAR_TO_2
    RegFile#(TA,TD_bus0) memory2_0 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    RegFile#(TA,TD_bus1) memory2_1 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    RegFile#(TA,TD_bus2) memory2_2 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    `ifndef CENTRE_BUFFER_ONCHIP
    RegFile#(TA,TD_bus3) memory2_3 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    `endif
    RegFile#(TA,TD_bus4) memory2_4 <- mkRegFileLoad("freelist_initialization.hex",0,1023);

    RegFile#(TA,TD_bus0) memory3_0 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    RegFile#(TA,TD_bus1) memory3_1 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    RegFile#(TA,TD_bus2) memory3_2 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    `ifndef CENTRE_BUFFER_ONCHIP
    RegFile#(TA,TD_bus3) memory3_3 <- mkRegFile(0,`MEM_REGION_SIZE-1);
    `endif
    RegFile#(TA,TD_bus4) memory3_4 <- mkRegFileLoad("freelist_initialization.hex",0,1023);

    `endif
    `endif

    FIFOF#(TA) readAddrFifo0_0 <- mkSizedFIFOF(16);
    FIFOF#(TA) readAddrFifo0_1 <- mkSizedFIFOF(16);
    FIFOF#(TA) readAddrFifo0_2 <- mkSizedFIFOF(16);
    `ifndef CENTRE_BUFFER_ONCHIP
    FIFOF#(TA) readAddrFifo0_3 <- mkSizedFIFOF(16);
    `endif
    FIFOF#(TA) readAddrFifo0_4 <- mkSizedFIFOF(16);

    `ifndef REDUCE_PAR_TO_1
    FIFOF#(TA) readAddrFifo1_0 <- mkSizedFIFOF(16);
    FIFOF#(TA) readAddrFifo1_1 <- mkSizedFIFOF(16);
    FIFOF#(TA) readAddrFifo1_2 <- mkSizedFIFOF(16);
    `ifndef CENTRE_BUFFER_ONCHIP
    FIFOF#(TA) readAddrFifo1_3 <- mkSizedFIFOF(16);
    `endif
    FIFOF#(TA) readAddrFifo1_4 <- mkSizedFIFOF(16);

    `ifndef REDUCE_PAR_TO_2
    FIFOF#(TA) readAddrFifo2_0 <- mkSizedFIFOF(16);
    FIFOF#(TA) readAddrFifo2_1 <- mkSizedFIFOF(16);
    FIFOF#(TA) readAddrFifo2_2 <- mkSizedFIFOF(16);
    `ifndef CENTRE_BUFFER_ONCHIP
    FIFOF#(TA) readAddrFifo2_3 <- mkSizedFIFOF(16);
    `endif
    FIFOF#(TA) readAddrFifo2_4 <- mkSizedFIFOF(16);

    FIFOF#(TA) readAddrFifo3_0 <- mkSizedFIFOF(16);
    FIFOF#(TA) readAddrFifo3_1 <- mkSizedFIFOF(16);
    FIFOF#(TA) readAddrFifo3_2 <- mkSizedFIFOF(16);
    `ifndef CENTRE_BUFFER_ONCHIP
    FIFOF#(TA) readAddrFifo3_3 <- mkSizedFIFOF(16);
    `endif
    FIFOF#(TA) readAddrFifo3_4 <- mkSizedFIFOF(16);

    `endif
    `endif
   
    Reg#(STATE) state <- mkReg(STATE_idle);
    Reg#(UInt#(32)) cycleCounter <- mkReg(0);
    Reg#(UInt#(32)) startCycle <- mkReg(0);
    Reg#(UInt#(32)) endCycle <- mkReg(0);    


    Reg#(MEMSTATE) read_state0_0 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state0_1 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state0_2 <- mkReg(MEMSTATE_idle);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(MEMSTATE) read_state0_3 <- mkReg(MEMSTATE_idle);
    `endif
    Reg#(MEMSTATE) read_state0_4 <- mkReg(MEMSTATE_idle);

    Reg#(UInt#(32)) readLatCounter0_0 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter0_1 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter0_2 <- mkReg(0);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(UInt#(32)) readLatCounter0_3 <- mkReg(0);
    `endif
    Reg#(UInt#(32)) readLatCounter0_4 <- mkReg(0);

    `ifndef REDUCE_PAR_TO_1
    Reg#(MEMSTATE) read_state1_0 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state1_1 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state1_2 <- mkReg(MEMSTATE_idle);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(MEMSTATE) read_state1_3 <- mkReg(MEMSTATE_idle);
    `endif
    Reg#(MEMSTATE) read_state1_4 <- mkReg(MEMSTATE_idle);

    Reg#(UInt#(32)) readLatCounter1_0 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter1_1 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter1_2 <- mkReg(0);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(UInt#(32)) readLatCounter1_3 <- mkReg(0);
    `endif
    Reg#(UInt#(32)) readLatCounter1_4 <- mkReg(0);

    `ifndef REDUCE_PAR_TO_2
    Reg#(MEMSTATE) read_state2_0 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state2_1 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state2_2 <- mkReg(MEMSTATE_idle);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(MEMSTATE) read_state2_3 <- mkReg(MEMSTATE_idle);
    `endif
    Reg#(MEMSTATE) read_state2_4 <- mkReg(MEMSTATE_idle);

    Reg#(UInt#(32)) readLatCounter2_0 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter2_1 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter2_2 <- mkReg(0);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(UInt#(32)) readLatCounter2_3 <- mkReg(0);
    `endif
    Reg#(UInt#(32)) readLatCounter2_4 <- mkReg(0);

    Reg#(MEMSTATE) read_state3_0 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state3_1 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state3_2 <- mkReg(MEMSTATE_idle);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(MEMSTATE) read_state3_3 <- mkReg(MEMSTATE_idle);
    `endif
    Reg#(MEMSTATE) read_state3_4 <- mkReg(MEMSTATE_idle);

    Reg#(UInt#(32)) readLatCounter3_0 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter3_1 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter3_2 <- mkReg(0);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(UInt#(32)) readLatCounter3_3 <- mkReg(0);
    `endif
    Reg#(UInt#(32)) readLatCounter3_4 <- mkReg(0);

    `endif
    `endif

    
    Reg#(MEMSTATE) write_state0_0 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state0_1 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state0_2 <- mkReg(MEMSTATE_idle);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(MEMSTATE) write_state0_3 <- mkReg(MEMSTATE_idle);
    `endif
    Reg#(MEMSTATE) write_state0_4 <- mkReg(MEMSTATE_idle);

    Reg#(UInt#(32)) writeLatCounter0_0 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter0_1 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter0_2 <- mkReg(0);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(UInt#(32)) writeLatCounter0_3 <- mkReg(0);
    `endif
    Reg#(UInt#(32)) writeLatCounter0_4 <- mkReg(0);

    `ifndef REDUCE_PAR_TO_1
    Reg#(MEMSTATE) write_state1_0 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state1_1 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state1_2 <- mkReg(MEMSTATE_idle);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(MEMSTATE) write_state1_3 <- mkReg(MEMSTATE_idle);
    `endif
    Reg#(MEMSTATE) write_state1_4 <- mkReg(MEMSTATE_idle);

    Reg#(UInt#(32)) writeLatCounter1_0 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter1_1 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter1_2 <- mkReg(0);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(UInt#(32)) writeLatCounter1_3 <- mkReg(0);
    `endif
    Reg#(UInt#(32)) writeLatCounter1_4 <- mkReg(0);

    `ifndef REDUCE_PAR_TO_2
    Reg#(MEMSTATE) write_state2_0 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state2_1 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state2_2 <- mkReg(MEMSTATE_idle);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(MEMSTATE) write_state2_3 <- mkReg(MEMSTATE_idle);
    `endif
    Reg#(MEMSTATE) write_state2_4 <- mkReg(MEMSTATE_idle);

    Reg#(UInt#(32)) writeLatCounter2_0 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter2_1 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter2_2 <- mkReg(0);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(UInt#(32)) writeLatCounter2_3 <- mkReg(0);
    `endif
    Reg#(UInt#(32)) writeLatCounter2_4 <- mkReg(0);

    Reg#(MEMSTATE) write_state3_0 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state3_1 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state3_2 <- mkReg(MEMSTATE_idle);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(MEMSTATE) write_state3_3 <- mkReg(MEMSTATE_idle);
    `endif
    Reg#(MEMSTATE) write_state3_4 <- mkReg(MEMSTATE_idle);

    Reg#(UInt#(32)) writeLatCounter3_0 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter3_1 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter3_2 <- mkReg(0);
    `ifndef CENTRE_BUFFER_ONCHIP
    Reg#(UInt#(32)) writeLatCounter3_3 <- mkReg(0);
    `endif
    Reg#(UInt#(32)) writeLatCounter3_4 <- mkReg(0);

    `endif
    `endif    

    `ifdef RANDOM_LATENCY
    // random number generators
    LFSR#(Bit#(8)) lfsr0_0 <- mkLFSR_8 ;
    LFSR#(Bit#(8)) lfsr0_1 <- mkLFSR_8 ;
    LFSR#(Bit#(8)) lfsr0_2 <- mkLFSR_8 ;
    `ifndef CENTRE_BUFFER_ONCHIP
    LFSR#(Bit#(8)) lfsr0_3 <- mkLFSR_8 ;
    `endif
    LFSR#(Bit#(8)) lfsr0_4 <- mkLFSR_8 ;

    `ifndef REDUCE_PAR_TO_1
    LFSR#(Bit#(8)) lfsr1_0 <- mkLFSR_8 ;
    LFSR#(Bit#(8)) lfsr1_1 <- mkLFSR_8 ;
    LFSR#(Bit#(8)) lfsr1_2 <- mkLFSR_8 ;
    `ifndef CENTRE_BUFFER_ONCHIP
    LFSR#(Bit#(8)) lfsr1_3 <- mkLFSR_8 ;
    `endif
    LFSR#(Bit#(8)) lfsr1_4 <- mkLFSR_8 ;

    `ifndef REDUCE_PAR_TO_2
    LFSR#(Bit#(8)) lfsr2_0 <- mkLFSR_8 ;
    LFSR#(Bit#(8)) lfsr2_1 <- mkLFSR_8 ;
    LFSR#(Bit#(8)) lfsr2_2 <- mkLFSR_8 ;
    `ifndef CENTRE_BUFFER_ONCHIP
    LFSR#(Bit#(8)) lfsr2_3 <- mkLFSR_8 ;
    `endif
    LFSR#(Bit#(8)) lfsr2_4 <- mkLFSR_8 ;

    LFSR#(Bit#(8)) lfsr3_0 <- mkLFSR_8 ;
    LFSR#(Bit#(8)) lfsr3_1 <- mkLFSR_8 ;
    LFSR#(Bit#(8)) lfsr3_2 <- mkLFSR_8 ;
    `ifndef CENTRE_BUFFER_ONCHIP
    LFSR#(Bit#(8)) lfsr3_3 <- mkLFSR_8 ;
    `endif
    LFSR#(Bit#(8)) lfsr3_4 <- mkLFSR_8 ;
    `endif
    `endif
    `endif


    // number of inputs per channel
    Reg#(TD_in2) n <- mkReg(2*`N-1-1-(`P-1));
    Reg#(TD_in3) k <- mkReg(`K-1);
    Reg#(TD_in2) l <- mkReg(1);

    // File IO
    
    RegFile#(TA, TD_in4) cntrIn <- mkRegFileLoad("initial_centres_N128_K4_D3_s0.75_1.hex", 0, `K-1);
    RegFile#(TA, TD_in1) treeDataIn <- mkRegFileLoad("tree_data_N128_K4_D3_s0.75.hex", 0, 2*`N-1-1-(`P-1));
    RegFile#(TA, TD_in1) treeAddrIn <- mkRegFileLoad("tree_data_N128_K4_D3_s0.75.hex", 0, 2*`N-1-1-(`P-1));
    
    /*
    RegFile#(TA, TD_in4) cntrIn <- mkRegFileLoad("initial_centres_N16384_K128_D3_s0.20_1.hex", 0, `K-1);
    RegFile#(TA, TD_in1) treeDataIn <- mkRegFileLoad("tree_data_N16384_K128_D3_s0.20.hex", 0, 2*`N-1-1-(`P-1));
    RegFile#(TA, TD_in1) treeAddrIn <- mkRegFileLoad("tree_data_N16384_K128_D3_s0.20.hex", 0, 2*`N-1-1-(`P-1));
    */

    Reg#(TA) cntrInCounter <- mkReg(0);
    Reg#(TA) treeDataInCounter <- mkReg(0);
    Reg#(TA) treeAddrInCounter <- mkReg(0);

    /* FSM */

    rule idle (STATE_idle == state);
        state <= STATE_start;        
    endrule


    rule start (STATE_start == state);
        $display("[%d] Start",cycleCounter);
        startCycle <= cycleCounter;

        `ifdef RANDOM_LATENCY
        lfsr0_0.seed('h1);
        lfsr0_1.seed('h2);
        lfsr0_2.seed('h3);
        `ifndef CENTRE_BUFFER_ONCHIP
        lfsr0_3.seed('hD);
        `endif
        lfsr0_4.seed('hD);

        `ifndef REDUCE_PAR_TO_1
        lfsr1_0.seed('h4);
        lfsr1_1.seed('h5);
        lfsr1_2.seed('h6);
        `ifndef CENTRE_BUFFER_ONCHIP
        lfsr1_3.seed('hE);
        `endif
        lfsr1_4.seed('hE);

        `ifndef REDUCE_PAR_TO_2
        lfsr2_0.seed('h7);
        lfsr2_1.seed('h8);
        lfsr2_2.seed('h9);
        `ifndef CENTRE_BUFFER_ONCHIP
        lfsr2_3.seed('hF);
        `endif
        lfsr2_4.seed('hF);

        lfsr3_0.seed('hA);
        lfsr3_1.seed('hB);
        lfsr3_2.seed('hC);
        `ifndef CENTRE_BUFFER_ONCHIP
        lfsr3_3.seed('h0);
        `endif
        lfsr3_4.seed('h0);
        `endif
        `endif
        `endif

        filtering_algorithm_top_wrapper.start();
        state <= STATE_processing;        
    endrule    


    rule processing (STATE_processing == state);

        filtering_algorithm_top_wrapper.en_i_node_data();
        filtering_algorithm_top_wrapper.en_root();
        filtering_algorithm_top_wrapper.en_cntr_pos_init();
        filtering_algorithm_top_wrapper.en_clusters_out();
        filtering_algorithm_top_wrapper.en_distortion_out();


        if ( filtering_algorithm_top_wrapper.ipDone() ) 
        begin
            $display("[%d] Done: %d cycles",cycleCounter,cycleCounter-startCycle);
            state <= STATE_done;    
        end                
        
    endrule 

    (* fire_when_enabled *)
    rule setN ( True );
        filtering_algorithm_top_wrapper.setN(n);
    endrule

    (* fire_when_enabled *)
    rule setK ( True );
        filtering_algorithm_top_wrapper.setK(k);
    endrule

    (* fire_when_enabled *)
    rule setL ( True );
        filtering_algorithm_top_wrapper.setL(l);
    endrule

    rule done (STATE_done == state);
        $finish(1);     
    endrule  



    // ====================================================================
    //
    // core FIFOs (input/output).
    //
    // ====================================================================

    rule i_node_data (True);
        treeDataInCounter <= treeDataInCounter + 1;
        filtering_algorithm_top_wrapper.i_node_data( treeDataIn.sub(treeDataInCounter) );
        $display("[%d] reading i_node_data from FIFO: (%d) val = %x", cycleCounter, treeDataInCounter, treeDataIn.sub(treeDataInCounter));    
    endrule 

    rule root (True);
        filtering_algorithm_top_wrapper.root( 1);        
        //$display("reading root from FIFO");         
    endrule 

    rule cntr_pos_init (True);
        cntrInCounter <= cntrInCounter + 1;

        filtering_algorithm_top_wrapper.cntr_pos_init( cntrIn.sub(cntrInCounter));
        $display("[%d] reading cntr_pos_init from FIFO: (%d) val = %x", cycleCounter, cntrInCounter, cntrIn.sub(cntrInCounter));         
    endrule 

    rule clusters_out (True);        
        TD_out1 d = filtering_algorithm_top_wrapper.clusters_out();
        $display("[%d] clusters_out: %x",cycleCounter,d);
    endrule 

    rule distortion_out (True);        
        TD_out2 d = filtering_algorithm_top_wrapper.distortion_out();
        $display("[%d] distortion_out: %d",cycleCounter,d);
    endrule 


    // ====================================================================
    //
    // memory writes.
    //
    // ====================================================================/

    (* fire_when_enabled *)
    rule bus_write0_0 ( True );   
        write_state0_0 <= MEMSTATE_busy ;
        writeLatCounter0_0 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr0_0();
        TD_bus0 d = filtering_algorithm_top_wrapper.writeData0_0();
        memory0_0.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write0_0: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write0_1 ( True );   
        write_state0_1 <= MEMSTATE_busy ;
        writeLatCounter0_1 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr0_1();
        TD_bus1 d = filtering_algorithm_top_wrapper.writeData0_1();
        memory0_1.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write0_1: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write0_2 ( True );   
        write_state0_2 <= MEMSTATE_busy ;
        writeLatCounter0_2 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr0_2();
        TD_bus2 d = filtering_algorithm_top_wrapper.writeData0_2();
        memory0_2.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write0_2: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule bus_write0_3 ( True );   
        write_state0_3 <= MEMSTATE_busy ;
        writeLatCounter0_3 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr0_3();
        TD_bus3 d = filtering_algorithm_top_wrapper.writeData0_3();
        memory0_3.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write0_3: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule access_critical_region0 ( True );   
        Bool r = filtering_algorithm_top_wrapper.accessCriticalRegion0();
        if (r)
            $display("[%d] enter critical region 0",cycleCounter);
        else
            $display("[%d] leave critical region 0",cycleCounter);
    endrule 
    `endif

    (* fire_when_enabled *)
    rule bus_write0_4 ( True );   
        write_state0_4 <= MEMSTATE_busy ;
        writeLatCounter0_4 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr0_4();
        TD_bus4 d = filtering_algorithm_top_wrapper.writeData0_4();
        memory0_4.upd(a,d);
        $display("[%d] write0_4: addr = %x, val = %x",cycleCounter,a,d);
    endrule 


    `ifndef REDUCE_PAR_TO_1

    (* fire_when_enabled *)
    rule bus_write1_0 ( True );   
        write_state1_0 <= MEMSTATE_busy ;
        writeLatCounter1_0 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr1_0();
        TD_bus0 d = filtering_algorithm_top_wrapper.writeData1_0();
        memory1_0.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write1_0: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write1_1 ( True );   
        write_state1_1 <= MEMSTATE_busy ;
        writeLatCounter1_1 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr1_1();
        TD_bus1 d = filtering_algorithm_top_wrapper.writeData1_1();
        memory1_1.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write1_1: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write1_2 ( True );   
        write_state1_2 <= MEMSTATE_busy ;
        writeLatCounter1_2 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr1_2();
        TD_bus2 d = filtering_algorithm_top_wrapper.writeData1_2();
        memory1_2.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write1_2: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule bus_write1_3 ( True );   
        write_state1_3 <= MEMSTATE_busy ;
        writeLatCounter1_3 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr1_3();
        TD_bus3 d = filtering_algorithm_top_wrapper.writeData1_3();
        memory1_3.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write1_3: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule access_critical_region1 ( True );   
        Bool r = filtering_algorithm_top_wrapper.accessCriticalRegion1();
        if (r)
            $display("[%d] enter critical region 1",cycleCounter);
        else
            $display("[%d] leave critical region 1",cycleCounter);
    endrule 
    `endif

    (* fire_when_enabled *)
    rule bus_write1_4 ( True );   
        write_state1_4 <= MEMSTATE_busy ;
        writeLatCounter1_4 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr1_4();
        TD_bus4 d = filtering_algorithm_top_wrapper.writeData1_4();
        memory1_4.upd(a,d);
        $display("[%d] write1_4: addr = %x, val = %x",cycleCounter,a,d);
    endrule 


    `ifndef REDUCE_PAR_TO_2
    (* fire_when_enabled *)
    rule bus_write2_0 ( True );   
        write_state2_0 <= MEMSTATE_busy ;
        writeLatCounter2_0 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr2_0();
        TD_bus0 d = filtering_algorithm_top_wrapper.writeData2_0();
        memory2_0.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write2_0: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write2_1 ( True );   
        write_state2_1 <= MEMSTATE_busy ;
        writeLatCounter2_1 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr2_1();
        TD_bus1 d = filtering_algorithm_top_wrapper.writeData2_1();
        memory2_1.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write2_1: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write2_2 ( True );   
        write_state2_2 <= MEMSTATE_busy ;
        writeLatCounter2_2 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr2_2();
        TD_bus2 d = filtering_algorithm_top_wrapper.writeData2_2();
        memory2_2.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write2_2: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule bus_write2_3 ( True );   
        write_state2_3 <= MEMSTATE_busy ;
        writeLatCounter2_3 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr2_3();
        TD_bus3 d = filtering_algorithm_top_wrapper.writeData2_3();
        memory2_3.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write2_3: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule access_critical_region2 ( True );   
        Bool r = filtering_algorithm_top_wrapper.accessCriticalRegion2();
        if (r)
            $display("[%d] enter critical region 2",cycleCounter);
        else
            $display("[%d] leave critical region 2",cycleCounter);
    endrule 
    `endif

    (* fire_when_enabled *)
    rule bus_write2_4 ( True );   
        write_state2_4 <= MEMSTATE_busy ;
        writeLatCounter2_4 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr2_4();
        TD_bus4 d = filtering_algorithm_top_wrapper.writeData2_4();
        memory2_4.upd(a,d);
        $display("[%d] write2_4: addr = %x, val = %x",cycleCounter,a,d);
    endrule 


    (* fire_when_enabled *)
    rule bus_write3_0 ( True );   
        write_state3_0 <= MEMSTATE_busy ;
        writeLatCounter3_0 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr3_0();
        TD_bus0 d = filtering_algorithm_top_wrapper.writeData3_0();
        memory3_0.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write3_0: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write3_1 ( True );   
        write_state3_1 <= MEMSTATE_busy ;
        writeLatCounter3_1 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr3_1();
        TD_bus1 d = filtering_algorithm_top_wrapper.writeData3_1();
        memory3_1.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write3_1: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write3_2 ( True );   
        write_state3_2 <= MEMSTATE_busy ;
        writeLatCounter3_2 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr3_2();
        TD_bus2 d = filtering_algorithm_top_wrapper.writeData3_2();
        memory3_2.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write3_2: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule bus_write3_3 ( True );   
        write_state3_3 <= MEMSTATE_busy ;
        writeLatCounter3_3 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr3_3();
        TD_bus3 d = filtering_algorithm_top_wrapper.writeData3_3();
        memory3_3.upd(a,d);
        //UInt#(384) d2 = truncate(d);
        $display("[%d] write3_3: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule access_critical_region3 ( True );   
        Bool r = filtering_algorithm_top_wrapper.accessCriticalRegion3();
        if (r)
            $display("[%d] enter critical region 3",cycleCounter);
        else
            $display("[%d] leave critical region 3",cycleCounter);
    endrule 
    `endif

    (* fire_when_enabled *)
    rule bus_write3_4 ( True );   
        write_state3_4 <= MEMSTATE_busy ;
        writeLatCounter3_4 <= 0;
        TA a = filtering_algorithm_top_wrapper.writeAddr3_4();
        TD_bus4 d = filtering_algorithm_top_wrapper.writeData3_4();
        memory3_4.upd(a,d);
        $display("[%d] write3_4: addr = %x, val = %x",cycleCounter,a,d);
    endrule 

    `endif   
    `endif 


    rule write_lat0_0 ( write_state0_0 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr0_0.value));
        lfsr0_0.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter0_0 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state0_0 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter0_0 <= writeLatCounter0_0 + 1;
        end        
    endrule

    rule write_lat0_1 ( write_state0_1 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr0_1.value));
        lfsr0_1.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter0_1 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd ) )
        begin
            write_state0_1 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter0_1 <= writeLatCounter0_1 + 1;
        end
    endrule

    rule write_lat0_2 ( write_state0_2 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr0_2.value));
        lfsr0_2.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter0_2 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state0_2 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter0_2 <= writeLatCounter0_2 + 1;
        end
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule write_lat0_3 ( write_state0_3 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr0_3.value));
        lfsr0_3.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter0_3 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state0_3 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter0_3 <= writeLatCounter0_3 + 1;
        end
    endrule
    `endif

    rule write_lat0_4 ( write_state0_4 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr0_4.value));
        lfsr0_4.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter0_4 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state0_4 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter0_4 <= writeLatCounter0_4 + 1;
        end
    endrule


    rule enwrite0_0 ( write_state0_0 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite0_0();
    endrule

    rule enwrite0_1 ( write_state0_1 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite0_1();
    endrule

    rule enwrite0_2 ( write_state0_2 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite0_2();
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule enwrite0_3 ( write_state0_3 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite0_3();
    endrule
    `endif

    rule enwrite0_4 ( write_state0_4 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite0_4();
    endrule


    `ifndef REDUCE_PAR_TO_1    
    rule write_lat1_0 ( write_state1_0 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr1_0.value));
        lfsr1_0.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter1_0 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state1_0 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter1_0 <= writeLatCounter1_0 + 1;
        end
    endrule

    rule write_lat1_1 ( write_state1_1 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr1_1.value));
        lfsr1_1.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter1_1 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state1_1 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter1_1 <= writeLatCounter1_1 + 1;
        end
    endrule

    rule write_lat1_2 ( write_state1_2 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr1_2.value));
        lfsr1_2.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter1_2 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state1_2 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter1_2 <= writeLatCounter1_2 + 1;
        end
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule write_lat1_3 ( write_state1_3 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr1_3.value));
        lfsr1_3.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter1_3 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state1_3 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter1_3 <= writeLatCounter1_3 + 1;
        end
    endrule
    `endif

    rule write_lat1_4 ( write_state1_4 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr1_4.value));
        lfsr1_4.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter1_4 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state1_4 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter1_4 <= writeLatCounter1_4 + 1;
        end
    endrule


    rule enwrite1_0 ( write_state1_0 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite1_0();
    endrule

    rule enwrite1_1 ( write_state1_1 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite1_1();
    endrule

    rule enwrite1_2 ( write_state1_2 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite1_2();
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule enwrite1_3 ( write_state1_3 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite1_3();
    endrule
    `endif

    rule enwrite1_4 ( write_state1_4 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite1_4();
    endrule

    
    `ifndef REDUCE_PAR_TO_2
    rule write_lat2_0 ( write_state2_0 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr2_0.value));
        lfsr2_0.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter2_0 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state2_0 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter2_0 <= writeLatCounter2_0 + 1;
        end
    endrule

    rule write_lat2_1 ( write_state2_1 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr2_1.value));
        lfsr2_1.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter2_1 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state2_1 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter2_1 <= writeLatCounter2_1 + 1;
        end
    endrule

    rule write_lat2_2 ( write_state2_2 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr2_2.value));
        lfsr2_2.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter2_2 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state2_2 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter2_2 <= writeLatCounter2_2 + 1;
        end
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule write_lat2_3 ( write_state2_3 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr2_3.value));
        lfsr2_3.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter2_3 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state2_3 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter2_3 <= writeLatCounter2_3 + 1;
        end
    endrule
    `endif

    rule write_lat2_4 ( write_state2_4 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr2_4.value));
        lfsr2_4.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter2_4 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state2_4 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter2_4 <= writeLatCounter2_4 + 1;
        end
    endrule


    rule enwrite2_0 ( write_state2_0 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite2_0();
    endrule

    rule enwrite2_1 ( write_state2_1 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite2_1();
    endrule

    rule enwrite2_2 ( write_state2_2 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite2_2();
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule enwrite2_3 ( write_state2_3 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite2_3();
    endrule
    `endif

    rule enwrite2_4 ( write_state1_4 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite2_4();
    endrule


    rule write_lat3_0 ( write_state3_0 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr3_0.value));
        lfsr3_0.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter3_0 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state3_0 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter3_0 <= writeLatCounter3_0 + 1;
        end
    endrule

    rule write_lat3_1 ( write_state3_1 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr3_1.value));
        lfsr3_1.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter3_1 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state3_1 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter3_1 <= writeLatCounter3_1 + 1;
        end
    endrule

    rule write_lat3_2 ( write_state3_2 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr3_2.value));
        lfsr3_2.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter3_2 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state3_2 <= MEMSTATE_idle;            
        end
        else 
        begin
            writeLatCounter3_2 <= writeLatCounter3_2 + 1;
        end
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule write_lat3_3 ( write_state3_3 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr3_3.value));
        lfsr3_3.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter3_3 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state3_3 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter3_3 <= writeLatCounter3_3 + 1;
        end
    endrule
    `endif

    rule write_lat3_4 ( write_state3_4 == MEMSTATE_busy );

        `ifdef RANDOM_LATENCY
        UInt#(32) rnd = zeroExtend(unpack(lfsr3_4.value));
        lfsr3_4.next;
        `else
        UInt#(32) rnd = 0;
        `endif
        if ( writeLatCounter3_4 == (fromInteger(valueof(WRITE_MEM_LATENCY)) + rnd) )
        begin
            write_state3_4 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter3_4 <= writeLatCounter3_4 + 1;
        end
    endrule


    rule enwrite3_0 ( write_state3_0 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite3_0();
    endrule

    rule enwrite3_1 ( write_state3_1 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite3_1();
    endrule

    rule enwrite3_2 ( write_state3_2 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite3_2();
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule enwrite3_3 ( write_state3_3 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite3_3();
    endrule
    `endif

    rule enwrite3_4 ( write_state3_4 == MEMSTATE_idle );
        filtering_algorithm_top_wrapper.enWrite3_4();
    endrule

    `endif    
    `endif


    // ====================================================================
    //
    // memory reads.
    //
    // ====================================================================
    
    (* fire_when_enabled *)
    rule bus_read0_0 (True);    
        //read_state0_0 <= MEMSTATE_busy;
        //readLatCounter0_0 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest0_0();
        readAddrFifo0_0.enq(a);
        $display("[%d] read request 0_0: addr = %d",cycleCounter,a);
    endrule 

    (* fire_when_enabled *)
    rule bus_read0_1 (True);    
        //read_state0_1 <= MEMSTATE_busy;
        //readLatCounter0_1 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest0_1();
        readAddrFifo0_1.enq(a);
        $display("[%d] read request 0_1: addr = %d",cycleCounter,a);
    endrule 

    (* fire_when_enabled *)
    rule bus_read0_2 (True);    
        //read_state0_2 <= MEMSTATE_busy;
        //readLatCounter0_2 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest0_2();
        readAddrFifo0_2.enq(a);
        $display("[%d] read request 0_2: addr = %d",cycleCounter,a);
    endrule 

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule bus_read0_3 (True);    
        //read_state0_3 <= MEMSTATE_busy;
        //readLatCounter0_3 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest0_3();
        readAddrFifo0_3.enq(a);
        $display("[%d] read request 0_3: addr = %d",cycleCounter,a);
    endrule 
    `endif

    (* fire_when_enabled *)
    rule bus_read0_4 (True);    
        //read_state0_4 <= MEMSTATE_busy;
        //readLatCounter0_4 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest0_4();
        readAddrFifo0_4.enq(a);
        $display("[%d] read request 0_4: addr = %d",cycleCounter,a);
    endrule 


    `ifndef REDUCE_PAR_TO_1

    (* fire_when_enabled *)
    rule bus_read1_0 (True);    
        //read_state1_0 <= MEMSTATE_busy;
        //readLatCounter1_0 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest1_0();
        readAddrFifo1_0.enq(a);
        $display("[%d] read request 1_0: addr = %d",cycleCounter,a);
    endrule 

    (* fire_when_enabled *)
    rule bus_read1_1 (True);    
        //read_state1_1 <= MEMSTATE_busy;
        //readLatCounter1_1 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest1_1();
        readAddrFifo1_1.enq(a);
        $display("[%d] read request 1_1: addr = %d",cycleCounter,a);
    endrule 

    (* fire_when_enabled *)
    rule bus_read1_2 (True);    
        //read_state1_2 <= MEMSTATE_busy;
        //readLatCounter1_2 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest1_2();
        readAddrFifo1_2.enq(a);
        $display("[%d] read request 1_2: addr = %d",cycleCounter,a);
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule bus_read1_3 (True);    
        //read_state1_3 <= MEMSTATE_busy;
        //readLatCounter1_3 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest1_3();
        readAddrFifo1_3.enq(a);
        $display("[%d] read request 1_3: addr = %d",cycleCounter,a);
    endrule 
    `endif

    (* fire_when_enabled *)
    rule bus_read1_4 (True);    
        //read_state1_4 <= MEMSTATE_busy;
        //readLatCounter1_4 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest1_4();
        readAddrFifo1_4.enq(a);
        $display("[%d] read request 1_4: addr = %d",cycleCounter,a);
    endrule 


    `ifndef REDUCE_PAR_TO_2

    (* fire_when_enabled *)
    rule bus_read2_0 (True);    
        //read_state2_0 <= MEMSTATE_busy;
        //readLatCounter2_0 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest2_0();
        readAddrFifo2_0.enq(a);
        $display("[%d] read request 2_0: addr = %d",cycleCounter,a);
    endrule 

    (* fire_when_enabled *)
    rule bus_read2_1 (True);    
        //read_state2_1 <= MEMSTATE_busy;
        //readLatCounter2_1 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest2_1();
        readAddrFifo2_1.enq(a);
        $display("[%d] read request 2_1: addr = %d",cycleCounter,a);
    endrule 

    (* fire_when_enabled *)
    rule bus_read2_2 (True);    
        //read_state2_2 <= MEMSTATE_busy;
        //readLatCounter2_2 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest2_2();
        readAddrFifo2_2.enq(a);
        $display("[%d] read request 2_2: addr = %d",cycleCounter,a);
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule bus_read2_3 (True);    
        //read_state2_3 <= MEMSTATE_busy;
        //readLatCounter2_3 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest2_3();
        readAddrFifo2_3.enq(a);
        $display("[%d] read request 2_3: addr = %d",cycleCounter,a);
    endrule 
    `endif

    (* fire_when_enabled *)
    rule bus_read2_4 (True);    
        //read_state2_4 <= MEMSTATE_busy;
        //readLatCounter2_4 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest2_4();
        readAddrFifo2_4.enq(a);
        $display("[%d] read request 2_4: addr = %d",cycleCounter,a);
    endrule 


    (* fire_when_enabled *)
    rule bus_read3_0 (True);    
        //read_state3_0 <= MEMSTATE_busy;
        //readLatCounter3_0 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest3_0();
        readAddrFifo3_0.enq(a);
        $display("[%d] read request 3_0: addr = %d",cycleCounter,a);
    endrule 

    (* fire_when_enabled *)
    rule bus_read3_1 (True);    
        //read_state3_1 <= MEMSTATE_busy;
        //readLatCounter3_1 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest3_1();
        readAddrFifo3_1.enq(a);
        $display("[%d] read request 3_1: addr = %d",cycleCounter,a);
    endrule 

    (* fire_when_enabled *)
    rule bus_read3_2 (True);    
        //read_state3_2 <= MEMSTATE_busy;
        //readLatCounter3_2 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest3_2();
        readAddrFifo3_2.enq(a);
        $display("[%d] read request 3_2: addr = %d",cycleCounter,a);
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    (* fire_when_enabled *)
    rule bus_read3_3 (True);    
        //read_state3_3 <= MEMSTATE_busy;
        //readLatCounter3_3 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest3_3();
        readAddrFifo3_3.enq(a);
        $display("[%d] read request 3_3: addr = %d",cycleCounter,a);
    endrule 
    `endif

    (* fire_when_enabled *)
    rule bus_read3_4 (True);    
        //read_state3_4 <= MEMSTATE_busy;
        //readLatCounter3_4 <= 0;
        TA a = filtering_algorithm_top_wrapper.readRequest3_4();
        readAddrFifo3_4.enq(a);
        $display("[%d] read request 3_4: addr = %d",cycleCounter,a);
    endrule 

    `endif
    `endif


    rule read_lat0_0 ( readAddrFifo0_0.notEmpty  );
        if ( readLatCounter0_0 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData0_0(memory0_0.sub(readAddrFifo0_0.first));
            //UInt#(384) d2 = truncate(memory0_0.sub(readAddrFifo0_0.first));
            $display("[%d] bus0_0 read response: addr = %x, val = %x",cycleCounter,readAddrFifo0_0.first,memory0_0.sub(readAddrFifo0_0.first));
            readAddrFifo0_0.deq;
            readLatCounter0_0 <= 0;
        end
        else 
        begin
            readLatCounter0_0 <= readLatCounter0_0 + 1;
        end
    endrule

    rule read_lat0_1 ( readAddrFifo0_1.notEmpty  );
        if ( readLatCounter0_1 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData0_1(memory0_1.sub(readAddrFifo0_1.first));
            //UInt#(384) d2 = truncate(memory0_1.sub(readAddrFifo0_1.first));
            $display("[%d] bus0_1 read response: addr = %x, val = %x",cycleCounter,readAddrFifo0_1.first,memory0_1.sub(readAddrFifo0_1.first));
            readAddrFifo0_1.deq;
            readLatCounter0_1 <= 0;
        end
        else 
        begin
            readLatCounter0_1 <= readLatCounter0_1 + 1;
        end
    endrule

    rule read_lat0_2 ( readAddrFifo0_2.notEmpty  );
        if ( readLatCounter0_2 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData0_2(memory0_2.sub(readAddrFifo0_2.first));
            //UInt#(384) d2 = truncate(memory0_2.sub(readAddrFifo0_2.first));
            $display("[%d] bus0_2 read response: addr = %x, val = %x",cycleCounter,readAddrFifo0_2.first,memory0_2.sub(readAddrFifo0_2.first));
            readAddrFifo0_2.deq;
            readLatCounter0_2 <= 0;
        end
        else 
        begin
            readLatCounter0_2 <= readLatCounter0_2 + 1;
        end
        //$display("lat counter: %d",readLatCounter0_2);
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule read_lat0_3 ( readAddrFifo0_3.notEmpty  );
        if ( readLatCounter0_3 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData0_3(memory0_3.sub(readAddrFifo0_3.first));
            //UInt#(384) d2 = truncate(memory0_3.sub(readAddrFifo0_3.first));
            $display("[%d] bus0_3 read response: addr = %x, val = %x",cycleCounter,readAddrFifo0_3.first,memory0_3.sub(readAddrFifo0_3.first));
            readAddrFifo0_3.deq;
            readLatCounter0_3 <= 0;
        end
        else 
        begin
            readLatCounter0_3 <= readLatCounter0_3 + 1;
        end
        //$display("lat counter: %d",readLatCounter0_3);
    endrule
    `endif

    rule read_lat0_4 ( readAddrFifo0_4.notEmpty  );
        if ( readLatCounter0_4 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData0_4(memory0_4.sub(readAddrFifo0_4.first));
            $display("[%d] bus0_4 read response: addr = %x, val = %x",cycleCounter,readAddrFifo0_4.first,memory0_4.sub(readAddrFifo0_4.first));
            readAddrFifo0_4.deq;
            readLatCounter0_4 <= 0;
        end
        else 
        begin
            readLatCounter0_4 <= readLatCounter0_4 + 1;
        end
        //$display("lat counter: %d",readLatCounter0_4);
    endrule


    `ifndef REDUCE_PAR_TO_1

    rule read_lat1_0 ( readAddrFifo1_0.notEmpty  );
        if ( readLatCounter1_0 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData1_0(memory1_0.sub(readAddrFifo1_0.first));
            //UInt#(384) d2 = truncate(memory1_0.sub(readAddrFifo1_0.first));
            $display("[%d] bus1_0 read response: addr = %x, val = %x",cycleCounter,readAddrFifo1_0.first,memory1_0.sub(readAddrFifo1_0.first));
            readAddrFifo1_0.deq;
            readLatCounter1_0 <= 0;
        end
        else 
        begin
            readLatCounter1_0 <= readLatCounter1_0 + 1;
        end
    endrule


    rule read_lat1_1 ( readAddrFifo1_1.notEmpty  );
        if ( readLatCounter1_1 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData1_1(memory1_1.sub(readAddrFifo1_1.first));
            //UInt#(384) d2 = truncate(memory1_1.sub(readAddrFifo1_1.first));
            $display("[%d] bus1_1 read response: addr = %x, val = %x",cycleCounter,readAddrFifo1_1.first,memory1_1.sub(readAddrFifo1_1.first));
            readAddrFifo1_1.deq;
            readLatCounter1_1 <= 0;
        end
        else 
        begin
            readLatCounter1_1 <= readLatCounter1_1 + 1;
        end
    endrule

    rule read_lat1_2 ( readAddrFifo1_2.notEmpty  );
        if ( readLatCounter1_2 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData1_2(memory1_2.sub(readAddrFifo1_2.first));
            //UInt#(384) d2 = truncate(memory1_2.sub(readAddrFifo1_2.first));
            $display("[%d] bus1_2 read response: addr = %x, val = %x",cycleCounter,readAddrFifo1_2.first,memory1_2.sub(readAddrFifo1_2.first));
            readAddrFifo1_2.deq;
            readLatCounter1_2 <= 0;
        end
        else 
        begin
            readLatCounter1_2 <= readLatCounter1_2 + 1;
        end
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule read_lat1_3 ( readAddrFifo1_3.notEmpty  );
        if ( readLatCounter1_3 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData1_3(memory1_3.sub(readAddrFifo1_3.first));
            //UInt#(384) d2 = truncate(memory1_3.sub(readAddrFifo1_3.first));
            $display("[%d] bus1_3 read response: addr = %x, val = %x",cycleCounter,readAddrFifo1_3.first,memory1_3.sub(readAddrFifo1_3.first));
            readAddrFifo1_3.deq;
            readLatCounter1_3 <= 0;
        end
        else 
        begin
            readLatCounter1_3 <= readLatCounter1_3 + 1;
        end
        //$display("lat counter: %d",readLatCounter1_3);
    endrule
    `endif

    rule read_lat1_4 ( readAddrFifo1_4.notEmpty  );
        if ( readLatCounter1_4 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData1_4(memory1_4.sub(readAddrFifo1_4.first));
            $display("[%d] bus1_4 read response: addr = %x, val = %x",cycleCounter,readAddrFifo1_4.first,memory1_4.sub(readAddrFifo1_4.first));
            readAddrFifo1_4.deq;
            readLatCounter1_4 <= 0;
        end
        else 
        begin
            readLatCounter1_4 <= readLatCounter1_4 + 1;
        end
        //$display("lat counter: %d",readLatCounter1_4);
    endrule


    `ifndef REDUCE_PAR_TO_2

    rule read_lat2_0 ( readAddrFifo2_0.notEmpty  );
        if ( readLatCounter2_0 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData2_0(memory2_0.sub(readAddrFifo2_0.first));
            //UInt#(384) d2 = truncate(memory2_0.sub(readAddrFifo2_0.first));
            $display("[%d] bus2_0 read response: addr = %x, val = %x",cycleCounter,readAddrFifo2_0.first,memory2_0.sub(readAddrFifo2_0.first));
            readAddrFifo2_0.deq;
            readLatCounter2_0 <= 0;
        end
        else 
        begin
            readLatCounter2_0 <= readLatCounter2_0 + 1;
        end
    endrule

    rule read_lat2_1 ( readAddrFifo2_1.notEmpty  );
        if ( readLatCounter2_1 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData2_1(memory2_1.sub(readAddrFifo2_1.first));
            //UInt#(384) d2 = truncate(memory2_1.sub(readAddrFifo2_1.first));
            $display("[%d] bus2_1 read response: addr = %x, val = %x",cycleCounter,readAddrFifo2_1.first,memory2_1.sub(readAddrFifo2_1.first));
            readAddrFifo2_1.deq;
            readLatCounter2_1 <= 0;
        end
        else 
        begin
            readLatCounter2_1 <= readLatCounter2_1 + 1;
        end
    endrule

    rule read_lat2_2 ( readAddrFifo2_2.notEmpty  );
        if ( readLatCounter2_2 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData2_2(memory2_2.sub(readAddrFifo2_2.first));
            //UInt#(384) d2 = truncate(memory2_2.sub(readAddrFifo2_2.first));
            $display("[%d] bus2_2 read response: addr = %x, val = %x",cycleCounter,readAddrFifo2_2.first,memory2_2.sub(readAddrFifo2_2.first));
            readAddrFifo2_2.deq;
            readLatCounter2_2 <= 0;
        end
        else 
        begin
            readLatCounter2_2 <= readLatCounter2_2 + 1;
        end
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule read_lat2_3 ( readAddrFifo2_3.notEmpty  );
        if ( readLatCounter2_3 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData2_3(memory2_3.sub(readAddrFifo2_3.first));
            //UInt#(384) d2 = truncate(memory2_3.sub(readAddrFifo2_3.first));
            $display("[%d] bus2_3 read response: addr = %x, val = %x",cycleCounter,readAddrFifo2_3.first,memory2_3.sub(readAddrFifo2_3.first));
            readAddrFifo2_3.deq;
            readLatCounter2_3 <= 0;
        end
        else 
        begin
            readLatCounter2_3 <= readLatCounter2_3 + 1;
        end
        //$display("lat counter: %d",readLatCounter2_3);
    endrule
    `endif

    rule read_lat2_4 ( readAddrFifo2_4.notEmpty  );
        if ( readLatCounter2_4 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData2_4(memory2_4.sub(readAddrFifo2_4.first));
            $display("[%d] bus2_4 read response: addr = %x, val = %x",cycleCounter,readAddrFifo2_4.first,memory2_4.sub(readAddrFifo2_4.first));
            readAddrFifo2_4.deq;
            readLatCounter2_4 <= 0;
        end
        else 
        begin
            readLatCounter2_4 <= readLatCounter2_4 + 1;
        end
        //$display("lat counter: %d",readLatCounter2_4);
    endrule


    rule read_lat3_0 ( readAddrFifo3_0.notEmpty  );
        if ( readLatCounter3_0 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData3_0(memory3_0.sub(readAddrFifo3_0.first));
            //UInt#(384) d2 = truncate(memory3_0.sub(readAddrFifo3_0.first));
            $display("[%d] bus3_0 read response: addr = %x, val = %x",cycleCounter,readAddrFifo3_0.first,memory3_0.sub(readAddrFifo3_0.first));
            readAddrFifo3_0.deq;
            readLatCounter3_0 <= 0;
        end
        else 
        begin
            readLatCounter3_0 <= readLatCounter3_0 + 1;
        end
    endrule

    rule read_lat3_1 ( readAddrFifo3_1.notEmpty  );
        if ( readLatCounter3_1 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData3_1(memory3_1.sub(readAddrFifo3_1.first));
            //UInt#(384) d2 = truncate(memory3_1.sub(readAddrFifo3_1.first));
            $display("[%d] bus3_1 read response: addr = %x, val = %x",cycleCounter,readAddrFifo3_1.first,memory3_1.sub(readAddrFifo3_1.first));
            readAddrFifo3_1.deq;
            readLatCounter3_1 <= 0;
        end
        else 
        begin
            readLatCounter3_1 <= readLatCounter3_1 + 1;
        end
    endrule

    rule read_lat3_2 ( readAddrFifo3_2.notEmpty  );
        if ( readLatCounter3_2 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData3_2(memory3_2.sub(readAddrFifo3_2.first));
            //UInt#(384) d2 = truncate(memory3_2.sub(readAddrFifo3_2.first));
            $display("[%d] bus3_2 read response: addr = %x, val = %x",cycleCounter,readAddrFifo3_2.first,memory3_2.sub(readAddrFifo3_2.first));
            readAddrFifo3_2.deq;
            readLatCounter3_2 <= 0;
        end
        else 
        begin
            readLatCounter3_2 <= readLatCounter3_2 + 1;
        end
    endrule

    `ifndef CENTRE_BUFFER_ONCHIP
    rule read_lat3_3 ( readAddrFifo3_3.notEmpty  );
        if ( readLatCounter3_3 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData3_3(memory3_3.sub(readAddrFifo3_3.first));
            //UInt#(384) d2 = truncate(memory3_3.sub(readAddrFifo3_3.first));
            $display("[%d] bus3_3 read response: addr = %x, val = %x",cycleCounter,readAddrFifo3_3.first,memory3_3.sub(readAddrFifo3_3.first));
            readAddrFifo3_3.deq;
            readLatCounter3_3 <= 0;
        end
        else 
        begin
            readLatCounter3_3 <= readLatCounter3_3 + 1;
        end
        //$display("lat counter: %d",readLatCounter3_3);
    endrule
    `endif

    rule read_lat3_4 ( readAddrFifo3_4.notEmpty  );
        if ( readLatCounter3_4 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            filtering_algorithm_top_wrapper.readData3_4(memory3_4.sub(readAddrFifo3_4.first));
            $display("[%d] bus3_4 read response: addr = %x, val = %x",cycleCounter,readAddrFifo3_4.first,memory3_4.sub(readAddrFifo3_4.first));
            readAddrFifo3_4.deq;
            readLatCounter3_4 <= 0;
        end
        else 
        begin
            readLatCounter3_4 <= readLatCounter3_4 + 1;
        end
        //$display("lat counter: %d",readLatCounter3_4);
    endrule

    `endif
    `endif

    

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
