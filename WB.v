`define ISA_EXC_NO_EXC	   5'h10	// No exception
`define ISA_EXC_INT	   	   5'h00	// Interuption
`define ISA_EXC_RI 		   5'h0a	// Reserve
`define ISA_EXC_OV                5'h0c	// Arithmetic overflow
`define ISA_EXC_ADEL            5'h04	// Aligned Data Error of Load
`define ISA_EXC_ADES	           5'h05	// Aligned Data Error of Read
`define ISA_EXC_SYS	           5'h08	// System Call
`define ISA_EXC_BP                5'h09	// Break Point

`define ISA_OP_LB   	   6'h20 // 
`define ISA_OP_LBU		   6'h24 // 
`define ISA_OP_LH		   6'h21 // 
`define ISA_OP_LHU		   6'h25 // 
`define ISA_OP_LW		   6'h23 // 
`define ISA_OP_SB		   6'h28 // 
`define ISA_OP_SH		   6'h29 // 
`define ISA_OP_SW		   6'h2b // 
`define	INSN_MTC0		6'h38


`define INSN_ADD		6'h00
`define	INSN_ADDI		6'h01
`define	INSN_ADDU		6'h02
`define	INSN_ADDIU		6'h03
`define	INSN_SUB		6'h04
`define	INSN_SUBU		6'h05
`define	INSN_SLT		6'h06
`define	INSN_SLTI		6'h07
`define	INSN_SLTU		6'h08
`define	INSN_SLTIU		6'h09
`define	INSN_DIV		6'h0a
`define	INSN_DIVU		6'h0b
`define INSN_MULT		6'h0c
`define	INSN_MULTU		6'h0d
`define	INSN_AND		6'h0e
`define	INSN_ANDI		6'h0f
`define	INSN_LUI		6'h10
`define	INSN_NOR		6'h11
`define	INSN_OR			6'h12
`define	INSN_ORI		6'h13
`define	INSN_XOR		6'h14
`define	INSN_XORI		6'h15
`define	INSN_SLL		6'h16
`define INSN_SLLV		6'h17
`define	INSN_SRA		6'h18
`define	INSN_SRAV		6'h19
`define	INSN_SRL		6'h1a
`define	INSN_SRLV		6'h1b
`define	INSN_BEQ		6'h1c
`define	INSN_BNE		6'h1d
`define	INSN_BGEZ		6'h1e
`define	INSN_BGTZ		6'h1f
`define	INSN_BLEZ		6'h20
`define	INSN_BLTZ		6'h21
`define	INSN_BLTZAL		6'h22
`define	INSN_BGEZAL		6'h23
`define	INSN_J			6'h24
`define	INSN_JAL		6'h25
`define	INSN_JR			6'h26
`define	INSN_JALR		6'h27
`define	INSN_MFHI		6'h28
`define INSN_MFLO		6'h29
`define	INSN_MTHI		6'h2a
`define	INSN_MTLO		6'h2b
`define	INSN_BREAK		6'h2c
`define	INSN_SYSCALL	6'h2d
`define	INSN_LB			6'h2e
`define	INSN_LBU		6'h2f
`define	INSN_LH			6'h30
`define	INSN_LHU		6'h31
`define	INSN_LW			6'h32
`define	INSN_SB			6'h33
`define	INSN_SH			6'h34
`define	INSN_SW			6'h35
`define	INSN_ERET		6'h36
`define	INSN_MFC0		6'h37
`define	INSN_MTC0		6'h38
`define	INSN_RI			6'h39
`define	INSN_NOP		6'h3a
	
/*********       ISA      define       ************/
`define ISA_EXC_ERET               5'h11
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

`define IDLE            3'b000
`define SB_SEARCH_BEGIN 3'b001
`define SB_SEARCH       3'b010
`define WAIT_SB_EMPTY   3'b011
`define CACHE_SEARCH    3'b100

