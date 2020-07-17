`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/04 15:25:35
// Design Name: 
// Module Name: MUL
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

 `include "cpu.h"
 `include "global_config.h"
 `include "isa.h"
 `include "nettype.h"
 `include "stddef.h"
 
 `define Aluopden              	 3:0
 `define Type                       1:0
`define INSN_DIV_TYPE		2'b10
`define INSN_MULT_TYPE		2'b01
`define CEBus              4:0
 
module MUL(
	input	wire	clk,
	input	wire	reset,
	//input	wire 	stall,
	input	wire 	flush,
	/*********** CPU interface(from PSReg_Rd) ***********/
	input 	wire 	CE_in,
	input   wire   ex_valid_ns,
	input   wire   wb_allin,
	input 	wire 	[`WordDataBus]		mulx,
	input 	wire	[`WordDataBus]		muly,
	/*********** Data Pipeline (from alu_4_FU) ***********/
	//input	wire 	[`PDEST_ADDR_W - 1 : 0]			is_Dest_out,
	//input	wire 	[`WordDataBus]						is_pc,
	input	wire 	[`AluOpBus]				            is_op,
	//input	wire	[`RobAddrBus]					is_rob_addr,
	//input	wire									is_rob_age_bit,
	//input	wire	[`Aluopden]					        is_opd_en,
	//input	wire									    is_en,
	/*********** Equivalent is_type (to decide FU2 whether busy) ***********/
	//output 	reg 	[`Type] 				is_type_multmp,
	/*********** CPU interface(to WB_transfer) ***********/
	//output 	reg 	[`PDEST_ADDR_W - 1 : 0]		exe_Dest_out,
	//output 	reg  	[`WordDataBus]						exe_pc,
	//output	reg  	[`AluOpBus]						exe_op,
	//output	reg  	[`RobAddrBus]					exe_rob_addr,
	//output	reg  									exe_rob_age_bit,
	//output  wire 	[`ISA_EXC_W - 1 : 0]			exe_exc_code,
	//output 	reg 	[`Aluopden]					exe_opd_en,
	//output 	reg 									exe_en,
	/*********** CPU interface(to WB_transfer) ***********/
	output 	reg 	[`WordDataBus]		mul_hi,
	output 	reg 	[`WordDataBus]		mul_lo,
	output  reg                        CE_out
);
	/********** Internal Signal **********/
	reg CE_1,CE_2,CE_3,CE_4,CE_5;
	reg [`AluOpBus] mulop_1,mulop_2,mulop_3,mulop_4,mulop_5,mulop_out;
    reg CE;
	//reg  [`PDEST_ADDR_W - 1 : 0] 	exe_Dest_out_1,exe_Dest_out_2,exe_Dest_out_3,exe_Dest_out_4,exe_Dest_out_5;
 	//reg  [`WordDataBus] 			exe_pc_1,exe_pc_2,exe_pc_3,exe_pc_4,exe_pc_5;
	//reg  [`AluOpBus] 				exe_op_1,exe_op_2,exe_op_3,exe_op_4,exe_op_5;
	//reg  [`RobAddrBus] 			    exe_rob_addr_1,exe_rob_addr_2,exe_rob_addr_3,exe_rob_addr_4,exe_rob_addr_5;
	//reg  						    exe_rob_age_bit_1,exe_rob_age_bit_2,exe_rob_age_bit_3,exe_rob_age_bit_4,exe_rob_age_bit_5;
	//reg  [`Aluopden] 				exe_opd_en_1,exe_opd_en_2,exe_opd_en_3,exe_opd_en_4,exe_opd_en_5;
	//reg  			 				exe_en_1,exe_en_2,exe_en_3,exe_en_4,exe_en_5;

	wire [`WordDataBus] 	        mult_hi,mult_lo,multu_hi,multu_lo;
    /************** instantiation **************/
    mult_signed mult(
        .CLK                (clk),
        .A                  (mulx),
        .B                  (muly),
       // .CE                 (1),
        .SCLR               (~reset),
        .P                  ({mult_hi,mult_lo})
	);
    mult_unsigned multu(
        .CLK                (clk),
        .A                  (mulx),
        .B                  (muly),
       // .CE                 (1),
        .SCLR               (~reset),
        .P                  ({multu_hi,multu_lo})
	);
    /************** Output logic **************/
    always @(posedge clk) begin
	     if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			      mul_hi <= 32'hzzzz_zzzz;
			      mul_lo <= 32'hzzzz_zzzz;
		 end
	     else if(ex_valid_ns && wb_allin) begin
		     if(mulop_out == `INSN_MULT)begin
    		      mul_hi <= mult_hi;
    		      mul_lo <= mult_lo;
             end
             else if(mulop_out == `INSN_MULTU)begin
    		      mul_hi <= multu_hi;
    		      mul_lo <= multu_lo;
             end 
             else begin
			      mul_hi <= 32'hzzzz_zzzz;
			      mul_lo <= 32'hzzzz_zzzz;
             end
	     end
	end
    //whether to transfer mult output or multu output
    
   /* always @(*) begin
     if(mulop_out == `INSN_MULT)begin
    		mul_hi = mult_hi;
    		mul_lo = mult_lo;
     end
     else if(mulop_out == `INSN_MULTU)begin
    		mul_hi = multu_hi;
    		mul_lo = multu_lo;
     end
     else begin
			mul_hi = 32'hzzzz_zzzz;
			mul_lo = 32'hzzzz_zzzz;
     end
    end*/
    
    //CE_out == CE_in delay 6 cycles 
    /*always @(posedge clk or `RESET_EDGE reset) begin
     if(reset == `RESET_ENABLE || flush == `ENABLE) begin
            CE    	<= 5'b0;
     end
     else if(stall == `DISABLE) begin
      if(CE_in == `DISABLE) begin
            CE    	<= 5'b0;
      end
      else if (CE_in == `ENABLE && CE == 5'b000000) begin
            CE      <= 5'b1;
      end
      else begin
            CE  <= CE << 1;
      end
     end
     else begin
     //empty
     end
    end*/
    
    always @(posedge clk) begin
        if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			CE_1 	<= 1'b0;
			CE_2 	<= 1'b0;
			CE_3  	<= 1'b0;
			CE_4 	<= 1'b0;
			CE_5    <= 1'b0;
			CE_out 	<= 1'b0;
		end
		else if(ex_valid_ns && wb_allin) begin
			CE_1 	<= CE_in;
			CE_2 	<= 1'b0;
			CE_3  	<= 1'b0;
			CE_4 	<= 1'b0;
			CE_5 	<= 1'b0;
			CE_out 	<= 1'b0;
		end
		else begin
		    CE_1 	<= CE_in;
			CE_2 	<= CE_1;
			CE_3  	<= CE_2;
			CE_4 	<= CE_3;
			CE_5 	<= CE_4;
			CE_out 	<= CE_5;
		end
	  end 
	  
     //mulop_out == is_op delay 6 cycles 
    always @(posedge clk or `RESET_EDGE reset) begin
        if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			mulop_1 	<= 6'b0;
			mulop_2 	<= 6'b0;
			mulop_3  	<= 6'b0;
			mulop_4 	<= 6'b0;
			mulop_5 	<= 6'b0;
			mulop_out 	<= 6'b0;
		end
		else begin
            mulop_1 	<= is_op;
            mulop_2 	<= mulop_1;
            mulop_3 	<= mulop_2;
            mulop_4 	<= mulop_3;
            mulop_5 	<= mulop_4;
            mulop_out 	<= mulop_5;
		end
	  end 
	 
endmodule
`undef CEBus