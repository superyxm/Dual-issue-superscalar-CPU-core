/********** Common header file **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** Individual header file **********/
`include "cpu.h"
`include "isa.h"
`include "each_module.h"

`define		Pdest2wayBus		15:0
//EX define
/*********       ISA      define       ************/
//`define ISA_EXC_ERET               5'h0d
/*********       Internal define        ************/
`define WordAddrBus_2way			63:0
`define WordAddrBus_way0           31:0
`define WordAddrBus_way1          63:32
`define AluOpBus_2way              11:0
`define AluOpBus_way0               5:0
`define AluOpBus_way1              11:6
`define WordDataBus_2way           63:0
`define WordDataBus_way0           31:0
`define WordDataBus_way1          63:32
`define DestAddr                    4:0
`define DestAddr_2way               9:0
`define DestAddr_way0               4:0
`define DestAddr_way1               9:5
`define isbrflag_2way               1:0
`define MemOpBus_2way               3:0
`define CtrlOpBus_2way              3:0
`define RegAddrBus_2way             9:0
`define IsaExpBus_2way              9:0
`define IsaExpBus_way0              4:0
`define IsaExpBus_way1              9:5
`define UnCache2WayBus		         1:0 
`define UnCacheCheckWay0	       31:16
`define UnCacheCheckWay1	       63:48
`define DestValid_2way              1:0
`define FUen                        3:0
`define FUen_MUL                    2
`define FUen_DIV                    3
`define BranchCond_2Way             1:0    
`define En2Bus                      1:0
`define PtabaddrBus_2way		     9:0
`define PtabdataBus_2way		   127:0
`define PtabdataBus_way0		    63:0
`define PtabdataBus_way1		  127:64
`define Ptabnextpc_way0	        31:0
`define Ptabnextpc_way1	       95:64
`define Delotflag_2Way              1:0    
`define FUselect_2way               3:0
`define 	RwenBus_2way             7:0
`define 	RwenBus_way0             3:0
`define 	RwenBus_way1             7:4
`define     offset_way0             1:0
`define     offset_way1           33:32
`define     Cp0rdaddrBus_2way       9:0
`define     IDinfo_W                55
`define     IDValid_W               6

module mycpu_top(
	/******** Global Signal ********/
	input	wire	aclk,
	input	wire	aresetn,
	/******** Interruption ********/
	input	wire	[`CPU_IRQ_CH-1:0] int,
	/******** Debug Channel ********/
	output	wire	[`WordAddrBus]	debug_wb_pc,
	output	wire	[3 : 0]			debug_wb_rf_wen,
	output	wire	[4 : 0]			debug_wb_rf_wnum,
	output	wire	[`WordDataBus]	debug_wb_rf_wdata,
	/******** AXI Interface ********/
	output wire [3 : 0] 	awid,
	output wire [31 : 0] 	awaddr,
	output wire [3 : 0] 	awlen,
	output wire [2 : 0] 	awsize,
	output wire [1 : 0] 	awburst,
	output wire [1 : 0] 	awlock,
	output wire [3 : 0] 	awcache,
	output wire [2 : 0] 	awprot,
	output wire  			awvalid,
	input  wire  			awready,
	
	output wire	[3 : 0]		wid,
	output wire [31 : 0] 	wdata,
	output wire [3 : 0] 	wstrb,
	output wire  			wlast,
	output wire  			wvalid,
	input  wire  			wready,
	
	input  wire [3 : 0] 	bid,
	input  wire [1 : 0] 	bresp,
	input  wire  			bvalid,
	output wire  			bready,
	
	output wire [3 : 0] 	arid,
	output wire [31 : 0] 	araddr,
	output wire [3 : 0] 	arlen,
	output wire [2 : 0] 	arsize,
	output wire [1 : 0] 	arburst,
	output wire [1 : 0] 	arlock,
	output wire [3 : 0] 	arcache,
	output wire [2 : 0] 	arprot,



	input  wire [3 : 0] 	rid,
	output wire  			arvalid,
	input  wire  			arready,
	input  wire [31 : 0] 	rdata,
	input  wire [1 : 0] 	rresp,
	input  wire  			rlast,

	input  wire  			rvalid,
	output wire  			rready
);
	
	wire flush;
	assign flush = (ex_bp_result)||(exc_flush_all);//20190723
	//assign flush = 0;//20190723
	//cache_top
	
	//wire     cache_top_flus=0;
	wire    addr_reg_eq_new_pc_flag;
	wire						icache_busy;
	
	
	//IF
	wire    [`WordAddrBus]      if_bp_pc;//
	wire   						if_icache_rw;	
	wire   	[`WriteEnBus]		if_icache_rwen;
	wire	[`WordAddrBus]		if_icache_rd_addr;
	wire    [1:0]				if_icache_delot_en;
	wire 						if_valid_ns;
	wire                       flush_reg_to_bp;
	//icache
	wire  	[`FourWordDataBus]	if_icache_rd_data;
	wire						if_icache_addr_ok;
	wire						if_icache_data_ok;
	wire   	[`PtabAddrBus]		bp_icache_ptab;
	wire    [`PtabAddrBus]		icache_ib_ptab;
	wire	[`WordAddrBus]		icache_ib_branch_pc;
	wire	[`WordAddrBus]		cpu_rd_pc;
	wire    [1:0]               icache_ib_delot_en;
	wire						icache_ns;
	wire						icache_allin;

	//uncacheable
	/*wire						cpu_mem_uncache_en;
	wire						cpu_mem_uncache_rw;
	wire	[`WordAddrBus]		cpu_uncache_rd_addr;
	wire	[`WordDataBus]		cpu_uncache_wr_data;
	wire	[`WordDataBus]		cpu_uncache_rd_data;
	wire						cpu_uncache_data_ok;*/
	//cacheable
	/*wire	[`WordDataBus]		cpu_mem_rd_data;
	wire						cpu_mem_addr_ok;
	wire						cpu_mem_data_ok;*/

	//bp
	wire 						bp_if_en;
	wire 	[`WordAddrBus]		bp_if_target;
	wire    					bp_if_delot_en;
	wire    [`WordAddrBus]		bp_if_delot_pc;
	//wire    [`Ptab2addrBus] 	bp_icache_ptab_addr;`PtabAddrBus by ysr
	wire    [`PtabAddrBus] 	   bp_icache_ptab_addr;
	wire    [`WordAddrBus]		bp_icache_branch_pc;
	wire    [`Ptab2dataBus] 	ex_ptab_data;
	wire   						bp_allin;
	
	//IB
	wire 	[`WordAddrBus] 		ib_id_pc_0;
	wire 	[`WordAddrBus] 		ib_id_pc_1;
	wire 	[`WordDataBus]		ib_id_insn_0;
	wire 	[`WordDataBus]		ib_id_insn_1;
	wire 	[`PtabAddrBus] 		ib_id_ptab_addr_0;
	wire 	[`PtabAddrBus] 		ib_id_ptab_addr_1;
	wire 				   		ib_id_valid_0;
	wire 						ib_id_valid_1;
	wire 						ib_allin;
	wire 						ib_valid_ns;
	wire    [1:0]               ib_id_delot_flag;

	//ID
	wire 	[`WordAddrBus]		id_branch_pc;
	wire 	[`BtbTypeBus]		id_branch_type;
	wire 	[`WordAddrBus]		id_branch_target_addr;
	wire 						id_branch_en;
	wire	[`TwoWordAddrBus]	id_is_pc;
	wire	[`Ptab2addrBus]		id_is_ptab_addr;
	wire    [`IDinfo_W-1 : 0]	id_is_decode_info_0;
	wire    [`IDinfo_W-1 : 0]	id_is_decode_info_1;
	wire    [`IDValid_W-1 : 0]	id_is_decode_valid_0;
	wire    [`IDValid_W-1 : 0]	id_is_decode_valid_1;
	wire    [1:0]				id_is_delot_flag;
	wire 	[`ISA_EXC_W*2-1:0]  id_is_exc_code;
	wire    					id_allin;
	wire   						id_valid_ns;
	
		//	EX input 
	wire	[`WordAddrBus_2way]					       is_pc;
    wire    [`AluOpBus_2way]	                       is_alu_op;
	wire    [`DestAddr_2way]                           is_scr0_addr;
	wire    [`DestAddr_2way]                           is_scr1_addr;
    wire	[`DestAddr_2way]		                   is_Dest_out;
	//wire    [`WordDataBus_2way]                        is_alu_in_0;
	//wire    [`WordDataBus_2way]                        is_alu_in_1;
	wire    [`WordDataBus_2way]                        is_alu_imme;
	//wire    [`WordDataBus_2way]                        is_hi;
	//wire    [`WordDataBus_2way]                        is_lo;
	wire    [`PtabaddrBus_2way]					       is_ex_ptab_addr;
	wire    [`PtabdataBus_2way]                        ptab_data;
	wire                                               is_valid_ns;
	wire    [`IsaExpBus_2way]                          is_exp_code;	
	wire    [`Delotflag_2Way]                          is_delot_flag;
	//wire 	[`WordDataBus_2way]	                       cp0_data_in;
	wire                                               wb_allin;
	wire   [`WordDataBus]                              wb_loadbypass_data;
	wire                                               load_bypass_en;
	wire   [`DestAddr]                                 wb_load_bypass_addr;
      //	EX output
    wire                                                ex_delot_en;
    wire    [`WordAddrBus]                              ex_delot_pc;
    wire                                                ex_allin;
    //wire                                                FU_cp0_re;
    wire 	[`WordDataBus_2way]	                        alu_result;
	wire    [`WordDataBus_2way]		                    mul_result;
	wire   	[`WordDataBus_2way]		                    div_result;
	wire    [7:0]                                       ex_bp_ghr;
	wire 	[`BranchCond_2Way]				            ex_branchcond;
	wire 					                            ex_bp_result;
	wire   [1:0]                                       ex_bp_error_2way;
	wire 	[`WordDataBus_2way]	                        ex_wr_data;	
    wire    [`RwenBus_2way]                             ex_rwen;
	wire 	[`DestAddr_2way]		                    ex_Dest_out;
	wire 	[`DestValid_2way]		                    ex_Dest_valid;
	wire 	[`DestValid_2way]		                    ex_Dest_data_valid;
	wire    [`Delotflag_2Way]                           ex_delot_flag;
	wire    [`FUselect_2way]                            ex_fu_select;
	wire    [`WordAddrBus_2way]                         ex_pc;
	wire  	[`AluOpBus_2way]				            ex_op;
	wire 	[`IsaExpBus_2way]		                    ex_exp_code;
    wire                                                ex_valid_ns;
	wire 	[`UnCache2WayBus]				            uncacheable;
	wire    [`WordDataBus]                              ex_new_target;//fresh
	wire                                                ex_update_en;//fresh
	wire    [`WordDataBus]                              ex_update_pc;//fresh
	wire    [`Cp0rdaddrBus_2way]                        cp0_FU_Scr_addr;//fresh
	//20190721
	wire    [`En2Bus]                                    FU_cp0_re;
	wire    [`DestAddr_2way]                             FU_scr0_addr;
	wire    [`DestAddr_2way]                             FU_scr1_addr;
	wire    [`En2Bus]                                    FU_scr0_valid;
	wire    [`En2Bus]                                    FU_scr1_valid;
    wire                                                 FU_hilo_valid;
	wire   [`WordDataBus_2way]                           FU_scr0_data;
	wire   [`WordDataBus_2way]                           FU_scr1_data;
    wire   [`WordDataBus]                                FU_hi;
	wire   [`WordDataBus]                                FU_lo;
	//d_cache_arbitrator
	
	wire	d_cache_arbitrator_flus;
	wire	uncache_busy;
	wire	cache_busy;
	
	/********** load_mem **********/
	wire	[`WordAddrBus]	load_mem_addr;
	wire	[`WordDataBus]	load_mem_rd_data;
	wire	[`WriteEnBus]	load_mem_rwen;
	wire					load_mem_rw;
	wire					load_mem_en;
	wire					load_mem_data_ok;
	wire					load_mem_addr_ok;
	
	wire					load_uncache_en;
	wire	[`WordDataBus]	load_uncache_rd_data;
	
	/********** store_mem **********/
	wire	[`WordAddrBus]	store_mem_addr;
	wire	[`WordDataBus]	store_mem_data;
	wire	[`WriteEnBus]	store_mem_rwen;
	wire					store_mem_rw;
	wire					store_mem_en;
	wire					store_mem_addr_ok;
	wire                    store_mem_data_ok;
	
	wire	[`WordAddrBus]	store_uncache_addr;
	wire	[`WordDataBus]	store_uncache_data;
	wire	[`WriteEnBus]	store_uncache_rwen;
	wire					store_uncache_rw;
	wire					store_uncache_en;
	wire					store_uncache_data_ok;   
	
	/********** cache_top (mainly D_cache) **********/
	wire   [3:0]            cpu_mem_uncache_rwen;
	wire					cpu_mem_uncache_en;
	wire					cpu_mem_uncache_rw;
	wire	[`WordDataBus]	cpu_mem_uncache_rd_data;
	wire					cpu_mem_uncache_data_ok;
	wire	[`WordDataBus]	cpu_mem_uncache_wr_data;
	wire	[`WordAddrBus]	cpu_mem_uncache_rd_addr;
	wire                   cpu_mem_en;
	wire	[`WordAddrBus]	cpu_mem_rd_addr;
	wire					cpu_mem_rw;
	wire	[`WriteEnBus]	cpu_mem_rwen;
	wire	[`WordDataBus]	cpu_mem_wr_data;
	wire	[`WordDataBus]	cpu_mem_rd_data;
	wire					cpu_mem_addr_ok;
	wire					cpu_mem_data_ok;

	//cp0
	wire 	[`WordDataBus] 	ex_cp0_rdata_0;	
	wire 	[`WordDataBus] 	ex_cp0_rdata_1;
	wire 					exc_flush_all;
	wire 					exc_flush_icache;
	wire 	[`WordAddrBus]  cp0_if_excaddr;
	
	
	wire [4:0] write_addr0;
	wire [4:0] write_addr1;
	wire [31:0] write_data0;
	wire [31:0] write_data1;
	wire write_addr0_valid;
	wire write_addr1_valid;

	wire [31:0] in_store_data;
	wire [31:0] in_store_addr;
	wire [3:0]  in_store_rwen;
	wire        in_store_valid;
	wire        in_store_uncache;
	wire        store_buffer_allow_in;	
	wire [31:0] store_buffer_load_addr;
	wire        store_buffer_hit;
	wire [31:0] store_buffer_load_data;
	wire        store_buffer_search_enanble;

	wire [31:0] read_regfile_data0;
	wire [31:0] read_regfile_data1;
	wire [31:0] read_regfile_data2;
	wire [31:0] read_regfile_data3;
	wire [4:0]  read_regfile_addr0;
	wire [4:0]  read_regfile_addr1;
	wire [4:0]  read_regfile_addr2;
	wire [4:0]  read_regfile_addr3;
		
	wire is_allow_in;
