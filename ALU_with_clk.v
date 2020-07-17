`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/04 15:24:57
// Design Name: 
// Module Name: ALU0
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

/**********      Common header file      **********/
`include "cpu.h"
`include "global_config.h"
`include "isa.h"
`include "nettype.h"
`include "stddef.h"

`define DestAddr           4:0
`define PtabdataBus       63:0
`define Ptabnextpc        31:0
`define IsaExpBus          4:0
`define BranchOp (op == `INSN_BEQ || op == `INSN_BNE || op == `INSN_BLEZ || op == `INSN_BLTZ || op == `INSN_BLTZAL || op == `INSN_BGEZAL || op == `INSN_BGTZ || op == `INSN_BGEZ || op == `INSN_J || op == `INSN_JAL || op == `INSN_JR || op == `INSN_JALR )

`define LoadtypeOp   (op == `INSN_LB || op == `INSN_LBU || op == `INSN_LH || op == `INSN_LHU || op == `INSN_LW)
`define StoretypeOp  (op == `INSN_SB || op == `INSN_SH || op == `INSN_SW)

`define LoadtypeAluOpWay1   (alu_op_way1 == `INSN_LB || alu_op_way1 == `INSN_LBU || alu_op_way1 == `INSN_LH || alu_op_way1 == `INSN_LHU || alu_op_way1 == `INSN_LW)
`define StoretypeAluOpWay1  (alu_op_way1 == `INSN_SB || alu_op_way1 == `INSN_SH || alu_op_way1 == `INSN_SW)
`define LoadtypeAluOp   (alu_op == `INSN_LB || alu_op == `INSN_LBU || alu_op == `INSN_LH || alu_op == `INSN_LHU || alu_op == `INSN_LW)
`define StoretypeAluOp  (alu_op == `INSN_SB || alu_op == `INSN_SH || alu_op == `INSN_SW)
`define RDBranchAluOp (alu_op == `INSN_JAL || alu_op == `INSN_JALR || alu_op == `INSN_BGEZAL || alu_op == `INSN_BLTZAL)
`define ByteOffset         1:0


module ALU_with_clk (
    //global signal
    input wire                 clk,
    input wire                 reset,
    input wire                 flush,
    input wire                 flush_caused_by_exc,
    //CE
    //input wire                 CE_in,
    //output reg                 CE_out,
    //alu data in
	input  wire [`WordDataBus]   scr0_data,  
	input  wire [`WordDataBus]   scr1_data,
	input  wire [`DestAddr]      dest_addr,
	input  wire [`WordDataBus]   imme,
	input  wire [`WordDataBus]   pc,
	input  wire [`AluOpBus]	      op,	  
	input  wire [`AluOpBus]	      op_way1,	  
	input  wire [`WordDataBus] cp0_data,
	input  wire                ptab_direction,
	input  wire [`PtabdataBus] ptab_data,
	input  wire [`WordDataBus] hi,
	input  wire [`WordDataBus] lo,
	input  wire [`IsaExpBus]   exp_code_in,
	input  wire [1:0]          alu_delot_flag,
	//handshake signal
	input  wire                ex_valid_ns,
	input  wire                wb_allin,
	//alu data out             
	output reg  [`DestAddr]    alu_dest_addr,
	output reg  [`WordDataBus] alu_pc,
	output reg  [`AluOpBus]	    alu_op,
	output reg                 branchcond,
	output reg                 bp_result,
	output reg	 [`WordDataBus] out,
	output reg	 [`WordDataBus] out_wr,	  
	output reg				    fu_ov,	  
	output reg   [`IsaExpBus]  exp_code_out
    );

/**********      Local definition      **********/ 
    `define        sa          4:0
    `define PtabAddrValid	      4
    `define Byte               7:0
    `define Halfword          15:0
    `define BpBus              1:0
/**********      Internal signal      **********/ 
    wire signed [`WordDataBus] s_scr0_data = $signed(scr0_data); 
	wire signed [`WordDataBus] s_scr1_data = $signed(scr1_data); 
	wire signed [`WordDataBus] s_imme      = $signed(imme);
	wire signed [`WordDataBus] s_out       = $signed(out);  
	wire        [`BpBus]       bpbus;
	reg                        ptab_direction_i;
	reg         [`AluOpBus]    alu_op_way1;
	
	wire        [`WordDataBus] alu_dataforrwen;

	
	assign alu_dataforrwen = scr0_data + imme;
	assign bpbus           = {ptab_direction_i,branchcond};
   // reg                      fu_ov;
   //CE logic
    //always @ (posedge clk) begin
        // CE_out          <=  CE_in;
    //end
    always @ (posedge clk) begin //maybe should seperate the flush signals coming from bp error and exception;
         if (reset == `RESET_ENABLE) begin
         branchcond       <=  1'b0;
         //bp_result        <=  1'b1;//fresh
         out              <= 32'b0;
         out_wr           <= 32'b0;
         fu_ov            <=  1'b0;
         
         alu_dest_addr    <=   5'b0;
         alu_pc           <=  32'b0;
         alu_op           <=    `INSN_NOP;
         alu_op_way1      <=    `INSN_NOP;
         exp_code_out     <= `ISA_EXC_NO_EXC;
         ptab_direction_i <= 1'b0;
         end
         else if(flush && !flush_caused_by_exc && alu_delot_flag == 2'b10 && (`LoadtypeAluOp||`StoretypeAluOp))begin
         
         end
         else if(flush && !flush_caused_by_exc && alu_delot_flag == 2'b10 && `RDBranchAluOp && (`LoadtypeAluOpWay1||`StoretypeAluOpWay1))begin
         
         end
         else if(flush)begin
         branchcond       <=  1'b0;
         //bp_result        <=  1'b1;//fresh
         out              <= 32'b0;
         out_wr           <= 32'b0;
         fu_ov            <=  1'b0;
         
         alu_dest_addr    <=   5'b0;
         alu_pc           <=  32'b0;
         alu_op           <=   `INSN_NOP;
         alu_op_way1      <=   `INSN_NOP;
         exp_code_out     <= `ISA_EXC_NO_EXC;
         ptab_direction_i <= 1'b0;
         end
         else if (ex_valid_ns && wb_allin) begin
         //Initialization
         //branchcond       <=  1'b0;
         //bp_result        <=  1'b1;//fresh
         //out              <= 32'b0;
         //out_wr           <= 32'b0;
         //fu_ov            <=  1'b0;
         //data transfer
         alu_dest_addr    <=   dest_addr;
         alu_pc           <=          pc;
         alu_op           <=          op;
         alu_op_way1      <=     op_way1;
         exp_code_out     <= exp_code_in;
         ptab_direction_i <= ptab_direction;
         case (op) 
         //addtion
					`INSN_ADD: begin
						{fu_ov,out} <= {scr0_data[`WORD_MSB],scr0_data} + {scr1_data[`WORD_MSB],scr1_data};
						branchcond  <= 1'b0;
					end
					`INSN_ADDI: begin
						{fu_ov,out} <= {scr0_data[`WORD_MSB],scr0_data} + {imme[`WORD_MSB],imme};
						branchcond  <= 1'b0;
					end
					`INSN_ADDU: begin
						 out        <= scr0_data + scr1_data;
						 fu_ov            <=  1'b0;
						branchcond = 1'b0;
					end
					`INSN_ADDIU: begin
						out         <= scr0_data + imme;
						fu_ov            <=  1'b0;
						branchcond  <= 1'b0;
					end
					
		//subtraction
					`INSN_SUB: begin
						{fu_ov,out}  <= {scr0_data[`WORD_MSB],scr0_data} - {scr1_data[`WORD_MSB],scr1_data};
						branchcond   <= 1'b0;
					end
					`INSN_SUBU: begin
						out          <= scr0_data - scr1_data;
						fu_ov            <=  1'b0;
						branchcond   <= 1'b0;
					end
					
		//compare
					`INSN_SLT: begin
						if (s_scr0_data < s_scr1_data) begin
							out        <= 32'd1;
							fu_ov            <=  1'b0;
							branchcond <= 1'b0;
						end
						else begin
							out        <= 32'd0;
							fu_ov            <=  1'b0;
							branchcond <= 1'b0;
						end
					end
					`INSN_SLTI: begin
					    fu_ov            <=  1'b0;
						if (s_scr0_data < s_imme) begin
							out        <= 32'd1;
							branchcond <= 1'b0;
						end
						else begin
							out        <= 32'd0;
							branchcond <= 1'b0;
						end
					end
					`INSN_SLTU: begin
					    fu_ov            <=  1'b0;
						if ({`DISABLE,scr0_data} < {`DISABLE,scr1_data}) begin
							out         <= 32'd1;
							branchcond  <= 1'b0;
						end
						else begin
							out         <= 32'd0;
							branchcond  <= 1'b0;
						end
					end
					`INSN_SLTIU: begin
					    fu_ov            <=  1'b0;
						if ({`DISABLE,scr0_data} < {`DISABLE,imme}) begin
							out         <= 32'd1;
							branchcond  <= 1'b0;
						end
						else begin
							out         <= 32'd0;
							branchcond  <= 1'b0;
						end
					end	
					
		//logic
					`INSN_AND: begin
					    fu_ov            <=  1'b0;
						out              <= scr0_data & scr1_data;
						branchcond       <= 1'b0;
					end
					`INSN_ANDI: begin
					    fu_ov            <=  1'b0;
						out              <= scr0_data & imme;
						branchcond       <= 1'b0;
					end
					`INSN_LUI: begin
					    fu_ov            <=  1'b0;
						out              <= imme;
						branchcond       <= 1'b0;
					end
					`INSN_NOR: begin
					    fu_ov            <=  1'b0;
						out              <= ~(scr0_data | scr1_data);
						branchcond       <= 1'b0;
					end
					`INSN_OR: begin
					    fu_ov            <=  1'b0;
						out              <= scr0_data | scr1_data;
						branchcond       <= 1'b0;
					end
					`INSN_ORI: begin
					    fu_ov            <=  1'b0;
						out              <= scr0_data | imme;
						branchcond       <= 1'b0;
					end
					`INSN_XOR: begin
					    fu_ov            <=  1'b0;
						out              <= scr0_data ^ scr1_data;
						branchcond       <= 1'b0;
					end
					`INSN_XORI: begin
					    fu_ov            <=  1'b0;
						out              <= scr0_data ^ imme;
						branchcond       <= 1'b0;
					end
					
		//shift
					`INSN_SLLV: begin
					    fu_ov            <=  1'b0;
						out <= scr1_data << scr0_data[`sa];
						branchcond <= 1'b0;
					end
                    `INSN_SLL: begin
                        fu_ov            <=  1'b0;
						out <= scr0_data << imme[`sa];
						branchcond <= 1'b0;
					end
					`INSN_SRAV: begin
					    fu_ov            <=  1'b0;
						out <= s_scr1_data >>> scr0_data[`sa];
						branchcond <= 1'b0;
					end
					`INSN_SRA: begin
					    fu_ov            <=  1'b0;
						out <= s_scr0_data >>> imme[`sa];
						branchcond <= 1'b0;
					end
					`INSN_SRLV: begin
					    fu_ov            <=  1'b0;
						out <= s_scr1_data >> s_scr0_data[`sa];
						branchcond <= 1'b0;
					end
					`INSN_SRL: begin
					    fu_ov            <=  1'b0;
						out <= s_scr0_data >> imme[`sa];
						branchcond <= 1'b0;
					end
		//branch
					`INSN_BEQ: begin		
					    fu_ov            <=  1'b0;	
					if(scr0_data == scr1_data) begin
					    out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= pc + 32'd8;
					    out <= pc + 32'd8;
					end
					if(scr0_data == scr1_data) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end

					
					`INSN_BNE: begin
					    fu_ov            <=  1'b0;
					if(scr0_data != scr1_data) begin
					    out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= pc + 32'd8;
					    out <= pc + 32'd8;
					end
					if(scr0_data != scr1_data) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_BGEZ: begin
					    fu_ov            <=  1'b0;
				    if(scr0_data[`WORD_MSB] == 1'b0) begin
					    out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= pc + 32'd8;
					    out <= pc + 32'd8;
					end
					if(scr0_data[`WORD_MSB] == 1'b0) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_BGTZ: begin
					    fu_ov            <=  1'b0;
				    if(scr0_data[`WORD_MSB] == 1'b0 && scr0_data != 0) begin
					    out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= pc + 32'd8;
					    out <= pc + 32'd8;
					end
					if(scr0_data[`WORD_MSB] == 1'b0 && scr0_data != 0) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_BLEZ: begin
					    fu_ov            <=  1'b0;
				    if(scr0_data[`WORD_MSB] == 1'b1 || scr0_data == 0) begin
				        out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= pc + 32'd8;
					    out <= pc + 32'd8;
					end
					if(scr0_data[`WORD_MSB] == 1'b1 || scr0_data == 0) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_BLTZ: begin
					    fu_ov            <=  1'b0;
					if(scr0_data[`WORD_MSB] == 1'b1) begin
				        out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= pc + 32'd8;
					    out <= pc + 32'd8;
					end
					if(scr0_data[`WORD_MSB] == 1'b1) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_BGEZAL: begin
					    fu_ov            <=  1'b0;
				    if(scr0_data[`WORD_MSB] == 1'b0) begin
				        out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= pc + 32'd8;
					    out <= pc + 32'd8;
					end
					if(scr0_data[`WORD_MSB] == 1'b0) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_BLTZAL: begin
					    fu_ov            <=  1'b0;
				    if(scr0_data[`WORD_MSB] == 1'b1) begin
				        out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= pc + 32'd8;
					    out <= pc + 32'd8;
					end
					if(scr0_data[`WORD_MSB] == 1'b1) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_J: begin
					    fu_ov            <=  1'b0;
				       	out_wr <= imme;
					    out <= pc + 32'd8;
				        branchcond <= 1'b1; 
				    end
					
					`INSN_JAL: begin
					    fu_ov            <=  1'b0;
				    	out_wr <= imme;
					    out <= pc + 32'd8;
				        branchcond <= 1'b1; 
				    end
					
					`INSN_JR: begin
					    fu_ov            <=  1'b0;
				    	out_wr <= scr0_data;
					    out <= pc + 32'd8;
				        branchcond <= 1'b1; 
				    end
					
					`INSN_JALR: begin
					    fu_ov            <=  1'b0;
				    	out_wr <= scr0_data;
					    out <= pc + 32'd8;
				        branchcond <= 1'b1; 
				    end
					
		//movement
					`INSN_MFHI: begin
					    fu_ov            <=  1'b0;
						out <= hi;
						branchcond <= 1'b0;
					end
					`INSN_MFLO: begin
					    fu_ov            <=  1'b0;
						out <= lo;
						branchcond <= 1'b0;
					end
					`INSN_MTHI: begin
					    fu_ov            <=  1'b0;
						out <= scr0_data;
						branchcond <= 1'b0;
					end
					`INSN_MTLO: begin
					    fu_ov            <=  1'b0;
						out <= scr0_data;
						branchcond <= 1'b0;
					end
					
		//access memory
					`INSN_LB: begin
					    fu_ov            <=  1'b0;
						out <= scr0_data + imme;
						branchcond <= 1'b0; 
					end
					`INSN_LBU: begin
					    fu_ov            <=  1'b0;
						out <= scr0_data + imme;
						branchcond <= 1'b0;
					end
					`INSN_LH: begin
					    fu_ov            <=  1'b0;
						out <= scr0_data + imme;
						branchcond <= 1'b0;
					end
					`INSN_LHU: begin
					    fu_ov            <=  1'b0;
						out <= scr0_data + imme;
						branchcond <= 1'b0;
					end
					`INSN_LW: begin
					    fu_ov            <=  1'b0;
						out <= scr0_data + imme;
						branchcond <= 1'b0;
					end
					`INSN_SB: begin
					    fu_ov            <=  1'b0;
						out <= scr0_data + imme;
						out_wr <= (alu_dataforrwen[`ByteOffset] == 2'b00) ? {24'b0,scr1_data[`Byte]} :
						          (alu_dataforrwen[`ByteOffset] == 2'b01) ? {16'b0,scr1_data[`Byte],8'b0} :
						          (alu_dataforrwen[`ByteOffset] == 2'b10) ? {8'b0,scr1_data[`Byte],16'b0} : {scr1_data[`Byte],24'b0};
						          
						branchcond <= 1'b0;
					end
					`INSN_SH: begin
					    fu_ov            <=  1'b0;
						out <= scr0_data + imme;
						out_wr <= (alu_dataforrwen[`ByteOffset] == `BYTE_OFFSET_WORD) ? {16'b0,scr1_data[`Halfword]} : {scr1_data[`Halfword], 16'b0};
						branchcond <= 1'b0;
					end
					`INSN_SW: begin
					    fu_ov            <=  1'b0;
						out <= scr0_data+ imme;
						out_wr <= scr1_data;
						branchcond <= 1'b0;
					end
	    //special
					`INSN_MFC0: begin
					    fu_ov            <=  1'b0;
						out <= cp0_data;
						branchcond <= 1'b0;
					end
					`INSN_MTC0: begin
					    fu_ov            <=  1'b0;
						out_wr <= scr0_data;
						branchcond <= 1'b0;
					end
					`INSN_ERET: begin
					    fu_ov            <=  1'b0;
					    out_wr <= cp0_data;
					end
					/*if((ptab_direction == `DISABLE) || (ptab_data[`PtabdataBus] == cp0_data && `BranchOp && ptab_direction == `ENABLE)) begin
				    	out_wr <= cp0_data;
				    end
				    else begin
				    	out_wr <= ptab_data[`Ptabnextpc];
				    end
				    branchcond <= 1'b1; 
				    end*/
				  
					default: begin
                    //keep
					end
		endcase
		end
		else begin
		//keep
		end			
	 end
	 //branch predict logic
	 always @(*) begin
	 case(bpbus) //1 mean bp right, 0 mena bp error
	 2'b00:bp_result = 1'b1;
	 2'b01:bp_result = 1'b0;
	 2'b10:bp_result = 1'b0;
	 2'b11:bp_result = (ptab_data[63:32] == out_wr && `BranchOp)? 1'b1:1'b0;
	 endcase
	 end

endmodule
