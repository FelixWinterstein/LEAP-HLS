/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: privateSPInterface.bsv
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

//import StmtFSM::*;
import FIFO::*;
import RegFile::*;
import LFSR::*;

import MyIP::*;
typedef Bit#(32) TD_io;
typedef Bit#(64) TD_bus;
typedef Bit#(32) TA;

typedef 4 READ_MEM_LATENCY; 
typedef 4 WRITE_MEM_LATENCY;

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
    MyIP#(TD_io, TD_bus, TA) merger_top_wrapper <- mkMyIP;
    
    RegFile#(TA,TD_bus) memory0 <- mkRegFile(0,8191);
    RegFile#(TA,TD_bus) memory1 <- mkRegFile(0,8191);
    RegFile#(TA,TD_bus) memory2 <- mkRegFile(0,8191);
    RegFile#(TA,TD_bus) memory3 <- mkRegFile(0,8191);

    RegFile#(TA,TA) memory4 <- mkRegFileLoad("freelist_initialization.hex",0,8191);
    RegFile#(TA,TA) memory5 <- mkRegFileLoad("freelist_initialization.hex",0,8191);
    RegFile#(TA,TA) memory6 <- mkRegFileLoad("freelist_initialization.hex",0,8191);
    RegFile#(TA,TA) memory7 <- mkRegFileLoad("freelist_initialization.hex",0,8191);

    FIFO#(TA) readAddrFifo0 <- mkSizedFIFO(16);
    FIFO#(TA) readAddrFifo1 <- mkSizedFIFO(16);
    FIFO#(TA) readAddrFifo2 <- mkSizedFIFO(16);
    FIFO#(TA) readAddrFifo3 <- mkSizedFIFO(16);
    FIFO#(TA) readAddrFifo4 <- mkSizedFIFO(16);
    FIFO#(TA) readAddrFifo5 <- mkSizedFIFO(16);
    FIFO#(TA) readAddrFifo6 <- mkSizedFIFO(16);
    FIFO#(TA) readAddrFifo7 <- mkSizedFIFO(16);

    // random number generators
    LFSR#(Bit#(16)) lfsr0 <- mkLFSR_16 ;
    LFSR#(Bit#(16)) lfsr1 <- mkLFSR_16 ;
    LFSR#(Bit#(16)) lfsr2 <- mkLFSR_16 ;
    LFSR#(Bit#(16)) lfsr3 <- mkLFSR_16 ;

   
    Reg#(STATE) state <- mkReg(STATE_idle);
    Reg#(UInt#(32)) cycleCounter <- mkReg(0);
    Reg#(UInt#(32)) startCycle <- mkReg(0);
    Reg#(UInt#(32)) endCycle <- mkReg(0);
    


    Reg#(MEMSTATE) read_state0 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state1 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state2 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state3 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state4 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state5 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state6 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) read_state7 <- mkReg(MEMSTATE_idle);
    Reg#(UInt#(32)) readLatCounter0 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter1 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter2 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter3 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter4 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter5 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter6 <- mkReg(0);
    Reg#(UInt#(32)) readLatCounter7 <- mkReg(0);

    Reg#(MEMSTATE) write_state0 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state1 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state2 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state3 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state4 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state5 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state6 <- mkReg(MEMSTATE_idle);
    Reg#(MEMSTATE) write_state7 <- mkReg(MEMSTATE_idle);
    Reg#(UInt#(32)) writeLatCounter0 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter1 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter2 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter3 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter4 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter5 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter6 <- mkReg(0);
    Reg#(UInt#(32)) writeLatCounter7 <- mkReg(0);

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

        merger_top_wrapper.enDataIn0();
        merger_top_wrapper.enDataIn1();
        merger_top_wrapper.enDataIn2();
        merger_top_wrapper.enDataIn3();
        merger_top_wrapper.enDataOut();

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
        merger_top_wrapper.data_in0( zeroExtend(lfsr0.value));
        lfsr0.next;
        //$display("data_in0");    
    endrule 

    rule data_in1 (True);
        merger_top_wrapper.data_in1( zeroExtend(lfsr1.value));
        lfsr1.next;
        //$display("data_in1");         
    endrule 

    rule data_in2 (True);
        merger_top_wrapper.data_in2( zeroExtend(lfsr2.value));
        lfsr2.next;
        //$display("data_in2");         
    endrule 

    rule data_in3 (True);
        merger_top_wrapper.data_in3( zeroExtend(lfsr3.value));
        lfsr3.next;
        //$display("data_in3");         
    endrule 

    rule data_out (True);        
        TD_io a = merger_top_wrapper.data_out();
        $display("[%d] data_out: %d",cycleCounter,a);
    endrule 


    // ====================================================================
    //
    // memory writes.
    //
    // ====================================================================/

    (* fire_when_enabled *)
    rule bus_write0 ( True );   
        write_state0 <= MEMSTATE_busy ;
        writeLatCounter0 <= 0;
        TA a = merger_top_wrapper.writeAddr0();
        TD_bus d = merger_top_wrapper.writeData0();
        memory0.upd(a,d);
        $display("[%d] write0: addr = %d, val = %d",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write1 ( True );   
        write_state1 <= MEMSTATE_busy ;
        writeLatCounter1 <= 0;
        TA a = merger_top_wrapper.writeAddr1();
        TD_bus d = merger_top_wrapper.writeData1();
        memory1.upd(a,d);
        $display("[%d] write1: addr = %d, val = %d",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write2 ( True );   
        write_state2 <= MEMSTATE_busy ;
        writeLatCounter2 <= 0;
        TA a = merger_top_wrapper.writeAddr2();
        TD_bus d = merger_top_wrapper.writeData2();
        memory2.upd(a,d);
        $display("[%d] write2: addr = %d, val = %d",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write3 ( True );   
        write_state3 <= MEMSTATE_busy ;
        writeLatCounter3 <= 0;
        TA a = merger_top_wrapper.writeAddr3();
        TD_bus d = merger_top_wrapper.writeData3();
        memory3.upd(a,d);
        $display("[%d] write3: addr = %d, val = %d",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write4 ( True );   
        write_state4 <= MEMSTATE_busy ;
        writeLatCounter4 <= 0;
        TA a = merger_top_wrapper.writeAddr4();
        TA d = merger_top_wrapper.writeData4();
        memory4.upd(a,d);
        $display("[%d] write4: addr = %d, val = %d",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write5 ( True );   
        write_state5 <= MEMSTATE_busy ;
        writeLatCounter5 <= 0;
        TA a = merger_top_wrapper.writeAddr5();
        TA d = merger_top_wrapper.writeData5();
        memory5.upd(a,d);
        $display("[%d] write5: addr = %d, val = %d",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write6 ( True );   
        write_state6 <= MEMSTATE_busy ;
        writeLatCounter6 <= 0;
        TA a = merger_top_wrapper.writeAddr6();
        TA d = merger_top_wrapper.writeData6();
        memory6.upd(a,d);
        $display("[%d] write6: addr = %d, val = %d",cycleCounter,a,d);
    endrule 

    (* fire_when_enabled *)
    rule bus_write7 ( True );   
        write_state7 <= MEMSTATE_busy ;
        writeLatCounter7 <= 0;
        TA a = merger_top_wrapper.writeAddr7();
        TA d = merger_top_wrapper.writeData7();
        memory7.upd(a,d);
        $display("[%d] write7: addr = %d, val = %d",cycleCounter,a,d);
    endrule 


    rule write_lat0 ( write_state0 == MEMSTATE_busy );

        if ( writeLatCounter0 == fromInteger(valueof(WRITE_MEM_LATENCY)) )
        begin
            write_state0 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter0 <= writeLatCounter0 + 1;
        end
    endrule

    rule write_lat1 ( write_state1 == MEMSTATE_busy );

        if ( writeLatCounter1 == fromInteger(valueof(WRITE_MEM_LATENCY)) )
        begin
            write_state1 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter1 <= writeLatCounter1 + 1;
        end
    endrule

    rule write_lat2 ( write_state2 == MEMSTATE_busy );

        if ( writeLatCounter2 == fromInteger(valueof(WRITE_MEM_LATENCY)) )
        begin
            write_state2 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter2 <= writeLatCounter2 + 1;
        end
    endrule

    rule write_lat3 ( write_state3 == MEMSTATE_busy );

        if ( writeLatCounter3 == fromInteger(valueof(WRITE_MEM_LATENCY)) )
        begin
            write_state3 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter3 <= writeLatCounter3 + 1;
        end
    endrule

    rule write_lat4 ( write_state4 == MEMSTATE_busy );

        if ( writeLatCounter4 == fromInteger(valueof(WRITE_MEM_LATENCY)) )
        begin
            write_state4 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter4 <= writeLatCounter4 + 1;
        end
    endrule

    rule write_lat5 ( write_state5 == MEMSTATE_busy );

        if ( writeLatCounter5 == fromInteger(valueof(WRITE_MEM_LATENCY)) )
        begin
            write_state5 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter5 <= writeLatCounter5 + 1;
        end
    endrule

    rule write_lat6 ( write_state6 == MEMSTATE_busy );

        if ( writeLatCounter6 == fromInteger(valueof(WRITE_MEM_LATENCY)) )
        begin
            write_state6 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter6 <= writeLatCounter6 + 1;
        end
    endrule

    rule write_lat7 ( write_state7 == MEMSTATE_busy );

        if ( writeLatCounter7 == fromInteger(valueof(WRITE_MEM_LATENCY)) )
        begin
            write_state7 <= MEMSTATE_idle;
        end
        else 
        begin
            writeLatCounter7 <= writeLatCounter7 + 1;
        end
    endrule

    rule enwrite0 ( write_state0 == MEMSTATE_idle );
        merger_top_wrapper.enWrite0();
    endrule

    rule enwrite1 ( write_state1 == MEMSTATE_idle );
        merger_top_wrapper.enWrite1();
    endrule

    rule enwrite2 ( write_state2 == MEMSTATE_idle );
        merger_top_wrapper.enWrite2();
    endrule

    rule enwrite3 ( write_state3 == MEMSTATE_idle );
        merger_top_wrapper.enWrite3();
    endrule

    rule enwrite4 ( write_state4 == MEMSTATE_idle );
        merger_top_wrapper.enWrite4();
    endrule

    rule enwrite5 ( write_state5 == MEMSTATE_idle );
        merger_top_wrapper.enWrite5();
    endrule

    rule enwrite6 ( write_state6 == MEMSTATE_idle );
        merger_top_wrapper.enWrite6();
    endrule

    rule enwrite7 ( write_state7 == MEMSTATE_idle );
        merger_top_wrapper.enWrite7();
    endrule


    // ====================================================================
    //
    // memory reads.
    //
    // ====================================================================
    
    (* fire_when_enabled *)
    rule bus_read0 (True);    
        read_state0 <= MEMSTATE_busy;
        readLatCounter0 <= 0;
        TA a = merger_top_wrapper.readRequest0();
        readAddrFifo0.enq(a);
        $display("[%d] read request 0: addr = %d",cycleCounter,a);
    endrule 

    (* fire_when_enabled *)
    rule bus_read1 (True);    
        read_state1 <= MEMSTATE_busy;
        readLatCounter1 <= 0;
        TA a = merger_top_wrapper.readRequest1();
        readAddrFifo1.enq(a);
        $display("[%d] read request 1: addr = %d",cycleCounter,a);
    endrule 

    (* fire_when_enabled *)
    rule bus_read2 (True);    
        read_state2 <= MEMSTATE_busy;
        readLatCounter2 <= 0;
        TA a = merger_top_wrapper.readRequest2();
        readAddrFifo2.enq(a);
        $display("[%d] read request 2: addr = %d",cycleCounter,a);
    endrule 

    (* fire_when_enabled *)
    rule bus_read3 (True);    
        read_state3 <= MEMSTATE_busy;
        readLatCounter3 <= 0;
        TA a = merger_top_wrapper.readRequest3();
        readAddrFifo3.enq(a);
        $display("[%d] read request 3: addr = %d",cycleCounter,a);
    endrule 

    (* fire_when_enabled *)
    rule bus_read4 (True);    
        read_state4 <= MEMSTATE_busy;
        readLatCounter4 <= 0;
        TA a = merger_top_wrapper.readRequest4();
        readAddrFifo4.enq(a);
        $display("[%d] read request 4: addr = %d",cycleCounter,a);
    endrule

    (* fire_when_enabled *)
    rule bus_read5 (True);    
        read_state5 <= MEMSTATE_busy;
        readLatCounter5 <= 0;
        TA a = merger_top_wrapper.readRequest5();
        readAddrFifo5.enq(a);
        $display("[%d] read request 5: addr = %d",cycleCounter,a);
    endrule

    (* fire_when_enabled *)
    rule bus_read6 (True);    
        read_state6 <= MEMSTATE_busy;
        readLatCounter6 <= 0;
        TA a = merger_top_wrapper.readRequest6();
        readAddrFifo6.enq(a);
        $display("[%d] read request 6: addr = %d",cycleCounter,a);
    endrule

    (* fire_when_enabled *)
    rule bus_read7 (True);    
        read_state7 <= MEMSTATE_busy;
        readLatCounter7 <= 0;
        TA a = merger_top_wrapper.readRequest7();
        readAddrFifo7.enq(a);
        $display("[%d] read request 7: addr = %d",cycleCounter,a);
    endrule


    rule read_lat0 ( read_state0 == MEMSTATE_busy );
        if ( readLatCounter0 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            read_state0 <= MEMSTATE_idle;
        end
        else 
        begin
            readLatCounter0 <= readLatCounter0 + 1;
        end
    endrule

    rule read_lat1 ( read_state1 == MEMSTATE_busy );
        if ( readLatCounter1 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            read_state1 <= MEMSTATE_idle;
        end
        else 
        begin
            readLatCounter1 <= readLatCounter1 + 1;
        end
    endrule

    rule read_lat2 ( read_state2 == MEMSTATE_busy );
        if ( readLatCounter2 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            read_state2 <= MEMSTATE_idle;
        end
        else 
        begin
            readLatCounter2 <= readLatCounter2 + 1;
        end
    endrule

    rule read_lat3 ( read_state3 == MEMSTATE_busy );
        if ( readLatCounter3 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            read_state3 <= MEMSTATE_idle;
        end
        else 
        begin
            readLatCounter3 <= readLatCounter3 + 1;
        end
    endrule

    rule read_lat4 ( read_state4 == MEMSTATE_busy );
        if ( readLatCounter4 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            read_state4 <= MEMSTATE_idle;
        end
        else 
        begin
            readLatCounter4 <= readLatCounter4 + 1;
        end
    endrule

    rule read_lat5 ( read_state5 == MEMSTATE_busy );
        if ( readLatCounter5 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            read_state5 <= MEMSTATE_idle;
        end
        else 
        begin
            readLatCounter5 <= readLatCounter5 + 1;
        end
    endrule

    rule read_lat6 ( read_state6 == MEMSTATE_busy );
        if ( readLatCounter6 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            read_state6 <= MEMSTATE_idle;
        end
        else 
        begin
            readLatCounter6 <= readLatCounter6 + 1;
        end
    endrule

    rule read_lat7 ( read_state7 == MEMSTATE_busy );
        if ( readLatCounter7 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            read_state7 <= MEMSTATE_idle;
        end
        else 
        begin
            readLatCounter7 <= readLatCounter7 + 1;
        end
    endrule

    
    rule read_lat_done0 ( True );
        if ( readLatCounter0 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            merger_top_wrapper.readData0(memory0.sub(readAddrFifo0.first));
            readAddrFifo0.deq;
            //$display("bus read response");
        end
    endrule

    rule read_lat_done1 ( True );
        if ( readLatCounter1 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            merger_top_wrapper.readData1(memory1.sub(readAddrFifo1.first));
            readAddrFifo1.deq;
            //$display("bus read response: addr = %d", readAddrFifo1.first);
        end
    endrule

    rule read_lat_done2 ( True );
        if ( readLatCounter2 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            merger_top_wrapper.readData2(memory2.sub(readAddrFifo2.first));
            readAddrFifo2.deq;
            //$display("bus read response");
        end
    endrule

    rule read_lat_done3 ( True );
        if ( readLatCounter3 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            merger_top_wrapper.readData3(memory3.sub(readAddrFifo3.first));
            readAddrFifo3.deq;
            //$display("bus read response");
        end
    endrule

    rule read_lat_done4 ( True );
        if ( readLatCounter4 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            merger_top_wrapper.readData4(memory4.sub(readAddrFifo4.first));
            readAddrFifo4.deq;
            //$display("bus read response");
        end
    endrule

    rule read_lat_done5 ( True );
        if ( readLatCounter5 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            merger_top_wrapper.readData5(memory5.sub(readAddrFifo5.first));
            readAddrFifo5.deq;
            //$display("bus read response");
        end
    endrule

    rule read_lat_done6 ( True );
        if ( readLatCounter6 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            merger_top_wrapper.readData6(memory6.sub(readAddrFifo6.first));
            readAddrFifo6.deq;
            //$display("bus read response");
        end
    endrule

    rule read_lat_done7 ( True );
        if ( readLatCounter7 == fromInteger(valueof(READ_MEM_LATENCY)) )
        begin
            merger_top_wrapper.readData7(memory7.sub(readAddrFifo7.first));
            readAddrFifo7.deq;
            //$display("bus read response");
        end
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
