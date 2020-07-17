//7.15 update: CHANGE THE MACRO DEFINE OF EXC_RI & EXC_NONE
/********** general header **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** module header **********/
`include "isa.h"
`include "cpu.h"
`include "each_module.h"

/********** internal define ***********/
/* `define Isa2regAddrBus 9:0
`define	Imme2wayBus 63:0
`define Type2wayBus 3:0
`define Insn2wayBus 11:0
`define Insn2wayOpnEnBus 7:0
`define TwoADDR_WORDSIZE 63:0 */
`define IDinfo_W 55//20190722
`define IDValid_W 6
`define ISA_I_TYPE 6'b110111
`define ISA_S_TYPE 6'b011111
`define ISA_R_TYPE 6'b111011
`define ISA_J_TYPE 6'b000111
`define ISA_JAL_TYPE 6'b100111
`define ISA_MUL_DIV_TYPE 6'b011011
`define ISA_BGBL_TYPE 6'b010111
`define ISA_BGBLZAL_TYPE 6'b110111
`define ISA_JR_MTHILO_TYPE 6'b010011
`define ISA_JALR_TYPE 6'b110011
`define ISA_MFHILO_TYPE 6'b100011
`define ISA_B_TYPE 6'b011111
`define EXC_RI 5'h0a
`define EXC_NONE 5'h10
`define INSN_UNDEFINED 6'h39
//`define INSN_ALU_TYPE 3'b000
//`define	INSN_MULT_TYPE 3'b001
//`define INSN_DIV_TYPE 3'b010
//`define INSN_NOP_TYPE 3'b011
//`define INSN_MEM_TYPE 3'b100
`define IsaSaLoc 10:6

module decoder(
	/********* Decoder Signal **********/
	input   wire    [`WordAddrBus]  pc,
	input	wire	[`WordDataBus]	insn,
	input	wire	valid,
	output	reg		[`BtbTypeBus]	branch_type,
	output	reg		[`WordAddrBus]	branch_target_addr,
	output	reg		branch_en,
	output  wire    [`IDinfo_W-1 : 0]   decode_info,
	output	reg		[`IDValid_W-1 : 0]	decode_valid,
	output  wire	[`ISA_EXC_W-1 : 0] 	exc_code
	);

	wire	[`IsaOpBus]			op;
	wire	[`IsaFunBus] 		func;
	wire	[`IsaSaBus]			sa;
	wire	[`IsaRegAddrBus]	rs_addr;
	wire	[`IsaRegAddrBus]	rt_addr;
	wire	[`IsaRegAddrBus]	rd_addr;
	

	reg		[`IsaRegAddrBus]	dst_addr;
	reg		[`IsaRegAddrBus]	src0_addr;
	reg		[`IsaRegAddrBus]	src1_addr;	
	reg		[`ImmeBus]			imme;
	reg		[`InsnTypeBus]		insn_type;
	reg		[`InsnBus]			insn_meaning;
	/***** Combinational Logic *****/
	assign op   = insn[`IsaOpLoc];
	assign func = insn[`IsaFunLoc];
	assign sa   = insn[`IsaSaLoc];
	assign rs_addr  = insn[`IsaRsAddrLoc];
	assign rt_addr  = insn[`IsaRtAddrLoc];
	assign rd_addr  = insn[`IsaRdAddrLoc];
	assign decode_info = {dst_addr, src0_addr, src1_addr, imme, insn_type, insn_meaning};
	assign exc_code = (insn_meaning == `INSN_UNDEFINED) ? `EXC_RI : `EXC_NONE;

	always @(*) begin
		insn_type 	 = `INSN_ALU_TYPE;
		insn_meaning = `INSN_NOP;
		dst_addr 	 = `REG_ADDR_BASE;
		src0_addr	 = `REG_ADDR_BASE;
		src1_addr	 = `REG_ADDR_BASE;
		imme    	 = `WORD_DATA_W'b0;
		decode_valid = `IDValid_W'b000011;
		branch_type  = `TYPE_NOP;
		branch_target_addr = `WORD_ADDR_W'b0;
		branch_en    = `DISABLE;
		if(valid)begin
			case(op)
				`ISA_OP_ADD : begin
					case(func)
						`ISA_FUN_ADD: begin
							if(sa == `ISA_ZERO_ID)begin
								dst_addr  = rd_addr;
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_meaning = `INSN_ADD;
								decode_valid = `ISA_R_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_ADDU: begin
							if(sa == `ISA_ZERO_ID)begin
								dst_addr  = rd_addr;
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_meaning = `INSN_ADDU;
								decode_valid = `ISA_R_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_SUB: begin
							if(sa == `ISA_ZERO_ID)begin
								dst_addr  = rd_addr;
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_meaning = `INSN_SUB;
								decode_valid = `ISA_R_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_SUBU: begin
							if(sa == `ISA_ZERO_ID)begin
								dst_addr  = rd_addr;
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_meaning = `INSN_SUBU;
								decode_valid = `ISA_R_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_SLT: begin
							if(sa == `ISA_ZERO_ID)begin
								dst_addr  = rd_addr;
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_meaning = `INSN_SLT;
								decode_valid = `ISA_R_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_SLTU: begin
							if(sa == `ISA_ZERO_ID)begin
								dst_addr  = rd_addr;
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_meaning = `INSN_SLTU;
								decode_valid = `ISA_R_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_MULT: begin
							if(sa == `ISA_ZERO_ID && (rd_addr == `ISA_ZERO_ID))begin
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_type = `INSN_MULT_TYPE;
								insn_meaning = `INSN_MULT;
								decode_valid = `ISA_MUL_DIV_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_MULTU : begin
							if((sa == `ISA_ZERO_ID) && (rd_addr == `ISA_ZERO_ID)) begin
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_type = `INSN_MULT_TYPE;
								insn_meaning = `INSN_MULTU;
								decode_valid = `ISA_MUL_DIV_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_DIV : begin
							if((sa == `ISA_ZERO_ID) && (rd_addr == `ISA_ZERO_ID)) begin
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_type = `INSN_DIV_TYPE;
								insn_meaning = `INSN_DIV;
								decode_valid = `ISA_MUL_DIV_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_DIVU : begin
							if((sa == `ISA_ZERO_ID) && (rd_addr == `ISA_ZERO_ID)) begin
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_type = `INSN_DIV_TYPE;
								insn_meaning = `INSN_DIVU;
								decode_valid = `ISA_MUL_DIV_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_AND : begin
							if(sa == `ISA_ZERO_ID) begin
								dst_addr  = rd_addr;
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_meaning = `INSN_AND;
								decode_valid = `ISA_R_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_NOR : begin
							if(sa == `ISA_ZERO_ID) begin
								dst_addr  = rd_addr;
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_meaning = `INSN_NOR;
								decode_valid = `ISA_R_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_OR : begin
							if(sa == `ISA_ZERO_ID) begin
								dst_addr  = rd_addr;
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_meaning = `INSN_OR;
								decode_valid = `ISA_R_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_XOR : begin
							if(sa == `ISA_ZERO_ID) begin
								dst_addr  = rd_addr;
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_meaning = `INSN_XOR;
								decode_valid = `ISA_R_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_SLLV : begin
							if(sa == `ISA_ZERO_ID) begin
								dst_addr  = rd_addr;
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_meaning = `INSN_SLLV;
								decode_valid = `ISA_R_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_SLL : begin
							if(rs_addr == `ISA_ZERO_ID) begin
								dst_addr  = rd_addr;
								src0_addr = rt_addr;
								imme      = {27'b0, sa};
								insn_meaning = `INSN_SLL;
								decode_valid = `ISA_I_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_SRAV : begin
							if(sa == `ISA_ZERO_ID) begin
								dst_addr  = rd_addr;
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_meaning = `INSN_SRAV;
								decode_valid = `ISA_R_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_SRA : begin
							if(rs_addr == `ISA_ZERO_ID) begin
								dst_addr  = rd_addr;
								src0_addr = rt_addr;
								imme      = {27'b0, sa};
								insn_meaning = `INSN_SRA;
								decode_valid = `ISA_I_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_SRLV : begin
							if(sa == `ISA_ZERO_ID) begin
								dst_addr  = rd_addr;
								src0_addr = rs_addr;
								src1_addr = rt_addr;
								insn_meaning = `INSN_SRLV;
								decode_valid = `ISA_R_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_SRL : begin
							if(rs_addr == `ISA_ZERO_ID) begin
								dst_addr  = rd_addr;
								src0_addr = rt_addr;
								imme      = {27'b0, sa};
								insn_meaning = `INSN_SRL;
								decode_valid = `ISA_I_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_JR : begin
							if((sa == `ISA_ZERO_ID) && (rt_addr == `ISA_ZERO_ID) && (rd_addr == `ISA_ZERO_ID)) begin
								src0_addr = rs_addr;
								insn_meaning = `INSN_JR;
								decode_valid = `ISA_JR_MTHILO_TYPE;
								branch_en = `ENABLE;
								branch_type = `TYPE_RETURN;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_JALR : begin
							if((sa == `ISA_ZERO_ID) && (rt_addr == `ISA_ZERO_ID)) begin
								dst_addr = rd_addr;
								src0_addr = rs_addr;
								insn_meaning = `INSN_JALR;
								decode_valid = `ISA_JALR_TYPE;
								branch_en = `ENABLE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_MFHI : begin
							if((sa == `ISA_ZERO_ID) && (rt_addr == `ISA_ZERO_ID) && (rs_addr == `ISA_ZERO_ID)) begin
								dst_addr = rd_addr;
								insn_meaning = `INSN_MFHI;
								decode_valid = `ISA_MFHILO_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_MFLO : begin
							if((sa == `ISA_ZERO_ID) && (rt_addr == `ISA_ZERO_ID) && (rs_addr == `ISA_ZERO_ID)) begin
								dst_addr = rd_addr;
								insn_meaning = `INSN_MFLO;
								decode_valid = `ISA_MFHILO_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_MTHI : begin
							if((sa == `ISA_ZERO_ID) && (rt_addr == `ISA_ZERO_ID) && (rd_addr == `ISA_ZERO_ID)) begin
								src0_addr = rs_addr;
								insn_meaning = `INSN_MTHI;
								decode_valid = `ISA_JR_MTHILO_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_MTLO : begin
							if((sa == `ISA_ZERO_ID) && (rt_addr == `ISA_ZERO_ID) && (rd_addr == `ISA_ZERO_ID)) begin
								src0_addr = rs_addr;
								insn_meaning = `INSN_MTLO;
								decode_valid = `ISA_JR_MTHILO_TYPE;
							end
							else begin
								insn_meaning = `INSN_UNDEFINED;
							end
						end
						`ISA_FUN_BREAK : begin
							insn_meaning = `INSN_BREAK;
						end
						`ISA_FUN_SYSCALL: begin
							insn_meaning = `INSN_SYSCALL;
						end
						default: begin
							insn_meaning = `INSN_UNDEFINED;
						end
					endcase
				end
				`ISA_OP_ADDI: begin
					dst_addr  = rt_addr;
					src0_addr = rs_addr;
					imme      = {{`ISA_EXT_W{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc]};
					insn_meaning = `INSN_ADDI;
					decode_valid = `ISA_I_TYPE;
				end
				`ISA_OP_ADDIU: begin
					dst_addr  = rt_addr;
					src0_addr = rs_addr;
					imme      = {{`ISA_EXT_W{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc]};
					insn_meaning = `INSN_ADDIU;
					decode_valid = `ISA_I_TYPE;
				end
				`ISA_OP_SLTI: begin
					dst_addr  = rt_addr;
					src0_addr = rs_addr;
					imme      = {{`ISA_EXT_W{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc]};
					insn_meaning = `INSN_SLTI;
					decode_valid = `ISA_I_TYPE;
				end
				`ISA_OP_SLTIU: begin
					dst_addr  = rt_addr;
					src0_addr = rs_addr;
					imme      = {{`ISA_EXT_W{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc]};
					insn_meaning = `INSN_SLTIU;
					decode_valid = `ISA_I_TYPE;
				end
				`ISA_OP_ANDI: begin
					dst_addr  = rt_addr;
					src0_addr = rs_addr;
					imme      = {`ISA_EXT_W'b0, insn[`IsaImmLoc]};
					insn_meaning = `INSN_ANDI;
					decode_valid = `ISA_I_TYPE;
				end
				`ISA_OP_LUI: begin
					if(rs_addr == `ISA_ZERO_ID)begin
						dst_addr  = rt_addr;
						src0_addr = rs_addr;
						imme      = {insn[`IsaImmLoc],`ISA_EXT_W'b0};
						insn_meaning = `INSN_LUI;
						decode_valid = `ISA_I_TYPE;	
					end
					else begin
						insn_meaning = `INSN_UNDEFINED;
					end
				end
				`ISA_OP_ORI: begin
					dst_addr  = rt_addr;
					src0_addr = rs_addr;
					imme      = {`ISA_EXT_W'b0,insn[`IsaImmLoc]};
					insn_meaning = `INSN_ORI;
					decode_valid = `ISA_I_TYPE;
				end
				`ISA_OP_XORI: begin
					dst_addr  = rt_addr;
					src0_addr = rs_addr;
					imme      = {`ISA_EXT_W'b0,insn[`IsaImmLoc]};
					insn_meaning = `INSN_XORI;
					decode_valid = `ISA_I_TYPE;
				end
				`ISA_OP_BEQ: begin
					src0_addr = rs_addr;
					src1_addr = rt_addr;
					imme      = {{`ISA_EXT_B{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc],{`ISA_SLL_B{1'b0}}};
					insn_meaning = `INSN_BEQ;
					decode_valid = `ISA_B_TYPE;
					branch_en    = `ENABLE;
					branch_type  = `TYPE_RELATIVE;
					branch_target_addr = pc + 32'h4 + {{`ISA_EXT_B{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc],{`ISA_SLL_B{1'b0}}};
				end
				`ISA_OP_BNE: begin
					src0_addr = rs_addr;
					src1_addr = rt_addr;
					imme      = {{`ISA_EXT_B{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc],{`ISA_SLL_B{1'b0}}};
					insn_meaning = `INSN_BNE;
					decode_valid = `ISA_B_TYPE;
					branch_en    = `ENABLE;
					branch_type  = `TYPE_RELATIVE;
					branch_target_addr = pc + 32'h4 +{{`ISA_EXT_B{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc],{`ISA_SLL_B{1'b0}}};
				end
				`ISA_OP_BGEZ: begin
					src0_addr = rs_addr;
					dst_addr  = (rt_addr == `ISA_B_BGEZAL || rt_addr == `ISA_B_BLTZAL)?`REG_ADDR_31:`REG_ADDR_BASE;
					imme      = {{`ISA_EXT_B{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc],{`ISA_SLL_B{1'b0}}};
					insn_meaning = (rt_addr == `ISA_B_BGEZ)?`INSN_BGEZ:
									(rt_addr == `ISA_B_BLTZ)?`INSN_BLTZ:
									(rt_addr == `ISA_B_BGEZAL)?`INSN_BGEZAL:
									(rt_addr == `ISA_B_BLTZAL)?`INSN_BLTZAL:`INSN_UNDEFINED;
					decode_valid =(rt_addr == `ISA_B_BGEZAL || rt_addr == `ISA_B_BLTZAL)? `ISA_BGBLZAL_TYPE: `ISA_BGBL_TYPE;
					branch_en    = (rt_addr == `ISA_B_BGEZ || rt_addr == `ISA_B_BLTZ
									 ||rt_addr == `ISA_B_BGEZAL || rt_addr == `ISA_B_BLTZAL)?`ENABLE:`DISABLE;
					branch_type  = `TYPE_RELATIVE;
					branch_target_addr = pc + 32'h4 +{{`ISA_EXT_B{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc],{`ISA_SLL_B{1'b0}}};
				end
				`ISA_OP_BGTZ: begin
					src0_addr = rs_addr;
					imme      = {{`ISA_EXT_B{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc],{`ISA_SLL_B{1'b0}}};
					insn_meaning = (rt_addr == `ISA_ZERO_ID)?`INSN_BGTZ:`INSN_UNDEFINED;
					decode_valid = `ISA_BGBL_TYPE;
					branch_en    = (rt_addr == `ISA_ZERO_ID)?`ENABLE:`DISABLE;
					branch_type  = `TYPE_RELATIVE;
					branch_target_addr = pc + 32'h4 +{{`ISA_EXT_B{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc],{`ISA_SLL_B{1'b0}}};
				end
				`ISA_OP_BLEZ: begin
					src0_addr = rs_addr;
					imme      = {{`ISA_EXT_B{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc],{`ISA_SLL_B{1'b0}}};
					insn_meaning = (rt_addr == `ISA_ZERO_ID)?`INSN_BLEZ:`INSN_UNDEFINED;
					decode_valid = `ISA_BGBL_TYPE;
					branch_en    = (rt_addr == `ISA_ZERO_ID)?`ENABLE:`DISABLE;
					branch_type  = `TYPE_RELATIVE;
					branch_target_addr = pc + 32'h4 +{{`ISA_EXT_B{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc],{`ISA_SLL_B{1'b0}}};
				end
				`ISA_OP_J: begin
					imme = {pc[`ISA_PC_J],insn[`ISA_INSN_J],{`ISA_SLL_J{1'b0}}};
					insn_meaning = `INSN_J;
					decode_valid = `ISA_J_TYPE;
					branch_en    = `ENABLE;
					branch_type  = `TYPE_RELATIVE;
					branch_target_addr = {pc[`ISA_PC_J],insn[`ISA_INSN_J],{`ISA_SLL_J{1'b0}}};
				end
				`ISA_OP_JAL: begin
					imme 	 = {pc[`ISA_PC_J],insn[`ISA_INSN_J],`ISA_SLL_J'b0};
					dst_addr = `REG_ADDR_31;
					insn_meaning = `INSN_JAL;
					decode_valid = `ISA_JAL_TYPE;
					branch_en    = `ENABLE;
					branch_type  = `TYPE_RELATIVE;
					branch_target_addr = {pc[`ISA_PC_J],insn[`ISA_INSN_J],{`ISA_SLL_J{1'b0}}};
				end
				`ISA_OP_LB: begin
					imme 	  = {{`ISA_EXT_W{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc]};
					dst_addr  = rt_addr;
					src0_addr = rs_addr;
					insn_type = `INSN_ALU_TYPE;
					insn_meaning = `INSN_LB;
					decode_valid = `ISA_I_TYPE;
				end
				`ISA_OP_LBU: begin
					imme      = {{`ISA_EXT_W{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc]};
					dst_addr  = rt_addr;
					src0_addr = rs_addr;
					insn_type = `INSN_ALU_TYPE;
					insn_meaning = `INSN_LBU;
					decode_valid = `ISA_I_TYPE;
				end
				`ISA_OP_LH: begin
					imme      = {{`ISA_EXT_W{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc]};
					dst_addr  = rt_addr;
					src0_addr = rs_addr;
					insn_type = `INSN_ALU_TYPE;
					insn_meaning = `INSN_LH;
					decode_valid = `ISA_I_TYPE;
				end
				`ISA_OP_LHU: begin
					imme      = {{`ISA_EXT_W{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc]};
					dst_addr  = rt_addr;
					src0_addr = rs_addr;
					insn_type = `INSN_ALU_TYPE;
					insn_meaning = `INSN_LHU;
					decode_valid = `ISA_I_TYPE;
					end
				`ISA_OP_LW: begin//LW
					imme      = {{`ISA_EXT_W{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc]};
					dst_addr  = rt_addr;
					src0_addr = rs_addr;
					insn_type = `INSN_ALU_TYPE;
					insn_meaning = `INSN_LW;
					decode_valid = `ISA_I_TYPE;
				end
				`ISA_OP_SB: begin
					imme      = {{`ISA_EXT_W{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc]};
					src0_addr = rs_addr;
					src1_addr = rt_addr;
					insn_type = `INSN_ALU_TYPE;
					insn_meaning = `INSN_SB;
					decode_valid = `ISA_S_TYPE;
				end
				`ISA_OP_SH: begin
					imme      = {{`ISA_EXT_W{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc]};
					src0_addr = rs_addr;
					src1_addr = rt_addr;
					insn_type = `INSN_ALU_TYPE;
					insn_meaning = `INSN_SH;
					decode_valid = `ISA_S_TYPE;
				end
				`ISA_OP_SW: begin
					imme      = {{`ISA_EXT_W{insn[`ISA_IMM_MSB]}},insn[`IsaImmLoc]};
					src0_addr = rs_addr;
					src1_addr = rt_addr;
					insn_type = `INSN_ALU_TYPE;
					insn_meaning = `INSN_SW;
					decode_valid = `ISA_S_TYPE;
				end
				`ISA_OP_ERET: begin
					if(func == `ISA_FUN_ERET) begin
						if(insn[`IsaEretLoc] == `ISA_ERET_ID) begin
							insn_meaning = `INSN_ERET;
							decode_valid = 6'b000011;
						end
						else begin
							insn_meaning = `INSN_UNDEFINED;
						end
				    end
					else begin
						if(insn[`IsaCp0Loc] == `ISA_CP0_ID)begin
							case(rs_addr)
								`ISA_MFC0: begin
									dst_addr     = rt_addr;
									src0_addr    = rd_addr;
									insn_meaning = `INSN_MFC0;
									decode_valid = 6'b110011;
								end
								`ISA_MTC0: begin
									dst_addr 	 = rd_addr;
									src0_addr    = rt_addr;
									insn_meaning = `INSN_MTC0;
									decode_valid = 6'b110011;
								end
								default: begin
									insn_meaning = `INSN_UNDEFINED;
								end
							endcase
						end
						else begin
							insn_meaning = `INSN_UNDEFINED;
						end
					end
				end
				default: begin
					insn_meaning = `INSN_UNDEFINED;
				end
			endcase
		end
	end
endmodule
