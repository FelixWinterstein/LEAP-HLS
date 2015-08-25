`timescale 1ns / 1ps
/**********************************************************************
* Felix Winterstein, Imperial College London
*
* File: fifo.v
*
* Revision 1.01
* Additional Comments: distributed under a BSD license, see LICENSE.txt
*
**********************************************************************/

module fifo
   #(
      parameter DATA_WIDTH = 8,
      parameter LOG2_DEPTH = 3 
   )   
   (
      input clk,
      input rst_n,
      input [DATA_WIDTH-1:0]  din,
      input wr_en,
      input rd_en,
      output reg [DATA_WIDTH-1:0] dout,
      output full,
      output empty,
      output reg valid
   );
 
    parameter MAX_COUNT = 2**LOG2_DEPTH;
    reg   [LOG2_DEPTH-1 : 0]   rd_ptr;
    reg   [LOG2_DEPTH-1 : 0]   wr_ptr;
    reg   [DATA_WIDTH-1 : 0]   mem[MAX_COUNT-1 : 0];   //memory size: 2**LOG2_DEPTH
    reg   [LOG2_DEPTH : 0]     depth_cnt;
      
 
    always @(posedge clk) begin
        if(~rst_n) begin
            wr_ptr <= 'h0;
            rd_ptr <= 'h0;
        end // end if
        else begin
            if(wr_en)
                wr_ptr <= wr_ptr+1;            
            if(rd_en)
                rd_ptr <= rd_ptr+1;
        end //end else
    end//end always
 
    assign empty= (depth_cnt=='h0);
    assign full = (depth_cnt==MAX_COUNT);
    
    //comment if you want a registered dout
    //assign dout = rd_en ? mem[rd_ptr]:'h0;
 
    always @(posedge clk) begin
        if (wr_en)
            mem[wr_ptr] <= din;
    end //end always
    
    //uncomment if you want a registered dout
    always @(posedge clk) begin
        if (~rst_n) begin
            dout <= 'h0;
            valid <= 1'b0;
        end else begin
            if (rd_en)
                valid <= 1'b1;
            else
                valid <= 1'b0;
            dout <= mem[rd_ptr];            
        end
    end
 
    always @(posedge clk) begin
        if (~rst_n)
            depth_cnt <= 'h0;
        else begin
            case({rd_en,wr_en})
                2'b10    :  depth_cnt <= depth_cnt-1;
                2'b01    :  depth_cnt <= depth_cnt+1;
            endcase
        end //end else
    end //end always
 
endmodule
