`include "nettype.h"
`include "global_config.h"
`include "stddef.h"


`include "isa.h"
`include "cpu.h"
`include "each_module.h"


`define		StateBus	2:0
`define		IDEL		3'b000
`define		LC			3'b001
`define		SC			3'b010
`define		LU			3'b011
`define		SU			3'b100


module d_cache_arbitrator(
	/********** global **********/
	input	wire 	clk,
	input	wire	reset,
	input	wire	flus,
	output	wire	uncache_busy,
	output	wire	cache_busy,
	
	/********** load_mem **********/
	input	wire	[`WordAddrBus]	load_mem_addr,
	output	wire	[`WordDataBus]	load_mem_rd_data,
	input	wire	[`WriteEnBus]	load_mem_rwen,
	input	wire					load_mem_rw,
	input	wire					load_mem_en,
	output	wire					load_mem_data_ok,
	output	wire					load_mem_addr_ok,
	
	input						   load_uncache_en,
	//output  wire                   load_uncache_data_ok,
	output	wire	[`WordDataBus]	load_uncache_rd_data,
	
	/********** store_mem **********/
	input	wire	[`WordAddrBus]	store_mem_addr,
	input	wire	[`WordDataBus]	store_mem_data,
	input	wire	[`WriteEnBus]	store_mem_rwen,
	input	wire					store_mem_rw,
	input	wire					store_mem_en,
	output	wire					store_mem_addr_ok,
	output  wire                   store_mem_data_ok,//20190720fresh
	
	
	input	wire	[`WordAddrBus]	store_uncache_addr,
	input	wire	[`WordDataBus]	store_uncache_data,
	input	wire	[`WriteEnBus]	store_uncache_rwen,
	input	wire					store_uncache_rw,
	input	wire					store_uncache_en,
	output  wire                   store_uncache_data_ok,  //both load uncache and store uncache use it                 
	
	/********** cache_top (mainly D_cache) **********/
	output  wire    [3:0]           cpu_mem_uncache_rwen,//0804
	output	wire					cpu_mem_uncache_en,
	output	wire					cpu_mem_uncache_rw,
	input	wire	[`WordDataBus]	cpu_mem_uncache_rd_data,
	input	wire					cpu_mem_uncache_data_ok,
	output	wire	[`WordDataBus]	cpu_mem_uncache_wr_data,
	output	wire	[`WordAddrBus]	cpu_mem_uncache_rd_addr,
	output  wire                   cpu_mem_en,
	output	wire	[`WordAddrBus]	cpu_mem_rd_addr,
	output	wire					cpu_mem_rw,
	output	wire	[`WriteEnBus]	cpu_mem_rwen,
	output	wire	[`WordDataBus]	cpu_mem_wr_data,
	//output	wire	[`WordDataBus]	cpu_mem_wr_data,
	input	wire	[`WordDataBus]	cpu_mem_rd_data,
	input	wire					cpu_mem_addr_ok,
	input	wire					cpu_mem_data_ok
);


	
	/********** internal signal **********/
	//
	reg		[`StateBus]		state;
	reg		[`StateBus]		nxstate;
	wire					state_idel;
	wire					state_sc;
	wire					state_lc;
	wire					state_lu;
	wire					state_su;
	wire					nxstate_idel;
	wire					nxstate_sc;
	wire					nxstate_lc;
	wire					nxstate_lu;
	wire					nxstate_su;
	
	
	//reg						addr_ok;
	
	//
	//reg		[`WordDataBus]	load_uncache_rd_data_reg;
	
	//reg		[`WordDataBus]	load_data;
	//reg		[`WordDataBus]	wr_gpr_data;
	
	reg						flag;
	
	
	/********** state machine **********/
	assign	state_idel		=	(state == `IDEL);
	assign	state_lc		=	(state == `LC);
	assign	state_sc		=	(state == `SC);
	assign	state_lu		=	(state == `LU);
	assign	state_su		=	(state == `SU);
	assign	nxstate_idel	=	(nxstate == `IDEL);
	assign	nxstate_lc		=	(nxstate == `LC);
	assign	nxstate_sc		=	(nxstate == `SC);
	assign	nxstate_lu		=	(nxstate == `LU);
	assign	nxstate_su		=	(nxstate == `SU);


	
	always @ (*) begin
		case (state) 
			`IDEL	:	nxstate	=	(store_uncache_en) ? `SU :
									(load_uncache_en && ~flag) ? `LU : 
									(load_mem_en) ? `LC :
									(store_mem_en) ? `SC:
									`IDEL;
			`SU		:	nxstate	=	(!cpu_mem_uncache_data_ok) ? `SU :
									(store_mem_en)? `SC:
									`IDEL;
			`LU		:	nxstate	=	(!cpu_mem_uncache_data_ok) ? `LU :
								    (store_mem_en)? `SC:
									`IDEL;
			`SC		:	nxstate	=	(!store_mem_data_ok)? `SC :
									`IDEL;
			`LC		:	nxstate	=	(!load_mem_data_ok) ? `LC:
									//(store_mem_en)? `SC :
									`IDEL;
			default	:	nxstate	=	`IDEL;
		endcase
	end
	
	always @ (posedge clk) begin
		if (reset == `RESET_ENABLE) begin
			state		<=	`IDEL;
		end
		else begin
			state		<=	nxstate;
		end
	end
	
	
	/********** assignment **********/
	//
	//assign	cpu_mem_uncache_rw		=	(nxstate_su & store_mem_rw) | (nxstate_lu & load_mem_rw);
	//assign	cpu_mem_uncache_wr_data	=	(nxstate_su) ? store_mem_data : 'b0;
	/*assign	cpu_mem_uncache_rd_addr	=	(nxstate_su) ? store_mem_addr :
										(nxstate_lu) ? load_mem_addr  :
										'b0;*/
	assign  cpu_mem_uncache_rwen    =   (nxstate_su)?store_uncache_rwen:'b0;
	assign	cpu_mem_uncache_en		=	(nxstate_su | nxstate_lu);
	assign	cpu_mem_uncache_rw		=	(nxstate_su & store_uncache_rw) | (nxstate_lu & load_mem_rw);
	assign	cpu_mem_uncache_wr_data	=	(nxstate_su) ? store_uncache_data : 'b0;
	assign	cpu_mem_uncache_rd_addr	=	(nxstate_su) ? store_uncache_addr :
										(nxstate_lu) ? load_mem_addr  :
										'b0;
										
	
	/*assign	cpu_mem_rw				=	(nxstate_sc) ? store_mem_rw :
										(nxstate_lc) ? load_mem_rw  :
										(nxstate_idel & store_mem_en & (~state_lc)) ? store_mem_rw :
										(nxstate_idel & load_mem_en & (~state_lc)) ? load_mem_rw : 
										`READ;
	assign	cpu_mem_rwen			=	(nxstate_sc) ? store_mem_rwen :
										(nxstate_lc) ? load_mem_rwen  :
										(nxstate_idel & store_mem_en & (~state_lc)) ? store_mem_rwen :
										(nxstate_idel & load_mem_en & (~state_lc)) ? load_mem_rwen : 
										`RW_DISABLE;
	assign	cpu_mem_rd_addr			=	(nxstate_sc) ? store_mem_addr :
										(nxstate_lc) ? load_mem_addr  :
										(nxstate_idel & store_mem_en & (~state_lc)) ? store_mem_addr :
										(nxstate_idel & load_mem_en & (~state_lc)) ? load_mem_addr : 
										'b0;
	assign	cpu_mem_wr_data			=	(nxstate_sc |(nxstate_idel & store_mem_en)) ? store_mem_data : 'b0;*/
	
	//assign  cpu_mem_en             =    (nxstate_sc | nxstate_lc);
	assign  cpu_mem_en             =    ((nxstate_sc & (~state_sc)))| ((nxstate_lc&&(~state_lc)));
	assign	cpu_mem_rw				=	(nxstate_lc) ? load_mem_rw  :
	                                    (nxstate_sc) ? store_mem_rw :
	                                    (nxstate_idel & load_mem_en & (~state_sc)) ? load_mem_rw :
										(nxstate_idel & store_mem_en & (~state_sc)) ? store_mem_rw :
										`READ;
	assign	cpu_mem_rwen			=	(nxstate_lc) ? load_mem_rwen  :
	                                    (nxstate_sc) ? store_mem_rwen :
										(nxstate_idel & load_mem_en & (~state_sc)) ? load_mem_rwen : 										
										(nxstate_idel & store_mem_en & (~state_sc)) ? store_mem_rwen :
										`RW_DISABLE;
	assign	cpu_mem_rd_addr			=	(nxstate_lc) ? load_mem_addr  :
	                                    (nxstate_sc) ? store_mem_addr :
										(nxstate_idel & load_mem_en & (~state_sc)) ? load_mem_addr : 										
										(nxstate_idel & store_mem_en & (~state_sc)) ? store_mem_addr :
										'b0;
	assign	cpu_mem_wr_data			=	(nxstate_sc |(nxstate_idel & store_mem_en)) ? store_mem_data : 'b0;
	
	
	//
	assign	store_mem_addr_ok		=	cpu_mem_addr_ok;
	assign  store_mem_data_ok       =   (state_sc)?cpu_mem_data_ok : 1'b0;//20190720fresh  by ysr
	assign  store_uncache_data_ok   =   cpu_mem_uncache_data_ok;//20190720fresh by ysr
	//assign  load_uncache_data_ok    =   cpu_mem_uncache_data_ok;//20190727 zheshiyigeyinhuan
	assign	load_mem_addr_ok		=	cpu_mem_addr_ok;
	assign	load_mem_rd_data		=	cpu_mem_rd_data;
	assign	load_mem_data_ok		=	(state_lc)?cpu_mem_data_ok : 1'b0;
	assign	load_uncache_rd_data	=	(state_lu & load_uncache_en) ? cpu_mem_uncache_rd_data : 32'b0;
	assign	uncache_busy			=	(nxstate_su) | (nxstate_lu);
	assign	cache_busy				=	(nxstate_sc | nxstate_lc);//20190720fresh by ysr
	
	always @ (posedge clk) begin
		if(reset == `RESET_ENABLE)begin
			flag	<=	'b0;
		end
		else if(flus)begin
			flag	<= 'b0;
		end
		else if (state_lu & cpu_mem_uncache_data_ok)begin
			flag	<= 1'b1;
		end
		else	begin
			flag	<= 'b0;
		end
	end
	
	/*always @(posedge clk)begin
		if(reset == `RESET_ENABLE)begin
			addr_ok	<= `DISABLE;
		end
		else begin
			addr_ok	<= cpu_mem_addr_ok;
		end
	end*/
	
	
endmodule
	
`undef		StateBus	
`undef		IDEL		
`undef		LC			
`undef		SC			
`undef		LU			
`undef		SU			
	
	
	
	
	
	
	
	
	
	
	
	
	