//	wire [31:0] ex_Dest_out0; by ysr
//	wire [31:0] ex_Dest_out1;
    wire [4:0] ex_Dest_out0; 
	wire [4:0] ex_Dest_out1;
	wire ex_Dest_valid0;
	wire ex_Dest_valid1;
	wire ex_Dest_data_valid0;
	wire ex_Dest_data_valid1;
	wire read_regfile_addr0_valid;
	wire read_regfile_addr1_valid;
	wire read_regfile_addr2_valid;
	wire read_regfile_addr3_valid;
		
	wire inst0_delot_flag;
	wire inst1_delot_flag;
	wire [4:0] inst0_to_fu_dst;
	wire [4:0] inst1_to_fu_dst;
	wire [5:0] inst0_to_fu_meaning;
	wire [5:0] inst1_to_fu_meaning;
	wire [4:0] inst0_error_code;
	wire [4:0] inst1_error_code;
	wire [4:0] inst0_to_fu_ptab_addr;
	wire [4:0] inst1_to_fu_ptab_addr;
	wire [4:0] inst0_to_fu_src0;
	wire [4:0] inst0_to_fu_src1;
	wire [4:0] inst1_to_fu_src0;
	wire [4:0] inst1_to_fu_src1;
	wire [31:0] inst0_to_fu_pc;
	wire [31:0] inst1_to_fu_pc;
	wire [31:0] inst0_to_fu_imme;
	wire [31:0] inst1_to_fu_imme;
	wire inst0_valid;
	wire inst1_valid;
	wire is_to_next_stage_valid;

	wire [31:0]inst0_to_fu_data0;
	wire [31:0]inst0_to_fu_data1;
	wire [31:0]inst1_to_fu_data0;
	wire [31:0]inst1_to_fu_data1;		
	

	IF IF(
		.clk(aclk),
		.rst_(aresetn),
		//bp
		.bp_if_en(bp_if_en),
		.bp_if_target(bp_if_target),
		.bp_if_delot_en(bp_if_delot_en),
		.bp_if_delot_pc(bp_if_delot_pc),
		.if_bp_pc(if_bp_pc),
		.flush_reg_to_bp(flush_reg_to_bp),
		//to icache
		.if_rw(if_icache_rw),
		.if_rwen(if_icache_rwen),
		.if_icache_pc(if_icache_rd_addr),
		.if_icache_delot_en(if_icache_delot_en),
		.flag(addr_reg_eq_new_pc_flag),//by ysr 0728
		//handshake
		.icache_allin(icache_allin),
		.bp_allin(bp_allin),
		.if_valid_ns(if_valid_ns),
		//from ex
		.ex_bp_error(|ex_bp_result),  ///////////////////////
		.ex_new_target(ex_new_target), ///////////////////////
		.ex_delot_en(ex_delot_en),
		.ex_delot_pc(ex_delot_pc),
		//from cp0
		.exc_flush_all(exc_flush_all),
		//.cp0_if_excaddr(0)//20190723
		.cp0_if_excaddr(cp0_if_excaddr)//20190723
		);
	
