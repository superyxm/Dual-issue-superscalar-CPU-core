/*
 -- ============================================================================
 -- FILE NAME	: trace_interface.v
 -- DESCRIPTION : the module for trace debug 
 -- ============================================================================
*/
/********** Common header file **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** Individual header file **********/
`include "cpu.h"
`include "isa.h"
`include "each_module.h"

/********** Trace Define ************/
`define TraceFifoAddrBus 5:0
`define	TraceFifoDataBus 69:0
`define TraceFifoDepthBus 63:0

module trace_interface (
	/********** Global Signal **********/
	input	wire	clk,
	input	wire	reset,
	/********** core *********/
	input	wire	[`WordAddrBus]	pc_0,
	input	wire	wen_0,
	input	wire	[`AregAddrBus]	reg_addr_0,
	input	wire	[`WordDataBus]	reg_data_0,
	input	wire	[`WordAddrBus]	pc_1,
	input	wire	wen_1,
	input	wire	[`AregAddrBus]	reg_addr_1,
	input	wire	[`WordDataBus]	reg_data_1,
	/********** Trace *********/
	output	wire	[3:0]			debug_wb_rf_wen,
	output	wire	[`WordDataBus]	debug_wb_rf_wdata,
	output	wire	[`WordAddrBus]	debug_wb_pc,
	output	wire	[`AregAddrBus]	debug_wb_rf_wnum
);
	/********* Internal Signal **********/
	reg  [`TraceFifoAddrBus]	counter;
	reg  [`TraceFifoAddrBus]	read_ptr;
	reg  [`TraceFifoAddrBus]	write_ptr;
	reg  [`TraceFifoDataBus]	ram [`TraceFifoDepthBus];
	wire						read_ready;
	wire [`TraceFifoAddrBus] 	write_ptr_p_1;
	reg	 [`TraceFifoDataBus] 	fifo_out;
    reg  [`WordAddrBus]         pc_0_reg;
    reg  [`WordAddrBus]         pc_1_reg;
	wire fifo_wen_0;
	wire fifo_wen_1;
	
	/********* Assignment *********/
	//	output
	assign debug_wb_pc = fifo_out[69:38];
	assign debug_wb_rf_wdata = fifo_out[37:6];
	assign debug_wb_rf_wnum = fifo_out[5:1];
	assign debug_wb_rf_wen = {4{fifo_out[0]}};
	//	internal
	assign read_ready = |counter;
	assign write_ptr_p_1 = write_ptr + 1;
    assign fifo_wen_0 = (pc_0!=pc_0_reg)?wen_0:'b0;
    assign fifo_wen_1 = (pc_1!=pc_1_reg)?wen_1:'b0;
    always @ (posedge clk) begin
        pc_0_reg <= pc_0;
        pc_1_reg <= pc_1;
    end
	always @ (posedge clk) begin
		if(reset == `RESET_ENABLE) begin
			read_ptr <= 'b0;
			write_ptr <= 'b0;
			counter <= 'b0;
			fifo_out <= 'b0;
		end
		else begin
			//case({wen_0 & (pc_0!=pc_0_reg), wen_1 & (pc_1!=pc_1_reg), read_ready})
			case({fifo_wen_0, fifo_wen_1, read_ready})
				3'b000 : begin
					counter <= counter;
					fifo_out <= 'b0;
				end
				3'b001 : begin
					fifo_out <= ram[read_ptr];
					counter <= counter - 1;
					read_ptr <= read_ptr + 1;
				end
				3'b010 : begin
					fifo_out <= 'b0;
					counter <= counter + 1;
					write_ptr <= write_ptr + 1;
					ram[write_ptr] <= {pc_1,reg_data_1,reg_addr_1,fifo_wen_1};
				end
				3'b011 : begin
					fifo_out <= ram[read_ptr];
					counter <= counter;
					write_ptr <= write_ptr + 1;
					read_ptr <= read_ptr + 1;
					ram[write_ptr] <= {pc_1,reg_data_1,reg_addr_1,fifo_wen_1};
				end
				3'b100 : begin
					fifo_out <= 'b0;
					counter <= counter + 1;
					write_ptr <= write_ptr + 1;
					ram[write_ptr] <= {pc_0,reg_data_0,reg_addr_0,fifo_wen_0};
				end
				3'b101 : begin
					fifo_out <= ram[read_ptr];
					counter <= counter;
					write_ptr <= write_ptr + 1;
					read_ptr <= read_ptr + 1;
					ram[write_ptr] <= {pc_0,reg_data_0,reg_addr_0,fifo_wen_0};
				end
				3'b110 : begin
					fifo_out <= 'b0;
					counter <= counter + 2;
					write_ptr <= write_ptr + 2;
					ram[write_ptr] <= {pc_0,reg_data_0,reg_addr_0,fifo_wen_0};
					ram[write_ptr_p_1] <= {pc_1,reg_data_1,reg_addr_1,fifo_wen_1};
				end
				3'b111 : begin
					fifo_out <= ram[read_ptr];
					counter <= counter + 1;
					read_ptr <= read_ptr + 1;
					write_ptr <= write_ptr + 2;
					ram[write_ptr] <= {pc_0,reg_data_0,reg_addr_0,fifo_wen_0};
					ram[write_ptr_p_1] <= {pc_1,reg_data_1,reg_addr_1,fifo_wen_1};
				end
			endcase
		end
	end
endmodule
		
	
