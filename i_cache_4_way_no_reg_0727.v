/********** Common header file **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** Individual header file **********/
`include "cpu.h"
`include "each_module.h"



/********* Internal define ************/
`define TagLen			17:0
`define	IndexLen		7:0
`define	BlockLen		3:0
`define	ByteLen			1:0
`define	InsnGroupLen 	1:0
`define	TagLoc			31:14
`define	IndexLoc		13:6	// 256 entries in one way cache
`define	BlockLoc		5:2		// 16 words per block
`define	ByteLoc			1:0		// 4 bytes per word
`define    InsnGroupLoc 5:4	// which insn group will be chose


`define SixtWordDataBus 511:0
`define SixtBlockBus	15:0
`define FOUR_WORD_DATA_W 128
`define	WORD_NUM		512
`define	IndexNum		255:0

`define	StateBus		1:0	
`define	STATE_IDLE      2'b00
`define STATE_NORMAL    2'b01
`define	STATE_MISS 		2'b10
//`define	STATE_FULL 2'b10
`define MissAddrLoc		31:6	// miss handle addr
`define	MISS_ZERO_NUM	6	// number of zero-fill for miss handle addr	
`define CounterBus 		4:0		// the counter for loading
`define	ReplaceBus 		1:0		// to choose which way to be replaced
`define REPLACE_WAY_0 	2'b00
`define REPLACE_WAY_1 	2'b01
`define REPLACE_WAY_2 	2'b10
`define REPLACE_WAY_3 	2'b11