module write_back_to_register(
	input clk,
	input rst_,
	input flush,
	
	//----EX---//
	input ex_valid_ns,
    input [`WordDataBus_2way] alu_result,
	input [`WordDataBus_2way] mul_result,
	input [`WordDataBus_2way] div_result,

	input [`WordDataBus_2way] ex_wr_data,		
	input [`RwenBus_2way]     ex_rwen,
	input [`DestAddr_2way]	  ex_Dest_out,
	input [`DestValid_2way]	  ex_Dest_valid,
	input [1:0] ex_Dest_data_valid,
	input [`Delotflag_2Way]   ex_delot_flag,
	input [`FUselect_2way]    ex_fu_select,
	input [`WordAddrBus_2way] ex_pc,
	input [`AluOpBus_2way]	  ex_op,
	input [`IsaExpBus_2way]   ex_exp_code,
	input [`UnCache2WayBus]   uncacheable,
	output        wb_allin,
	
	//----register-file----//
	output reg [4:0]  write_addr0,
	output reg [4:0]  write_addr1,
	output reg        write_addr0_valid,
	output reg        write_addr1_valid,
	output reg [31:0] write_data0,
	output reg [31:0] write_data1,
	output reg [63:0] write_hilo_data,
	output reg        write_hilo_enable,
	
	//----store_buffer----//
	input store_buffer_allow_in,
	input store_buffer_is_empty,
	output reg [31:0] in_store_data,
	output reg [31:0] in_store_addr,
	output reg [3:0]  in_store_rwen,
	//output reg        in_store_uncache,
	output reg        in_store_valid,
	output reg [31:0] in_store_pc,
	
	//----cache-----//
	input        store_buffer_hit,
	input [31:0] store_buffer_load_data,
	input        load_mem_data_ok,
	input        load_mem_addr_ok,
	input [31:0] load_uncache_rd_data,
	input [31:0] load_mem_rd_data,
	input        store_buffer_load_data_valid,
	input [3:0]  store_buffer_load_data_rwen,
	
	output reg [31:0] store_buffer_load_addr,
	output reg        store_buffer_search_enanble,
	output reg [3:0]  load_mem_rwen,
	output reg        load_mem_rw,
	output reg        load_mem_en,
	output reg [31:0] load_mem_addr,	
	output reg        load_uncache_en,
	output reg     [63:0] wb_pc,
	output reg        wb_cp0_we,
	output reg [4:0]  wb_cp0_waddr_0,
	output reg [4:0]  wb_cp0_waddr_1,
	output reg [31:0] wb_cp0_wdata_0,
	output reg [31:0] wb_cp0_wdata_1,
	
	output reg [31:0] store_uncache_addr,
	output reg [31:0] store_uncache_data,
	output reg [3:0]  store_uncache_rwen,
	output reg        store_uncache_rw,
	output reg       store_uncache_en,
	output wire       [31:0] load_bupass_data,
	output wire       load_data_bypass_en,
	output reg [31:0] inst_load_pc,
	input             store_uncache_data_ok,
    output [4:0]  wb_load_bypass_addr
);

	wire [4:0] inst0_exe_code;
	wire [4:0] inst1_exe_code;
	wire       inst0_retire_enable;
	wire       inst1_retire_enable;	
	reg        inst0_exc_detect;
	reg        inst1_exc_detect;
	reg [31:0] load_data;
	//reg [31:0] store_buffer_load_data_select;//fresh
	reg [31:0] load_data_select;
	reg [31:0] load; //fresh
	reg        load_data_seletc_valid;
	reg        inst0_issued;
	reg        inst1_issued;
	reg        wait_store_buffer_is_empty;

assign load_bupass_data = load_data_select;

wire inst0_delot_flag;
wire inst1_delot_flag;

assign inst0_delot_flag = ex_delot_flag[0];
assign inst1_delot_flag = ex_delot_flag[1];

wire state_change;
reg [2:0] state;
reg [2:0] nextstate;

wire inst0_load_cache;
wire inst1_load_cache;
wire [31:0] load_pc_now; 



//----load and store detect----//
wire [5:0] inst0_op;
wire [5:0] inst1_op;
assign inst0_op = ex_op[5:0];
assign inst1_op = ex_op[11:6];

reg [1:0] inst0_load_store_detect;
reg [1:0] inst1_load_store_detect;
wire inst0_load_detect;
wire inst1_load_detect;
wire inst0_store_detect;
wire inst1_store_detect;

assign inst0_load_detect  = inst0_load_store_detect[0];
assign inst0_store_detect = inst0_load_store_detect[1];
assign inst1_load_detect  = inst1_load_store_detect[0];
assign inst1_store_detect = inst1_load_store_detect[1];

wire inst0_mtc0_detect;
wire inst1_mtc0_detect;

assign inst0_mtc0_detect = (inst0_op == `INSN_MTC0)? 1'b1 : 1'b0;
assign inst1_mtc0_detect = (inst1_op == `INSN_MTC0)? 1'b1 : 1'b0;
	
	


//----exc detect----//	
assign inst1_exe_code = ex_exp_code[9:5];
assign inst0_exe_code = ex_exp_code[4:0];

assign inst0_retire_enable = (!inst0_exc_detect) || (inst0_exc_detect && inst1_delot_flag) ;
assign inst1_retire_enable = ((inst0_retire_enable)&&(!inst1_exc_detect))? 1'b1 : 1'b0;

always @(*)begin
	case (inst0_exe_code)
		`ISA_EXC_NO_EXC: inst0_exc_detect = 1'b0;
		`ISA_EXC_INT,`ISA_EXC_RI,`ISA_EXC_OV,`ISA_EXC_ADEL,`ISA_EXC_ADES,`ISA_EXC_SYS,`ISA_EXC_BP: inst0_exc_detect = 1'b1;
		default: inst0_exc_detect = 1'b1;
	endcase
	
	case (inst1_exe_code)
		`ISA_EXC_NO_EXC: inst1_exc_detect = 1'b0;
		`ISA_EXC_INT,`ISA_EXC_RI,`ISA_EXC_OV,`ISA_EXC_ADEL,`ISA_EXC_ADES,`ISA_EXC_SYS,`ISA_EXC_BP: inst1_exc_detect = 1'b1;
		default: inst1_exc_detect = 1'b1;
	endcase	
end

//----write_data_to_register----//
wire [1:0] inst0_fu_select;
wire [1:0] inst1_fu_select;
wire [4:0] alu0_write_addr;
wire [4:0] alu1_write_addr;
wire       alu0_write_addr_valid;
wire       alu1_write_addr_valid;

wire [31:0] alu0_result;
wire [31:0] alu1_result;

assign alu0_result = alu_result[31:0];
assign alu1_result = alu_result[63:32];

assign inst0_fu_select = ex_fu_select[1:0];
assign inst1_fu_select = ex_fu_select[3:2];

assign alu0_write_addr = ex_Dest_out[4:0];
assign alu1_write_addr = ex_Dest_out[9:5];

assign alu0_write_addr_valid = ex_Dest_data_valid[0];
assign alu1_write_addr_valid = ex_Dest_data_valid[1];

wire inst0_uncache;
wire inst1_uncache;

wire [31:0] alu0_wr_data;
wire [31:0] alu1_wr_data;
wire [3:0]  alu0_ex_rwen;
wire [3:0]  alu1_ex_rwen;
wire        alu0_uncacheable;
wire        alu1_uncacheable;

assign inst0_uncache = (inst0_fu_select == 2'b00)? alu0_uncacheable : (inst0_fu_select == 2'b01)? alu1_uncacheable : 1'b0;
assign inst1_uncache = (inst1_fu_select == 2'b00)? alu0_uncacheable : (inst1_fu_select == 2'b01)? alu1_uncacheable : 1'b0;

assign alu0_wr_data = ex_wr_data[31:0];
assign alu1_wr_data = ex_wr_data[63:32];

assign alu0_ex_rwen = ex_rwen[3:0];
assign alu1_ex_rwen = ex_rwen[7:4];

assign alu0_uncacheable = uncacheable[0];
assign alu1_uncacheable = uncacheable[1];



/*

always @(*)begin
		wb_allin = 1'b1;
end
*/
reg inst0_ready_write;
reg inst1_ready_write;
reg [3:0] store_buffer_search_rwen;

	wire wb_ready_go;
	reg wb_valid;
	
	assign wb_ready_go = inst0_ready_write & inst1_ready_write;
	assign wb_allin = !wb_valid || wb_ready_go;
	
always @(posedge clk or negedge rst_) begin
	if (!rst_) begin
		wb_valid <= 1'b0;		
	end
	else if (wb_allin) begin
		wb_valid <= ex_valid_ns;
	end
end

always@(posedge clk)begin
	if (wb_ready_go) begin 
		wb_pc <= ex_pc;
	end
end

wire [3:0] rwen_hit;
wire rwen_hit_ok;
/*always@(*)begin
    rwen_hit[3] = ~((~store_buffer_search_rwen [3]) & (store_buffer_load_data_rwen [3]));
    rwen_hit[2] = ~((~store_buffer_search_rwen [2]) & (store_buffer_load_data_rwen [2]));
    rwen_hit[1] = ~((~store_buffer_search_rwen [1]) & (store_buffer_load_data_rwen [1]));
    rwen_hit[0] = ~((~store_buffer_search_rwen [0]) & (store_buffer_load_data_rwen [0]));
    rwen_hit_ok = & rwen_hit;
end*/
assign rwen_hit_ok = (store_buffer_search_rwen == store_buffer_load_data_rwen);//20190801biang

	
always@(*)begin
	if(inst0_retire_enable)begin
		if(inst0_load_store_detect == 2'b00)            inst0_ready_write = 1'b1;
		else if(inst0_load_detect)                      inst0_ready_write = load_data_seletc_valid;
		else if((inst0_store_detect)&&(!inst0_uncache)) inst0_ready_write = store_buffer_allow_in;
		else if((inst0_store_detect)&&( inst0_uncache)) inst0_ready_write = store_uncache_data_ok;
		else                                            inst0_ready_write = 1'b0;
	end
	else begin
		inst0_ready_write = 1'b0;
	end

	if(inst1_retire_enable)begin
		if(inst1_load_store_detect == 2'b00)            inst1_ready_write = 1'b1;
		else if(inst1_load_detect)                      inst1_ready_write = load_data_seletc_valid;
		else if((inst1_store_detect)&&(!inst1_uncache)) inst1_ready_write = store_buffer_allow_in;
		else if((inst1_store_detect)&&( inst1_uncache)) inst1_ready_write = store_uncache_data_ok;
		else                                            inst1_ready_write = 1'b0;
	end
	else if(!inst1_retire_enable &&(flush))begin
		inst1_ready_write = 1'b1;
	end
	else begin
	   inst1_ready_write = 1'b0;
	end
end

reg inst0_last_pc;
reg inst1_last_pc;

always@(posedge clk)begin
    inst0_last_pc <= ex_pc[31:0];
    inst1_last_pc <= ex_pc[63:32];
end

//----write register-file----//
always @(posedge clk)begin
	if((inst0_retire_enable)&&(inst1_retire_enable))begin
	
		if(inst0_load_store_detect == 2'b00)begin
			/*write_addr0 <= ((inst0_fu_select == 2'b00)&&(alu0_write_addr_valid))? alu0_write_addr : 
			               ((inst0_fu_select == 2'b01)&&(alu1_write_addr_valid))? alu1_write_addr : 5'b0;*/
			               
			write_addr0 <= (inst0_fu_select == 2'b00)? alu0_write_addr : 
			               (inst0_fu_select == 2'b01)? alu1_write_addr : 5'b0;			         
						  
			write_addr0_valid <= (alu0_write_addr!=5'b0)?((inst0_fu_select == 2'b00)&&(alu0_write_addr_valid))|((inst0_fu_select == 2'b01)&&(alu1_write_addr_valid)):'b0;
			
			/*write_addr0_valid <= (inst0_fu_select == 2'b00)|(inst0_fu_select == 2'b01);*/
			
			/*write_data0 <= ((inst0_fu_select == 2'b00)&&(alu0_write_addr_valid))? alu0_result :
			               ((inst0_fu_select == 2'b01)&&(alu1_write_addr_valid))? alu1_result : 32'b0;*/
						   
			write_data0 <= (inst0_fu_select == 2'b00)? alu0_result :
			               (inst0_fu_select == 2'b01)? alu1_result : 32'b0;			
		end
		else if(inst0_load_detect)begin
			/*write_addr0 <= ((inst0_fu_select == 2'b00)&&(alu0_write_addr_valid))? alu0_write_addr : 
			               ((inst0_fu_select == 2'b01)&&(alu1_write_addr_valid))? alu1_write_addr :5'b0;*/

			write_addr0 <= (inst0_fu_select == 2'b00)? alu0_write_addr : 
			               (inst0_fu_select == 2'b01)? alu1_write_addr : 5'b0;	
						   
			write_addr0_valid <= (nextstate == `IDLE)? load_data_seletc_valid : 1'b0;
			
			write_data0       <= load_data_select;
		end
		else begin
			write_addr0       <= 5'b0;
			write_addr0_valid <= 1'b0;
			write_data0       <= 32'b0;
		end		
		
		if(inst1_load_store_detect == 2'b00)begin	
			/*write_addr1 <= ((inst1_fu_select == 2'b00)&&(alu0_write_addr_valid))? alu0_write_addr : 
			               ((inst1_fu_select == 2'b01)&&(alu1_write_addr_valid))? alu1_write_addr : 5'b0;*/
						  
			write_addr1 <= (inst1_fu_select == 2'b00)? alu0_write_addr : 
			               (inst1_fu_select == 2'b01)? alu1_write_addr :5'b0;

			write_addr1_valid <= (alu1_write_addr!=5'b0 && inst1_fu_select == 2'b00)?alu0_write_addr_valid:
			                     (alu1_write_addr!=5'b0 && inst1_fu_select == 2'b01)?alu1_write_addr_valid:'b0;
			
			/*write_addr1_valid <= (inst1_fu_select == 2'b00)|(inst1_fu_select == 2'b01);*/
			
			/*write_data1 <= ((inst1_fu_select == 2'b00)&&(alu0_write_addr_valid))? alu0_result :
			               ((inst1_fu_select == 2'b01)&&(alu1_write_addr_valid))? alu1_result : 32'b0;*/
						   
			write_data1 <= (inst1_fu_select == 2'b00)? alu0_result :
			               (inst1_fu_select == 2'b01)? alu1_result : 32'b0;						   
		end		
		else if(inst1_load_detect)begin
			/*write_addr1 <= ((inst1_fu_select == 2'b00)&&(alu0_write_addr_valid))? alu0_write_addr : 
			               ((inst1_fu_select == 2'b01)&&(alu1_write_addr_valid))? alu1_write_addr : 5'b0;*/
						  
			write_addr1 <= (inst1_fu_select == 2'b00)? alu0_write_addr : 
			               (inst1_fu_select == 2'b01)? alu1_write_addr :5'b0;
						  
			write_addr1_valid <= (nextstate == `IDLE)? load_data_seletc_valid : 1'b0;
			
			write_data1       <= load_data_select;
		end
		else begin
			write_addr1       <= 5'b0;
			write_addr1_valid <= 1'b0;
			write_data1       <= 32'b0;
		end
		
		write_hilo_enable <= ((inst1_fu_select == 2'b10)||(inst1_fu_select == 2'b11)||(inst0_fu_select == 2'b10)||(inst0_fu_select == 2'b11))? 1'b1 : 1'b0;
		write_hilo_data   <= (inst1_fu_select == 2'b10)? mul_result : 
						     (inst1_fu_select == 2'b11)? div_result : 
						     (inst0_fu_select == 2'b10)? mul_result : 
						     (inst0_fu_select == 2'b11)? div_result : 64'b0;
		
	end
	else if((inst0_retire_enable)&&(!inst1_retire_enable))begin
	    write_addr1       <= 5'b0;
		write_addr1_valid <= 1'b0;
		write_data1       <= 32'b0;
		if(inst0_load_store_detect == 2'b00)begin
			write_addr0 <= ((inst0_fu_select == 2'b00)&&(alu0_write_addr_valid))? alu0_write_addr : 
			               ((inst0_fu_select == 2'b01)&&(alu1_write_addr_valid))? alu1_write_addr : 5'b0;
						  
			write_addr0_valid <= ((inst0_fu_select == 2'b00)&&(alu0_write_addr_valid))|((inst0_fu_select == 2'b01)&&(alu1_write_addr_valid));
			
			write_data0 <= ((inst0_fu_select == 2'b00)&&(alu0_write_addr_valid))? alu0_result :
			               ((inst0_fu_select == 2'b01)&&(alu1_write_addr_valid))? alu1_result : 32'b0;
		end
		else if(inst0_load_detect)begin
			write_addr0 <= ((inst0_fu_select == 2'b00)&&(alu0_write_addr_valid))? alu0_write_addr : 
			               ((inst0_fu_select == 2'b01)&&(alu1_write_addr_valid))? alu1_write_addr : 5'b0;
						  
			write_addr0_valid <= (nextstate == `IDLE)? load_data_seletc_valid : 1'b0;
			
			write_data0       <= load_data_select;
		end
		else begin
			write_addr0       <= 5'b0;
			write_addr0_valid <= 1'b0;
			write_data0       <= 32'b0;
		end			
	
		write_hilo_enable <= ((inst0_fu_select == 2'b10)||(inst0_fu_select == 2'b11))? 1'b1 : 1'b0;
		write_hilo_data   <= (inst0_fu_select == 2'b10)? mul_result : 
						     (inst0_fu_select == 2'b11)? div_result : 64'b0;
			
	end
	else begin
		write_addr0       <= 5'b0;
		write_addr0_valid <= 1'b0;
		write_data0       <= 32'b0;
		
		write_addr1       <= 5'b0;
		write_addr1_valid <= 1'b0;
		write_data1       <= 32'b0;
		
		write_hilo_enable <= 1'b0;
		write_hilo_data   <= 64'b0;
	end
end




//----load and store detect----//
always@(posedge clk)begin
	if((inst0_retire_enable)&&(inst0_mtc0_detect))begin

		wb_cp0_wdata_0 <= (inst0_fu_select == 2'b00)? alu0_wr_data    : (inst0_fu_select == 2'b01)? alu1_wr_data    : 32'b0;
		wb_cp0_waddr_0 <= (inst0_fu_select == 2'b00)? alu0_write_addr : (inst0_fu_select == 2'b01)? alu1_write_addr : 5'b0;
		
	end
	else begin
		wb_cp0_wdata_0 <= 32'b0;
		wb_cp0_waddr_0 <= 5'b0;	
	end

	if((inst1_retire_enable)&&(inst1_mtc0_detect))begin
	
		wb_cp0_wdata_1 <= (inst1_fu_select == 2'b00)? alu0_wr_data    : (inst1_fu_select == 2'b01)? alu1_wr_data    : 32'b0;
		wb_cp0_waddr_1 <= (inst1_fu_select == 2'b00)? alu0_write_addr : (inst1_fu_select == 2'b01)? alu1_write_addr : 5'b0;
		
	end
	else begin
		wb_cp0_wdata_1 <= 32'b0;
		wb_cp0_waddr_1 <= 5'b0;	
	end

	wb_cp0_we <= (inst0_exc_detect || inst1_exc_detect)?1'b0:((inst0_retire_enable)&&(inst0_mtc0_detect))? 1'b1 : ((inst1_retire_enable)&&(inst1_mtc0_detect))? 1'b1 : 1'b0;
end



always @(*)begin
	case (inst0_op)
		`INSN_LB  : inst0_load_store_detect = 2'b01;//01 <- load 
		`INSN_LBU : inst0_load_store_detect = 2'b01;//10 <- store
		`INSN_LH  : inst0_load_store_detect = 2'b01;
		`INSN_LHU : inst0_load_store_detect = 2'b01;
		`INSN_LW  : inst0_load_store_detect = 2'b01;
		`INSN_SB  : inst0_load_store_detect = 2'b10;
		`INSN_SH  : inst0_load_store_detect = 2'b10;
		`INSN_SW  : inst0_load_store_detect = 2'b10;
		default   : inst0_load_store_detect = 2'b00;
	endcase
	
	case (inst1_op)
		`INSN_LB  : inst1_load_store_detect = 2'b01;//01 <- load 
		`INSN_LBU : inst1_load_store_detect = 2'b01;//10 <- store
		`INSN_LH  : inst1_load_store_detect = 2'b01;
		`INSN_LHU : inst1_load_store_detect = 2'b01;
		`INSN_LW  : inst1_load_store_detect = 2'b01;
		`INSN_SB  : inst1_load_store_detect = 2'b10;
		`INSN_SH  : inst1_load_store_detect = 2'b10;
		`INSN_SW  : inst1_load_store_detect = 2'b10;
		default   : inst1_load_store_detect = 2'b00;
	endcase
end



assign load_pc_now =  (((inst0_load_detect) && (inst0_fu_select == 2'b00))||((inst1_load_detect) && (inst1_fu_select == 2'b00)))? ex_pc[31:0]  :  
		                               (((inst0_load_detect) && (inst0_fu_select == 2'b01))||((inst1_load_detect) && (inst1_fu_select == 2'b01)))? ex_pc[63:32]   : 32'b0;

assign inst0_load_cache = ((inst0_retire_enable)&&(inst0_load_detect)&&(!inst0_uncache));
assign inst1_load_cache = ((inst1_retire_enable)&&(inst1_load_detect)&&(!inst1_uncache));

assign 	state_change 		= (state != nextstate);	

	always @ (posedge clk) begin
		if(!rst_) begin
			state <= `IDLE;
		end
		else if (state_change) begin
			state <= nextstate;
		end
	end

reg new_in;
always@(posedge clk)begin
    if(!rst_ | flush)begin
        new_in <= 1'b0;
    end
    else if((ex_valid_ns) && (wb_allin))begin
        new_in <= 1'b1;
    end
    else begin
         new_in <= 1'b0;
    end
end


	always @(*) begin
		case (state)
			`IDLE    	     : nextstate =	((inst0_load_cache || inst1_load_cache)&& (new_in))? `SB_SEARCH_BEGIN : `IDLE;
			`SB_SEARCH_BEGIN : nextstate =  `SB_SEARCH;
			`SB_SEARCH       : nextstate = ((store_buffer_hit) && (rwen_hit_ok))? `IDLE : ((store_buffer_hit) && (!rwen_hit_ok))? `WAIT_SB_EMPTY :`CACHE_SEARCH;
			`WAIT_SB_EMPTY   : nextstate = (store_buffer_is_empty)? `CACHE_SEARCH : `WAIT_SB_EMPTY;
			`CACHE_SEARCH    : nextstate = (load_mem_data_ok)? `IDLE : `CACHE_SEARCH;
			default		     : nextstate = `IDLE;
		endcase
	end
	


//----load data from mem or cache----//
always @(posedge clk)begin//----store_cache_type----//
    if(!rst_)begin
 		store_buffer_load_addr      <= 32'b0;
		store_buffer_search_enanble <= 1'b0;      
		inst_load_pc                <=  32'b0;
		store_buffer_search_rwen    <=4'b0;
    end
	else if(nextstate == `SB_SEARCH_BEGIN )begin
		store_buffer_load_addr      <= (((inst0_load_detect) && (inst0_fu_select == 2'b00))||((inst1_load_detect) && (inst1_fu_select == 2'b00)))? alu0_result  :  
		                               (((inst0_load_detect) && (inst0_fu_select == 2'b01))||((inst1_load_detect) && (inst1_fu_select == 2'b01)))? alu1_result  : 32'b0;
		store_buffer_search_enanble <= 1'b1;
		
		store_buffer_search_rwen    <= (((inst0_load_detect) && (inst0_fu_select == 2'b00))||((inst1_load_detect) && (inst1_fu_select == 2'b00)))? alu0_ex_rwen  :  
		                               (((inst0_load_detect) && (inst0_fu_select == 2'b01))||((inst1_load_detect) && (inst1_fu_select == 2'b01)))? alu1_ex_rwen  : 32'b0;
		
		inst_load_pc                <= (((inst0_load_detect) && (inst0_fu_select == 2'b00))||((inst1_load_detect) && (inst1_fu_select == 2'b00)))? ex_pc[31:0]  :  
		                               (((inst0_load_detect) && (inst0_fu_select == 2'b01))||((inst1_load_detect) && (inst1_fu_select == 2'b01)))? ex_pc[63:32]   : 32'b0;
	end
	else if(nextstate == `IDLE )begin
		store_buffer_load_addr      <= 32'b0;
		store_buffer_search_enanble <= 1'b0;
		inst_load_pc                <=  32'b0;
		store_buffer_search_rwen    <=4'b0;
	end
end



always@(posedge clk)begin
	if(!rst_)begin
		load_mem_addr   <= 32'b0;
		load_mem_rwen   <= 4'b0;
		load_mem_rw     <= 1'b0;
		load_mem_en     <= 1'b0;
		load_uncache_en <= 1'b0;
	end
	else if(nextstate == `CACHE_SEARCH)begin
		load_mem_addr   <= (((inst0_load_detect) && (inst0_fu_select == 2'b00))||((inst1_load_detect) && (inst1_fu_select == 2'b00)))? alu0_result  :  
		                   (((inst0_load_detect) && (inst0_fu_select == 2'b01))||((inst1_load_detect) && (inst1_fu_select == 2'b01)))? alu1_result  : 32'b0;
		load_mem_rwen   <= (inst0_fu_select == 2'b00 || inst1_fu_select == 2'b00)? alu0_ex_rwen     : (inst0_fu_select == 2'b01 || inst1_fu_select == 2'b01)? alu1_ex_rwen     : 4'b0;
		load_mem_rw     <= 1'b0;
		load_mem_en     <= 1'b1;
		load_uncache_en <= 1'b0;
	end
	else if((inst0_load_detect & inst0_uncache) | (inst1_load_detect & inst1_uncache) )begin
		load_mem_addr   <= (((inst0_load_detect) && (inst0_fu_select == 2'b00))||((inst1_load_detect) && (inst1_fu_select == 2'b00)))? alu0_result  :  
		                   (((inst0_load_detect) && (inst0_fu_select == 2'b01))||((inst1_load_detect) && (inst1_fu_select == 2'b01)))? alu1_result  : 32'b0;
		load_mem_rwen   <= (inst0_fu_select == 2'b00 || inst1_fu_select == 2'b00)? alu0_ex_rwen     : (inst0_fu_select == 2'b01 || inst1_fu_select == 2'b01)? alu1_ex_rwen     : 4'b0;
		load_mem_rw     <= 1'b0;
		load_mem_en     <= 1'b0;
		load_uncache_en <= 1'b1;
	end
	else begin
		load_mem_addr   <= 32'b0;
		load_mem_rwen   <= 4'b0;
		load_mem_rw     <= 1'b0;
		load_mem_en     <= 1'b0;
		load_uncache_en <= 1'b0;
	end
end


always@(*)begin
	if((inst0_load_detect)||(inst1_load_detect))begin
		load_data = (store_buffer_hit && store_buffer_load_data_valid)? store_buffer_load_data : (load_mem_data_ok && (!inst0_uncache && !inst1_uncache))? load_mem_rd_data : (store_uncache_data_ok &&(inst0_uncache || inst1_uncache))? load_uncache_rd_data : 32'b0;
	end
	else begin
		load_data = 32'b0;
	end
end

always@(*)begin
	load_data_seletc_valid = (store_buffer_hit && store_buffer_load_data_valid && rwen_hit_ok)? 1'b1 : (load_mem_data_ok && (!inst0_uncache && !inst1_uncache))?  1'b1  : (store_uncache_data_ok &&(inst0_uncache || inst1_uncache))?  1'b1  : 1'b0;
end
    assign load_data_bypass_en = load_data_seletc_valid;
/*
always @(posedge clk)begin
	if((inst0_load_detect)||(inst1_load_detect))begin
		wb_allin <= (store_buffer_hit && store_buffer_load_data_valid)? 1'b1 : (load_mem_data_ok && load_mem_en)? 1'b1 : (load_mem_data_ok )?1'b1 : 1'b0;
	end
	else if ((inst0_store_detect && (!inst0_uncache))||(inst1_store_detect && (!inst1_uncache)))begin
		wb_allin <= store_buffer_allow_in;
	end
	else if((inst0_store_detect && inst0_uncache)||(inst1_store_detect && inst1_uncache))begin
		wb_allin <= store_uncache_data_ok;
	end
	else begin
		wb_allin <= 1'b1;
	end
end
*/



//----select data----//
/*always @(*)begin

	if((inst0_retire_enable)&&(inst0_load_detect))begin
		case (inst0_op)
			`INSN_LB  : load_data_select = {{24{load_data[7]}},load_data[7:0]};
			`INSN_LBU : load_data_select = {24'b0,load_data[7:0]};
			`INSN_LH  : load_data_select = {{16{load_data[15]}},load_data[15:0]};
			`INSN_LHU : load_data_select = {16'b0,load_data[15:0]};
			`INSN_LW  : load_data_select = load_data;
			default   : load_data_select = load_data;
		endcase
	end
	else if((inst1_retire_enable)&&(inst1_load_detect))begin
		case (inst1_op)
			`INSN_LB  : load_data_select = {{24{load_data[7]}},load_data[7:0]};
			`INSN_LBU : load_data_select = {24'b0,load[7:0]};
			`INSN_LH  : load_data_select = {{16{load_data[15]}},load_data[15:0]};
			`INSN_LHU : load_data_select = {16'b0,load_data[15:0]};
			`INSN_LW  : load_data_select = load_data;
			default   : load_data_select = load_data;
		endcase
	end
	else begin
		load_data_select = load_data;
	end
end*/  // by ysr 20190731
reg [31:0] store_buffer_load_addr_reg;//by  ysr 0731
always @ (posedge clk)begin
   store_buffer_load_addr_reg   <= store_buffer_load_addr; 
end



assign wb_load_bypass_addr = ((store_buffer_hit || load_mem_data_ok || store_uncache_data_ok )&&(inst0_load_detect && inst0_fu_select == 2'b00))? alu0_write_addr :
                             ((store_buffer_hit || load_mem_data_ok || store_uncache_data_ok )&&(inst0_load_detect && inst0_fu_select == 2'b01))? alu1_write_addr :
                             ((store_buffer_hit || load_mem_data_ok || store_uncache_data_ok )&&(inst1_load_detect && inst1_fu_select == 2'b00))? alu0_write_addr :
                             ((store_buffer_hit || load_mem_data_ok || store_uncache_data_ok )&&(inst1_load_detect && inst1_fu_select == 2'b01))? alu1_write_addr : 5'b0;




always @(*)begin

	if((inst0_retire_enable)&&(inst0_load_detect))begin
		case (inst0_op)
			`INSN_LB  : load_data_select = (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b00))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b00)))?{{24{load_data[7]}},load_data[7:0]}:
			                               (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b01))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b01)))?{{24{load_data[15]}},load_data[15:8]}:
			                               (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b10))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b10)))?{{24{load_data[23]}},load_data[23:16]}:
			                                {{24{load_data[31]}},load_data[31:24]};
			`INSN_LBU : load_data_select = (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b00))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b00)))?{24'b0,load_data[7:0]}:
			                               (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b01))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b01)))?{24'b0,load_data[15:8]}:
			                               (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b10))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b10)))?{24'b0,load_data[23:16]}:
			                                {24'b0,load_data[31:24]};
			`INSN_LH  : load_data_select = (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b00))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b00)))?{{16{load_data[15]}},load_data[15:0]}:
			                               {{16{load_data[31]}},load_data[31:16]};
			`INSN_LHU : load_data_select = (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b00))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b00)))?{16'b0,load_data[15:0]}:
			                                {16'b0,load_data[31:16]};
			`INSN_LW  : load_data_select = load_data;
			default   : load_data_select = load_data;
		endcase
	end
	else if((inst1_retire_enable)&&(inst1_load_detect))begin
		case (inst1_op)
			`INSN_LB  : load_data_select = (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b00))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b00)))?{{24{load_data[7]}},load_data[7:0]}:
			                               (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b01))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b01)))?{{24{load_data[15]}},load_data[15:8]}:
			                               (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b10))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b10)))?{{24{load_data[23]}},load_data[23:16]}:
			                                {{24{load_data[31]}},load_data[31:24]};
			`INSN_LBU : load_data_select = (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b00))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b00)))?{24'b0,load_data[7:0]}:
			                               (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b01))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b01)))?{24'b0,load_data[15:8]}:
			                               (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b10))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b10)))?{24'b0,load_data[23:16]}:
			                                {24'b0,load_data[31:24]};
			`INSN_LH  : load_data_select = (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b00))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b00)))?{{16{load_data[15]}},load_data[15:0]}:
			                               {{16{load_data[31]}},load_data[31:16]};
			`INSN_LHU : load_data_select = (((!store_buffer_hit)&&(load_mem_addr[1:0]==2'b00))|((store_buffer_hit)&&(store_buffer_load_addr_reg[1:0]==2'b00)))?{16'b0,load_data[15:0]}:
			                                {16'b0,load_data[31:16]};
			`INSN_LW  : load_data_select = load_data;
			default   : load_data_select = load_data;
		endcase
	end
	else begin
		load_data_select = load_data;
	end
