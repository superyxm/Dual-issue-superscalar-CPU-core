/*Skip to content
 
Search or jump to?ву?

Pull requests
Issues
Marketplace
Explore*/
 
    
/*
 -- ============================================================================
 -- FILE NAME	: branch_prediction.v
 -- DESCRIPTION : moved up a cycle for generating branch_pc and ptab_addr; A handshake with icache would be needed if any bugs occur.
                  deleted signal icache_bp_stall, change the define of bp_dir_stall and bp_addr_stall;
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by		Comment
 -- 1.0.0	  2019/06/16  Yau			Yau
 -- ============================================================================
*/
/********** Common header file **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** Individual header file **********/
`include "cpu.h"
`include "each_module.h"

/********** Internal Define **********/
 //	Direction Prediction
`define	PhtDataBus 1:0
`define	PhtDepthBus 255:0
`define	PhtAddrBus 7:0
`define BhrDataBus 7:0
`define	BHR_DATA_W 8
`define	OldBhtLoc 6:0
`define	BankOffsetBus 1:0
`define	BankOffsetLoc 3:2
//	Address Prediction
`define	BtbTypeBus 1:0
`define BtbIndexBus 7:0
`define	BtbTagBus 9:0
`define PcIndexLoc 9:2
`define	PcTagLoc 19:10
`define	BtbDataBus 43:0
`define BtbTagLoc 43:34 
//`define	BtbValidLoc 44
`define BtbTypeLoc 33:32
`define BtbAddrLoc 31:0
`define	BtbDepthBus 255:0
`define TYPE_RELATIVE 2'b01
`define TYPE_CALL 2'b10
`define	TYPE_RETURN 2'b11
`define	TYPE_NOP 2'b00
`define	BtbChoiceBus 1:0
`define CHOOSE_WAY_0 2'b00
`define CHOOSE_WAY_1 2'b01
`define CHOOSE_WAY_2 2'b10
`define CHOOSE_WAY_3 2'b11
//	RAS
`define RasDepthBus 7:0
`define RasDataBus 31:0
`define RasAddrBus 2:0
`define Ptab2AddrBus 9:0
module branch_prediction(
	/******* global signal *******/
	input  wire clk,
	input  wire rst_,
	input  wire flush,
	/******* IF signal *******/
	input  wire [`WordAddrBus]	if_bp_pc,
	input  wire if_bp_delot_en,
	input  wire flush_reg,
	output wire bp_if_en,
	output wire [`WordAddrBus]	bp_if_target,
	output wire bp_if_delot_en,
	output wire [`WordAddrBus]	bp_if_delot_pc,
	/******* I-cache signal *******/
	output wire [`PtabAddrBus] bp_icache_ptab_addr,
	output wire [`WordAddrBus]	bp_icache_branch_pc,
	/******* IB signal *******/
	input  wire [`PtabAddrBus] ib_ptab_addr,//20190722
	/******* ID signal *******/
	input  wire id_update_en,
	input  wire [`WordAddrBus]	id_update_pc,
	input  wire [`BtbTypeBus]	id_update_branch_type,
	input  wire [`WordAddrBus]	id_update_target,
	input  wire [`Ptab2AddrBus]  id_ptab_addr,
	/******* IS signal *******/
	input  wire [`Ptab2AddrBus] is_ptab_addr,
	/******* EX signal *******/
	input  wire [`Ptab2AddrBus]	ex_ptab_addr,
	output wire [`Ptab2dataBus] ex_ptab_data,
	input  wire	ex_bp_error,
	input  wire [`BHR_DATA_W-1:0] ex_bp_bhr,
	input  wire ex_update_en,
	input  wire [`WordAddrBus]	ex_update_pc,
	input  wire ex_real_dir,
	/****** Handshake ******/
	input  wire if_valid_ns,
	output wire bp_allin  //to IF, together with i$_allin
	);
	
	/****** Internal Signal ******/
	wire [`WordAddrBus] dir_pc;
	wire [3:0] bp_dir;
	wire bp_dir_en;
	wire bp_addr_en;
	wire bp_delot_en;
	wire addr_bp_failed;
	wire [`WordAddrBus] addr_pc;
	wire [`WordAddrBus] branch_pc;
	wire bp_ptab_full;
	wire bp_dir_stall;
	wire bp_addr_stall;

	/****** Combinational Logic ******/
	//pc_in
	assign dir_pc = (flush_reg)?32'b0:if_bp_pc;
	assign addr_pc = (flush_reg)?32'b0:(bp_dir==4'b0001)? dir_pc:
				     ((bp_dir==4'b0010) && (if_bp_pc[`BankOffsetLoc]==2'b00))?dir_pc + 4:
				     (bp_dir==4'b0010)? dir_pc:
					 ((bp_dir==4'b0100) && (if_bp_pc[`BankOffsetLoc]==2'b00))? dir_pc + 8:
					 ((bp_dir==4'b0100) && (if_bp_pc[`BankOffsetLoc]==2'b01))? dir_pc + 4:
					 (bp_dir==4'b0100)?dir_pc:
					 (bp_dir==4'b1000 && if_bp_pc[`BankOffsetLoc]==2'b00)?dir_pc+12:
					 (bp_dir==4'b1000 && if_bp_pc[`BankOffsetLoc]==2'b01)?dir_pc+8:
					 (bp_dir==4'b1000 && if_bp_pc[`BankOffsetLoc]==2'b10)?dir_pc+4:
					 (bp_dir==4'b1000 && if_bp_pc[`BankOffsetLoc]==2'b11)?dir_pc : dir_pc;
	//pc_out
	assign bp_icache_branch_pc = branch_pc; 
	//assign bp_icache_branch_pc = addr_pc;
	//stall
	assign bp_dir_stall  = (!if_valid_ns)| bp_ptab_full;
	assign bp_addr_stall = (!if_valid_ns)| bp_ptab_full;
	//handshake
	assign bp_dir_en = 1'b0; //bp button
	assign bp_if_en  = 1'b0;
	assign bp_if_delot_en  = 1'b0;
	//assign bp_dir_en = 1'b0;
	assign bp_allin  = (!bp_ptab_full) && ( bp_if_en || (!bp_dir_en));

//global history direction predictor
dir_predictor bp_direction(
	.clk(clk),
	.rst_(rst_),
	.stall(bp_dir_stall),
	.bp_pc(dir_pc),
	.bp_dir(bp_dir),
	.flush(flush),
	.backup_ghr(ex_bp_bhr),
	.real_dir(ex_real_dir),
	.update_en(ex_update_en),
	.update_pc(ex_update_pc)
	);

addr_predictor bp_addr(
	.clk(clk),
	.rst_(rst_),
	.stall(bp_addr_stall),
	.bp_pc(addr_pc),
	.bp_dir(bp_dir & {4{!if_bp_delot_en}}),
	.addr_bp_failed(addr_bp_failed),
	.target_addr(bp_if_target),
	.branch_pc(branch_pc),
	.bp_en(bp_addr_en),
	.bp_delot_pc(bp_if_delot_pc),
	.bp_delot_en(bp_delot_en),
	.update_pc(id_update_pc),
	.update_target(id_update_target),
	.update_branch_type(id_update_branch_type),
	.update_en(id_update_en),
	.flush(flush)
	);
PTAB ptab(
	.clk(clk),
	.rst_(rst_),
	.flush(flush),
	.ex_ptab_addr(ex_ptab_addr),
	.ex_ptab_data(ex_ptab_data),
	.is_ptab_addr(is_ptab_addr),
	.id_ptab_addr(id_ptab_addr),
	.ib_ptab_addr(ib_ptab_addr),
	.bp_dir_en(1'b0),
	.bp_addr_en(1'b0),
	.bp_target_addr(bp_if_target),
	.bp_now_addr(branch_pc),
	.bp_ptab_full(bp_ptab_full),
	.bp_ptab_addr(bp_icache_ptab_addr)
	);
endmodule

module dir_predictor(
	/**** global signal ****/
	input  wire clk,
	input  wire rst_,
	input  wire stall,
	/**** dir prediction ****/
	input  wire [`WordAddrBus]	bp_pc,
	output wire [3:0]	bp_dir,
	/**** error recover ****/
	input  wire flush,
	input  wire [`BhrDataBus]	backup_ghr,
	/**** PHT update from EX ****/
	input  wire real_dir,
	input  wire [`WordAddrBus]	update_pc,
	input  wire update_en
	);

	/***** Internal Signal *****/
	//PHT
	integer	counter;
	reg		[`PhtDataBus]	pht_bank_0	[`PhtDepthBus];
	reg		[`PhtDataBus]	pht_bank_1	[`PhtDepthBus];
	reg		[`PhtDataBus]	pht_bank_2	[`PhtDepthBus];
	reg		[`PhtDataBus]	pht_bank_3	[`PhtDepthBus];

	//GHR
	reg		[`BhrDataBus]	ghr;

	//Read Channel
	wire	[`PhtAddrBus]	pht_addr_read;

	//Update Channel
	wire	[`PhtAddrBus]	pht_addr_update;
	wire	[`BankOffsetBus]pht_offset_update;
	wire	[`PhtDataBus]	pht_data_update_0;
	wire	[`PhtDataBus]	pht_data_update_1;
	wire	[`PhtDataBus]	pht_data_update_2;
	wire	[`PhtDataBus]	pht_data_update_3;
	wire					pht_update_en_0;
	wire					pht_update_en_1;
	wire					pht_update_en_2;
	wire					pht_update_en_3;

	/***** Combinational Logic *****/
	//Read Channel
	assign pht_addr_read = {bp_pc[19:16]^bp_pc[15:12], bp_pc[11:8]^bp_pc[7:4]} ^ ghr;
	assign bp_dir = (pht_bank_0[pht_addr_read][1] & (bp_pc[`BankOffsetLoc] == 2'b00))?4'b0001:
						(pht_bank_1[pht_addr_read][1] & ((bp_pc[`BankOffsetLoc] == 2'b00) | (bp_pc[`BankOffsetLoc] == 2'b01)))?4'b0010:
							(pht_bank_2[pht_addr_read][1] & (bp_pc[`BankOffsetLoc] != 2'b11))?4'b0100:
								(pht_bank_3[pht_addr_read][1])?4'b1000:4'b0000;

	//Update Channel
	assign pht_addr_update = {update_pc[19:16]^update_pc[15:12], update_pc[11:8]^update_pc[7:4]} ^ ghr;
	assign pht_offset_update = update_pc[`BankOffsetLoc];

	assign	pht_update_en_0 = (pht_offset_update == 2'b00) & update_en;
	assign	pht_update_en_1 = (pht_offset_update == 2'b01) & update_en;
	assign	pht_update_en_2 = (pht_offset_update == 2'b10) & update_en;
	assign	pht_update_en_3 = (pht_offset_update == 2'b11) & update_en;

	assign pht_data_update_0 =  (pht_bank_0[pht_addr_update] == 2'b00) ? (real_dir  ? 2'b01 : 2'b00) :
								(pht_bank_0[pht_addr_update] == 2'b01) ? (real_dir  ? 2'b10 : 2'b00) :
								(pht_bank_0[pht_addr_update] == 2'b10) ? (real_dir  ? 2'b11 : 2'b01) :
								(real_dir  ? 2'b11 : 2'b10);
	assign pht_data_update_1 =  (pht_bank_1[pht_addr_update] == 2'b00) ? (real_dir  ? 2'b01 : 2'b00) :
								(pht_bank_1[pht_addr_update] == 2'b01) ? (real_dir  ? 2'b10 : 2'b00) :
								(pht_bank_1[pht_addr_update] == 2'b10) ? (real_dir  ? 2'b11 : 2'b01) :
								(real_dir  ? 2'b11 : 2'b10);
	assign pht_data_update_2 =  (pht_bank_2[pht_addr_update] == 2'b00) ? (real_dir  ? 2'b01 : 2'b00) :
								(pht_bank_2[pht_addr_update] == 2'b01) ? (real_dir  ? 2'b10 : 2'b00) :
								(pht_bank_2[pht_addr_update] == 2'b10) ? (real_dir  ? 2'b11 : 2'b01) :
								(real_dir  ? 2'b11 : 2'b10);
	assign pht_data_update_3 =  (pht_bank_3[pht_addr_update] == 2'b00) ? (real_dir  ? 2'b01 : 2'b00) :
								(pht_bank_3[pht_addr_update] == 2'b01) ? (real_dir  ? 2'b10 : 2'b00) :
								(pht_bank_3[pht_addr_update] == 2'b10) ? (real_dir  ? 2'b11 : 2'b01) :
								(real_dir  ? 2'b11 : 2'b10);

	/***** Sequential Logic *****/
	//GHR
	always @(posedge clk) begin
		if (!rst_) begin
			ghr <= `BHR_DATA_W'b0;
		end
		else if (flush) begin
			ghr <= backup_ghr; //fresh
		end
		else if (~stall) begin  //ptab_full, cannot receive new PC from IF
			ghr <= (update_en)?{ghr[6:0],real_dir}:ghr;
		end
	end
	//PHT
	always @(posedge clk) begin
		if (!rst_) begin
			for(counter = 0; counter < 256; counter = counter + 1)begin
				pht_bank_0[counter] <= 2'b01;
				pht_bank_1[counter] <= 2'b01;
				pht_bank_2[counter] <= 2'b01;
				pht_bank_3[counter] <= 2'b01;
			end	
		end
		else if(!stall) begin
			pht_bank_0[pht_addr_update] <= (pht_update_en_0) ? pht_data_update_0 : pht_bank_0[pht_addr_update];
			pht_bank_1[pht_addr_update] <= (pht_update_en_1) ? pht_data_update_1 : pht_bank_1[pht_addr_update];
			pht_bank_2[pht_addr_update] <= (pht_update_en_2) ? pht_data_update_2 : pht_bank_2[pht_addr_update];
			pht_bank_3[pht_addr_update] <= (pht_update_en_3) ? pht_data_update_3 : pht_bank_3[pht_addr_update];
		end
	end
endmodule


module addr_predictor(
	/****** Global Signal ******/
	input	wire	clk,
	input	wire	rst_,
	input   wire    stall,
	/****** IF Signal ******/
	input	wire	[`WordAddrBus]	bp_pc,	//different from the one in dir_predictor, this one refers to the branch
	input	wire	[3:0]			bp_dir,
	output	wire	[`WordAddrBus]	target_addr,
	output  wire	[`WordAddrBus]	branch_pc,
	output  wire    bp_en,
	output  wire     [`WordAddrBus]	bp_delot_pc,
	output  wire     bp_delot_en,
	/***** Update BTB ******/
	input   wire	[`WordAddrBus]	update_pc,
	input   wire    [`WordAddrBus]	update_target,
	input	wire    [`BtbTypeBus]	update_branch_type,
	input   wire	update_en,
	input   wire    flush,
	/***** to BP top *****/
	output wire addr_bp_failed
	);
/********** Internal Signal **********/
	//	Valid Reg
	reg		[`BtbDepthBus]	btb_valid_0;	
	reg		[`BtbDepthBus]	btb_valid_1;	
	reg		[`BtbDepthBus]	btb_valid_2;	
	reg		[`BtbDepthBus]	btb_valid_3;	
	//	Read Channel
	wire	[`BtbIndexBus]	btb_index_read;
	reg		[`BtbIndexBus]	btb_index_read_reg;
	wire	[`BtbTagBus]	btb_tag_read;
	reg		[`BtbTagBus]	btb_tag_read_reg;
	wire	[`BtbDataBus]	btb_data_0;
	wire	[`BtbDataBus]	btb_data_1;
	wire	[`BtbDataBus]	btb_data_2;
	wire	[`BtbDataBus]	btb_data_3;
	wire	[3:0]			btb_hit;
	reg 	[`BtbTypeBus]	btb_type;
	reg 	[`WordAddrBus]	btb_addr;
	wire	[`WordAddrBus]	ras_addr;
	wire                    ras_read_en;
	reg     [`WordAddrBus] branch_pc_last;
	//	Update Channel
	wire	[`BtbChoiceBus]	btb_way_choice;
	wire	[`BtbIndexBus]	btb_index_update;
	wire	[`BtbTagBus]	btb_tag_update;
	wire	[`BtbTypeBus]	btb_type_update;
	wire	[`WordAddrBus]	btb_addr_update;
	wire					btb_update_en_0;
	wire					btb_update_en_1;
	wire					btb_update_en_2;
	wire					btb_update_en_3;
	//	Ras Update
	reg		[`WordAddrBus]	ras_pc_update;
	wire					ras_update_en;

	/******* Combinational Logic *******/
	/******* Read Channel *******/
	assign ras_read_en 	  = (btb_type == `TYPE_RETURN)? `ENABLE:`DISABLE;
	assign btb_index_read = bp_pc[`PcIndexLoc];
	assign btb_tag_read   = bp_pc[`PcTagLoc];
	//hit or not, 4 bits
	assign btb_hit = (btb_tag_read_reg == btb_data_0[`BtbTagLoc] && btb_valid_0)?4'b0001:
						(btb_tag_read_reg == btb_data_1[`BtbTagLoc] && btb_valid_1)?4'b0010:
						(btb_tag_read_reg == btb_data_2[`BtbTagLoc] && btb_valid_2)?4'b0100:
						(btb_tag_read_reg == btb_data_3[`BtbTagLoc] && btb_valid_3)?4'b1000:4'b0000;
	assign addr_bp_failed = (|bp_dir) && (!(|btb_hit) || (btb_type==2'b00));
	assign branch_pc 	  = ((|btb_hit)!=0) ? bp_pc : 32'b0;
	//read out btb data
	always @(*) begin
		casex(btb_hit)
			4'bxxx1:begin
				btb_type = btb_data_0[`BtbTypeLoc];
				btb_addr = btb_data_0[`BtbAddrLoc];
			end
			4'bxx10:begin
				btb_type = btb_data_1[`BtbTypeLoc];
				btb_addr = btb_data_1[`BtbAddrLoc];
			end
			4'bx100:begin
				btb_type = btb_data_2[`BtbTypeLoc];
				btb_addr = btb_data_2[`BtbAddrLoc];
			end
			4'b1000:begin
				btb_type = btb_data_3[`BtbTypeLoc];
				btb_addr = btb_data_3[`BtbAddrLoc];
			end
		default: begin
				 btb_type = `TYPE_NOP;
				 btb_addr = btb_data_3[`BtbAddrLoc];
			end
		endcase
	end
	//final target addr and prediction finished
	assign target_addr = (branch_pc != branch_pc_last)?`WORD_ADDR_W'b0:
	                       (btb_type == `TYPE_RELATIVE | btb_type == `TYPE_CALL)?btb_addr:
							(btb_type == `TYPE_RETURN)? ras_addr : `WORD_ADDR_W'b0;
	//assign bp_en = (|btb_hit) & (btb_type != `TYPE_NOP) & (!stall);
	assign bp_en = (branch_pc != branch_pc_last)?`WORD_ADDR_W'b0:
	                   (|bp_dir) && (|btb_hit) & (btb_type != `TYPE_NOP); //fresh
	//assign bp_en = 1'b0; //bp button 
	//delayslot signal if a branch at way-4
	assign bp_delot_en = (flush)?`DISABLE:
								(bp_dir == 4'b1000 && bp_en == 1)? `ENABLE:`DISABLE;
	assign bp_delot_pc = (flush)?`WORD_ADDR_W'b0:
								(bp_dir == 4'b1000 && bp_en == 1)? branch_pc + 4 : `WORD_ADDR_W'b0;

	/******* Update Channel ******/
	assign ras_update_en    = (btb_type == `TYPE_CALL) ? `ENABLE:`DISABLE;
	assign btb_index_update = update_pc[`PcIndexLoc];
	assign btb_tag_update   = update_pc[`PcTagLoc];
	assign btb_type_update  = update_branch_type;
	assign btb_addr_update  = update_target;
	assign btb_update_en_0  = update_en & (~btb_valid_0[btb_index_update]);
	assign btb_update_en_1  = update_en & btb_valid_0[btb_index_update] & (~btb_valid_1[btb_index_update]);
	assign btb_update_en_2  = update_en & btb_valid_0[btb_index_update] & btb_valid_1[btb_index_update]
										& (~btb_valid_2[btb_index_update]);
	assign btb_update_en_3  = update_en & btb_valid_0[btb_index_update] & btb_valid_1[btb_index_update]
										& btb_valid_2[btb_index_update];

	/******* Sequential Logic *******/
	//read channel
	always @(posedge clk) begin
		if (!rst_) begin
			btb_tag_read_reg   <= 10'b0;
			btb_index_read_reg <= 8'b0;
			ras_pc_update	   <= `WORD_ADDR_W'b0;
			branch_pc_last 		   <= `WORD_ADDR_W'b0;
		end
		else if (flush) begin
			btb_tag_read_reg   <= 10'b0;
			btb_index_read_reg <= 8'b0;
			ras_pc_update	   <= `WORD_ADDR_W'b0;
			branch_pc_last 	   <= `WORD_ADDR_W'b0;
		end
		else if(!stall) begin
			btb_tag_read_reg   <= btb_tag_read;
			btb_index_read_reg <= btb_index_read;
			ras_pc_update	   <= bp_pc + 8;
			branch_pc_last	   <= branch_pc;
		end
		else begin
		    branch_pc_last	   <= branch_pc; 
		end
	end
	//valid reg
	always @ (posedge clk) begin
		if (rst_ == `RESET_ENABLE) begin
			btb_valid_0 <= 256'b0;
			btb_valid_1 <= 256'b0;
			btb_valid_2 <= 256'b0;
			btb_valid_3 <= 256'b0;
		end
		else begin
			btb_valid_0[btb_index_update] <= btb_update_en_0 ? `ENABLE : btb_valid_0[btb_index_update];
			btb_valid_1[btb_index_update] <= btb_update_en_1 ? `ENABLE : btb_valid_1[btb_index_update];
			btb_valid_2[btb_index_update] <= btb_update_en_2 ? `ENABLE : btb_valid_2[btb_index_update];
			btb_valid_3[btb_index_update] <= btb_update_en_3 ? `ENABLE : btb_valid_3[btb_index_update];
			if(bp_en && !stall)begin
				btb_valid_0[btb_index_read_reg] <= btb_hit[0]? `DISABLE:btb_valid_0[btb_index_read_reg];
				btb_valid_1[btb_index_read_reg] <= btb_hit[1]? `DISABLE:btb_valid_1[btb_index_read_reg];
				btb_valid_2[btb_index_read_reg] <= btb_hit[2]? `DISABLE:btb_valid_2[btb_index_read_reg];
				btb_valid_3[btb_index_read_reg] <= btb_hit[3]? `DISABLE:btb_valid_3[btb_index_read_reg];
			end
		end
	end	
/*************** Instantiation **************/
	//////////////////////////////////////////////
	//	data_bram: 44x256x4; tag|type|address; 
	//			  A port update/B port read
	//////////////////////////////////////////////
	btb_bram tag_way_0 (
		.clka(clk),
		.addra(btb_index_update),
		.dina({btb_tag_update, btb_type_update, btb_addr_update}),
		.ena(btb_update_en_0),
		.wea(`ENABLE),
		.clkb(clk),
		.addrb(btb_index_read),
		.enb(|bp_dir),
		.doutb(btb_data_0)	//44 bits
	);
	btb_bram tag_way_1 (
		.clka(clk),
		.addra(btb_index_update),
		.dina({btb_tag_update, btb_type_update, btb_addr_update}),
		.ena(btb_update_en_1),
		.wea(`ENABLE),
		.clkb(clk),
		.addrb(btb_index_read),
		.enb(|bp_dir),
		.doutb(btb_data_1)
	);
	btb_bram tag_way_2 (
		.clka(clk),
		.addra(btb_index_update),
		.dina({btb_tag_update, btb_type_update, btb_addr_update}),
		.ena(btb_update_en_2),
		.wea(`ENABLE),
		.clkb(clk),
		.addrb(btb_index_read),
		.enb(|bp_dir),
		.doutb(btb_data_2)
	);
	btb_bram tag_way_3 (
		.clka(clk),
		.addra(btb_index_update),
		.dina({btb_tag_update, btb_type_update, btb_addr_update}),
		.ena(btb_update_en_3),
		.wea(`ENABLE),
		.clkb(clk),
		.addrb(btb_index_read),
		.enb(|bp_dir),
		.doutb(btb_data_3)
	);
	//	RAS_LIFO
	RAS_LIFO RAS_LIFO(
		.clk(clk),
		.rst_(rst_),
		.ras_read_en(ras_read_en),
		.ras_write_en(ras_update_en),
		.ras_read_data(ras_addr),
		.ras_write_data(ras_pc_update)
	);
endmodule

module RAS_LIFO(
	/**** Global Signal ****/
	input  wire clk,
	input  wire rst_,
	/**** Addr_Predictor Signal ****/
	input  wire ras_write_en,
	input  wire ras_read_en,
	output wire [`WordAddrBus] ras_read_data,
	input  wire [`WordAddrBus] ras_write_data
	);
	
	/**** Internal Signal ****/
	reg 	[`RasDataBus]	ras_data [`RasDepthBus];
	reg 	[`RasAddrBus]	ras_front;
	reg     [`RasAddrBus]   ras_rear;
	integer					reset_counter;

	/****** Combinational Logic ******/
	//Read Channel
	assign ras_read_data = (ras_read_en & ras_write_en) ? ras_write_data:
							(ras_read_en) ? ((ras_front==ras_rear && ras_rear == 3'b000)?`WORD_DATA_W'b0:
								            ((ras_front != ras_rear && ras_front==3'b000)?ras_data[3'b111]:ras_data[ras_front-1])): `WORD_DATA_W'b0;
	//Write Channel
	

	/****** Sequential Logic *******/
	always @(posedge clk) begin
		if (!rst_) begin
			ras_front   <= 3'b0;
			ras_rear    <= 3'b0;
			for(reset_counter = 0; reset_counter < 8; reset_counter = reset_counter + 1)begin
				ras_data[reset_counter] <= 32'b0;
			end
		end
		else begin
			case({ras_read_en, ras_write_en})
				2'b00:begin
					//keep the data
				end
				2'b01: begin
					ras_front 	<= (ras_front == ras_rear && ras_front == 3'b111)?3'b000:ras_front+1;
					ras_rear    <= 	(ras_rear == ras_front + 1 && ras_rear == 3'b111) ? 3'b000: 
									(ras_rear == ras_front + 1 || (ras_rear == 3'b000 && ras_front == 3'b111)) ? ras_rear + 1 : ras_rear;
					ras_data[ras_front] <= ras_write_data;
				end
				2'b10: begin
					ras_front   <= (ras_front == ras_rear)?3'b000:
									(ras_front == 3'b000)?3'b111:ras_front-1;
					ras_rear    <= (ras_front == ras_rear)?3'b000:ras_rear;
				end
				2'b11: begin
					//keep the data
				end
			endcase
		end
	end
endmodule



module PTAB(
	/***** Global Signal *****/
	input  wire clk,
	input  wire rst_,
	/***** EX Signal *****/
	input  wire flush,
	input  wire [`Ptab2AddrBus] ex_ptab_addr,
	output wire [`Ptab2dataBus] ex_ptab_data,
	/***** Flush Signal *****/
	input  wire [`Ptab2AddrBus] is_ptab_addr,
	input  wire [`Ptab2AddrBus] id_ptab_addr,
	input  wire [`PtabAddrBus] ib_ptab_addr,
	/***** Addr_Predictor Signal *****/
	input  wire bp_dir_en,
	input  wire bp_addr_en,
	input  wire [`WordAddrBus] bp_target_addr,
	input  wire [`WordAddrBus] bp_now_addr,
	output wire bp_ptab_full,
	output wire [`PtabAddrBus] bp_ptab_addr
	);
	/****** Internal Signal ******/
	//ptab
	reg  [`PtabDataBus]  ptab_ram [`PtabDepthBus];
	reg  [`PtabDepthBus] ptab_valid;
	integer				 ptab_reset_counter;
	//write channel
	wire [`PtabIaddrBus] set_choice;
	wire [`PtabAddrBus]  is_ptab_addr_0;
	wire [`PtabAddrBus]  is_ptab_addr_1;
	wire [`PtabAddrBus]  id_ptab_addr_0;
	wire [`PtabAddrBus]  id_ptab_addr_1;
	//read channel
	wire [`PtabAddrBus]  ex_ptab_addr_0;
	wire [`PtabAddrBus]  ex_ptab_addr_1;
	wire [`PtabIaddrBus] ex_ptab_realaddr_0;  //4 bits, without the direction bit.
	wire [`PtabIaddrBus] ex_ptab_realaddr_1;

	/****** Combinational Logic ******/
	//Write Channel
	assign	set_choice = (~ptab_valid[0]) ? 4'd0  :(~ptab_valid[1])  ? 4'd1  :
						(~ptab_valid[2])  ? 4'd2  :(~ptab_valid[3])  ? 4'd3  :
						(~ptab_valid[4])  ? 4'd4  :(~ptab_valid[5])  ? 4'd5  :
						(~ptab_valid[6])  ? 4'd6  :(~ptab_valid[7])  ? 4'd7  :
						(~ptab_valid[8])  ? 4'd8  :(~ptab_valid[9])  ? 4'd9  :
						(~ptab_valid[10]) ? 4'd10 :(~ptab_valid[11]) ? 4'd11 :
						(~ptab_valid[12]) ? 4'd12 :(~ptab_valid[13]) ? 4'd13 :
						(~ptab_valid[14]) ? 4'd14 : 4'd15;
	assign bp_ptab_full = &ptab_valid;
	//assign bp_ptab_addr = {(bp_addr_en & (!bp_ptab_full)), set_choice};
	//Read Channel
	assign ex_ptab_data = {ptab_ram[ex_ptab_realaddr_1], ptab_ram[ex_ptab_realaddr_0]};
	assign {ex_ptab_addr_1, ex_ptab_addr_0} = ex_ptab_addr;
	assign {id_ptab_addr_1, id_ptab_addr_0} = id_ptab_addr;
	assign {is_ptab_addr_1, is_ptab_addr_0} = is_ptab_addr;
	assign ex_ptab_realaddr_0 = ex_ptab_addr_0[`PtabIaddrBus];
	assign ex_ptab_realaddr_1 = ex_ptab_addr_1[`PtabIaddrBus];
    assign bp_ptab_addr = (bp_addr_en & (!bp_ptab_full))?{(bp_addr_en & (!bp_ptab_full)), set_choice}:5'b0;
	/****** Sequential Logic ******/
	//ptab
	always @(posedge clk) begin
		if (!rst_) begin
			for(ptab_reset_counter = 0; ptab_reset_counter < 16; ptab_reset_counter = ptab_reset_counter + 1)begin
				ptab_ram[ptab_reset_counter] <= 'b0;
				//bp_ptab_addr <= 5'b0;
			end
		end
		else if (bp_addr_en & (!bp_ptab_full)) begin
			ptab_ram[set_choice] <= {bp_target_addr, bp_now_addr + 8};
			//bp_ptab_addr <= {(bp_addr_en & (!bp_ptab_full)), set_choice};
		end
		/*else begin
		    bp_ptab_addr <= 5'b0;
		end*/
	end
	//valid
	always @(posedge clk) begin
		if (!rst_) begin
			ptab_valid <= 'b0;
		end
		else if (flush) begin
			ptab_valid[ex_ptab_realaddr_0] <= (ex_ptab_addr_0[4])?`DISABLE:ptab_valid[ex_ptab_realaddr_0];
			ptab_valid[ex_ptab_realaddr_1] <= (ex_ptab_addr_1[4])?`DISABLE:ptab_valid[ex_ptab_realaddr_1];
			ptab_valid[is_ptab_addr_0[`PtabIaddrBus]] <=(is_ptab_addr_0[4])? `DISABLE:ptab_valid[is_ptab_addr_0[`PtabIaddrBus]];
			ptab_valid[is_ptab_addr_1[`PtabIaddrBus]] <=(is_ptab_addr_1[4])? `DISABLE:ptab_valid[is_ptab_addr_1[`PtabIaddrBus]];
			ptab_valid[id_ptab_addr_0[`PtabIaddrBus]] <=(id_ptab_addr_0[4])? `DISABLE:ptab_valid[id_ptab_addr_0[`PtabIaddrBus]];
			ptab_valid[id_ptab_addr_1[`PtabIaddrBus]] <=(id_ptab_addr_1[4])? `DISABLE:ptab_valid[id_ptab_addr_1[`PtabIaddrBus]];
			ptab_valid[ib_ptab_addr[`PtabIaddrBus]]   <=(ib_ptab_addr[4])?   `DISABLE:ptab_valid[ib_ptab_addr[`PtabIaddrBus]];
		end
		else begin
			ptab_valid[set_choice]     <= (bp_addr_en && !bp_ptab_full)? `ENABLE : ptab_valid[set_choice];
			ptab_valid[ex_ptab_realaddr_0] <= (ex_ptab_addr_0[4])?`DISABLE:ptab_valid[ex_ptab_realaddr_0];
			ptab_valid[ex_ptab_realaddr_1] <= (ex_ptab_addr_1[4])?`DISABLE:ptab_valid[ex_ptab_realaddr_1];
		end
	end
endmodule

