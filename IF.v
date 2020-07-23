/*
 -- ============================================================================
 -- FILE NAME	: IF.v
 -- DESCRIPTION : Instruction Fetch stage
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by		Comment
 -- 1.0.0	  2019/05/25  Yau			Yau
 -- ============================================================================
*/
/********** Common header file **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** Individual header file **********/
`include "cpu.h"
`include "each_module.h"

`define ADDR_WORDSIZE 31:0
`define INSN_WORDSIZE 31:0
//`define ENABLE 1'b1
//`define DISABLE 1'b0
//`define RESET_ENABLE 1'b0

module IF(
	/****global signal****/
	input  wire clk,
	input  wire rst_,
	/****Branch Prediction Unit****/
	input  wire bp_if_en,	//prediction completed
	input  wire [`ADDR_WORDSIZE] bp_if_target,
	input  wire bp_if_delot_en,
	input  wire [`ADDR_WORDSIZE] bp_if_delot_pc,
	output wire flush_reg_to_bp,
	output wire [`ADDR_WORDSIZE] if_bp_pc,		//same as if_rd_addr
	output reg    flag,//by ysr
	/**** Icache Signal ****/
	output wire if_rw,
	//output wire [3:0] if_rwen,
	output reg [3:0] if_rwen, //fresh
	output wire [`ADDR_WORDSIZE] if_icache_pc,
	output reg  [1:0]if_icache_delot_en,
	/**** Hand Shake ****/
	input  wire icache_allin,
	input  wire bp_allin,
	output wire if_valid_ns, 
	/******** EX ********/
	input wire ex_bp_error,
	input wire [`ADDR_WORDSIZE] ex_new_target,
	input wire ex_delot_en,
	input wire [`ADDR_WORDSIZE] ex_delot_pc,
	/******** CP0 ********/
	input wire exc_flush_all,
	input wire [`ADDR_WORDSIZE] cp0_if_excaddr	//if the exception arbiter is in WB
	);
	
	/***** Internal Signal *****/
	wire stall;
	wire [`ADDR_WORDSIZE] next_pc;
	wire [`ADDR_WORDSIZE] new_pc;
	wire if_ready_go;
	reg  if_valid;
	reg  [`ADDR_WORDSIZE] target_after_delot;
	reg  [`ADDR_WORDSIZE] if_pc;
	reg  flush_reg;
	reg  [`ADDR_WORDSIZE] new_pc_reg;
	reg  ex_delot_en_reg;
	reg  ex_delot_en_reg_i; //delot_en kept for target_after_delot;

/***** Combinational Logic *****/
	//to BP
	assign if_bp_pc = if_pc;
	assign if_icache_pc = if_pc;
	assign flush_reg_to_bp = flush_reg;
	//to icache
	assign if_rw = `DISABLE;
	//assign if_rwen = 4'b1111;
	//Next PC
	assign next_pc =   (bp_if_delot_en && (!ex_delot_en_reg_i))? bp_if_delot_pc:
						(target_after_delot != 32'b0) ? target_after_delot:
						(bp_if_en) ? bp_if_target:(if_pc[`PcByteOffsetLoc] == 2'b00) ? (if_pc + `WORD_ADDR_W'd16):
												  (if_pc[`PcByteOffsetLoc] == 2'b01) ? (if_pc + `WORD_ADDR_W'd12):
												  (if_pc[`PcByteOffsetLoc] == 2'b10) ? (if_pc + `WORD_ADDR_W'd8) : (if_pc + `WORD_ADDR_W'd4);
	assign new_pc  = (exc_flush_all)?cp0_if_excaddr:(ex_bp_error & ex_delot_en)?ex_delot_pc:
	                   (ex_bp_error)?ex_new_target:32'b0;
	//Hand shake
	assign if_ready_go = `ENABLE;
	assign if_valid_ns = if_valid && if_ready_go;
	assign stall = !(if_valid_ns && icache_allin && bp_allin);

/**** sequential logic ****/
always @(posedge clk)begin
    if(!rst_)begin
        flush_reg <= 1'b0;
        new_pc_reg <= 32'b0;
        ex_delot_en_reg <= 1'b0;
    end
    else if((ex_bp_error || exc_flush_all) && stall == `DISABLE)begin
        if(exc_flush_all && stall == `DISABLE)begin
            new_pc_reg <= 32'b0;
            flush_reg <= 1'b0;
        end
    end
    else if(ex_bp_error || exc_flush_all)begin
        flush_reg <= ex_bp_error|exc_flush_all;
        new_pc_reg <= new_pc;
        ex_delot_en_reg <= ex_delot_en;
    end
    else if(stall==`DISABLE)begin
        flush_reg <= 1'b0;
        new_pc_reg <= 32'b0;
        ex_delot_en_reg <= 1'b0;
    end
end//fresh

always @(posedge clk) begin
	if (!rst_) begin
		if_pc <= `RESET_VECTOR;
		if_valid <= `ENABLE;
		if_icache_delot_en <= 2'b00;
		if_rwen  <= 4'b1111;
	end
	else if (((ex_bp_error == `ENABLE) || exc_flush_all == `ENABLE) & stall ==`DISABLE)begin
		if_pc <= new_pc;
		if_valid <= `ENABLE;
		if_icache_delot_en <= {ex_delot_en,1'b0};
		if_rwen  <= 4'b1111;
	end
	else if(stall == `DISABLE)begin
		if_pc <= (flush_reg)?new_pc_reg:next_pc; //fresh
		if_valid <= `ENABLE;
		if_icache_delot_en <= (ex_delot_en_reg)?2'b10:(bp_if_delot_en)?2'b01:2'b00;
		if_rwen  <= 4'b1111;
	end
end

always @(posedge clk) begin
	if (!rst_ || ex_bp_error & !ex_delot_en || exc_flush_all) begin
		target_after_delot <= 32'b0;
		ex_delot_en_reg_i <= 1'b0;
	end
	else if (ex_delot_en) begin
		target_after_delot <= ex_new_target;
		ex_delot_en_reg_i <= ex_delot_en;
	end
	else if (bp_if_delot_en & !ex_delot_en_reg_i) begin
		target_after_delot <= bp_if_target;
	end
	else if (stall == `DISABLE && !ex_delot_en_reg) begin
		target_after_delot <= 32'b0;
		ex_delot_en_reg_i <= 1'b0;
	end
end

//by ysr 
/*reg if_pc_reg;
always @(posedge clk) begin
	if (!rst_) begin
		if_pc_reg <= 32'b0;
	end
	else if ((ex_bp_error == `ENABLE || exc_flush_all == `ENABLE) & stall ==`DISABLE) begin
		if_pc_reg <= if_pc;
	end
end
always @(posedge clk) begin
	if (!rst_) begin
		flag <= 1'b0;
	end
	else if ((if_pc_reg != 'b0)&&(if_pc_reg == new_pc)&&((ex_bp_error == `ENABLE || exc_flush_all == `ENABLE) & stall ==`DISABLE)) begin
		flag <= 1'b1;
	end
	else if((if_pc_reg != 'b0)&&(if_pc_reg == new_pc_reg)&&(stall == `DISABLE))begin
	   flag <= 1'b1;
	end
	else begin
	   flag    <= 1'b0;
	end
end*/
always @(posedge clk) begin
	if (!rst_) begin
		flag <= 1'b0;
	end
	else if ((if_pc!= 'b0)&&(if_pc == new_pc)&&((ex_bp_error == `ENABLE || exc_flush_all == `ENABLE) & stall ==`DISABLE)) begin
		flag <= 1'b1;
	end
	else if((if_pc != 'b0)&&(if_pc == new_pc_reg)&&(stall == `DISABLE))begin
	   flag <= 1'b1;
	end
	else begin
	   flag    <= 1'b0;
	end
end
endmodule