cache_top cache_top(
		.clk(aclk),
		.reset(aresetn),
		.flus(flush),
		.icache_busy(icache_busy),
		.flag(addr_reg_eq_new_pc_flag),
		
		.if_icache_rd_addr(if_icache_rd_addr),
		.if_icache_rw(if_icache_rw),
		.if_icache_rwen(if_icache_rwen),
		.if_icache_rd_data(if_icache_rd_data),
		.if_icache_addr_ok(if_icache_addr_ok),
		.if_icache_data_ok(if_icache_data_ok),
		.bp_icache_ptab(bp_icache_ptab_addr),
		.icache_ib_ptab(icache_ib_ptab),
		.icache_ib_branch_pc(icache_ib_branch_pc),
		.bp_icache_branch_pc(bp_icache_branch_pc),
		.cpu_rd_pc(cpu_rd_pc),
		.if_icache_delot_en(if_icache_delot_en),
		.icache_ib_delot_en(icache_ib_delot_en),
		
		.if_valid_ns( if_valid_ns),
	    .ib_allin(ib_allin),
		.icache_allin(icache_allin),
		.icache_ns(icache_ns),
		
		.cpu_mem_uncache_rwen(cpu_mem_uncache_rwen),
		.cpu_mem_uncache_en(cpu_mem_uncache_en),
		.cpu_mem_uncache_rw(cpu_mem_uncache_rw),
		.cpu_mem_uncache_rd_addr(cpu_mem_uncache_rd_addr),
		.cpu_mem_uncache_wr_data(cpu_mem_uncache_wr_data),
		.cpu_mem_uncache_rd_data(cpu_mem_uncache_rd_data),
		.cpu_mem_uncache_data_ok(cpu_mem_uncache_data_ok),
		
		.cpu_mem_rd_addr(cpu_mem_rd_addr),
		.cpu_mem_rw(cpu_mem_rw),
		.cpu_mem_rwen(cpu_mem_rwen),
		.cpu_mem_wr_data(cpu_mem_wr_data),
		.cpu_mem_rd_data(cpu_mem_rd_data),
		.cpu_mem_addr_ok(cpu_mem_addr_ok),
		.cpu_mem_data_ok(cpu_mem_data_ok),
		.cpu_mem_en(cpu_mem_en),//20190729
		
		.awid(awid),
		.awaddr(awaddr),
		.awlen(awlen),
		.awsize(awsize),
		.awburst(awburst),
		.awlock(awlock),
		.awcache(awcache),
		.awprot(awprot),
		.awvalid(awvalid),
		.awready(awready),
		
		.wid(wid),
		.wdata(wdata),
		.wstrb(wstrb),
		.wlast(wlast),
		.wvalid(wvalid),
		.wready(wready),
		
		.bid(bid),
		.bresp(bresp),
		.bvalid(bvalid),
		.bready(bready),
		
		.arid(arid),
		.araddr(araddr),
		.arlen(arlen),
		.arsize(arsize),
		.arburst(arburst),
		.arlock(arlock),
		.arcache(arcache),
		.arprot(arprot),
		.arvalid(arvalid),
		.arready(arready),
		
		.rid(rid),
		.rdata(rdata),
		.rresp(rresp),
		.rlast(rlast),
		.rvalid(rvalid),
		.rready(rready)
	);
	
	
	d_cache_arbitrator d_cache_arbitrator(
		.clk(aclk),
		.reset(aresetn),
		//.flus(d_cache_arbitrator_flus),
		.flus(flush),
		.uncache_busy(uncache_busy),
		.cache_busy(cache_busy),
		
		.load_mem_addr(load_mem_addr),
		.load_mem_rd_data(load_mem_rd_data),
		.load_mem_rwen(load_mem_rwen),
		.load_mem_rw(load_mem_rw),
		.load_mem_en(load_mem_en),
		.load_mem_data_ok(load_mem_data_ok),
		.load_mem_addr_ok(load_mem_addr_ok),
		
	//	.load_uncache_en(load_uncache_en),
	//	.load_uncache_rd_data(load_uncache_rd_data),
		
		.load_uncache_en(load_uncache_en),
		.load_uncache_rd_data(load_uncache_rd_data),
		
		.store_mem_addr(store_mem_addr),
		.store_mem_data(store_mem_data),
		.store_mem_rwen(store_mem_rwen),
		.store_mem_rw(store_mem_rw),
		.store_mem_en(store_mem_en),
		.store_mem_addr_ok(store_mem_addr_ok),
		.store_mem_data_ok(store_mem_data_ok),
		
		
		.store_uncache_addr(store_uncache_addr),
		.store_uncache_data(store_uncache_data),
		.store_uncache_rwen(store_uncache_rwen),
		.store_uncache_rw(store_uncache_rw),
		.store_uncache_en(store_uncache_en),
		.store_uncache_data_ok(store_uncache_data_ok),
		
		.cpu_mem_uncache_rwen(cpu_mem_uncache_rwen),//0804
		.cpu_mem_uncache_en(cpu_mem_uncache_en),
		.cpu_mem_uncache_rw(cpu_mem_uncache_rw),
		.cpu_mem_uncache_rd_data(cpu_mem_uncache_rd_data),
		.cpu_mem_uncache_data_ok(cpu_mem_uncache_data_ok),
		.cpu_mem_uncache_wr_data(cpu_mem_uncache_wr_data),
		.cpu_mem_uncache_rd_addr(cpu_mem_uncache_rd_addr),
		.cpu_mem_en(cpu_mem_en),//20190729
		.cpu_mem_rd_addr(cpu_mem_rd_addr),
		.cpu_mem_rw(cpu_mem_rw),
		.cpu_mem_rwen(cpu_mem_rwen),
		.cpu_mem_wr_data(cpu_mem_wr_data),
		.cpu_mem_rd_data(cpu_mem_rd_data),
		.cpu_mem_addr_ok(cpu_mem_addr_ok),
		.cpu_mem_data_ok(cpu_mem_data_ok)
	);
		
	

	branch_prediction branch_prediction(
		.clk(aclk),
		.rst_(aresetn),
		.flush(flush),
		//IF
		.if_bp_pc(if_bp_pc),
		.if_bp_delot_en(if_icache_delot_en[1]),
		.flush_reg(flush_reg_to_bp),
		.bp_if_en(bp_if_en),
		.bp_if_target(bp_if_target),
		.bp_if_delot_en(bp_if_delot_en),
		.bp_if_delot_pc(bp_if_delot_pc),
		//icache
		.bp_icache_ptab_addr(bp_icache_ptab_addr),		//////////////////////////
		.bp_icache_branch_pc(bp_icache_branch_pc),		////////////////////////// needs handshake
		//IB
		.ib_ptab_addr(icache_ib_ptab),   //////////////////////
		//ID
		.id_update_en(id_branch_en),
		.id_update_pc(id_branch_pc),
		.id_update_branch_type(id_branch_type),
		.id_update_target(id_branch_target_addr),
		.id_ptab_addr({ib_id_ptab_addr_1,ib_id_ptab_addr_0}),
		//IS
		.is_ptab_addr(id_is_ptab_addr),
		//EX
		.ex_ptab_addr(is_ex_ptab_addr),
		.ex_ptab_data(ptab_data),
		.ex_bp_error(ex_bp_result),
		.ex_update_en(ex_update_en),
		.ex_update_pc(ex_update_pc),
		.ex_real_dir(|ex_branchcond),
		.ex_bp_bhr(ex_bp_ghr),
		//handshake
		.if_valid_ns(if_valid_ns),
		.bp_allin(bp_allin)
		);

	IB IB(
		.clk(aclk),
		.rst_(aresetn),
		.flush(flush),
		//icache
		.icache_ib_insn(if_icache_rd_data), ///////////////////
		.icache_ib_pc(cpu_rd_pc),
		.icache_ib_ptab_addr(icache_ib_ptab),
		.icache_ib_delot_en(icache_ib_delot_en),
		.icache_ib_branch_pc(icache_ib_branch_pc),
		//ID
		.ib_id_pc_0(ib_id_pc_0),
		.ib_id_pc_1(ib_id_pc_1),
		.ib_id_insn_0(ib_id_insn_0),
		.ib_id_insn_1(ib_id_insn_1),
		.ib_id_ptab_addr_0(ib_id_ptab_addr_0),
		.ib_id_ptab_addr_1(ib_id_ptab_addr_1),
		.ib_id_valid_0(ib_id_valid_0),
		.ib_id_valid_1(ib_id_valid_1),
		.ib_id_delot_flag(ib_id_delot_flag),
		//handshake
		.id_allin(id_allin),
		.icache_valid_ns(icache_ns), /////////////////
		.ib_allin(ib_allin),
		.ib_valid_ns(ib_valid_ns)
		);

	ID ID(
		.clk(aclk),
		.rst_(aresetn),
		.flush(flush),
		//IB
		.ib_id_pc_0(ib_id_pc_0),
		.ib_id_pc_1(ib_id_pc_1),
		.ib_id_insn_0(ib_id_insn_0),
		.ib_id_insn_1(ib_id_insn_1),
		.ib_id_ptab_addr_0(ib_id_ptab_addr_0),
		.ib_id_ptab_addr_1(ib_id_ptab_addr_1),
		.ib_id_valid_0(ib_id_valid_0),
		.ib_id_valid_1(ib_id_valid_1),
		.ib_id_delot_flag(ib_id_delot_flag),
		//BP
		.id_branch_pc(id_branch_pc),
		.id_branch_type(id_branch_type),
		.id_branch_target_addr(id_branch_target_addr),
		.id_branch_en(id_branch_en),
		//IS
		.id_is_pc(id_is_pc),
		.id_is_ptab_addr(id_is_ptab_addr),
		.id_is_decode_info_0(id_is_decode_info_0),
		.id_is_decode_info_1(id_is_decode_info_1),
		.id_is_decode_valid_0(id_is_decode_valid_0),
		.id_is_decode_valid_1(id_is_decode_valid_1),
		.id_is_delot_flag(id_is_delot_flag),
		.id_is_exc_code(id_is_exc_code),
		//handshake
		.is_allin(is_allow_in),
		.ib_valid_ns(ib_valid_ns),
		.id_allin(id_allin),
		.id_valid_ns(id_valid_ns)
		);
