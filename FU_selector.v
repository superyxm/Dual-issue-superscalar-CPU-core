`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/04 09:03:36
// Design Name: 
// Module Name: FU_selector
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

/*********       Internal define        ************/
`define AluOpBus_2way              11:0
`define AluOpBus_way0               5:0
`define AluOpBus_way1              11:6
`define FUen                        3:0

`define Alutype_way0    (is_alu_op[`AluOpBus_way0] == `INSN_ADD || is_alu_op[`AluOpBus_way0] == `INSN_ADDI || is_alu_op[`AluOpBus_way0] == `INSN_ADDU || is_alu_op[`AluOpBus_way0] == `INSN_ADDIU || is_alu_op[`AluOpBus_way0] == `INSN_SUB || is_alu_op[`AluOpBus_way0] == `INSN_SUBU || is_alu_op[`AluOpBus_way0] == `INSN_SLT || is_alu_op[`AluOpBus_way0] == `INSN_SLTI || is_alu_op[`AluOpBus_way0] == `INSN_SLTU || is_alu_op[`AluOpBus_way0] == `INSN_SLTIU || is_alu_op[`AluOpBus_way0] == `INSN_AND || is_alu_op[`AluOpBus_way0] == `INSN_ANDI || is_alu_op[`AluOpBus_way0] == `INSN_LUI || is_alu_op[`AluOpBus_way0] == `INSN_NOR || is_alu_op[`AluOpBus_way0] == `INSN_OR || is_alu_op[`AluOpBus_way0] == `INSN_ORI || is_alu_op[`AluOpBus_way0] == `INSN_XOR || is_alu_op[`AluOpBus_way0] == `INSN_XORI || is_alu_op[`AluOpBus_way0] == `INSN_SLLV || is_alu_op[`AluOpBus_way0] == `INSN_SLL || is_alu_op[`AluOpBus_way0] == `INSN_SRAV || is_alu_op[`AluOpBus_way0] == `INSN_SRA || is_alu_op[`AluOpBus_way0] == `INSN_SRLV  || is_alu_op[`AluOpBus_way0] == `INSN_SRL || is_alu_op[`AluOpBus_way0] == `INSN_BEQ || is_alu_op[`AluOpBus_way0] == `INSN_BNE || is_alu_op[`AluOpBus_way0] == `INSN_BGEZ || is_alu_op[`AluOpBus_way0] == `INSN_BGTZ || is_alu_op[`AluOpBus_way0] == `INSN_BLEZ || is_alu_op[`AluOpBus_way0] == `INSN_BLTZ || is_alu_op[`AluOpBus_way0] == `INSN_BGEZAL || is_alu_op[`AluOpBus_way0] == `INSN_BLTZAL || is_alu_op[`AluOpBus_way0] == `INSN_J || is_alu_op[`AluOpBus_way0] == `INSN_JAL || is_alu_op[`AluOpBus_way0] == `INSN_JR || is_alu_op[`AluOpBus_way0] == `INSN_JALR || is_alu_op[`AluOpBus_way0] == `INSN_MFHI || is_alu_op[`AluOpBus_way0] == `INSN_MFLO || is_alu_op[`AluOpBus_way0] == `INSN_MTHI || is_alu_op[`AluOpBus_way0] == `INSN_MTLO || is_alu_op[`AluOpBus_way0] == `INSN_BREAK || is_alu_op[`AluOpBus_way0] == `INSN_SYSCALL || is_alu_op[`AluOpBus_way0] == `INSN_LB || is_alu_op[`AluOpBus_way0] == `INSN_LBU || is_alu_op[`AluOpBus_way0] == `INSN_LH || is_alu_op[`AluOpBus_way0] == `INSN_LHU || is_alu_op[`AluOpBus_way0] == `INSN_LW || is_alu_op[`AluOpBus_way0] == `INSN_SB || is_alu_op[`AluOpBus_way0] == `INSN_SH || is_alu_op[`AluOpBus_way0] == `INSN_SW || is_alu_op[`AluOpBus_way0] == `INSN_MTC0 || is_alu_op[`AluOpBus_way0] == `INSN_ERET || is_alu_op[`AluOpBus_way0] == `INSN_MFC0 || is_alu_op[`AluOpBus_way0] == `INSN_NOP  )
`define Alutype_way1    (is_alu_op[`AluOpBus_way1] == `INSN_ADD || is_alu_op[`AluOpBus_way1] == `INSN_ADDI || is_alu_op[`AluOpBus_way1] == `INSN_ADDU || is_alu_op[`AluOpBus_way1] == `INSN_ADDIU || is_alu_op[`AluOpBus_way1] == `INSN_SUB || is_alu_op[`AluOpBus_way1] == `INSN_SUBU || is_alu_op[`AluOpBus_way1] == `INSN_SLT || is_alu_op[`AluOpBus_way1] == `INSN_SLTI || is_alu_op[`AluOpBus_way1] == `INSN_SLTU || is_alu_op[`AluOpBus_way1] == `INSN_SLTIU || is_alu_op[`AluOpBus_way1] == `INSN_AND || is_alu_op[`AluOpBus_way1] == `INSN_ANDI || is_alu_op[`AluOpBus_way1] == `INSN_LUI || is_alu_op[`AluOpBus_way1] == `INSN_NOR || is_alu_op[`AluOpBus_way1] == `INSN_OR || is_alu_op[`AluOpBus_way1] == `INSN_ORI || is_alu_op[`AluOpBus_way1] == `INSN_XOR || is_alu_op[`AluOpBus_way1] == `INSN_XORI || is_alu_op[`AluOpBus_way1] == `INSN_SLLV || is_alu_op[`AluOpBus_way1] == `INSN_SLL || is_alu_op[`AluOpBus_way1] == `INSN_SRAV || is_alu_op[`AluOpBus_way1] == `INSN_SRA || is_alu_op[`AluOpBus_way1] == `INSN_SRLV  || is_alu_op[`AluOpBus_way1] == `INSN_SRL || is_alu_op[`AluOpBus_way1] == `INSN_BEQ || is_alu_op[`AluOpBus_way1] == `INSN_BNE || is_alu_op[`AluOpBus_way1] == `INSN_BGEZ || is_alu_op[`AluOpBus_way1] == `INSN_BGTZ || is_alu_op[`AluOpBus_way1] == `INSN_BLEZ || is_alu_op[`AluOpBus_way1] == `INSN_BLTZ || is_alu_op[`AluOpBus_way1] == `INSN_BGEZAL || is_alu_op[`AluOpBus_way1] == `INSN_BLTZAL || is_alu_op[`AluOpBus_way1] == `INSN_J || is_alu_op[`AluOpBus_way1] == `INSN_JAL || is_alu_op[`AluOpBus_way1] == `INSN_JR || is_alu_op[`AluOpBus_way1] == `INSN_JALR || is_alu_op[`AluOpBus_way1] == `INSN_MFHI || is_alu_op[`AluOpBus_way1] == `INSN_MFLO || is_alu_op[`AluOpBus_way1] == `INSN_MTHI || is_alu_op[`AluOpBus_way1] == `INSN_MTLO || is_alu_op[`AluOpBus_way1] == `INSN_BREAK || is_alu_op[`AluOpBus_way1] == `INSN_SYSCALL || is_alu_op[`AluOpBus_way1] == `INSN_LB || is_alu_op[`AluOpBus_way1] == `INSN_LBU || is_alu_op[`AluOpBus_way1] == `INSN_LH || is_alu_op[`AluOpBus_way1] == `INSN_LHU || is_alu_op[`AluOpBus_way1] == `INSN_LW || is_alu_op[`AluOpBus_way1] == `INSN_SB || is_alu_op[`AluOpBus_way1] == `INSN_SH || is_alu_op[`AluOpBus_way1] == `INSN_SW || is_alu_op[`AluOpBus_way1] == `INSN_MTC0 || is_alu_op[`AluOpBus_way1] == `INSN_ERET || is_alu_op[`AluOpBus_way1] == `INSN_MFC0 || is_alu_op[`AluOpBus_way1] == `INSN_NOP  )
`define Multype_way0    (is_alu_op[`AluOpBus_way0] == `INSN_MULT || is_alu_op[`AluOpBus_way0] == `INSN_MULTU)
`define Multype_way1    (is_alu_op[`AluOpBus_way1] == `INSN_MULT || is_alu_op[`AluOpBus_way1] == `INSN_MULTU)
`define Divtype_way0    (is_alu_op[`AluOpBus_way0] == `INSN_DIV || is_alu_op[`AluOpBus_way0] == `INSN_DIVU)
`define Divtype_way1    (is_alu_op[`AluOpBus_way1] == `INSN_DIV || is_alu_op[`AluOpBus_way1] == `INSN_DIVU)
//`define All_INSN_MUL              (`INSN_MULT || `INSN_MULTU)
//`define All_INSN_DIV              (`INSN_DIV || `INSN_DIVU)

