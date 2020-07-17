`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/04 15:25:54
// Design Name: 
// Module Name: DIV
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

`define	Sign2Num 			1:0
module DIV(
	/*********** Global Signal ***********/
	input	wire	clk,
	input	wire	reset,
	//input	wire 	stall,
	input	wire 	flush,
	/*********** CPU interface(from PSReg_Rd) ***********/
	input	wire 	CE_in,
	input   wire   ex_valid_ns,
	input   wire   wb_allin,
	input 	wire 	[`WordDataBus]		dividend_in,
	input 	wire 	[`WordDataBus]		divisor_in,
	/*********** Data Pipeline (from alu_4_FU) ***********/
	input	wire 	[`AluOpBus]			is_op,
	/*********** CPU interface(to WB_transfer) ***********/
	output 	reg 	[`WordDataBus]		quotient_out,
	output 	reg 	[`WordDataBus]		remainder_out,
	output	reg 	CE_out
    );

	/********** Internal Signal **********/
	//reg  [`WordDataBus]                 dividend,divisor;
    reg                                 CE_1,CE_2,CE_3,CE_4,CE_5,CE_6,CE_7,CE_8,CE_9,CE_10,CE_11,CE_12,CE_13,CE_14,CE_15;

    //reg  [`Sign2Num]                    sign2num_1,sign2num_2,sign2num_3,sign2num_4,sign2num_5,sign2num_6;
    reg                                 type_1,type_2,type_3,type_4,type_5,type_6,type_7,type_8,type_9,type_10,type_11,type_12,type_13,type_14,type_15,type_16;
    wire [`WordDataBus]                 quotient_unsigned,remainder_unsigned;
    wire [`WordDataBus]                 quotient_signed,remainder_signed;
    //wire [`Sign2Num] 	                 sign2num;
    wire                                type;
    /********** assignment **********/
    //assign sign2num = {dividend_in[31],divisor_in[31]};
    
    /************** instantiation **************/
	div_unsigned div_unsigned (
	.aclk                            (clk),
	.aresetn                         (reset),
	.s_axis_divisor_tdata            (divisor_in),
	.s_axis_dividend_tdata           (dividend_in),
	.m_axis_dout_tdata               ({quotient_unsigned,remainder_unsigned}),
	.s_axis_divisor_tvalid           (1),
	.s_axis_dividend_tvalid          (1),
	.m_axis_dout_tvalid              ()
	);
	
	div_signed div_signed (
	.aclk                            (clk),
	.aresetn                         (reset),
	.s_axis_divisor_tdata            (divisor_in),
	.s_axis_dividend_tdata           (dividend_in),
	.m_axis_dout_tdata               ({quotient_signed,remainder_signed}),
	.s_axis_divisor_tvalid           (1),
	.s_axis_dividend_tvalid          (1),
	.m_axis_dout_tvalid              ()
	);

	/************** input logic **************/
	//type decided
	assign type = (is_op == `INSN_DIV)?1'b1:1'b0;
	//input number type
    /*always @(*) begin
		if(type) begin
			case(sign2num)
			2'b00: begin
				dividend <= dividend_in;
				divisor  <= divisor_in;
			end
			2'b01: begin
                dividend <= dividend_in;
                divisor  <= ~(divisor_in - 1'b1);
			end
			2'b10: begin
				dividend <= ~(dividend - 1'b1);
				divisor  <= divisor_in;
			end
			2'b11: begin
				dividend <= ~(dividend - 1'b1);
				divisor  <= ~(divisor_in - 1'b1);
			end
            endcase
		end
        else begin
        	dividend <= dividend_in;
        	divisor  <= divisor_in;
		end
	end*/
	/************** output logic **************/
	//output number type
	/*always @(*) begin
		if(type_16) begin
			case(sign2num_16)
			2'b00: begin
				quotient_out <= quotient;
				remainder_out <= remainder;
			end
			2'b01: begin
				quotient_out <= ~quotient + 1'b1;
				remainder_out <= remainder;
			end
			2'b10: begin
				quotient_out <= ~quotient + 1'b1;
				remainder_out <= ~remainder + 1'b1;
			end
			2'b11: begin
				quotient_out <= quotient;
				remainder_out <= ~remainder + 1'b1;
			end
			endcase
		end
		else begin
			quotient_out <= quotient;
			remainder_out <= remainder;
		end
	end*/
    always @(posedge clk) begin
	     if(reset == `RESET_ENABLE || flush == `ENABLE) begin
				quotient_out <= 32'hzzzz_zzzz;
				remainder_out <= 32'hzzzz_zzzz;
				end
	     else if(ex_valid_ns && wb_allin) begin
		     if(type_16) begin
		/*	 case(sign2num_6)
			2'b00: begin
				quotient_out <= quotient;
				remainder_out <= remainder;
			end
			2'b01: begin
				quotient_out <= ~quotient + 1'b1;
				remainder_out <= remainder;
			end
			2'b10: begin
				quotient_out <= ~quotient + 1'b1;
				remainder_out <= ~remainder + 1'b1;
			end
			2'b11: begin
				quotient_out <= quotient;
				remainder_out <= ~remainder + 1'b1;
			end
			endcase*/
			quotient_out <= quotient_signed;
			remainder_out <= remainder_signed;
		end
		else begin
			quotient_out <= quotient_unsigned;
			remainder_out <= remainder_unsigned;
		end
		end
      end
	/************** data pipeline **************/
	//sign2num_16 for the output result, sign2num for the input data
	/*always @(posedge clk or `RESET_EDGE reset) begin
        if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			sign2num_1 	  <= 1'b0;
			sign2num_2 	  <= 1'b0;
			sign2num_3 	  <= 1'b0;
			sign2num_4 	  <= 1'b0;
			sign2num_5    <= 1'b0;
			sign2num_6    <= 1'b0;
		end
		else begin
			sign2num_1 	    <= sign2num;
			sign2num_2  	<= sign2num_1;
			sign2num_3  	<= sign2num_2;
			sign2num_4  	<= sign2num_3;
			sign2num_5  	<= sign2num_4;
			sign2num_6  	<= sign2num_5;  
		end
	end*/
	
	//CE_out == CE_in delay for 16 cycle
	always @(posedge clk or `RESET_EDGE reset) begin
        if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			CE_1 	<= 1'b0;
			CE_2 	<= 1'b0;
			CE_3 	<= 1'b0;
			CE_4 	<= 1'b0;
			CE_5 	<= 1'b0;
			CE_6 	<= 1'b0;
			CE_7 	<= 1'b0;
			CE_8 	<= 1'b0;
			CE_9 	<= 1'b0;
			CE_10 	<= 1'b0;
			CE_11	<= 1'b0;
			CE_12 	<= 1'b0;
			CE_13 	<= 1'b0;
			CE_14 	<= 1'b0;
			CE_15 	<= 1'b0;
			CE_out 	<= 1'b0;
		end
		else if(ex_valid_ns && wb_allin) begin
			CE_1 	<= CE_in;
			CE_2 	<= 1'b0;
			CE_3 	<= 1'b0;
			CE_4 	<= 1'b0;
			CE_5 	<= 1'b0;
			CE_6 	<= 1'b0;
			CE_7 	<= 1'b0;
			CE_8 	<= 1'b0;
			CE_9 	<= 1'b0;
			CE_10 	<= 1'b0;
			CE_11	<= 1'b0;
			CE_12 	<= 1'b0;
			CE_13 	<= 1'b0;
			CE_14 	<= 1'b0;
			CE_15 	<= 1'b0;
			CE_out 	<= 1'b0;
		end
		else begin
			CE_1 	<= CE_in;
			CE_2 	<= CE_1;
			CE_3 	<= CE_2;
			CE_4 	<= CE_3;
			CE_5 	<= CE_4;
			CE_6 	<= CE_5;
			CE_7 	<= CE_6;
			CE_8 	<= CE_7;
			CE_9 	<= CE_8;
			CE_10 	<= CE_9;
			CE_11 	<= CE_10;
			CE_12 	<= CE_11;
			CE_13 	<= CE_12;
			CE_14 	<= CE_13;
			CE_15 	<= CE_14;
			CE_out 	<= CE_15;
		end

	end
	
	//type_16 == type delay for 16 cycle
		always @(posedge clk or `RESET_EDGE reset) begin
        if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			type_1    <= 1'b0;
			type_2    <= 1'b0;
			type_3    <= 1'b0;
			type_4    <= 1'b0;
			type_5    <= 1'b0;
			type_6    <= 1'b0;
			type_7    <= 1'b0;
			type_8    <= 1'b0;
			type_9    <= 1'b0;
			type_10    <= 1'b0;
			type_11    <= 1'b0;
			type_12    <= 1'b0;
			type_13    <= 1'b0;
			type_14    <= 1'b0;
			type_15    <= 1'b0;
			type_16    <= 1'b0;
		end
		else begin
			type_1 	    <= type;
			type_2 	    <= type_1;
			type_3 	    <= type_2;
			type_4 	    <= type_3;
			type_5 	    <= type_4;
			type_6 	    <= type_5;
			type_7 	    <= type_6;
			type_8 	    <= type_7;
			type_9 	    <= type_8;
			type_10 	    <= type_9;
			type_11 	    <= type_10;
			type_12 	    <= type_11;
			type_13 	    <= type_12;
			type_14 	    <= type_13;
			type_15 	    <= type_14;
			type_16 	    <= type_15;
		end
	end
	
	 //CE_out == CE_in delay 6 cycles 
    /*always @(posedge clk or `RESET_EDGE reset) begin
     if(reset == `RESET_ENABLE || flush == `ENABLE) begin
            CE    	<= 15'b0;
     end
     else if(stall == `DISABLE) begin
      if(CE_in == `DISABLE) begin
            CE    	<= 15'b0;
      end
      else if (CE_in == `ENABLE && CE == 15'b000000) begin
            CE      <= 15'b1;
      end
      else begin
            CE  <= CE << 1;
      end
     end
     else begin
     //empty
     end
    end*/
endmodule
`undef CEBus