/*
		assign ex_Dest_out0 = ex_Dest_out [4:0];
		assign ex_Dest_out1 = ex_Dest_out [9:5];
		assign ex_Dest_valid0 = ex_Dest_valid [0];
		assign ex_Dest_valid1 = ex_Dest_valid [1];
		assign ex_Dest_data_valid0 = ex_Dest_data_valid [0];
		assign ex_Dest_data_valid1 = ex_Dest_data_valid [1];
*/		

		
		
/*		
	issue_queque IS(
		.clk(aclk),
		.rst_(aresetn),
		.flush(flush),

		.id_valid_ns_r(id_valid_ns),
		.is_pc(id_is_pc),
		.is_ptab_addr(id_is_ptab_addr),
		.is_decode_info_0(id_is_decode_info_0),
		.is_decode_info_1(id_is_decode_info_1),
		.is_decode_valid_0(id_is_decode_valid_0),
		.is_decode_valid_1(id_is_decode_valid_1),
		.is_exe_code(id_is_exc_code),
		.id_is_delot_flag(id_is_delot_flag),

//-----------  from Register File -----------//
		.read_regfile_data0(read_regfile_data0),
		.read_regfile_data1(read_regfile_data1),
		.read_regfile_data2(read_regfile_data2),
		.read_regfile_data3(read_regfile_data3),

//-----------  from EX -----------//
//---------for bypass------------------//
		.ex_allow_in(ex_allin),
		.ex_dst0(ex_Dest_out0),
		//.ex_dst1(ex_Dest_out0), by ysr
		.ex_dst1(ex_Dest_out1),
		.ex_dst0_valid(1'b0),
		.ex_dst1_valid(1'b0),
		.ex_dst0_data(32'b0),
		.ex_dst1_data(32'b0),
		.ex_dst0_data_valid(1'b0),
		.ex_dst1_data_valid(1'b0),


//-----------  from WB -----------//
		.wb_dst0(5'b0),
		.wb_dst1(5'b0),
		.wb_dst0_valid(1'b0),
		.wb_dst1_valid(1'b0),
		.wb_dst0_data(32'b0),
		.wb_dst1_data(32'b0),
		.wb_dst0_data_valid(1'b0),
		.wb_dst1_data_valid(1'b0),

//----------- output to EX -----------//
		.inst0_delot_flag(inst0_delot_flag),
		.inst1_delot_flag(inst1_delot_flag),
		.inst0_to_fu_dst(inst0_to_fu_dst),
		.inst1_to_fu_dst(inst1_to_fu_dst),
		.inst0_to_fu_meaning(inst0_to_fu_meaning),
		.inst1_to_fu_meaning(inst1_to_fu_meaning),
		.inst0_error_code(inst0_error_code),
		.inst1_error_code(inst1_error_code),
		.inst0_to_fu_ptab_addr(inst0_to_fu_ptab_addr),
		.inst1_to_fu_ptab_addr(inst1_to_fu_ptab_addr),
		.inst0_to_fu_src0(inst0_to_fu_src0),
		.inst0_to_fu_src1(inst0_to_fu_src1),
		.inst1_to_fu_src0(inst1_to_fu_src0),
		.inst1_to_fu_src1(inst1_to_fu_src1),
		.inst0_to_fu_pc(inst0_to_fu_pc),
		.inst1_to_fu_pc(inst1_to_fu_pc),
		.inst0_to_fu_imme(inst0_to_fu_imme),
		.inst1_to_fu_imme(inst1_to_fu_imme),
		.inst0_valid(inst0_valid),
		.inst1_valid(inst1_valid),
		.is_to_next_stage_valid_r(is_valid_ns),

		.inst0_to_fu_data0(inst0_to_fu_data0),
		.inst0_to_fu_data1(inst0_to_fu_data1),
		.inst1_to_fu_data0(inst1_to_fu_data0),
		.inst1_to_fu_data1(inst1_to_fu_data1),

//----------- output to Register File  -----------//
		.read_regfile_addr0(read_regfile_addr0),
		.read_regfile_addr1(read_regfile_addr1),
		.read_regfile_addr2(read_regfile_addr2),
		.read_regfile_addr3(read_regfile_addr3),
		.read_regfile_addr0_valid(read_regfile_addr0_valid),
		.read_regfile_addr1_valid(read_regfile_addr1_valid),
		.read_regfile_addr2_valid(read_regfile_addr2_valid),
		.read_regfile_addr3_valid(read_regfile_addr3_valid),

//----------- output to Decoder -----------//
		.is_allow_in(is_allow_in)
);	*/



