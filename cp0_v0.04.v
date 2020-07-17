/*
 -- ============================================================================
 -- FILE NAME	: cp0.v
 -- DESCRIPTION : add register count
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by		Comment
 -- 1.0.0	  2019/07/08  Yau			Yau
 -- ============================================================================
*/
/********** Common header file **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** Individual header file **********/
`include "cpu.h"
`include "each_module.h"
//macro define
`define PRIVILEGE 3'b110
`define REG_ADDR_BUS 4:0
`define CP0_INT_BUS 5:0
`define CP0_BADVADDR 8
`define CP0_COUNT 9
`define CP0_STATUS 12
`define CP0_CAUSE 13
`define CP0_EPC 14
`define EXC_CODE_WAY0 4:0
`define EXC_CODE_WAY1 9:5
`define EXC_CODE_W 5
`define EXC_INT 5'b00
`define EXC_ADEL 5'h04
`define EXC_ADES 5'H05
`define EXC_SYS 5'h08
`define EXC_NONE 5'h10
`define EXC_ERET 5'h11
`define EXC_RI 5'h0a
`define EXC_OV 5'h0c
`define EXC_ADDR 32'hbfc00380 //entrance PC of exception handling program
`define EXC_INT_ADDR 32'hbfc00380  //entrance PC of interrupt handling program
`define EXC_FLUSH_DISABLE 0
`define EXC_FLUSH_ENABLE 1

module cp0(
	/***** global *****/
	input  wire clk,
	input  wire rst_,
	/***** for MFC0 at EX *****/
	input  wire [1:0] ex_cp0_re,
	input  wire [`REG_ADDR_BUS] ex_cp0_raddr_0,
	input  wire [`REG_ADDR_BUS] ex_cp0_raddr_1,
	output wire [`WordDataBus]  ex_cp0_rdata_0,	
	output wire [`WordDataBus]  ex_cp0_rdata_1,
	/***** for MTC0 from WB *****/
	input  wire [`TwoWordAddrBus] wb_pc,
	input  wire wb_cp0_we,
	input  wire [`REG_ADDR_BUS] wb_cp0_waddr_0,
	input  wire [`REG_ADDR_BUS] wb_cp0_waddr_1,
	input  wire [`WordDataBus]  wb_cp0_wdata_0,
	input  wire [`WordDataBus]  wb_cp0_wdata_1,
	/***** External Interrupt input *****/
	input  wire [`CP0_INT_BUS]  int_i,
	/***** EXC input from EX *****/
	input  wire [`TwoWordAddrBus]  ex_cp0_exc_pc_i,
	input  wire [`TwoWordAddrBus]  ex_cp0_ade_vaddr,
	input  wire [`TwoWordAddrBus]  ex_cp0_adel_vaddr,//caused by PC error
	input  wire [1:0] ex_bp_error,
	input  wire [`WordAddrBus] ex_new_target,
	input  wire [1:0] ex_cp0_in_delay_i,
	input  wire [`EXC_CODE_W*2-1 : 0] ex_cp0_exc_code_i,
	/***** EXC output *****/
	output wire exc_flush_all,
	output reg  exc_flush_icache,		//to flush the latest icache output a cycle later than other stages.
	output wire [`WordAddrBus]  cp0_if_excaddr  //to if
);
	
	/***** Internal Signal *****/
	reg  [`WordAddrBus] badvaddr;
	reg  [`WordDataBus] count;
	reg  [`WordDataBus] status;
	reg  [`WordDataBus] cause;
	reg  [`WordAddrBus] epc;
	reg  [`WordAddrBus] epc_soft_int;
	reg  count_div;
	wire [1:0] exc_en;
	wire [`EXC_CODE_W-1 : 0] exc_code_0;
	wire [`EXC_CODE_W-1 : 0] exc_code_1;
	wire [`WordAddrBus] exc_pc_i;
	wire in_delay_i;
    reg  [63:0] wb_pc_reg;
	/***** Combinational Logic *****/
	//15:0 = hard int, 9:8 = soft int
	assign exc_code_0 = (status[15:8]&cause[15:8]!=8'h00 && status[1] == 1'b0 && status[0] == 1'b1)?`EXC_INT:ex_cp0_exc_code_i[`EXC_CODE_WAY0];
	//assign exc_code_0 = (status[15:10]&cause[15:10]!=8'h00 && status[1] == 1'b0 && status[0] == 1'b1)?`EXC_INT:ex_cp0_exc_code_i[`EXC_CODE_WAY0];
	assign exc_code_1 = ex_cp0_exc_code_i[`EXC_CODE_WAY1];
	assign exc_en = (exc_code_0 !=`EXC_NONE && exc_code_1 !=`EXC_NONE && ex_cp0_in_delay_i == 2'b10)?2'b10:(exc_code_0 !=`EXC_NONE)?2'b01:
					(exc_code_1 !=`EXC_NONE)?2'b10:2'b00;
	assign exc_pc_i = (exc_en == 2'b01)?ex_cp0_exc_pc_i[31:0]:
						(exc_en == 2'b10)?ex_cp0_exc_pc_i[63:32]:32'b0;
	assign in_delay_i = (exc_en == 2'b01 & ex_cp0_in_delay_i[0] == 1'b1) || (exc_en == 2'b10 & ex_cp0_in_delay_i[1] == 1'b1);
	assign exc_flush_all = (!rst_)? `EXC_FLUSH_DISABLE:
						(|exc_en) ? `EXC_FLUSH_ENABLE : `EXC_FLUSH_DISABLE;
	
	//entrance PC of exception handling program
	assign cp0_if_excaddr = (!rst_)?32'b0:
							(exc_code_0 == `EXC_INT)?`EXC_INT_ADDR:
							(exc_code_0 == `EXC_ERET && wb_cp0_waddr_0 == `CP0_EPC && wb_cp0_we && epc[1:0]==2'b00)?wb_cp0_wdata_0:
							(exc_code_0 == `EXC_ERET && epc[1:0]==2'b00 )?epc:
							(exc_code_0 == `EXC_ERET)? `EXC_ADDR:
							(exc_code_0 != `EXC_NONE)? `EXC_ADDR:
							(exc_code_1 == `EXC_INT)?`EXC_INT_ADDR:
							(exc_code_1 == `EXC_ERET && wb_cp0_waddr_1 == `CP0_EPC && wb_cp0_we && epc[1:0]==2'b00)?wb_cp0_wdata_1:
							(exc_code_1 == `EXC_ERET && epc[1:0]==2'b00)?epc:
							(exc_code_1 == `EXC_ERET)? `EXC_ADDR:
							(exc_code_1 != `EXC_NONE)? `EXC_ADDR:32'b0;

	//CP0 read
	assign ex_cp0_rdata_0 = (!rst_) ? 32'b0: (!ex_cp0_re[0]) ? 32'b0:
					 (ex_cp0_raddr_0 == `CP0_BADVADDR) ? badvaddr:
					 (ex_cp0_raddr_0 == `CP0_COUNT)  ? count:
					 (ex_cp0_raddr_0 == `CP0_STATUS) ? status:
					 (ex_cp0_raddr_0 == `CP0_CAUSE) ? cause:
					 (ex_cp0_raddr_0 == `CP0_EPC) ? epc:32'b0;
	assign ex_cp0_rdata_1 = (!rst_) ? 32'b0: (!ex_cp0_re[1]) ? 32'b0:
					 (ex_cp0_raddr_1 == `CP0_BADVADDR) ? badvaddr:
					 (ex_cp0_raddr_1 == `CP0_COUNT)  ? count:
					 (ex_cp0_raddr_1 == `CP0_STATUS) ? status:
					 (ex_cp0_raddr_1 == `CP0_CAUSE) ? cause:
					 (ex_cp0_raddr_1 == `CP0_EPC) ? epc:32'b0;

	/***** Sequential Logic *****/
	always @ (posedge clk)begin
	   if (!rst_) begin
			wb_pc_reg <= 32'b0;
	   end
	   else begin
	       wb_pc_reg <= wb_pc;
	   end
	end
	always @(posedge clk) begin
		if (!rst_) begin
			exc_flush_icache <= 1'b0;
		end
		else begin
			exc_flush_icache <= exc_flush_all;
		end
	end

	task do_exc;begin
		if(status[1]==0)begin
			if(in_delay_i)begin
				cause[31] <= 1'b1;
				epc       <= exc_pc_i - 4;
			end
			else if(|cause[9:8]!=1'b0)begin
			     cause[31] <= 1'b0;
			     epc <= epc_soft_int;
			end
			else begin
				cause[31] <= 1'b0;
				epc       <= (|(ex_bp_error & exc_en))?ex_new_target:exc_pc_i;
			end
		end
		status[1] <= 1'b1;
		cause[6:2]<= (exc_en==2'b01)?exc_code_0:exc_code_1;
		badvaddr <= (exc_code_0 == `EXC_ADEL || exc_code_0 == `EXC_ADES || exc_code_1 == `EXC_ADEL || exc_code_1 == `EXC_ADES)?
		             ((|(ex_bp_error & exc_en)&exc_en==2'b01)?ex_cp0_adel_vaddr[31:0]:
		             (|(ex_bp_error & exc_en)&exc_en==2'b10)?ex_cp0_adel_vaddr[63:32]:
		             (exc_en==2'b10)?ex_cp0_ade_vaddr[63:32]:
		             (exc_en==2'b01)?ex_cp0_ade_vaddr[31:0]:badvaddr):badvaddr;
	end
	endtask

	task do_eret;begin
		status[1] <= (epc[1:0]==2'b00)?1'b0:1'b1; //EXL <= 0, enable int detection
		badvaddr <= (epc[1:0]==2'b00)?badvaddr:epc;
		cause[6:2]<= (epc[1:0]==2'b00)?cause[6:2]:`EXC_ADEL;
	end
	endtask
	
	//CP0 update
	always @(posedge clk) begin
		if (!rst_) begin
			badvaddr <= 32'b0;
			status   <= {16'b0,8'b11111111,6'b0,1'b0,1'b1}; //status[28] = 1, enable CP0
			cause    <= 32'b0;
			epc      <= 32'b0;
		end
		else begin
			cause[15:10] <= int_i;
			case(exc_en)
				2'b01: if (exc_code_0 == `EXC_ERET) begin
							do_eret();
	  				   end
	  				   else begin
	  				   		do_exc();
	  				   end
	  			2'b10: if (exc_code_1 == `EXC_ERET) begin
							do_eret();
	  				   end
	  				   else begin
	  				   		do_exc();
	  				   end
	  			2'b00: if(wb_cp0_we && wb_pc != wb_pc_reg)begin
                       badvaddr <= (wb_cp0_waddr_1 == `CP0_BADVADDR)?wb_cp0_wdata_1:
                                   (wb_cp0_waddr_0 == `CP0_BADVADDR)?wb_cp0_wdata_0:badvaddr;
                       status   <= (wb_cp0_waddr_1 == `CP0_STATUS)?wb_cp0_wdata_1:
                                   (wb_cp0_waddr_0 == `CP0_STATUS)?wb_cp0_wdata_0:status;
                       cause    <= (wb_cp0_waddr_1 == `CP0_CAUSE)?wb_cp0_wdata_1:
                                   (wb_cp0_waddr_0 == `CP0_CAUSE)?wb_cp0_wdata_0:cause;
                       epc      <= (wb_cp0_waddr_1 == `CP0_EPC)?wb_cp0_wdata_1:
                                   (wb_cp0_waddr_0 == `CP0_EPC)?wb_cp0_wdata_0:epc;  
                       if(wb_cp0_waddr_1 == `CP0_CAUSE)begin
                            epc_soft_int <= wb_pc[63:32] + 32'h4;
                       end
                       else if(wb_cp0_waddr_0 == `CP0_CAUSE)begin
                            epc_soft_int <= wb_pc[31:0] + 32'h4;                            
                       end
                       end
                default:;
	  		endcase
		end
	end

	//clk frequency division
	always @(posedge clk) begin
		if (!rst_) begin
			count_div <= 1'b0;
		end
		else begin
			count_div <= ~count_div;
		end
	end
	//count update
	always @(posedge clk) begin
		if (!rst_) begin
			count <= 32'b0;
		end
		else if((|exc_en)==0 && wb_cp0_we)begin
			count <= (wb_cp0_waddr_1 == `CP0_COUNT)?wb_cp0_wdata_1:
					 (wb_cp0_waddr_0 == `CP0_COUNT)?wb_cp0_wdata_0:count;
		end
		else if (count_div) begin
			count <= count + 1'b1;
		end
	end

endmodule

