/*
 -- ============================================================================
 -- FILE NAME	: IB.v
 -- DESCRIPTION : Instruction Buffer
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by		Comment
 -- 1.0.0	  2019/06/25  Yau			Yau
 -- ============================================================================
*/
/********** Common header file **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** Individual header file **********/
`include "cpu.h"
`include "each_module.h"

/********** internal define********/
`define InsnValidBus 3:0
`define	DecodeEnBus	1:0
`define	DC_READ_DISABLE 2'b00
`define	DC_READ_0_1 2'b01
`define	DC_READ_2_3	2'b10
`define PcLocBus 64:33
`define InsnLocBus 32:1
`define ValidLocBus 0:0
`define	PcWordOffsetLoc 3:2
`define FifoPtabAddrLoc 69:65
`define FifoPCLoc 64:33
`define FifoInsnLoc 32:1
`define FifoValidBit 0
`define	 FifoDataBusNew 70:0

module IB(
	/***** Global Signal *****/
	input  wire clk,
	input  wire rst_,
	input  wire flush,
	/***** I$ Signal *****/
	input  wire [`FourWordDataBus] icache_ib_insn,
	input  wire [`WordAddrBus]	icache_ib_pc,
	input  wire [`PtabAddrBus]	icache_ib_ptab_addr,
	input  wire [1:0] icache_ib_delot_en,
	input  wire [`WordAddrBus]  icache_ib_branch_pc,
	/***** ID Signal *****/
	output wire [`WordAddrBus] ib_id_pc_0,
	output wire [`WordAddrBus] ib_id_pc_1,
	output wire [`WordDataBus] ib_id_insn_0,
	output wire [`WordDataBus] ib_id_insn_1,
	output wire [`PtabAddrBus] ib_id_ptab_addr_0,
	output wire [`PtabAddrBus] ib_id_ptab_addr_1,
	output wire ib_id_valid_0,
	output wire ib_id_valid_1,
	output wire [1:0] ib_id_delot_flag,
	/***** Handshake *****/
	input  wire id_allin,
	input  wire icache_valid_ns,
	output wire ib_allin,
	output wire ib_valid_ns
	);

	/****** Internal Signal ******/
	wire stall;
	//reg  flush_reg;
	reg  ib_valid;
	wire ib_ready_go;
	wire [`WordAddrBus] ib_pc_0;
	wire [`WordAddrBus] ib_pc_1;
	wire [`WordAddrBus] ib_pc_2;
	wire [`WordAddrBus] ib_pc_3;
	wire [`WordDataBus] ib_insn_0;
	wire [`WordDataBus] ib_insn_1;
	wire [`WordDataBus] ib_insn_2;
	wire [`WordDataBus] ib_insn_3;
	wire ib_delot_flag_0;
	wire ib_delot_flag_1;
	wire ib_delot_flag_2;
	wire ib_delot_flag_3;
	wire ib_empty;
	wire ib_full;
	wire fifo_empty_0;
	wire fifo_empty_1;
	wire fifo_empty_2;
	wire fifo_empty_3;
	wire fifo_full_0;
	wire fifo_full_1;
	wire fifo_full_2;
	wire fifo_full_3;
	wire [`InsnValidBus] ib_insn_valid;
	wire bp_en;
	//wire fifo_wen;
	reg fifo_wen;
	wire [`PtabAddrBus] fifo_in_ptab_addr_0;
	wire [`PtabAddrBus] fifo_in_ptab_addr_1;
	wire [`PtabAddrBus] fifo_in_ptab_addr_2;
	wire [`PtabAddrBus] fifo_in_ptab_addr_3;
	reg  [1:0] fifo_ren;
	wire fifo_ren_0;
	wire fifo_ren_1;
	wire fifo_ren_2;
	wire fifo_ren_3;
	//reg  [1:0] fifo_ren_i;
	//wire [1:0] fifo_ren_real;
	wire [`FifoDataBusNew] fifo_out_0;
	wire [`FifoDataBusNew] fifo_out_1;
	wire [`FifoDataBusNew] fifo_out_2;
	wire [`FifoDataBusNew] fifo_out_3;

	/****** Combinational Logic ******/
	//Handshake
	assign stall = !(ib_valid_ns && id_allin);
	//assign ib_ready_go = !ib_empty || (fifo_wen!=0 && fifo_ren !=`DC_READ_DISABLE);
	assign ib_ready_go = !ib_empty;
	assign ib_allin = !ib_full;
	//assign ib_allin = 1'b0;
	//assign ib_allin = (!ib_valid || (ib_ready_go && id_allin)) && !ib_full;
	//assign ib_valid_ns = ib_valid && ib_ready_go;
	assign ib_valid_ns = ib_ready_go; //fresh
	
	/***** FIFO write *****/
	//assign fifo_wen = ib_allin & icache_valid_ns;
	//insn valid
	assign bp_en = icache_ib_ptab_addr[4];
	assign ib_insn_valid = (icache_ib_delot_en==2'b01)?4'b0001:
	            (icache_ib_delot_en==2'b10 && icache_ib_pc[`PcWordOffsetLoc] == 2'b00)?4'b0001:
	            (icache_ib_delot_en==2'b10 && icache_ib_pc[`PcWordOffsetLoc] == 2'b01)?4'b0010:
	            (icache_ib_delot_en==2'b10 && icache_ib_pc[`PcWordOffsetLoc] == 2'b10)?4'b0100:
	            (icache_ib_delot_en==2'b10 && icache_ib_pc[`PcWordOffsetLoc] == 2'b11)?4'b1000:
				(icache_ib_pc[`PcWordOffsetLoc] == 2'b00 && bp_en == 1 && ib_pc_0 == icache_ib_branch_pc)? 4'b0011:
				(icache_ib_pc[`PcWordOffsetLoc] == 2'b00 && bp_en == 1 && ib_pc_1 == icache_ib_branch_pc)? 4'b0111:
				(icache_ib_pc[`PcWordOffsetLoc] == 2'b00)? 4'b1111:
				(icache_ib_pc[`PcWordOffsetLoc] == 2'b01 && bp_en == 1 && ib_pc_1 == icache_ib_branch_pc)? 4'b0110:
				(icache_ib_pc[`PcWordOffsetLoc] == 2'b01)? 4'b1110:
				(icache_ib_pc[`PcWordOffsetLoc] == 2'b10)? 4'b1100: 4'b1000;
	//insn & pc
	assign {ib_insn_3, ib_insn_2, ib_insn_1, ib_insn_0} = icache_ib_insn;
	assign ib_pc_0 = {icache_ib_pc[`PcOtherLoc], 4'b0000};
	assign ib_pc_1 = {icache_ib_pc[`PcOtherLoc], 4'b0100};
	assign ib_pc_2 = {icache_ib_pc[`PcOtherLoc], 4'b1000};
	assign ib_pc_3 = {icache_ib_pc[`PcOtherLoc], 4'b1100};
	//ptab_addr
	assign fifo_in_ptab_addr_0 = (ib_pc_0 == icache_ib_branch_pc) ? icache_ib_ptab_addr: 5'b0;
	assign fifo_in_ptab_addr_1 = (ib_pc_1 == icache_ib_branch_pc) ? icache_ib_ptab_addr: 5'b0;
	assign fifo_in_ptab_addr_2 = (ib_pc_2 == icache_ib_branch_pc) ? icache_ib_ptab_addr: 5'b0;
	assign fifo_in_ptab_addr_3 = (ib_pc_3 == icache_ib_branch_pc) ? icache_ib_ptab_addr: 5'b0;
    //delot flag
    assign ib_delot_flag_0 = (icache_ib_delot_en==2'b10 && icache_ib_pc[`PcWordOffsetLoc] == 2'b00)?1'b1:1'b0;
    assign ib_delot_flag_1 = (icache_ib_delot_en==2'b10 && icache_ib_pc[`PcWordOffsetLoc] == 2'b01)?1'b1:1'b0;
    assign ib_delot_flag_2 = (icache_ib_delot_en==2'b10 && icache_ib_pc[`PcWordOffsetLoc] == 2'b10)?1'b1:1'b0;
    assign ib_delot_flag_3 = (icache_ib_delot_en==2'b10 && icache_ib_pc[`PcWordOffsetLoc] == 2'b11)?1'b1:1'b0;
	/***** FIFO read *****/
	//assign fifo_ren_real = (stall==`DISABLE & fifo_ren_i==fifo_ren)?~fifo_ren:fifo_ren;
	assign fifo_ren_0 = (fifo_ren == `DC_READ_0_1) & (id_allin);
	assign fifo_ren_1 = (fifo_ren == `DC_READ_0_1) & (id_allin);
	assign fifo_ren_2 = (fifo_ren == `DC_READ_2_3) & (id_allin);
	assign fifo_ren_3 = (fifo_ren == `DC_READ_2_3) & (id_allin);
	assign ib_full    = fifo_full_0 | fifo_full_1 | fifo_full_2 | fifo_full_3;
	assign ib_empty   = fifo_empty_2| fifo_empty_3;
	assign ib_id_ptab_addr_0 = (fifo_ren == `DC_READ_0_1) ? fifo_out_0[`FifoPtabAddrLoc]:
								 (fifo_ren == `DC_READ_2_3) ? fifo_out_2[`FifoPtabAddrLoc]: 5'b0;
	assign ib_id_ptab_addr_1 = (fifo_ren == `DC_READ_0_1) ? fifo_out_1[`FifoPtabAddrLoc]:
								 (fifo_ren == `DC_READ_2_3) ? fifo_out_3[`FifoPtabAddrLoc]: 5'b0;
    assign ib_id_pc_0 	 = (fifo_ren == `DC_READ_0_1) ? fifo_out_0[`FifoPCLoc]:
							(fifo_ren == `DC_READ_2_3) ? fifo_out_2[`FifoPCLoc]: 32'b0;
	assign ib_id_pc_1 	 = (fifo_ren == `DC_READ_0_1) ? fifo_out_1[`FifoPCLoc]:
							(fifo_ren == `DC_READ_2_3) ? fifo_out_3[`FifoPCLoc]: 32'b0;
	assign ib_id_insn_0  = (fifo_ren == `DC_READ_0_1) ? fifo_out_0[`FifoInsnLoc]:
						    (fifo_ren == `DC_READ_2_3) ? fifo_out_2[`FifoInsnLoc]: 32'b0;
	assign ib_id_insn_1  = (fifo_ren == `DC_READ_0_1) ? fifo_out_1[`FifoInsnLoc]:
						    (fifo_ren == `DC_READ_2_3) ? fifo_out_3[`FifoInsnLoc]: 32'b0;
	assign ib_id_valid_0 = (fifo_ren == `DC_READ_0_1) ? fifo_out_0[`FifoValidBit]:
						   (fifo_ren == `DC_READ_2_3) ? fifo_out_2[`FifoValidBit]: 1'b0;
	assign ib_id_valid_1 = (fifo_ren == `DC_READ_0_1) ? fifo_out_1[`FifoValidBit]:
						   (fifo_ren == `DC_READ_2_3) ? fifo_out_3[`FifoValidBit]: 1'b0;
	assign ib_id_delot_flag = (fifo_ren == `DC_READ_0_1) ? {fifo_out_1[70],fifo_out_0[70]}:
						      (fifo_ren == `DC_READ_2_3) ? {fifo_out_3[70],fifo_out_2[70]}: 2'b00;
	//assign ib_id_delot_flag = 2'b00;				   

	/****** Sequential Logic ******/
	/*always @ (posedge clk)begin
	   if(!rst_)begin
	       flush_reg <= 1'b0;
	   end
	   if(flush)begin
	       flush_reg <= flush;
	   end
	   else if(icache_valid_ns)begin
	       flush_reg <= 1'b0;
	   end
	end*/
	always @(posedge clk) begin
	   if(!rst_)begin
	       fifo_wen <= 1'b0;
	   end
	   //else if(flush || flush_reg)begin
	   else if(flush)begin
	       fifo_wen <= 1'b0;
	   end
	   else begin
	       fifo_wen <= ib_allin & icache_valid_ns;
	   end
	end//fresh
	
	always @(posedge clk) begin
		if (!rst_) begin
			ib_valid <= `DISABLE;	
		end
		else if (ib_allin) begin
		    ib_valid <= icache_valid_ns;
		end
	end
	
	
	always @(posedge clk) begin
		if (!rst_) begin
			fifo_ren 	<= `DC_READ_DISABLE;
		end
		else if(flush)begin
			fifo_ren 	<= `DC_READ_DISABLE;
		end
		else if (stall == `DISABLE) begin
			fifo_ren <= (ib_empty)?`DC_READ_DISABLE:
						(fifo_ren == `DC_READ_DISABLE)?`DC_READ_0_1:~fifo_ren;
		end
	end

	IB_FIFO fifo_0 (
	.clk(clk),
	.rst_(rst_),
	.stall(stall),
	.flush(flush),
	.fifo_in({ib_delot_flag_0,fifo_in_ptab_addr_0,ib_pc_0,ib_insn_0,ib_insn_valid[0]}),
	.fifo_w_en(fifo_wen),
	.fifo_r_en(fifo_ren_0),
	.fifo_full(fifo_full_0),
	.fifo_empty(fifo_empty_0),
	.fifo_out(fifo_out_0)
	);
	IB_FIFO fifo_1 (
	.clk(clk),
	.rst_(rst_),
	.stall(stall),
	.flush(flush),
	.fifo_in({ib_delot_flag_1,fifo_in_ptab_addr_1,ib_pc_1,ib_insn_1,ib_insn_valid[1]}),
	.fifo_w_en(fifo_wen),
	.fifo_r_en(fifo_ren_1),
	.fifo_full(fifo_full_1),
	.fifo_empty(fifo_empty_1),
	.fifo_out(fifo_out_1)
	);
	IB_FIFO fifo_2 (
	.clk(clk),
	.rst_(rst_),
	.stall(stall),
	.flush(flush),
	.fifo_in({ib_delot_flag_2,fifo_in_ptab_addr_2,ib_pc_2,ib_insn_2,ib_insn_valid[2]}),
	.fifo_w_en(fifo_wen),
	.fifo_r_en(fifo_ren_2),
	.fifo_full(fifo_full_2),
	.fifo_empty(fifo_empty_2),
	.fifo_out(fifo_out_2)
	);
	IB_FIFO fifo_3 (
	.clk(clk),
	.rst_(rst_),
	.stall(stall),
	.flush(flush),
	.fifo_in({ib_delot_flag_3,fifo_in_ptab_addr_3,ib_pc_3,ib_insn_3,ib_insn_valid[3]}),
	.fifo_w_en(fifo_wen),
	.fifo_r_en(fifo_ren_3),
	.fifo_full(fifo_full_3),
	.fifo_empty(fifo_empty_3),
	.fifo_out(fifo_out_3)
	);
endmodule
	