wire [106:0] inst0_to_dispatch;
wire [106:0] inst1_to_dispatch;
wire [1:0] issue_enable;
wire is_valid;

issue_queue is(
	.clk(aclk),
	.rst_(aresetn),
	.flush(flush),
//----------- .from Decoder -----------//
	.id_valid_ns(id_valid_ns),
	.is_pc(id_is_pc),
	.is_ptab_addr(id_is_ptab_addr),
	.is_decode_info_0(id_is_decode_info_0),
	.is_decode_info_1(id_is_decode_info_1),
	.is_decode_valid_0(id_is_decode_valid_0),
	.is_decode_valid_1(id_is_decode_valid_1),
	.is_exe_code(id_is_exc_code),
	.id_is_delot_flag(id_is_delot_flag),
	.issue_enable(issue_enable),

//----output to Dispatch----//
	.inst0_to_dispatch(inst0_to_dispatch),
	.inst1_to_dispatch(inst1_to_dispatch),
	.is_allow_in(is_allow_in),
	.is_valid(is_valid)
);
        wire [63:0] is_to_ex_pc;
		assign is_to_ex_pc = {inst1_to_fu_pc,inst0_to_fu_pc};
		assign is_alu_op = {inst1_to_fu_meaning,inst0_to_fu_meaning};
		assign is_scr0_addr = {inst1_to_fu_src0,inst0_to_fu_src0};
		assign is_scr1_addr = {inst1_to_fu_src1,inst0_to_fu_src1};

		assign is_alu_imme = {inst1_to_fu_imme,inst0_to_fu_imme};
		assign is_ex_ptab_addr = {inst1_to_fu_ptab_addr,inst0_to_fu_ptab_addr};

		
		wire [9:0] ptab_from_is;
		assign ptab_from_is = {inst1_to_fu_ptab_addr,inst0_to_fu_ptab_addr};


