/*
 -- ============================================================================
 -- FILE NAME	: IB_FIFO.v
 -- DESCRIPTION : FIFO for IB
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by		Comment
 -- 1.0.0	  2019/06/23  Yau			Yau
 -- ============================================================================
*/

/********** general header **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** module header **********/
`include "isa.h"
`include "cpu.h"
`include "each_module.h"

/********** internal define *******/
 `define FifoAddrBus 3:0
`define	FifoDataBusNew 70:0
`define	FifoDepthBus 15:0
`define	FIFO_DATA_W_new 71 

module IB_FIFO(
	/****** Global Signal ******/
	input  wire clk,
	input  wire rst_,
	input  wire stall,
	input  wire flush,
	/****** FIFO signal ******/
	input  wire [`FifoDataBusNew] fifo_in,
	input  wire fifo_w_en,
	input  wire fifo_r_en,
	output wire fifo_full,
	output wire fifo_empty,
	//output wire  [`FifoDataBusNew] fifo_out
	output reg  [`FifoDataBusNew] fifo_out
	);
	
	/****** internal signal ******/
	reg [`FifoAddrBus] counter;
	wire ren_real;
	reg [`FifoAddrBus] read_pointer;
	reg [`FifoAddrBus] write_pointer;
	reg [`FifoDataBusNew] fifo [`FifoDepthBus];
	integer reset_counter;

	/****** Combinational Logic ******/
	assign fifo_full  = (counter == 4'b1111) || (read_pointer == write_pointer + 1'b1 || write_pointer == 4'hf && read_pointer == 4'h0);
	assign fifo_empty = (counter == 4'b0000);
	assign ren_real = fifo_r_en && (!stall);
   // assign fifo_out   = (fifo_r_en && !stall)?((!fifo_empty)?fifo[read_pointer]:`FIFO_DATA_W'b0):`FIFO_DATA_W'b0; //fresh
	/****** Sequential Logic *******/
	always @(posedge clk) begin
		if (!rst_) begin
			read_pointer  <= 4'b0;
			write_pointer <= 4'b0;
			counter       <= 4'b0;
			fifo_out      <= `FIFO_DATA_W_new'b0;
			for(reset_counter = 0; reset_counter < 16; reset_counter = reset_counter + 1)begin
				fifo[reset_counter] <= `FIFO_DATA_W_new'b0;
			end
		end
		else if (flush) begin
			read_pointer  <= 4'b0;
			write_pointer <= 4'b0;
			counter       <= 4'b0;
			for(reset_counter = 0; reset_counter < 16; reset_counter = reset_counter + 1)begin
				fifo[reset_counter] <= `FIFO_DATA_W_new'b0;
			end//fresh
			fifo_out      <= `FIFO_DATA_W_new'b0;
		end
		else begin
			case({fifo_w_en, ren_real})
				2'b00:begin
				end
				2'b01:begin
				      if(stall == `DISABLE)begin
						fifo_out <= (~fifo_empty) ? fifo[read_pointer] : `FIFO_DATA_W_new'b0;
						counter  <= (~fifo_empty) ? (counter - 4'b0001) : counter;
						read_pointer <= (~fifo_empty && read_pointer == 4'hf) ? 4'b0 :
										(~fifo_empty) ? (read_pointer + 4'b0001) : read_pointer;	//if 4'hf, read_pointer needs to be back to the front.
				      end
				end
				2'b10:begin
				      if(!fifo_full)begin
						fifo[write_pointer] <= (~fifo_full)?fifo_in : fifo[write_pointer];
						counter <= (~(counter == 4'b1111)) ? (counter + 4'b0001) : counter;
						write_pointer <= (~fifo_full && write_pointer == 4'hf) ? 4'b0:
										 (~fifo_full) ? (write_pointer + 4'b0001) : write_pointer;
					  end
				end
				2'b11:begin
				   /* if(!fifo_empty && write_pointer == read_pointer)begin
				        fifo_out <= fifo_in;
				    end
				    else begin*/
                        if(!fifo_full)begin
                            fifo[write_pointer] <= (~fifo_full) ? fifo_in : fifo[write_pointer];
                            write_pointer <= (fifo_full)? write_pointer:
                                                (write_pointer == 4'hf)? 4'b0: (write_pointer + 4'b0001);					
                         end
                         if(!stall)begin
                            fifo_out <= (fifo_empty) ? fifo_in : fifo[read_pointer];
                            read_pointer  <= (fifo_empty)? read_pointer:
                                                (read_pointer == 4'hf) ? 4'b0: (read_pointer + 4'b0001);
                         end
                    end 
				//end
			endcase
		end
	end
endmodule
