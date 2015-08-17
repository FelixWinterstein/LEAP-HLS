`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.08.2014 14:42:15
// Design Name: 
// Module Name: bus_bridge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bus_bridge
    #(
         parameter DATA_WIDTH = 32,
         parameter ADDR_WIDTH = 32
    )
    (
        input clk,
        input rst_n,
        // interface to the HLS core    
        output rsp_empty_n,    
        output rsp_full_n,
        input req_write,
        input req_din,
        input rsp_read,
        input [ADDR_WIDTH-1:0] address,
        input [31:0] size,
        input [DATA_WIDTH-1:0] dataout,
        output reg [DATA_WIDTH-1:0] datain,
        // req/resp/write interface to leap    
        output writeReq,
        output [DATA_WIDTH-1:0] writeReq_data,
        output [ADDR_WIDTH-1:0] writeReq_addr,
        input writeAck,
        output readReq,
        output [ADDR_WIDTH-1:0] readReq_addr,
        input readAck,
        input [DATA_WIDTH-1:0] readReq_data
    );
    
    reg [1:0] state;
    // states
    parameter free=0, mem_request=1, bus_write=2, bus_read=3;    
    
    parameter FIFO_WIDTH = DATA_WIDTH + ADDR_WIDTH + 1;
   
    wire [FIFO_WIDTH-1:0] request_fifo_din;
    wire [FIFO_WIDTH-1:0] request_fifo_dout;
    wire request_fifo_rd_en;
    wire request_fifo_full;
    wire request_fifo_emp;    
    wire request_fifo_valid;
    
    wire write_request;
    wire read_request;
    
    wire [ADDR_WIDTH-1:0] req_address;
    wire [DATA_WIDTH-1:0] req_data; 
    
    wire bus_write_done;
    wire bus_read_done;       
    
    
    // fsm proc
    always @(posedge clk) begin
         if ( ~rst_n ) begin
             state = free;
         end else begin
             case (state)
                 free: 
                     if ( req_write )                
                         state = mem_request;                     
                 mem_request: 
                     if ( write_request )
                         state = bus_write;
                     else if ( read_request )
                         state = bus_read;
                 bus_write: 
                     if ( bus_write_done ) begin
                         if ( ~request_fifo_emp )
                             state = mem_request;
                         else
                             state = free;
                     end
                 bus_read: 
                     if ( bus_read_done ) begin
                         if ( ~request_fifo_emp )
                             state = mem_request;
                         else
                             state = free;
                     end                
                 default : state = free;  
             endcase        
         end
     end //always      
    
        
    assign request_fifo_rd_en = ( state == mem_request && request_fifo_valid == 1'b0 ) ? 1'b1 : 1'b0;
             
    assign request_fifo_din = {req_din, dataout, address};    
    
    fifo #(
        .DATA_WIDTH( FIFO_WIDTH ),
        .LOG2_DEPTH( 3 )
    )
    fifo_U(
        .clk( clk ),
        .rst_n( rst_n ),        
        .din ( request_fifo_din ),
        .wr_en ( req_write ),
        .rd_en ( request_fifo_rd_en ),
        .dout ( request_fifo_dout ),
        .full ( request_fifo_full ),
        .empty ( request_fifo_emp ),
        .valid ( request_fifo_valid )               
    );    
    

    
    assign write_request = request_fifo_dout[DATA_WIDTH+ADDR_WIDTH] & request_fifo_valid;
    assign read_request = ~request_fifo_dout[DATA_WIDTH+ADDR_WIDTH] & request_fifo_valid;    
    
    
    assign req_address = request_fifo_dout[ADDR_WIDTH-1:0];
    assign req_data = request_fifo_dout[DATA_WIDTH+ADDR_WIDTH-1:ADDR_WIDTH];

    //direct_bus_write_done <= '1' WHEN state = direct_bus_write AND user_req_full_n = '1' ELSE '0';
    //direct_bus_read_done <= '1' WHEN state = direct_bus_read AND user_rsp_empty_n = '1' ELSE '0';
    
    assign bus_write_done = ( state == bus_write && writeAck == 1'b1 ) ? 1'b1 : 1'b0;
    assign bus_read_done = ( state == bus_read && readAck == 1'b1 ) ? 1'b1 : 1'b0;


    always @(posedge clk) begin
        if ( bus_read_done )
            datain = readReq_data;
    end // always


    assign rsp_empty_n = (state == free ) ? 1'b1 : 1'b0;
    assign rsp_full_n = (state == free) ? 1'b1 : 1'b0;
    
    assign writeReq =  write_request;
    assign writeReq_addr = req_address;
    assign writeReq_data = req_data;
    
    assign readReq = read_request;
    assign readReq_addr = req_address;
    
    
    
endmodule