wire inst0_to_fu_delot_flag;
wire inst1_to_fu_delot_flag;
wire [5:0] inst0_to_fu_data_valid;
wire [5:0] inst1_to_fu_data_valid;
wire inst0_to_fu_valid;
wire inst1_to_fu_valid;

wire [4:0]  inst0_to_fu_exe_code;
wire [4:0]  inst1_to_fu_exe_code;








dispatch DISPATCH(
.clk(aclk),
.rst_(aresetn),
.flush(flush),

//----from issue_queue----//
.inst0_to_dispatch(inst0_to_dispatch),
.inst1_to_dispatch(inst1_to_dispatch),

//---- output to issue_queue----//
.issue_enable(issue_enable),

.ex_allin(ex_allin),

//----------- output to EX -----------//
.inst0_to_fu_delot_flag(inst0_to_fu_delot_flag),
.inst1_to_fu_delot_flag(inst1_to_fu_delot_flag),
.inst0_to_fu_dst(inst0_to_fu_dst),
.inst1_to_fu_dst(inst1_to_fu_dst),
.inst0_to_fu_meaning(inst0_to_fu_meaning),
.inst1_to_fu_meaning(inst1_to_fu_meaning),
.inst0_to_fu_exe_code(inst0_to_fu_exe_code),
.inst1_to_fu_exe_code(inst1_to_fu_exe_code),
.inst0_to_fu_ptab_addr(inst0_to_fu_ptab_addr),
.inst1_to_fu_ptab_addr(inst1_to_fu_ptab_addr),
.inst0_to_fu_pc(inst0_to_fu_pc),
.inst1_to_fu_pc(inst1_to_fu_pc),
.inst0_to_fu_valid(inst0_to_fu_valid),
.inst1_to_fu_valid(inst1_to_fu_valid),



.inst0_to_fu_src0(inst0_to_fu_src0),
.inst0_to_fu_src1(inst0_to_fu_src1),
.inst1_to_fu_src0(inst1_to_fu_src0),
.inst1_to_fu_src1(inst1_to_fu_src1),
.inst0_to_fu_imme(inst0_to_fu_imme),
.inst1_to_fu_imme(inst1_to_fu_imme),
.inst0_to_fu_data_valid(inst0_to_fu_data_valid),
.inst1_to_fu_data_valid(inst1_to_fu_data_valid),
.is_valid(is_valid),
.is_valid_ns(is_valid_ns)
);