end

`define STORE_UNCACHE_IDLE  2'b00
`define STORE_UNCACHE_BEGIN 2'B01

reg [1:0] store_uncache_state;
reg [1:0] store_uncache_nextstate;
//----data to cache----//

wire inst0_store_uncache;
wire inst1_store_uncache;

assign inst0_store_uncache = ((inst0_retire_enable)&&(inst0_store_detect)&&(inst0_uncache));
assign inst1_store_uncache = ((inst1_retire_enable)&&(inst1_store_detect)&&(inst1_uncache));

reg [31:0] last_store_uncache_pc;
wire [31:0] now_store_uncache_pc;

assign now_store_uncache_pc =  (((inst0_store_uncache) && (inst0_fu_select == 2'b00))||((inst1_store_uncache) && (inst1_fu_select == 2'b00)))? ex_pc[31:0]  :  
		                       (((inst0_store_uncache) && (inst0_fu_select == 2'b01))||((inst1_store_uncache) && (inst1_fu_select == 2'b01)))? ex_pc[63:32]   : 32'b0;

always@(posedge clk)begin
   if(!rst_)begin
      store_uncache_state <= `STORE_UNCACHE_IDLE;
   end 
   else if(store_uncache_state != store_uncache_nextstate)begin
      store_uncache_state <= store_uncache_nextstate;
   end
end

always@(*)begin
    case(store_uncache_state)
            `STORE_UNCACHE_IDLE  : store_uncache_nextstate = ((inst0_store_uncache || inst1_store_uncache)&&(now_store_uncache_pc != last_store_uncache_pc))?  `STORE_UNCACHE_BEGIN : `STORE_UNCACHE_IDLE;
            `STORE_UNCACHE_BEGIN : store_uncache_nextstate = (store_uncache_data_ok)? `STORE_UNCACHE_IDLE : `STORE_UNCACHE_BEGIN;
            default              : store_uncache_nextstate = `STORE_UNCACHE_IDLE;
    endcase