module FU_selector(

input   wire    [`AluOpBus_2way]	                        is_alu_op,

output  reg    [`FUen]                                    FU_en,
output  reg                                               FU_ctrl //  0 -> way0 == ALU0||MUL  way1 == ALU1||DIV          1 ->way0 ==ALU0||DIV  way1 == ALU1||MUL
    );

    always @(*) begin
    if(`Divtype_way1 && `Multype_way0) begin
		   FU_en = 4'b1100;
		   FU_ctrl = 1'b0;
          end
    else if(`Divtype_way0 && `Multype_way1) begin
           FU_en = 4'b1100;
		   FU_ctrl = 1'b1;
		   end
    else if(`Divtype_way0 && `Alutype_way1) begin
		   FU_en = 4'b1010;
		   FU_ctrl = 1'b1; 
		   end
    else if(`Divtype_way1 && `Alutype_way0) begin
		   FU_en = 4'b1001;
		   FU_ctrl = 1'b0; 
		   end
    else if(`Multype_way0 && `Alutype_way1) begin
		   FU_en = 4'b0110;
		   FU_ctrl = 1'b0; 
		   end
    else if(`Multype_way1 && `Alutype_way0) begin
		   FU_en = 4'b0101;
		   FU_ctrl = 1'b1; 
		   end
    else if(`Divtype_way1) begin
		   FU_en = 4'b1000;
		   FU_ctrl = 1'b0; 
		   end
    else if(`Divtype_way0) begin
		   FU_en = 4'b1000;
		   FU_ctrl = 1'b1; 
		   end
    else if(`Multype_way1) begin
		   FU_en = 4'b0100;
		   FU_ctrl = 1'b1; 
		   end
    else if(`Multype_way0) begin
		   FU_en = 4'b0100;
		   FU_ctrl = 1'b0; 
		   end
    else if(`Alutype_way0) begin
		   FU_en = 4'b0001;
		   FU_ctrl = 1'b0; 
		   end
    else if(`Alutype_way1) begin
		   FU_en = 4'b0010;
		   FU_ctrl = 1'b0; 
		   end
    else begin 
           FU_en = 4'b0000;
		   FU_ctrl = 1'b0;
		   end
    end
    
    
    
   /* always @(*) begin
	   if ((is_alu_op[`AluOpBus_way0] == `INSN_MULT || is_alu_op[`AluOpBus_way0] == `INSN_MULTU) && (is_alu_op[`AluOpBus_way1] == `INSN_DIV || is_alu_op[`AluOpBus_way1] == `INSN_DIVU) ) begin // way0 == MUL  way1 == DIV
		   FU_en = 4'b1100;
		   FU_ctrl = 1'b0;
		   end
		   else if ((is_alu_op[`AluOpBus_way0] == `INSN_DIV || is_alu_op[`AluOpBus_way0] == `INSN_DIVU) && (is_alu_op[`AluOpBus_way1] == `INSN_MULT || is_alu_op[`AluOpBus_way1] == `INSN_MULTU) ) begin // way0 == DIV  way1 == MUL
		   FU_en = 4'b1100;
		   FU_ctrl = 1'b1;
		   end
		   else if (is_alu_op[`AluOpBus_way0] == `INSN_DIV || is_alu_op[`AluOpBus_way0] == `INSN_DIVU) begin // way0 == DIV way1 == ALU1
		   FU_en = 4'b1010;
		   FU_ctrl = 1'b1; 
		   end
		   else if (is_alu_op[`AluOpBus_way1] == `INSN_DIV || is_alu_op[`AluOpBus_way1] == `INSN_DIVU) begin // way0 == ALU0 way1 == DIV
		   FU_en = 4'b1001;
		   FU_ctrl = 1'b0; 
		   end
		   else if (is_alu_op[`AluOpBus_way0] == `INSN_MULT || is_alu_op[`AluOpBus_way0] == `INSN_MULTU) begin // way0 == MUL way1 == ALU1
		   FU_en = 4'b0110;
		   FU_ctrl = 1'b0; 
		   end
		   else if (is_alu_op[`AluOpBus_way0] == `INSN_MULT || is_alu_op[`AluOpBus_way0] == `INSN_MULTU) begin // way0 == MUL way1 == ALU1
		   FU_en = 4'b0110;
		   FU_ctrl = 1'b0; 
		   end
		   else if (is_alu_op[`AluOpBus_way1] == `INSN_MULT || is_alu_op[`AluOpBus_way1] == `INSN_MULTU) begin // way0 == ALU0 way1 == DIV
		   FU_en = 4'b0101;
		   FU_ctrl = 1'b1; 
		   end
		   else begin //way0 == ALU0 way1 == ALU1
		   FU_en = 4'b0011;
		   FU_ctrl = 1'b0;
		   end
		   
    end*/
		
endmodule