wire read_hilo_hi_enable;
wire read_hilo_lo_enable;
wire read_data0_valid;
wire read_data1_valid;
wire read_data2_valid;
wire read_data3_valid;
wire [63:0] write_hilo_data;
wire write_hilo_enable;

	register_file RF(
		.clk(aclk),
		.rst_(aresetn),
		.read_addr0(FU_scr0_addr[`DestAddr_way0]),
		.read_addr1(FU_scr0_addr[`DestAddr_way1]),
		.read_addr2(FU_scr1_addr[`DestAddr_way0]),
		.read_addr3(FU_scr1_addr[`DestAddr_way1]),
		.read_addr0_valid(FU_scr0_valid[0]),
		.read_addr1_valid(FU_scr0_valid[1]),
		.read_addr2_valid(FU_scr1_valid[0]),
		.read_addr3_valid(FU_scr1_valid[1]),
		.read_hilo_hi_enable(FU_hilo_valid),
		.read_hilo_lo_enable(FU_hilo_valid),
	
		.write_addr0(write_addr0),
		.write_addr1(write_addr1),
		.write_addr0_valid(write_addr0_valid),
		.write_addr1_valid(write_addr1_valid),
		.write_data0(write_data0),
		.write_data1(write_data1),
		.write_hilo_hi_data(write_hilo_data[63:32]),
		.write_hilo_lo_data(write_hilo_data[31:0]),
		.write_hilo_hi_data_valid(write_hilo_enable),
		.write_hilo_lo_data_valid(write_hilo_enable),
	
		.read_data0(FU_scr0_data[`WordDataBus_way0]),
		.read_data1(FU_scr0_data[`WordDataBus_way1]),
		.read_data2(FU_scr1_data[`WordDataBus_way0]),
		.read_data3(FU_scr1_data[`WordDataBus_way1]),
		.read_data0_valid(read_data0_valid),
		.read_data1_valid(read_data1_valid),
		.read_data2_valid(read_data2_valid),
		.read_data3_valid(read_data3_valid),
	
		.hilo_hi_data(FU_hi),//wait
		.hilo_lo_data(FU_lo),//wait
		.hilo_hi_data_valid(),
		.hilo_lo_data_valid()
		);		
		
		
	ex_stage ex_stage(
	//global siganl
		.clk(aclk),
		.reset(aresetn),
		.flush(flush),//wait for talk
    //data to IF
        .ex_delot_en(ex_delot_en),
        .ex_delot_pc(ex_delot_pc),
	//data from is
		.is_pc             (is_to_ex_pc),
		.is_alu_op         (is_alu_op),
		.is_scr0_addr      (is_scr0_addr),
		.is_scr1_addr      (is_scr1_addr),
		.is_Dest_out       ({inst1_to_fu_dst,inst0_to_fu_dst}),
		//.is_alu_in_0       (is_alu_in_0),//fresh
		//.is_alu_in_1       (is_alu_in_1),//fresh
		.is_alu_imme       (is_alu_imme),
		//.is_hi             (is_hi),//fresh
		//.is_lo             (is_lo),//fresh
		.is_ptab_addr      ({inst1_to_fu_ptab_addr,inst0_to_fu_ptab_addr}),
		.ptab_data         (ptab_data),//fresh
		.is_valid_ns       (is_valid_ns),	
		.is_exp_code       ({inst1_to_fu_exe_code,inst0_to_fu_exe_code}),
		.ex_allin          (ex_allin),
		.is_delot_flag     ({inst1_to_fu_delot_flag,inst0_to_fu_delot_flag}),
	//cp0 data
		.cp0_data_in       ({ex_cp0_rdata_1,ex_cp0_rdata_0}),    //revised
		.cp0_FU_Scr_addr   (cp0_FU_Scr_addr),//fresh
		.FU_cp0_re         (FU_cp0_re),
     //FU to register
        .FU_scr0_addr      (FU_scr0_addr),
        .FU_scr1_addr      (FU_scr1_addr),
        .FU_scr0_valid     (FU_scr0_valid),
        .FU_scr1_valid     (FU_scr1_valid),
        .FU_hilo_valid     (FU_hilo_valid),
        .FU_scr0_data      (FU_scr0_data),
        .FU_scr1_data      (FU_scr1_data),
        .FU_hi             (FU_hi),
        .FU_lo             (FU_lo),
	// data to wb
		.wb_allin          (wb_allin),
		.wb_loadbypass_data(wb_loadbypass_data),//20190728
		.wb_loadbypass_en  (load_bypass_en),
		.wb_load_bypass_addr (wb_load_bypass_addr),
		.alu_result        (alu_result),
		.mul_result        (mul_result),
		.div_result        (div_result),
		.ex_branchcond     (ex_branchcond),
		.ex_bp_result      (ex_bp_result),
		.ex_bp_error_2way  (ex_bp_error_2way),
		.ex_wr_data        (ex_wr_data),
		.ex_rwen           (ex_rwen),
		.ex_Dest_out       (ex_Dest_out),
		.ex_Dest_valid     (ex_Dest_valid),
		.ex_Dest_data_valid(ex_Dest_data_valid),
		.ex_delot_flag     (ex_delot_flag),
		.ex_fu_select      (ex_fu_select),
		.ex_pc             (ex_pc),
		.ex_op             (ex_op),
		.ex_exp_code       (ex_exp_code),
		.ex_valid_ns       (ex_valid_ns),
		.uncacheable       (uncacheable),
		.ex_bp_ghr            (ex_bp_ghr),  //fresh
		.ex_new_target     (ex_new_target),
		.ex_update_en      (ex_update_en),
		.ex_update_pc      (ex_update_pc)
	);

    wire [63:0] wb_pc;
	
	wire wb_cp0_we;
	wire [4:0] wb_cp0_waddr_0;
	wire [4:0] wb_cp0_waddr_1;
	wire [31:0] wb_cp0_wdata_0;
	wire [31:0] wb_cp0_wdata_1;
	wire store_buffer_load_data_valid;
	wire  [31:0] inst_load_pc;
	wire		[31:0] in_store_pc;
	wire [3:0]  store_buffer_load_data_rwen;
	wire store_buffer_is_empty;
	
	write_back_to_register 	WB(
		.clk(aclk),
		.rst_(aresetn),
		.flush(flush),
		.wb_allin(wb_allin),
		.ex_valid_ns(ex_valid_ns),
		.ex_Dest_data_valid(ex_Dest_data_valid),
		.alu_result(alu_result),
		.mul_result(mul_result),
		.div_result(div_result),
		//.ex_branchcond(ex_branchcond),
		//.ex_bp_result(ex_bp_result),
		.ex_wr_data(ex_wr_data),		
		.ex_rwen(ex_rwen),
		.ex_Dest_out(ex_Dest_out),
		.ex_Dest_valid(ex_Dest_valid),
		//.ex_Dest_data_valid(ex_Dest_data_valid),//fresh
		.ex_delot_flag(ex_delot_flag),//fresh
		.ex_fu_select(ex_fu_select),//fresh
		.ex_pc(ex_pc),
		.ex_op(ex_op),
		.ex_exp_code(ex_exp_code),
		.uncacheable(uncacheable),
		.write_addr0(write_addr0),
		.write_addr1(write_addr1),
		.write_addr0_valid(write_addr0_valid),
		.write_addr1_valid(write_addr1_valid),
		.write_data0(write_data0),
		.write_data1(write_data1),
		.write_hilo_data(write_hilo_data),
		.write_hilo_enable(write_hilo_enable),
		
		.store_buffer_load_data_rwen(store_buffer_load_data_rwen),
		.store_buffer_allow_in(store_buffer_allow_in),
		.in_store_data(in_store_data),
		.in_store_addr(in_store_addr),
		.in_store_rwen(in_store_rwen),
	//	.in_store_uncache(in_store_uncache),
		.in_store_valid(in_store_valid),
		.in_store_pc(in_store_pc),
	
	//----load-----//
	    .store_buffer_is_empty(store_buffer_is_empty),
		.store_buffer_load_addr(store_buffer_load_addr),
		.store_buffer_hit(store_buffer_hit),
		.store_buffer_load_data(store_buffer_load_data),
		.store_buffer_search_enanble(store_buffer_search_enanble),

		.load_mem_data_ok(load_mem_data_ok),
		.load_mem_addr_ok(load_mem_addr_ok),
		.load_mem_addr(load_mem_addr),
		.load_mem_rd_data(load_mem_rd_data),
		.load_mem_rwen(load_mem_rwen),
		.load_mem_rw(load_mem_rw),
		.load_mem_en(load_mem_en),
		.load_uncache_en(load_uncache_en),
		.load_uncache_rd_data(load_uncache_rd_data),
        .store_uncache_addr(store_uncache_addr),
        .store_uncache_data(store_uncache_data),
        .store_uncache_rwen(store_uncache_rwen),
        .store_uncache_rw(store_uncache_rw),
        .store_uncache_en(store_uncache_en),
        .store_uncache_data_ok(store_uncache_data_ok),	
		.store_buffer_load_data_valid(store_buffer_load_data_valid),
		.inst_load_pc(inst_load_pc),
		//( by ysr)
		.wb_pc(wb_pc),
		.wb_cp0_we(wb_cp0_we),
		.wb_cp0_waddr_0(wb_cp0_waddr_0),
		.wb_cp0_waddr_1(wb_cp0_waddr_1),
		.wb_cp0_wdata_0(wb_cp0_wdata_0),
		.wb_cp0_wdata_1(wb_cp0_wdata_1),
		.load_bupass_data (wb_loadbypass_data),
		.load_data_bypass_en(load_bypass_en),
		.wb_load_bypass_addr (wb_load_bypass_addr)
	);

	wire out_store_valid;
