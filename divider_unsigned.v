`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/30 21:58:26
// Design Name: 
// Module Name: divider_unsigned
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

/********* Internal define ************/
`define GLOBAL_DATA_W		32
`define PIPELINE			16
`define TMP_DATAWIDTH		64
`define SHIFT_BIT			63:32

module divider_unsigned (
	/*********** Global Signal ***********/
	input	wire	clk,
	input	wire	reset,
	//input	wire 	stall,
	input	wire 	flush,
	/*********** CPU interface(from FU4_divider) ***********/
	input	wire 	[`GLOBAL_DATA_W - 1 : 0] 		beichu,
	input	wire 	[`GLOBAL_DATA_W - 1 : 0] 		chushu,
	/*********** CPU interface(to FU4_divider) ***********/
	output 	wire	[`GLOBAL_DATA_W - 1 : 0]		quotient,
	output 	wire  	[`GLOBAL_DATA_W - 1 : 0]		remainder
);

	/********** Internal Signal **********/
	reg 			[`TMP_DATAWIDTH - 1 : 0]		tmp_a 	[`PIPELINE - 1 : 0];
	reg 			[`TMP_DATAWIDTH - 1 : 0]		tmp_b 	[`PIPELINE - 1 : 0];
	wire 			[`TMP_DATAWIDTH - 1 : 0] 		tmp_a_w [`PIPELINE - 1 : 0];
	wire 			[`TMP_DATAWIDTH - 1 : 0]		tmp_b_w [`PIPELINE - 1 : 0];
	wire 			[`TMP_DATAWIDTH - 1 : 0]		tmpa0;
	wire 			[`TMP_DATAWIDTH - 1 : 0]		tmpb0;
	
	/********** assignment **********/
	//	temporary varient
	assign 			tmpa0 = {31'b0,beichu,1'b0};
	assign 			tmpb0 = {chushu,32'b0};

	/************** Output Logic **************/
	assign	{remainder,quotient} = tmp_a[15];

	/************** Divider Algorithm Logic **************/
	//-------Level 1-----------
	assign	tmp_a_w[0]	=	(tmpa0[`SHIFT_BIT] >= tmpb0[`SHIFT_BIT]) ? ((tmpa0 - tmpb0 + 1'b1)<<1'b1) : (tmpa0<<1'b1);
	//SHIFT_BIT ??32??????
	assign	tmp_b_w[0]	=	tmpb0;

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[0] <= 64'b0;
			tmp_b[0] <= 64'b0;
		end
		else begin
			tmp_a[0] <= (tmp_a_w[0][`SHIFT_BIT] >= tmp_b_w[0][`SHIFT_BIT]) ? ((tmp_a_w[0] - tmp_b_w[0] + 1'b1)<<1'b1) : (tmp_a_w[0]<<1'b1);
			tmp_b[0] <= tmp_b_w[0];
		end

	end
	//-------Level 2-----------
	assign	tmp_a_w[1]	=	(tmp_a[0][`SHIFT_BIT] >= tmp_b[0][`SHIFT_BIT]) ? ((tmp_a[0] - tmp_b[0] + 1'b1)<<1'b1) : (tmp_a[0]<<1'b1);
	assign	tmp_b_w[1]	=	tmp_b[0];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[1] <= 0;
			tmp_b[1] <= 0;
		end
		else begin
			tmp_a[1] <= (tmp_a_w[1][`SHIFT_BIT] >= tmp_b_w[1][`SHIFT_BIT]) ? ((tmp_a_w[1] - tmp_b_w[1] + 1'b1)<<1'b1) : (tmp_a_w[1]<<1'b1);
			tmp_b[1] <= tmp_b_w[1];
		end

	end
	//-------Level 3-----------
	assign	tmp_a_w[2]	=	(tmp_a[1][`SHIFT_BIT] >= tmp_b[1][`SHIFT_BIT]) ? ((tmp_a[1] - tmp_b[1] + 1'b1)<<1'b1) : (tmp_a[1]<<1'b1);
	assign	tmp_b_w[2]	=	tmp_b[1];

	always@(posedge clk or `RESET_EDGE reset) begin 
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin 
			tmp_a[2] <= 0;
			tmp_b[2] <= 0;
		end
		else begin
			tmp_a[2] <= (tmp_a_w[2][`SHIFT_BIT] >= tmp_b_w[2][`SHIFT_BIT]) ? ((tmp_a_w[2] - tmp_b_w[2] + 1'b1)<<1'b1) : (tmp_a_w[2]<<1'b1);
			tmp_b[2] <= tmp_b_w[2];
		end
	end
	//-------Level 4-----------
	assign	tmp_a_w[3]	=	(tmp_a[2][`SHIFT_BIT] >= tmp_b[2][`SHIFT_BIT]) ? ((tmp_a[2] - tmp_b[2] + 1'b1)<<1'b1) : (tmp_a[2]<<1'b1);
	assign	tmp_b_w[3]	=	tmp_b[2];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin 
			tmp_a[3] <= 0;
			tmp_b[3] <= 0;
		end
		else begin
			tmp_a[3] <= (tmp_a_w[3][`SHIFT_BIT] >= tmp_b_w[3][`SHIFT_BIT]) ? ((tmp_a_w[3] - tmp_b_w[3] + 1'b1)<<1'b1) : (tmp_a_w[3]<<1'b1);
			tmp_b[3] <= tmp_b_w[3];
		end

	end		
	//-------Level 5-----------
	assign	tmp_a_w[4]	=	(tmp_a[3][`SHIFT_BIT] >= tmp_b[3][`SHIFT_BIT]) ? ((tmp_a[3] - tmp_b[3] + 1'b1)<<1'b1) : (tmp_a[3]<<1'b1);
	assign	tmp_b_w[4]	=	tmp_b[3];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[4] <= 0;
			tmp_b[4] <= 0;
		end
		else begin
			tmp_a[4] <= (tmp_a_w[4][`SHIFT_BIT] >= tmp_b_w[4][`SHIFT_BIT]) ? ((tmp_a_w[4] - tmp_b_w[4] + 1'b1)<<1'b1) : (tmp_a_w[4]<<1'b1);
			tmp_b[4] <= tmp_b_w[4];
		end
	end
	//-------Level 6-----------
	assign	tmp_a_w[5]	=	(tmp_a[4][`SHIFT_BIT] >= tmp_b[4][`SHIFT_BIT]) ? ((tmp_a[4] - tmp_b[4] + 1'b1)<<1'b1) : (tmp_a[4]<<1'b1);
	assign	tmp_b_w[5]	=	tmp_b[4];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[5] <= 0;
			tmp_b[5] <= 0;
		end
		else begin
			tmp_a[5] <= (tmp_a_w[5][`SHIFT_BIT] >= tmp_b_w[5][`SHIFT_BIT]) ? ((tmp_a_w[5] - tmp_b_w[5] + 1'b1)<<1'b1) : (tmp_a_w[5]<<1'b1);
			tmp_b[5] <= tmp_b_w[5];
		end
	end	
	//-------Level 7-----------
	assign	tmp_a_w[6]	=	(tmp_a[5][`SHIFT_BIT] >= tmp_b[5][`SHIFT_BIT]) ? ((tmp_a[5] - tmp_b[5] + 1'b1)<<1'b1) : (tmp_a[5]<<1'b1);
	assign	tmp_b_w[6]	=	tmp_b[5];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[6] <= 0;
			tmp_b[6] <= 0;
		end
		else begin
			tmp_a[6] <= (tmp_a_w[6][`SHIFT_BIT] >= tmp_b_w[6][`SHIFT_BIT]) ? ((tmp_a_w[6] - tmp_b_w[6] + 1'b1)<<1'b1) : (tmp_a_w[6]<<1'b1);
			tmp_b[6] <= tmp_b_w[6];
		end
	end
	//-------Level 8-----------
	assign	tmp_a_w[7]	=	(tmp_a[6][`SHIFT_BIT] >= tmp_b[6][`SHIFT_BIT]) ? ((tmp_a[6] - tmp_b[6] + 1'b1)<<1'b1) : (tmp_a[6]<<1'b1);
	assign	tmp_b_w[7]	=	tmp_b[6];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[7] <= 0;
			tmp_b[7] <= 0;
		end
		else begin
			tmp_a[7] <= (tmp_a_w[7][`SHIFT_BIT] >= tmp_b_w[7][`SHIFT_BIT]) ? ((tmp_a_w[7] - tmp_b_w[7] + 1'b1)<<1'b1) : (tmp_a_w[7]<<1'b1);
			tmp_b[7] <= tmp_b_w[7];
		end
	end
	//-------Level 9-----------
	assign	tmp_a_w[8]	=	(tmp_a[7][`SHIFT_BIT] >= tmp_b[7][`SHIFT_BIT]) ? ((tmp_a[7] - tmp_b[7] + 1'b1)<<1'b1) : (tmp_a[7]<<1'b1);
	assign	tmp_b_w[8]	=	tmp_b[7];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[8] <= 0;
			tmp_b[8] <= 0;
		end
		else begin
			tmp_a[8] <= (tmp_a_w[8][`SHIFT_BIT] >= tmp_b_w[8][`SHIFT_BIT]) ? ((tmp_a_w[8] - tmp_b_w[8] + 1'b1)<<1'b1) : (tmp_a_w[8]<<1'b1);
			tmp_b[8] <= tmp_b_w[8];
		end
	end
	//-------Level 10-----------
	assign	tmp_a_w[9]	=	(tmp_a[8][`SHIFT_BIT] >= tmp_b[8][`SHIFT_BIT]) ? ((tmp_a[8] - tmp_b[8] + 1'b1)<<1'b1) : (tmp_a[8]<<1'b1);
	assign	tmp_b_w[9]	=	tmp_b[8];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[9] <= 0;
			tmp_b[9] <= 0;
		end
		else begin
			tmp_a[9] <= (tmp_a_w[9][`SHIFT_BIT] >= tmp_b_w[9][`SHIFT_BIT]) ? ((tmp_a_w[9] - tmp_b_w[9] + 1'b1)<<1'b1) : (tmp_a_w[9]<<1'b1);
			tmp_b[9] <= tmp_b_w[9];
		end
	end
	//-------Level 11-----------
	assign	tmp_a_w[10]	=	(tmp_a[9][`SHIFT_BIT] >= tmp_b[9][`SHIFT_BIT]) ? ((tmp_a[9] - tmp_b[9] + 1'b1)<<1'b1) : (tmp_a[9]<<1'b1);
	assign	tmp_b_w[10]	=	tmp_b[9];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[10] <= 0;
			tmp_b[10] <= 0;
		end
		else begin
			tmp_a[10] <= (tmp_a_w[10][`SHIFT_BIT] >= tmp_b_w[10][`SHIFT_BIT]) ? ((tmp_a_w[10] - tmp_b_w[10] + 1'b1)<<1'b1) : (tmp_a_w[10]<<1'b1);
			tmp_b[10] <= tmp_b_w[10];
		end
	end
	//-------Level 12-----------
	assign	tmp_a_w[11]	=	(tmp_a[10][`SHIFT_BIT] >= tmp_b[10][`SHIFT_BIT]) ? ((tmp_a[10] - tmp_b[10] + 1'b1)<<1'b1) : (tmp_a[10]<<1'b1);
	assign	tmp_b_w[11]	=	tmp_b[10];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[11] <= 0;
			tmp_b[11] <= 0;
		end
		else begin
			tmp_a[11] <= (tmp_a_w[11][`SHIFT_BIT] >= tmp_b_w[11][`SHIFT_BIT]) ? ((tmp_a_w[11] - tmp_b_w[11] + 1'b1)<<1'b1) : (tmp_a_w[11]<<1'b1);
			tmp_b[11] <= tmp_b_w[11];
		end
	end
	//-------Level 13-----------
	assign	tmp_a_w[12]	=	(tmp_a[11][`SHIFT_BIT] >= tmp_b[11][`SHIFT_BIT]) ? ((tmp_a[11] - tmp_b[11] + 1'b1)<<1'b1) : (tmp_a[11]<<1'b1);
	assign	tmp_b_w[12]	=	tmp_b[11];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[12] <= 0;
			tmp_b[12] <= 0;
		end
		else begin
			tmp_a[12] <= (tmp_a_w[12][`SHIFT_BIT] >= tmp_b_w[12][`SHIFT_BIT]) ? ((tmp_a_w[12] - tmp_b_w[12] + 1'b1)<<1'b1) : (tmp_a_w[12]<<1'b1);
			tmp_b[12] <= tmp_b_w[12];
		end
	end

	//-------Level 14-----------
	assign	tmp_a_w[13]	=	(tmp_a[12][`SHIFT_BIT] >= tmp_b[12][`SHIFT_BIT]) ? ((tmp_a[12] - tmp_b[12] + 1'b1)<<1'b1) : (tmp_a[12]<<1'b1);
	assign	tmp_b_w[13]	=	tmp_b[12];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[13] <= 0;
			tmp_b[13] <= 0;
		end
		else begin
			tmp_a[13] <= (tmp_a_w[13][`SHIFT_BIT] >= tmp_b_w[13][`SHIFT_BIT]) ? ((tmp_a_w[13] - tmp_b_w[13] + 1'b1)<<1'b1) : (tmp_a_w[13]<<1'b1);
			tmp_b[13] <= tmp_b_w[13];
		end
	end
	//-------Level 15-----------
	assign	tmp_a_w[14]	=	(tmp_a[13][`SHIFT_BIT] >= tmp_b[13][`SHIFT_BIT]) ? ((tmp_a[13] - tmp_b[13] + 1'b1)<<1'b1) : (tmp_a[13]<<1'b1);
	assign	tmp_b_w[14]	=	tmp_b[13];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[14] <= 0;
			tmp_b[14] <= 0;
		end
		else begin
			tmp_a[14] <= (tmp_a_w[14][`SHIFT_BIT] >= tmp_b_w[14][`SHIFT_BIT]) ? ((tmp_a_w[14] - tmp_b_w[14] + 1'b1)<<1'b1) : (tmp_a_w[14]<<1'b1);
			tmp_b[14] <= tmp_b_w[14];
		end
	end
	//-------Level 16-----------
	assign	tmp_a_w[15]	=	(tmp_a[14][`SHIFT_BIT] >= tmp_b[14][`SHIFT_BIT]) ? ((tmp_a[14] - tmp_b[14] + 1'b1)<<1'b1) : (tmp_a[14]<<1'b1);
	assign	tmp_b_w[15]	=	tmp_b[14];

	always@(posedge clk or `RESET_EDGE reset) begin
		if(reset == `RESET_ENABLE || flush == `ENABLE) begin
			tmp_a[15] <= 0;
			tmp_b[15] <= 0;
		end
		else begin	// check if chushu is 0, if it is, set calculate result as 0
			tmp_a[15] <= (tmp_b_w[15]==0) ? 0 : ((tmp_a_w[15][`SHIFT_BIT] >= tmp_b_w[15][`SHIFT_BIT]) ? (tmp_a_w[15] - tmp_b_w[15] + 1'b1) : tmp_a_w[15]);
			tmp_b[15] <= tmp_b_w[15];
		end
	end

endmodule