end

//ysr0804
/*reg [31:0] alu0_result_reg;
reg [31:0] alu0_wr_data_reg;
reg [3:1]  alu0_ex_rwen_reg;
reg [31:0] alu1_result_reg;
reg [31:0] alu1_wr_data_reg;
reg [3:1]  alu1_ex_rwen_reg;
always@ (posedge clk)begin
    alu0_result_reg     <=  alu0_result;
    alu0_wr_data_reg    <=  alu0_wr_data;
    alu0_ex_rwen_reg    <=  alu0_ex_rwen;
    alu1_result_reg     <=  alu1_result;
    alu1_wr_data_reg    <=  alu1_wr_data;
    alu1_ex_rwen_reg    <=  alu1_ex_rwen;
end*/


always@(posedge clk)begin
    if(!rst_)begin
		store_uncache_addr    <= 32'b0;
		store_uncache_data    <= 32'b0;
		store_uncache_rwen    <= 4'b0;
		store_uncache_rw      <= 1'b0;
		store_uncache_en      <= 1'b0;	
		last_store_uncache_pc <=32'b0;
	end
	
//	else if(store_uncache_nextstate == `STORE_UNCACHE_BEGIN )begin
        else if((store_uncache_nextstate == `STORE_UNCACHE_BEGIN)&&(inst0_store_uncache|inst1_store_uncache) )begin
		store_uncache_addr    <= ((inst0_fu_select == 2'b00 && inst0_store_uncache) || (inst1_fu_select == 2'b00 && inst1_store_uncache))? alu0_result      : ((inst0_fu_select == 2'b01 && inst0_store_uncache) || (inst1_fu_select == 2'b01 && inst1_store_uncache))? alu1_result      : 32'b0;
		store_uncache_data    <= ((inst0_fu_select == 2'b00 && inst0_store_uncache) || (inst1_fu_select == 2'b00 && inst1_store_uncache))? alu0_wr_data     : ((inst0_fu_select == 2'b01 && inst0_store_uncache) || (inst1_fu_select == 2'b01 && inst1_store_uncache))? alu1_wr_data     : 32'b0;
		store_uncache_rwen    <= ((inst0_fu_select == 2'b00 && inst0_store_uncache) || (inst1_fu_select == 2'b00 && inst1_store_uncache))? alu0_ex_rwen     : ((inst0_fu_select == 2'b01 && inst0_store_uncache) || (inst1_fu_select == 2'b01 && inst1_store_uncache))? alu1_ex_rwen     : 4'b0;
		store_uncache_rw      <= 1'b1;
		store_uncache_en      <= 1'b1;
		last_store_uncache_pc <= now_store_uncache_pc;
	end
	else if(store_uncache_nextstate == `STORE_UNCACHE_IDLE) begin
		store_uncache_addr    <= 32'b0;
		store_uncache_data    <= 32'b0;
		store_uncache_rwen    <= 4'b0;
		store_uncache_rw      <= 1'b0;
		store_uncache_en      <= 1'b0;	
		last_store_uncache_pc <=32'b0;
	end

end 
/*
    assign  store_uncache_addr  =  ( (inst0_retire_enable)&&(inst0_store_detect)&&(inst0_uncache)&&(~ store_uncache_data_ok))?alu0_result:'b0;
    assign  store_uncache_data  =  ( (inst0_retire_enable)&&(inst0_store_detect)&&(inst0_uncache)&&(~ store_uncache_data_ok))?alu0_wr_data:'b0;
    assign  store_uncache_rwen  =  ( (inst0_retire_enable)&&(inst0_store_detect)&&(inst0_uncache)&&(~ store_uncache_data_ok))?alu0_ex_rwen:'b0;
    assign  store_uncache_rw   =  1'b1;
    assign  store_uncache_en   =  ( (inst0_retire_enable)&&(inst0_store_detect)&&(inst0_uncache)&&(~ store_uncache_data_ok))?1'b1:1'b0;*/



//----data to store_buffer----//
always @(posedge clk)begin
	if(!rst_)begin
		in_store_data    <= 32'b0;
		in_store_addr    <= 32'b0;
		in_store_valid   <= 1'b0;
		in_store_pc      <= 32'b0;		
	end
	else if((inst0_retire_enable)&&(inst0_store_detect)&&(!inst0_uncache)&&(wb_ready_go))begin
		in_store_data    <= (inst0_fu_select == 2'b00)? alu0_wr_data     : (inst0_fu_select == 2'b01)? alu1_wr_data     : 32'b0;
		in_store_addr    <= (inst0_fu_select == 2'b00)? alu0_result      : (inst0_fu_select == 2'b01)? alu1_result      : 32'b0;
		in_store_rwen    <= (inst0_fu_select == 2'b00)? alu0_ex_rwen     : (inst0_fu_select == 2'b01)? alu1_ex_rwen     : 4'b0;
		//in_store_uncache <= (inst0_fu_select == 2'b00)? alu0_uncacheable : (inst0_fu_select == 2'b01)? alu1_uncacheable : 1'b0;
		in_store_valid   <= 	1'b1;
		in_store_pc      <= (inst0_fu_select == 2'b00)? ex_pc[31:0]      : (inst0_fu_select == 2'b01)? ex_pc[63:32]     : 32'b0;
	end
	else if((inst1_retire_enable)&&(inst1_store_detect)&&(!inst1_uncache)&&(wb_ready_go))begin
		in_store_data    <= (inst1_fu_select == 2'b00)? alu0_wr_data     : (inst1_fu_select == 2'b01)? alu1_wr_data     : 32'b0;
		in_store_addr    <= (inst1_fu_select == 2'b00)? alu0_result      : (inst1_fu_select == 2'b01)? alu1_result      : 32'b0;
		in_store_rwen    <= (inst1_fu_select == 2'b00)? alu0_ex_rwen     : (inst1_fu_select == 2'b01)? alu1_ex_rwen     : 4'b0;
	//	in_store_uncache <= (inst1_fu_select == 2'b00)? alu0_uncacheable : (inst1_fu_select == 2'b01)? alu1_uncacheable : 1'b0;
		in_store_valid   <= 	1'b1;
		in_store_pc      <= (inst0_fu_select == 2'b00)? ex_pc[31:0]      : (inst0_fu_select == 2'b01)? ex_pc[63:32]     : 32'b0;
	end
	else begin
		in_store_data    <= 32'b0;
		in_store_addr    <= 32'b0;
		in_store_rwen    <= 4'b0;
//in_store_uncache <= 1'b0;
		in_store_valid   <= 1'b0;
		in_store_pc      <= 32'b0;
	end

end

endmodule

`undef IDLE