/*	wire [63:0] wb_pc;
	
	wire wb_cp0_we;
	wire [4:0] wb_cp0_waddr_0;
	wire [4:0] wb_cp0_waddr_1;
	wire [31:0] wb_cp0_wdata_0;
	wire [31:0] wb_cp0_wdata_1;*/
	
	store_buffer SB(
		.clk(aclk),
		.rst_(aresetn),
		.flush(flush),
		.inst_load_pc(inst_load_pc),
		.in_store_data(in_store_data),
		.in_store_addr(in_store_addr),
		.in_store_rwen(in_store_rwen),
		.in_store_valid(in_store_valid),
		.in_store_pc(in_store_pc),
		//.in_store_uncache(in_store_uncache),
		.cache_is_busy(~store_mem_data_ok),
        .store_buffer_load_data_rwen(store_buffer_load_data_rwen),
		.store_buffer_search_enanble(store_buffer_search_enanble),
		.store_buffer_load_addr(store_buffer_load_addr),
		.store_buffer_hit(store_buffer_hit),
		.store_buffer_load_data(store_buffer_load_data),
		.out_store_data(store_mem_data),
		.out_store_addr(store_mem_addr),
		.out_store_rwen(store_mem_rwen),
		.out_store_en(store_mem_en),
		//.out_store_uncache(store_uncache_en),
		.out_store_rw(store_mem_rw),
		.store_buffer_load_data_valid(store_buffer_load_data_valid),
		 .store_buffer_is_empty(store_buffer_is_empty),
		.store_buffer_allow_in(store_buffer_allow_in)
		/*.wb_pc(wb_pc),
		.wb_cp0_we(wb_cp0_we),
		.wb_cp0_waddr_0(wb_cp0_waddr_0),
		.wb_cp0_waddr_1(wb_cp0_waddr_1),
		.wb_cp0_wdata_0(wb_cp0_wdata_0),
		.wb_cp0_wdata_1(wb_cp0_wdata_1)*/ //ysr
	);	

	cp0 cp0(
		.clk(aclk),
		.rst_(aresetn),
		//ex
		//MFC0
		.ex_cp0_re(FU_cp0_re),
		.ex_cp0_raddr_0(cp0_FU_Scr_addr[4:0]),//wait for xuming
		.ex_cp0_raddr_1(cp0_FU_Scr_addr[9:5]),//
		.ex_cp0_rdata_0(ex_cp0_rdata_0),
		.ex_cp0_rdata_1(ex_cp0_rdata_1),
		//EXCCODE
		.ex_cp0_exc_pc_i(ex_pc),
		.ex_cp0_ade_vaddr(alu_result),
		.ex_cp0_adel_vaddr(ex_wr_data),
		.ex_cp0_in_delay_i(ex_delot_flag),
		.ex_cp0_exc_code_i(ex_exp_code),
		.ex_bp_error(ex_bp_error_2way),
	    .ex_new_target(ex_new_target),
		//wb
		.wb_pc(wb_pc),
		.wb_cp0_we(wb_cp0_we),
		.wb_cp0_waddr_0(wb_cp0_waddr_0),
		.wb_cp0_waddr_1(wb_cp0_waddr_1),
		.wb_cp0_wdata_0(wb_cp0_wdata_0),
		.wb_cp0_wdata_1(wb_cp0_wdata_1),
		//int
		.int_i(int),
		//other output
		.exc_flush_all(exc_flush_all),
		.exc_flush_icache(exc_flush_icache),
		.cp0_if_excaddr(cp0_if_excaddr)
		);


		
wire [31:0] wb_pc0;
wire [31:0] wb_pc1;

//assign wb_pc0 = wb_pc[31:0];//20190723
//assign wb_pc1 = wb_pc[63:32];
assign wb_pc0 = wb_pc[31:0];
assign wb_pc1 = wb_pc[63:32];

	trace_interface trace_interface(
		.clk(aclk),
		.reset(aresetn),
		.pc_0(wb_pc0),
		.wen_0(write_addr0_valid),
		.reg_addr_0(write_addr0),
		.reg_data_0(write_data0),
		.pc_1(wb_pc1),
		.wen_1(write_addr1_valid),
		.reg_addr_1(write_addr1),
		.reg_data_1(write_data1),
		.debug_wb_rf_wen(debug_wb_rf_wen),
		.debug_wb_rf_wdata(debug_wb_rf_wdata),
		.debug_wb_pc(debug_wb_pc),
		.debug_wb_rf_wnum(debug_wb_rf_wnum)
		);



endmodule
	
	
	
	
	
	
	
	