module i_cache_4_way_no_reg (
	/********** Global signal **********/
	input wire clk,
	input wire reset,
	input wire flus,
	
	
	/********** CPU interface ***********/
	//if
	input   wire	[`WordAddrBus]		cpu_rd_addr,
	input  wire    [`WordAddrBus]      	cpu_rd_addr_virtual,
	input   wire   						cpu_rw,		// 0:read from cache / 1:write to cache
	input   wire   	[`WriteEnBus]		cpu_rwen,
	output  reg   	[`FourWordDataBus]	cpu_rd_data,
	//output  wire  	[`FourWordDataBus]	cpu_rd_data,
	output  reg    	[`WordAddrBus]		cpu_rd_pc,	//for virtual addr
	input  wire     [1:0]               if_icache_delot_en,
	output reg      [1:0]               icache_ib_delot_en,
	input   wire  flag,
	//cpu state control
 
	//output	wire						cpu_if_addr_ok,
	//output	wire						cpu_if_data_ok,
	output	reg						cpu_if_addr_ok,
	output	reg						cpu_if_data_ok,
	//bp
	input	wire   	[`PtabAddrBus]		bp_icache_ptab,
	input  wire    [`WordAddrBus]      bp_icache_branch_pc,
	output  reg    	[`PtabAddrBus]		icache_ib_ptab,
	output  reg     [`WordAddrBus]      icache_ib_branch_pc,
	//output  wire    [`PtabAddrBus]		icache_ib_ptab,
	
	//handshake
	input	wire   						if_valid_ns,
	input   wire                       ib_allin,
	output	wire					        icache_allin,
	output	reg						    icache_ns_reg,
	//output	wire						    icache_ns,
	
	
	/********** Bus interface **********/
	input	wire	[`WordDataBus]		bus_rd_data,	// read data from bus
	input	wire						bus_data_ready,	// data from bus is ready
	output	reg							bus_rw,			// 0:read from bus / 1:write to bus
	output	reg		[`WordAddrBus]		bus_rd_addr,	// read addr to bus
	output	reg							bus_as,			// select bus to read
	input   wire    nxstate_ins_read
);





	/********** Internal signal **********/
	//internal signal for handshake
	
	reg  	[`FourWordDataBus]	cpu_rd_data_i;
	//wire   	[`FourWordDataBus]	cpu_rd_data_i;
	wire    [`PtabAddrBus]		icache_ib_ptab_i;
	wire    [`WordAddrBus]     icache_ib_branch_pc_i;
	//reg						bus_rw_i;
	//reg						bus_rd_addr_i;
	wire      [1:0]             if_icache_delot_en_i;
	//wire						data_ok;
	wire						icache_ib_ready_go;
	wire						pip_stall;
	reg                        	icache_valid;
	wire						    icache_ns;
	reg    [`WordAddrBus]	    cpu_rd_pc_i;
	//reg                        cpu_if_addr_ok_i;
	//reg                        cpu_if_data_ok_i;
	wire                        cpu_if_addr_ok_i;
	wire                        cpu_if_data_ok_i;
	//wire                       icache_allin_i;
	//wire                       icache_ns_i;
	
	
	
	wire	[`TagLen]		addr_tag;
	//reg		[`TagLen]		addr_tag_reg;
	wire	[`IndexLen]		addr_index;
	reg		[`IndexLen]		addr_index_reg;
	wire	[`IndexLen]		addr_index_mux;		//hit:wire;miss,full:reg
	wire	[`BlockLen]		addr_block_offset;	
	wire	[`ByteLen]		addr_byte_offset;	
	wire	[`InsnGroupLen]	addr_ingp_offset;	
	//reg		[`InsnGroupLen]	addr_ingp_offset_reg;	
	
	
	//reg		[`WordAddrBus]	cpu_rd_addr_reg;
	//reg		[`WriteEnBus]	cpu_rwen_reg;
	
	
	
	wire					cache_en;
	//reg						cache_en_reg;
	//wire					cache_en_mux;
	wire	[`SixtWordDataBus]	cache_data_read_0;
	wire	[`SixtWordDataBus]	cache_data_read_1;
	wire	[`SixtWordDataBus]	cache_data_read_2;
	wire	[`SixtWordDataBus]	cache_data_read_3;
	wire	[`FourWordDataBus]	cache_data_read_block_0;
	wire	[`FourWordDataBus]	cache_data_read_block_1;
	wire	[`FourWordDataBus]	cache_data_read_block_2;
	wire	[`FourWordDataBus]	cache_data_read_block_3;
	wire	[`FourWordDataBus]	cache_data_read_cpu_rd;
	
	
	wire					tag_wr_en_0;		// enable to write cache tag way
	wire					tag_wr_en_1;		// enable to write cache tag way
	wire					tag_wr_en_2;		// enable to write cache tag way
	wire					tag_wr_en_3;		// enable to write cache tag way
	wire	[`TagLen]		cache_tag_0;		// cache tag read from way 0
	wire	[`TagLen]		cache_tag_1;		// cache tag read from way 1
	wire	[`TagLen]		cache_tag_2;		// cache tag read from way 2
	wire	[`TagLen]		cache_tag_3;		// cache tag read from way 3
	wire	[`SixtBlockBus]	cache_bus_en_eachword_0;
	wire	[`SixtBlockBus]	cache_bus_en_eachword_1;
	wire	[`SixtBlockBus]	cache_bus_en_eachword_2;
	wire	[`SixtBlockBus]	cache_bus_en_eachword_3;
	wire					cache_hit;
	wire					cache_hit_0;		// hit signal of way 0
	wire					cache_hit_1;		// hit signal of way 1
	wire					cache_hit_2;		// hit signal of way 2
	wire					cache_hit_3;		// hit signal of way 3
	
	
	reg		[`IndexNum]		ram_valid_0;		// ram to store valid bit of way 0  
	reg		[`IndexNum]		ram_valid_1;		// ram to store valid bit of way 1
	reg		[`IndexNum]		ram_valid_2;		// ram to store valid bit of way 2
	reg		[`IndexNum]		ram_valid_3;		// ram to store valid bit of way 3
	//wire                   cache_way_all_valid;
	
	reg		[`IndexNum]		ram_used_0;
	reg		[`IndexNum]		ram_used_1;
	reg		[`IndexNum]		ram_used_2;
	
	//wire   [`IndexNum]    cache_hit_0_index;
	//reg    [`IndexNum]     cache_hit_1_index;
	//reg    [`IndexNum]     cache_hit_2_index;
	//reg    [`IndexNum]     cache_hit_3_index;
	
	wire	[`ReplaceBus]	replace_chioce;		// to choose which way to be replaced
	
	wire					nxstate_normal;
	wire					nxstate_miss;
	wire					nxstate_idle;
	wire					state_change;
	wire					state_idle;
	wire					state_normal;
	wire					state_miss;
	reg		[`StateBus]		state;
	reg		[`StateBus]		nextstate;
	
	//wire                   cache_full;
	
	reg		[`CounterBus]	icache_rd_mem_counter;
	wire                  	icache_rd_mem_counter_end;

	reg		[`WordAddrBus]	cpu_rd_virtual_addr_reg;
	reg					    icache_finish;
	wire					icache_start;
	reg    flus_reg;
	
	
	/********** assignment **********/
	//decode
	assign	addr_tag			=	cpu_rd_addr[`TagLoc];
	assign	addr_index			=	cpu_rd_addr[`IndexLoc];
	assign	addr_block_offset	=	cpu_rd_addr[`BlockLoc];
	assign	addr_byte_offset	=	cpu_rd_addr[`ByteLoc];
	assign	addr_ingp_offset	=	cpu_rd_addr[`InsnGroupLoc];
	
	
	assign      cache_en		=	((cpu_rw == `READ) && (cpu_rwen == `READ_WORD));
	assign		cache_hit 		= 	cache_hit_0 | cache_hit_1 | cache_hit_2 | cache_hit_3;
	assign		cache_hit_0		=	(addr_tag == cache_tag_0)&&(ram_valid_0[addr_index] == `ENABLE)&&(cpu_rwen == `READ_WORD); 
	assign		cache_hit_1		=	(addr_tag == cache_tag_1)&&(ram_valid_1[addr_index] == `ENABLE)&&(cpu_rwen == `READ_WORD); 
	assign		cache_hit_2		=	(addr_tag == cache_tag_2)&&(ram_valid_2[addr_index] == `ENABLE)&&(cpu_rwen == `READ_WORD); 
	assign		cache_hit_3		=	(addr_tag == cache_tag_3)&&(ram_valid_3[addr_index] == `ENABLE)&&(cpu_rwen == `READ_WORD);
	
	assign		cache_data_read_cpu_rd	=	(cache_hit_0	==	`ENABLE)?cache_data_read_block_0:
											(cache_hit_1	==	`ENABLE)?cache_data_read_block_1:
											(cache_hit_2	==	`ENABLE)?cache_data_read_block_2:
																		 cache_data_read_block_3;
	
	assign		cache_data_read_block_0	=	(addr_ingp_offset	==	2'b00)?cache_data_read_0[127:0]:
											(addr_ingp_offset	==	2'b01)?cache_data_read_0[255:128]:
											(addr_ingp_offset	==	2'b10)?cache_data_read_0[383:256]:
																			   cache_data_read_0[511:384];
	assign		cache_data_read_block_1	=	(addr_ingp_offset	==	2'b00)?cache_data_read_1[127:0]:
											(addr_ingp_offset	==	2'b01)?cache_data_read_1[255:128]:
											(addr_ingp_offset	==	2'b10)?cache_data_read_1[383:256]:
																			   cache_data_read_1[511:384];
	assign		cache_data_read_block_2	=	(addr_ingp_offset	==	2'b00)?cache_data_read_2[127:0]:
											(addr_ingp_offset	==	2'b01)?cache_data_read_2[255:128]:
											(addr_ingp_offset	==	2'b10)?cache_data_read_2[383:256]:
																			   cache_data_read_2[511:384];
	assign		cache_data_read_block_3	=	(addr_ingp_offset	==	2'b00)?cache_data_read_3[127:0]:
											(addr_ingp_offset	==	2'b01)?cache_data_read_3[255:128]:
											(addr_ingp_offset	==	2'b10)?cache_data_read_3[383:256]:
																			   cache_data_read_3[511:384];
	
	
	
	//miss
	assign replace_chioce 	= //(nxstate_normal)? replace_chioce:
	                          (~ram_valid_0[addr_index])? `REPLACE_WAY_0:
							  (~ram_valid_1[addr_index])? `REPLACE_WAY_1:
							  (~ram_valid_2[addr_index])? `REPLACE_WAY_2:
							  (~ram_valid_3[addr_index])? `REPLACE_WAY_3:
							  ((~ram_used_0[addr_index])&&(~ram_used_1[addr_index]))? `REPLACE_WAY_0:
							  ((~ram_used_0[addr_index])&&(ram_used_1[addr_index])) ? `REPLACE_WAY_1:
							  ((ram_used_0[addr_index])&&(~ram_used_2[addr_index])) ? `REPLACE_WAY_2:
																					  `REPLACE_WAY_3;
	/*assign replace_chioce 	= (nxstate_normal)? replace_chioce:
	                          (~ram_valid_0[addr_index_reg])? `REPLACE_WAY_0:
							  (~ram_valid_1[addr_index_reg])? `REPLACE_WAY_1:
							  (~ram_valid_2[addr_index_reg])? `REPLACE_WAY_2:
							  (~ram_valid_3[addr_index_reg])? `REPLACE_WAY_3:
							  ((~ram_used_0[addr_index_reg])&&(~ram_used_1[addr_index_reg]))? `REPLACE_WAY_0:
							  ((~ram_used_0[addr_index_reg])&&(ram_used_1[addr_index_reg])) ? `REPLACE_WAY_1:
							  ((ram_used_0[addr_index_reg])&&(~ram_used_2[addr_index_reg])) ? `REPLACE_WAY_2:
																					           `REPLACE_WAY_3;*/
	
	/*assign replace_chioce 	= (nxstate_normal)? replace_chioce:
	                          (~ram_valid_0[addr_index])? `REPLACE_WAY_0:
							  (~ram_valid_1[addr_index])? `REPLACE_WAY_1:
							  (~ram_valid_2[addr_index])? `REPLACE_WAY_2:
							  (~ram_valid_3[addr_index])? `REPLACE_WAY_3:
							  (~cache_line_age_0[addr_index])?*/
																							  
	assign	tag_wr_en_0		= ((icache_rd_mem_counter == 5'd1)&&(replace_chioce == `REPLACE_WAY_0));
	assign	tag_wr_en_1		= ((icache_rd_mem_counter == 5'd1)&&(replace_chioce == `REPLACE_WAY_1));
	assign	tag_wr_en_2		= ((icache_rd_mem_counter == 5'd1)&&(replace_chioce == `REPLACE_WAY_2));
	assign	tag_wr_en_3		= ((icache_rd_mem_counter == 5'd1)&&(replace_chioce == `REPLACE_WAY_3));
	
	assign	cache_bus_en_eachword_0	= (icache_rd_mem_counter == 5'd0)  ? 16'b0000_0000_0000_0001:
									  (icache_rd_mem_counter == 5'd1)  ? 16'b0000_0000_0000_0010:
									  (icache_rd_mem_counter == 5'd2)  ? 16'b0000_0000_0000_0100:
									  (icache_rd_mem_counter == 5'd3)  ? 16'b0000_0000_0000_1000:
									  (icache_rd_mem_counter == 5'd4)  ? 16'b0000_0000_0001_0000:
									  (icache_rd_mem_counter == 5'd5)  ? 16'b0000_0000_0010_0000:
									  (icache_rd_mem_counter == 5'd6)  ? 16'b0000_0000_0100_0000:
									  (icache_rd_mem_counter == 5'd7)  ? 16'b0000_0000_1000_0000:
									  (icache_rd_mem_counter == 5'd8)  ? 16'b0000_0001_0000_0000:
									  (icache_rd_mem_counter == 5'd9)  ? 16'b0000_0010_0000_0000:
									  (icache_rd_mem_counter == 5'd10) ? 16'b0000_0100_0000_0000:
									  (icache_rd_mem_counter == 5'd11) ? 16'b0000_1000_0000_0000:
									  (icache_rd_mem_counter == 5'd12) ? 16'b0001_0000_0000_0000:
									  (icache_rd_mem_counter == 5'd13) ? 16'b0010_0000_0000_0000:
									  (icache_rd_mem_counter == 5'd14) ? 16'b0100_0000_0000_0000:
									  (icache_rd_mem_counter == 5'd15) ? 16'b1000_0000_0000_0000:
																		 16'b0000_0000_0000_0000;
	
	assign	cache_bus_en_eachword_1	= cache_bus_en_eachword_0;
	assign	cache_bus_en_eachword_2 = cache_bus_en_eachword_0;
	assign	cache_bus_en_eachword_3 = cache_bus_en_eachword_0;
	
	//state machine
	
	//assign	nxstate_full		= (nextstate == `STATE_FULL);
	assign	nxstate_idle		= (nextstate == `STATE_IDLE);
	assign	nxstate_normal		= (nextstate == `STATE_NORMAL);
	assign	nxstate_miss		= (nextstate == `STATE_MISS);
	assign	state_idle			= (state	==	`STATE_IDLE);
	assign	state_normal		= (state	==	`STATE_NORMAL);
	assign	state_miss			= (state	==	`STATE_MISS);
	assign 	state_change 		= (state != nextstate);	
	
	always @ (posedge clk) begin
		
		cpu_rd_virtual_addr_reg <= cpu_rd_addr_virtual;
		
	end
	/*reg    addr_reg;//zhendui flus hou pc xiangtong de qingkaung
	always @ (posedge clk)begin
	   if(reset == `RESET_ENABLE)begin
	       addr_reg    <=  'b0;
	   end
       else if(icache_allin)begin
           addr_reg     <= cpu_rd_addr_virtual;
       end	       
	end*/
	
	
	assign	icache_start	=	(state_idle)&&(flag|(cpu_rd_virtual_addr_reg != cpu_rd_addr_virtual));
	
	always @ (posedge clk) begin
		if(reset==`RESET_ENABLE) begin
			icache_finish <= 'b0;
		end
		else if (state_normal&&cache_hit) begin
			icache_finish <= 1'b1;
		end
		else begin
		  icache_finish <= 1'b0;
		end
	end
	
	//state change(one)
	always @ (posedge clk) begin
		if(reset==`RESET_ENABLE) begin
			state <= `STATE_NORMAL;
		end
		else if (state_change) begin
			state <= nextstate;
		end
	end
	
	
	//(two) when it will  be full?????????????????????????????????????????????????????
	/*always @(*) begin
		case (state)
			`STATE_NORMAL : nextstate = ((cpu_rwen_reg != 4'b1111)? `STATE_NORMAL:
										(cache_hit)? `STATE_NORMAL:
										`STATE_MISS);
			`STATE_MISS	  : nextstate = (//(cache_hit)? `STATE_NORMAL:
			                             (cpu_rwen_reg != 4'b1111)? `STATE_NORMAL:
			                             (cache_way_all_valid)? `STATE_FULL:
			                             (cache_hit)? `STATE_NORMAL:
										`STATE_MISS);
			`STATE_FULL	  : nextstate = ((cpu_rwen_reg != 4'b1111)? `STATE_NORMAL:
										(cache_hit)? `STATE_NORMAL:
										`STATE_MISS);
			default		  : nextstate = `STATE_NORMAL;
		endcase
	end*/
	/*always @(*) begin
		case (state)
			`STATE_NORMAL : nextstate = ((cpu_rwen != 4'b1111)? `STATE_NORMAL:
										(cache_hit)? `STATE_NORMAL:
										`STATE_MISS);
			`STATE_MISS	  : nextstate = (//(cache_hit)? `STATE_NORMAL:
			                             (cpu_rwen != 4'b1111)? `STATE_NORMAL:
			                             //(cache_way_all_valid)? `STATE_FULL:
			                             (cache_hit)? `STATE_NORMAL:
										`STATE_MISS);
			default		  : nextstate = `STATE_NORMAL;
		endcase
	end*/
	always @(*) begin
		case (state)
			`STATE_IDLE	  : nextstate =	(icache_start)?`STATE_NORMAL : `STATE_IDLE;
			`STATE_NORMAL : nextstate = (cache_hit)?  ((icache_finish)?`STATE_IDLE : `STATE_NORMAL):
										`STATE_MISS;
			`STATE_MISS	  : nextstate = (cache_hit)? `STATE_NORMAL :
										`STATE_MISS;
			default		  : nextstate = `STATE_IDLE;
		endcase
	end
	
	
	/********** for External interface signal *********/
	// assign cpu_rd_data_i = (~flus)?cache_data_read_cpu_rd : 'b0;
	always @ (posedge clk)begin
	   if(reset == `RESET_ENABLE)begin
	      cpu_rd_data_i <= 'b0;
	   end
	   else if (flus|flus_reg)begin
	      cpu_rd_data_i <= 'b0;
	   end
	   else begin
	       cpu_rd_data_i <= cache_data_read_cpu_rd;
	   end
	end
	

	//for if  
	//assign cpu_if_addr_ok = (nxstate_normal) ? `ENABLE : `DISABLE;
	//assign cpu_if_data_ok = (cache_hit == `ENABLE);
	assign if_icache_delot_en_i    =  if_icache_delot_en;
	assign cpu_if_data_ok_i = (cache_hit == `ENABLE & nxstate_idle) ? `ENABLE : `DISABLE;
    assign cpu_if_addr_ok_i = (cache_hit == `ENABLE & nxstate_idle) ? `ENABLE : `DISABLE;
	/*always @(posedge clk) begin	
		if(reset == `RESET_ENABLE) begin
			cpu_if_data_ok_i <= `DISABLE;
			cpu_if_addr_ok_i <= `DISABLE;
		end
		else begin
			cpu_if_data_ok_i <= (cache_hit == `ENABLE & nxstate_normal) ? `ENABLE : `DISABLE;
			cpu_if_addr_ok_i <= (cache_hit == `ENABLE & nxstate_normal) ? `ENABLE : `DISABLE;
		end
	end*/
	
	
	//for bp  
	//assign     icache_ib_ptab_i    =   (nxstate_normal) ? bp_icache_ptab: 'b0;
	reg icache_finish_reg;
	always @ (posedge clk)begin
	   if(reset == `RESET_ENABLE)begin
	      icache_finish_reg <= 1'b0;
	   end
	    else begin
	      icache_finish_reg <= icache_finish;
	   end
	end
	
	always @ (posedge clk)begin
	   if(reset == `RESET_ENABLE)begin
	      icache_ns_reg <= 1'b0;
	   end
	   else if(flus_reg | flus)begin
	       icache_ns_reg   <= 0;
	   end
	   else if(icache_finish & (~icache_finish_reg))begin
	      icache_ns_reg <= icache_ns;
	   end
	   else if (!pip_stall)begin
	       icache_ns_reg <= 1'b0;
	   end
	   
	end
	
	always @ (posedge clk)begin
		if(reset == `RESET_ENABLE) begin
		//	cpu_icache_ptab	<=  'b0;
			//icache_ib_ptab_i	<=  'b0;
			cpu_rd_pc_i          <= 'b0;
			//icache_ib_branch_pc_i    <=  'b0;
		end
		else if (nxstate_normal) begin
			//icache_ib_ptab_i	<= bp_icache_ptab;
			cpu_rd_pc_i           <= cpu_rd_addr_virtual;
			//icache_ib_branch_pc_i    <=  bp_icache_branch_pc;
		end
	end
	assign icache_ib_branch_pc_i    =  bp_icache_branch_pc;
	assign icache_ib_ptab_i	= bp_icache_ptab;
	
	//for bus interface
	always @ (posedge clk) begin
		if(reset == `RESET_ENABLE) begin
			bus_rw			<= `READ;
			bus_as			<= `DISABLE;
			bus_rd_addr		<= `WORD_ADDR_W 'b0;
		end
		else if(nxstate_miss) begin
			bus_rw			<= `READ;
			bus_as			<= `ENABLE;
			bus_rd_addr		<= {cpu_rd_addr[`MissAddrLoc],`MISS_ZERO_NUM 'b0};
		end
		else begin
			bus_rw			<= `READ;
			bus_as			<= `DISABLE;
			bus_rd_addr		<= `WORD_ADDR_W 'b0;
		end
	end
	
	
	//for LRU
	//assign cache_hit_0_index[addr_index]  =   (nxstate_normal | (nxstate_normal & state_change))? cache_hit_0:cache_hit_0_index;
	always @ (posedge clk ) begin
		if (reset == `RESET_ENABLE) begin
			ram_used_0	<= 'b0;
			ram_used_1	<= 'b0;
			ram_used_2	<= 'b0;
		end
	   /*else if(nxstate_miss)begin
	         ram_used_0[addr_index]	<= ram_used_0[addr_index];
	         ram_used_1[addr_index]	<= ram_used_1[addr_index];
	         ram_used_2[addr_index]	<= ram_used_2[addr_index];
	   end*/
	
		//else if(nxstate_normal) begin
		else begin
		/*	ram_used_0[addr_index_reg]	<= ((cache_hit_0) | (cache_hit_1)) ? `DISABLE : `ENABLE;
			ram_used_1[addr_index_reg]	<= ((cache_hit_1)&&(~cache_hit_0)) ? `ENABLE  : `DISABLE;
			ram_used_2[addr_index_reg]	<= ((~cache_hit_2)&&(cache_hit_3)) ? `DISABLE : `ENABLE;
			ram_used_0[addr_index]	<= ((cache_hit_0) | (cache_hit_1)) ? `DISABLE : `ENABLE;
			ram_used_1[addr_index]	<= ((cache_hit_1)&&(~cache_hit_0)) ? `ENABLE  : `DISABLE;
			ram_used_2[addr_index]	<= ((~cache_hit_2)&&(cache_hit_3)) ? `DISABLE : `ENABLE;*/
			ram_used_0[addr_index]	<= ((cache_hit_0) | (cache_hit_1)) ? `ENABLE : `DISABLE;
			ram_used_1[addr_index]	<= ((cache_hit_1)&&(~cache_hit_0)) ? `DISABLE  : `ENABLE;
			ram_used_2[addr_index]	<= ((~cache_hit_2)&&(cache_hit_3)) ? `DISABLE : `ENABLE;
		end
		/*else begin
		  ram_used_0[addr_index]	<=   ram_used_0[addr_index]	;
		  ram_used_1[addr_index]	<=   ram_used_1[addr_index];
		  ram_used_2[addr_index]	<=   ram_used_2[addr_index];
		end*/
	end
	/*always @ (posedge clk ) begin
		if (reset == `RESET_ENABLE) begin
			cache_line_age_0	<=	'b0;
			cache_line_age_1	<=	'b0;
			cache_line_age_2	<=	'b0;
			cache_line_age_3	<=	'b0;
		end
		else  begin
			cache_line_age_0[addr_index]	<=	(cache_hit_0)? `ENABLE : `DISABLE;
			cache_line_age_1[addr_index]	<=	(cache_hit_1)? `ENABLE : `DISABLE;
			cache_line_age_2[addr_index]	<=	(cache_hit_2)? `ENABLE : `DISABLE;
			cache_line_age_3[addr_index]	<=	(cache_hit_3)? `ENABLE : `DISABLE;
		end
	end*/
	
	//for cache line valid
	always @ (posedge clk ) begin
		if (reset == `RESET_ENABLE) begin
			ram_valid_0	<= 'b0;
			ram_valid_1	<= 'b0;
			ram_valid_2	<= 'b0;
			ram_valid_3 <= 'b0;
		end
		else begin
			case(replace_chioce)
				`REPLACE_WAY_0	: begin
					if(~cache_hit) begin
						ram_valid_0[addr_index]	<= (ram_valid_0[addr_index] == `ENABLE) ? `DISABLE:
													(icache_rd_mem_counter_end) ? `ENABLE : ram_valid_0[addr_index];
					end
				end
				`REPLACE_WAY_1	: begin
					if(~cache_hit) begin
						ram_valid_1[addr_index]	<= (ram_valid_1[addr_index] == `ENABLE) ? `DISABLE:
													(icache_rd_mem_counter_end) ? `ENABLE : ram_valid_1[addr_index];
					end
				end
				`REPLACE_WAY_2	: begin
					if(~cache_hit) begin
						ram_valid_2[addr_index]	<= (ram_valid_2[addr_index] == `ENABLE) ? `DISABLE:
													(icache_rd_mem_counter_end) ? `ENABLE : ram_valid_2[addr_index];
					end
				end
				`REPLACE_WAY_3	: begin
					if(~cache_hit) begin
						ram_valid_3[addr_index]	<= (ram_valid_3[addr_index] == `ENABLE) ? `DISABLE:
													(icache_rd_mem_counter_end) ? `ENABLE : ram_valid_3[addr_index];
					end
				end
			endcase
		end
	end
	
	//for load words counter
	always @ (posedge clk) begin
		if(reset == `RESET_ENABLE) begin
			icache_rd_mem_counter	<= 5'd0;
		end
		else if (icache_rd_mem_counter == 5'd16) begin
			icache_rd_mem_counter	<= 5'd0;
		end
		else	begin
		//	icache_rd_mem_counter	<= (bus_data_ready)? (icache_rd_mem_counter+5'b1) : icache_rd_mem_counter;
			icache_rd_mem_counter	<= (bus_data_ready & (bus_rw==`READ) & nxstate_miss & nxstate_ins_read)? (icache_rd_mem_counter+5'b1) : icache_rd_mem_counter;
		end
	end
	
	assign	icache_rd_mem_counter_end = (icache_rd_mem_counter == 5'd16);
	
	//for handshake
	//assign	data_ok 			=	(cache_hit == `ENABLE);
	assign	icache_ib_ready_go	=	(cpu_if_data_ok_i);
	//biang
	/*reg cpu_if_data_ok_ii;
	always @(posedge clk) begin
	cpu_if_data_ok_ii <= cpu_if_data_ok_i;
	end*/
	
	assign	icache_allin		=	state_idle&&(!icache_valid || icache_ib_ready_go && ib_allin);
	//assign	icache_allin_i		=	!icache_valid || icache_ib_ready_go && ib_allin;
	assign	icache_ns			=	nxstate_idle&&icache_valid && icache_ib_ready_go;
	//assign	icache_ns_i			=	icache_valid && icache_ib_ready_go;
	assign	pip_stall			=	!( ib_allin&&icache_ns_reg);
	
	
	
	always @(posedge clk)begin
    if(reset==`RESET_ENABLE)begin
        flus_reg <= 1'b0;
    end
    else if(flus)begin
        flus_reg <= flus;
    end
    else if(icache_start)begin
        flus_reg <= 1'b0;
    end
end
	always	@ (posedge clk)begin
		if(reset == `RESET_ENABLE)begin
			//icache_valid	<=	`DISABLE;
			icache_valid	<=	`ENABLE;
		end
		else if (icache_allin) begin
			icache_valid	<=	if_valid_ns;
		end
	end
	
	/*always @(posedge clk)begin
		if(!pip_stall)begin
			cpu_rd_data		  <=	cpu_rd_data_i;
			cpu_rd_pc         <=    cpu_rd_pc_i;
			cpu_if_addr_ok    <=    cpu_if_addr_ok_i;
			cpu_if_data_ok    <=   cpu_if_data_ok_i;
			icache_ib_ptab    <=    icache_ib_ptab_i;
			//icache_allin      <=    icache_allin_i;
			//icache_ns         <=    icache_ns_i;
		  icache_ib_delot_en  <=     if_icache_delot_en_i;
		  icache_ib_branch_pc   <=  icache_ib_branch_pc_i;
		end
	end*/
	always @(posedge clk)begin
	    if(flus&&(!pip_stall))begin
	       cpu_rd_data		  <=	'b0;
			cpu_rd_pc         <=    'b0;
			cpu_if_addr_ok    <=    'b0;
			cpu_if_data_ok    <=   'b0;
			icache_ib_ptab    <=    'b0;
		  icache_ib_delot_en  <=    'b0;
		  icache_ib_branch_pc   <=  'b0;
	    end
		else if(!pip_stall)begin
			cpu_rd_data		  <=	(!flus_reg)?cpu_rd_data_i:'b0;
			cpu_rd_pc         <=    (!flus_reg)?cpu_rd_pc_i:'b0;
			cpu_if_addr_ok    <=    (!flus_reg)? cpu_if_addr_ok_i:'b0;
			cpu_if_data_ok    <=    (!flus_reg)?cpu_if_data_ok_i:'b0;
			icache_ib_ptab    <=    (!flus_reg)?icache_ib_ptab_i:'b0;
		  icache_ib_delot_en  <=    (!flus_reg)?if_icache_delot_en_i:'b0;
		  icache_ib_branch_pc   <=  (!flus_reg)?icache_ib_branch_pc_i:'b0;//20190725
		end
	end
	
	
	
	
	
	
	tag_bram tag_way_0(
        .addra(addr_index),
        .clka(clk),
        .dina(addr_tag),
        .douta(cache_tag_0),
        .ena(cache_en),
        .wea(tag_wr_en_0)
	);
	
	tag_bram tag_way_1(
        .addra(addr_index),
        .clka(clk),
        .dina(addr_tag),
        .douta(cache_tag_1),
        .ena(cache_en),
        .wea(tag_wr_en_1)
	);
	
	
	tag_bram tag_way_2(
        .addra(addr_index),
        .clka(clk),
        .dina(addr_tag),
        .douta(cache_tag_2),
        .ena(cache_en),
        .wea(tag_wr_en_2)
	);
	
	
	tag_bram tag_way_3(
        .addra(addr_index),
        .clka(clk),
        .dina(addr_tag),
        .douta(cache_tag_3),
        .ena(cache_en),
        .wea(tag_wr_en_3)
	);
	





	//A port for axi write,B port for read
	
	genvar     i_0;
	genvar     i_1;
	genvar     i_2;
	genvar     i_3;
	
	generate
	 
		for (i_0 = 0;i_0<`WORD_NUM ; i_0 = i_0 + 32) begin
	       data_ram    data_way_0(
	           .addra(addr_index),
	           .clka(clk),
	           .dina(bus_rd_data),
	           .ena(cache_bus_en_eachword_0[i_0 >> 5] & (replace_chioce == `REPLACE_WAY_0) & bus_data_ready),
	          // .wea(`ENABLE),
	          .wea(nxstate_miss),
	           .addrb(addr_index),
	           .clkb(clk),
	           .doutb(cache_data_read_0[(i_0 + 5'd31) : i_0]),
	           .enb(cache_en)
	       );
		end


		for (i_1 = 0;i_1<`WORD_NUM ; i_1 = i_1 + 32) begin
	       data_ram    data_way_1(
	           .addra(addr_index),
	           .clka(clk),
	           .dina(bus_rd_data),
	           .ena(cache_bus_en_eachword_1[i_1 >> 5] & (replace_chioce == `REPLACE_WAY_1) & bus_data_ready),
	          // .wea(`ENABLE),
	           .wea(nxstate_miss),
	           .addrb(addr_index),
	           .clkb(clk),
	           .doutb(cache_data_read_1[(i_1 + 5'd31) : i_1]),
	           .enb(cache_en)
	       );
		end


		for (i_2 = 0;i_2<`WORD_NUM ; i_2 = i_2 + 32) begin
	       data_ram    data_way_2(
	           .addra(addr_index),
	           .clka(clk),
	           .dina(bus_rd_data),
	           .ena(cache_bus_en_eachword_2[i_2 >> 5] & (replace_chioce == `REPLACE_WAY_2) & bus_data_ready),
	          // .wea(`ENABLE),
	           .wea(nxstate_miss),
	           .addrb(addr_index),
	           .clkb(clk),
	           .doutb(cache_data_read_2[(i_2 + 5'd31) : i_2]),
	           .enb(cache_en)
	       );
		end
	   
	    for (i_3 = 0;i_3<`WORD_NUM ; i_3 = i_3 + 32) begin
	       data_ram    data_way_3(
	           .addra(addr_index),
	           .clka(clk),
	           .dina(bus_rd_data),
	           .ena(cache_bus_en_eachword_3[i_3 >> 5] & (replace_chioce == `REPLACE_WAY_3) & bus_data_ready),
	           //.wea(`ENABLE),
	           .wea(nxstate_miss),
	           .addrb(addr_index),
	           .clkb(clk),
	           .doutb(cache_data_read_3[(i_3 + 5'd31) : i_3]),
	           .enb(cache_en)
	       );
		end
	endgenerate

endmodule	
	
`undef 	TagLen		
`undef 	IndexLen	
`undef 	BlockLen	
`undef 	ByteLen		
`undef 	InsnGroupLen
`undef 	TagLoc		
`undef 	IndexLoc		 
`undef 	BlockLoc			 
`undef 	ByteLoc				 
`undef  InsnGroupLoc 	  

`undef 	SixtWordDataBus	
 
`undef  SixtBlockBus	
`undef  FOUR_WORD_DATA_W 
`undef 	WORD_NUM		
`undef 	IndexNum	

//`undef	STATE_FULL
`undef	StateBus
`undef  STATE_NORMAL 
`undef 	STATE_MISS 
`undef  MissAddrLoc		 
`undef  MISS_ZERO_NUM		 
`undef  CounterBus 		 
`undef  ReplaceBus 		 
`undef  REPLACE_WAY_0 
`undef  REPLACE_WAY_1 
`undef  REPLACE_WAY_2 
`undef  REPLACE_WAY_3	
	
	