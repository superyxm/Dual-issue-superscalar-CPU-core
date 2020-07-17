/*
Design name??A direct associated D_Cache

	Tag		Index	Block_offset	Byte_offset
	31:14	13:6	5:2				1:0
	
	16KB
	
	write back and write allocate

*/
/********** Common header file **********/
`include "nettype.h"
`include "global_config.h"
`include "stddef.h"

/********** Individual header file **********/
`include "cpu.h"
`include "each_module.h"

//
`define		StateBus				1:0
`define		STATE_IDLE				2'b00
`define		STATE_TAG				2'b01
`define		STATE_WB				2'b10	//write back to mem
`define		STATE_RB				2'b11	//read block from mem

`define		IndexNum				255:0
`define 	SixtWordDataBus			    511:0
`define		WORD_NUM				512
`define     SixtBlockBus	            15:0

`define		TagLen					17:0
`define		IndexLen				7:0
`define	    BlockLen	   		 	3:0
//`define		DataGroupLen 			1:0

`define		TagLoc					31:14
`define		IndexLoc				13:6
`define	    BlockLoc	    		5:2
//`define		DataGroupLoc 			5:4	
`define	    MISS_ZERO_NUM	        6	
`define		CounterBus				4:0

module d_cache_directed(
	/**********	global siganl **********/
	input		wire	clk,
	input		wire 	reset,
	
	/********** cpu side **********/ 
	input       wire                        nxstate_rd_data,//20190729
	input       wire                        nxstate_wr_data,//20190729
	input		wire						cpu_mem_en,	//cpu load/store cache op
	input		wire	[`WordAddrBus]		cpu_dcache_addr,
	input		wire						cpu_dcache_rw,			//0 cpu read from cache;1 cpu write to cache
	input		wire	[`WriteEnBus]		cpu_dcache_rwen,		//byte read/write enable
	input		wire	[`WordDataBus]		cpu_dcache_wr_data,		//cpu write data to cache(32 bit)
	//output		reg		[`WordDataBus]		cpu_dcache_rd_data,		//cpu read data from cache
	output     wire    	[`WordDataBus]		cpu_dcache_rd_data,	
	output		wire						cpu_mem_data_ok,
	output      wire                        cpu_mem_addr_ok,
	//cpu reading/writing miss ready uses counter_end
	
	
	/********** low mem side **********/
	input		wire	[`WordDataBus]		bus_rd_data,			//read block from mem
	input		wire 						bus_ready,				//
	output		reg		[`WordAddrBus]		bus_rd_addr,			//
	output		reg		[`WordAddrBus]		bus_wr_addr,			//
	output		wire	[`WordDataBus]		bus_wr_data,			//write back to mem
	//output		wire						bus_rw,					//
	output		reg						    bus_rw,	
	output		reg							bus_as					//be like to cpu_dcache_req_op_valid
	);
	
	
	
	/********** state machine **********/
	reg		[`StateBus]			dcache_state;
	reg		[`StateBus]			dcache_nxstate;
	wire						dcache_state_change;
	wire						dcache_state_idle;
	wire						dcache_state_tag;
	wire						dcache_state_wb;
	wire						dcache_state_rb;
	wire						dcache_nxstate_idle;
	wire						dcache_nxstate_tag;
	wire						dcache_nxstate_wb;
	wire						dcache_nxstate_rb;
	
 	reg		[`WordAddrBus]		cpu_dcache_addr_reg;
 	reg     [`TagLen]			addr_tag_reg;       
	
	wire	[`TagLen]			addr_tag;
	wire	[`IndexLen]			addr_index;
	wire	[`BlockLen]			addr_block_offset;
	reg		[`IndexNum]			dcache_dirty;
	reg		[`IndexNum]			dcache_valid;
	wire						dcache_hit;
	wire	[`TagLen]			dcache_tag;
	
	wire						dcache_tag_en;
	reg							dcache_tag_en_reg;
	wire						dcache_tag_we;
	
	//wire	[`SixtBlockBus]		cpu_rd_data_en_mux;
	wire	[`SixtBlockBus]		cpu_rd_data_en;
	reg		[`SixtBlockBus]		cpu_rd_data_en_reg;
	wire    [`WordDataBus]		cpu_dcache_data_rd;
	wire	[`SixtWordDataBus]	dcache_data_rd_eachword;
	
	//bus 
	wire	[`SixtBlockBus]		bus_data_rd_en;
	//wire	[`SixtBlockBus]		bus_data_wr_en;
	wire    [`SixtWordDataBus]  bus_wr_data_eachword;
	wire   [`WordDataBus]      bus_wr_data_i;
	
	reg    dcache_finish;
	
	//counter
	reg		[`CounterBus]		rd_cnt;
	reg		[`CounterBus]		wr_cnt;
	wire						rd_end;
	wire						wr_end;
	wire                       dirty_en;
	
	/********** state machine **********/
	assign		dcache_state_idle		= 	(dcache_state 	== `STATE_IDLE);
	assign		dcache_state_tag		= 	(dcache_state 	== `STATE_TAG);
	assign		dcache_state_wb			= 	(dcache_state 	== `STATE_WB);
	assign		dcache_state_rb			= 	(dcache_state 	== `STATE_RB);
	assign		dcache_nxstate_idle		= 	(dcache_nxstate == `STATE_IDLE);
	assign		dcache_nxstate_tag		= 	(dcache_nxstate == `STATE_TAG);
	assign		dcache_nxstate_wb		= 	(dcache_nxstate == `STATE_WB);
	assign		dcache_nxstate_rb		= 	(dcache_nxstate == `STATE_RB);
	
	assign		dcache_state_change		=	(dcache_state	!= dcache_nxstate);
	
	always @ (posedge clk) begin
		if (reset == `RESET_ENABLE) begin
			dcache_state				<=		2'b00;
		end
		else if(dcache_state_change)begin
			dcache_state				<=		dcache_nxstate;
		end
	end
	
	/*always @ (*) begin
		case(dcache_state)begin
			`STATE_IDLE		:	dcache_nxstate	=	(~cpu_dcache_req_op_valid)?`STATE_IDLE	:	`STATE_TAG;
			`STATE_TAG		:	dcache_nxstate	=	(cpu_mem_data_ok)? `STATE_IDLE:
													(dcache_hit)? `STATE_TAG:
													(dcache_dirty[addr_index] == `ENABLE)? 	`STATE_WB	:
													`STATE_RB;
			`STATE_WB 		: 	dcache_nxstate	=	((wr_end)? `STATE_RB  : `STATE_WB);
			`STATE_RB 		: 	dcache_nxstate  =	((rd_end)? `STATE_TAG : `STATE_RB);
			default	  		: 	dcache_nxstate	=	`STATE_IDLE;
		end
	end*/
	always @ (posedge clk) begin
		if(reset==`RESET_ENABLE) begin
			dcache_finish <= 'b0;
		end
		else if (dcache_state_tag&&dcache_hit&&(~dcache_nxstate_rb)&&(~dcache_nxstate_wb)) begin
			dcache_finish <= 1'b1;
		end
		else begin
		  dcache_finish <= 1'b0;
		end
	end
	always @ (*) begin
		case(dcache_state) 
		    `STATE_IDLE: dcache_nxstate =   (cpu_mem_en)? `STATE_TAG : `STATE_IDLE;
			`STATE_TAG: dcache_nxstate	=	(//(~cpu_mem_en)? `STATE_TAG:
											(dcache_hit)?((dcache_finish)?`STATE_IDLE : `STATE_TAG):
											(dcache_dirty[addr_index] == `ENABLE)? `STATE_WB:
											`STATE_RB);
			`STATE_WB : dcache_nxstate	=	((wr_end)? `STATE_RB : `STATE_WB);
			`STATE_RB : dcache_nxstate  =	((rd_end)? `STATE_TAG : `STATE_RB);
			default	  : dcache_nxstate	=	`STATE_IDLE;
		endcase
	end
	
	/********** decode **********/
	reg cpu_dcache_rw_reg        ;
	reg [3:0]cpu_dcache_rwen_reg;
	always @ (posedge clk)begin
		if(reset == `RESET_ENABLE)begin
			cpu_dcache_addr_reg	<=	`DISABLE;
			cpu_dcache_rwen_reg      <= 'b0;
			cpu_dcache_rw_reg        <= 'b0;
		end
		else if(cpu_mem_en)begin
		    cpu_dcache_rwen_reg   <= cpu_dcache_rwen;
			cpu_dcache_addr_reg	<=	cpu_dcache_addr;
			cpu_dcache_rw_reg        <= cpu_dcache_rw;
		end
	end
	
	assign		addr_tag				= 	cpu_dcache_addr_reg[`TagLoc];
	assign		addr_index				= 	cpu_dcache_addr_reg[`IndexLoc];
	assign		addr_block_offset		= 	cpu_dcache_addr_reg[`BlockLoc];
	
	//
	//assign		dcache_hit				=	(~cpu_mem_en)? `DISABLE:((addr_tag == dcache_tag)&&(dcache_valid[addr_index] == `ENABLE));
	assign		dcache_hit				=((addr_tag_reg == dcache_tag)&&(dcache_valid[addr_index] == `ENABLE));
	
	//tag
	//assign		dcache_tag_en			=	dcache_tag_en_reg;
	assign      dcache_tag_en          =   1'b1;
	assign 		dcache_tag_we  			=   (rd_cnt  == 5'd01);
	always @ (posedge clk)begin
	   addr_tag_reg         <= addr_tag;
	end
	always @ (posedge clk)begin
		if(reset == `RESET_ENABLE)begin
			dcache_tag_en_reg	<=	`DISABLE;
			//addr_tag_reg         <= 'b0;
		end
		else if(cpu_mem_en)begin
			dcache_tag_en_reg	<=	`ENABLE;
			
		end
	end
	
	
	//cpu_data_read
	
	//assign		cpu_rd_data_en_mux		=	(dcache_nxstate_tag)?cpu_rd_data_en_reg : cpu_rd_data_en;
	/*always @ (posedge clk)begin
		if(reset == `RESET_ENABLE)begin
			cpu_rd_data_en_reg 	<=	`DISABLE;
		end
		else if(dcache_nxstate_tag)begin
			cpu_rd_data_en_reg	<=	cpu_rd_data_en;
		end
	end
	*/
	assign		cpu_rd_data_en			= 	(addr_block_offset == 4'd00)? 16'b0000_0000_0000_0001:
											(addr_block_offset == 4'd01)? 16'b0000_0000_0000_0010:
											(addr_block_offset == 4'd02)? 16'b0000_0000_0000_0100:
											(addr_block_offset == 4'd03)? 16'b0000_0000_0000_1000:
											(addr_block_offset == 4'd04)? 16'b0000_0000_0001_0000:
											(addr_block_offset == 4'd05)? 16'b0000_0000_0010_0000:
											(addr_block_offset == 4'd06)? 16'b0000_0000_0100_0000:
											(addr_block_offset == 4'd07)? 16'b0000_0000_1000_0000:
											(addr_block_offset == 4'd08)? 16'b0000_0001_0000_0000:
											(addr_block_offset == 4'd09)? 16'b0000_0010_0000_0000:
											(addr_block_offset == 4'd10)? 16'b0000_0100_0000_0000:
											(addr_block_offset == 4'd11)? 16'b0000_1000_0000_0000:
											(addr_block_offset == 4'd12)? 16'b0001_0000_0000_0000:
											(addr_block_offset == 4'd13)? 16'b0010_0000_0000_0000:
											(addr_block_offset == 4'd14)? 16'b0100_0000_0000_0000:
																		  16'b1000_0000_0000_0000;
	
	
	assign		cpu_dcache_data_rd		= 	(addr_block_offset == 4'd00)? dcache_data_rd_eachword[31:0]:
											(addr_block_offset == 4'd01)? dcache_data_rd_eachword[63:32]:
											(addr_block_offset == 4'd02)? dcache_data_rd_eachword[95:64]:
											(addr_block_offset == 4'd03)? dcache_data_rd_eachword[127:96]:
											(addr_block_offset == 4'd04)? dcache_data_rd_eachword[159:128]:
											(addr_block_offset == 4'd05)? dcache_data_rd_eachword[191:160]:
											(addr_block_offset == 4'd06)? dcache_data_rd_eachword[223:192]:
											(addr_block_offset == 4'd07)? dcache_data_rd_eachword[255:224]:
											(addr_block_offset == 4'd08)? dcache_data_rd_eachword[287:256]:
											(addr_block_offset == 4'd09)? dcache_data_rd_eachword[319:288]:
											(addr_block_offset == 4'd10)? dcache_data_rd_eachword[351:320]:
											(addr_block_offset == 4'd11)? dcache_data_rd_eachword[383:352]:
											(addr_block_offset == 4'd12)? dcache_data_rd_eachword[415:384]:
											(addr_block_offset == 4'd13)? dcache_data_rd_eachword[447:416]:
											(addr_block_offset == 4'd14)? dcache_data_rd_eachword[479:448]:
																		  dcache_data_rd_eachword[511:480];
	
	
	
	//data_ok
    assign  cpu_dcache_rd_data  =  // (reset==`RESET_ENABLE)?'b0:
                                    (dcache_hit && dcache_state_idle)? cpu_dcache_data_rd:'b0 ;
    assign  cpu_mem_data_ok     = (dcache_hit && dcache_state_idle);
	/*always	@ (posedge clk) begin
		if(reset == `RESET_ENABLE)begin
			cpu_mem_data_ok		 <=	`DISABLE;
		//	cpu_dcache_rd_data   <= 'b0;
		end
		else if(dcache_nxstate_tag)begin
			cpu_mem_data_ok		 <=	(dcache_hit);
			//cpu_dcache_rd_data   <= (dcache_hit)? cpu_dcache_data_rd:'b0 ;
		end
	end*/
	
	assign	cpu_mem_addr_ok	     =	(dcache_nxstate_tag);
	
	//bus
	assign	bus_wr_data = //(reset == `RESET_ENABLE)? 'b0:
	                      (dcache_nxstate_wb) ?( bus_wr_data_i) : `WORD_DATA_W'b0;
    /*assign  bus_rw = (reset == `RESET_ENABLE)?  `READ:
                      (dcache_nxstate_wb) ?     `WRITE:
                      `READ;	*/					
	always @(posedge clk) begin
		if(reset == `RESET_ENABLE) begin
			bus_rw <= `READ;
			bus_as <= `DISABLE;
			bus_rd_addr <= `WORD_ADDR_W'b0;
			bus_wr_addr <= `WORD_ADDR_W'b0;
		end
		else begin
			bus_rw <= (dcache_nxstate_wb) ? `WRITE : `READ;
			bus_as <= (dcache_nxstate_rb | dcache_nxstate_wb);
			bus_rd_addr <= (dcache_nxstate_rb) ? {addr_tag,addr_index,`MISS_ZERO_NUM'b0} :
						   `WORD_ADDR_W'b0;
			bus_wr_addr <= (dcache_nxstate_wb) ? {dcache_tag,addr_index,`MISS_ZERO_NUM'b0} :
						   `WORD_ADDR_W'b0;
		end
	end
	
	assign  	bus_wr_data_i    		=  	(wr_cnt == 5'd00) ? bus_wr_data_eachword[31 : 0] :
											(wr_cnt == 5'd01) ? bus_wr_data_eachword[63 : 32]:
											(wr_cnt == 5'd02) ? bus_wr_data_eachword[95 : 64]:
											(wr_cnt == 5'd03) ? bus_wr_data_eachword[127 : 96] 	:
											(wr_cnt == 5'd04) ? bus_wr_data_eachword[159 : 128] :
											(wr_cnt == 5'd05) ? bus_wr_data_eachword[191 : 160] :
											(wr_cnt == 5'd06) ? bus_wr_data_eachword[223 : 192] :
											(wr_cnt == 5'd07) ? bus_wr_data_eachword[255 : 224]	:
											(wr_cnt == 5'd08) ? bus_wr_data_eachword[287 : 256] :
											(wr_cnt == 5'd09) ? bus_wr_data_eachword[319 : 288] :
											(wr_cnt == 5'd10) ? bus_wr_data_eachword[351 : 320] :
											(wr_cnt == 5'd11) ? bus_wr_data_eachword[383 : 352] :
											(wr_cnt == 5'd12) ? bus_wr_data_eachword[415 : 384] :
											(wr_cnt == 5'd13) ? bus_wr_data_eachword[447 : 416] :
											(wr_cnt == 5'd14) ? bus_wr_data_eachword[479 : 448] :
											(wr_cnt == 5'd15) ? bus_wr_data_eachword[511 : 480] :
											`WORD_DATA_W'b0; 
											
	assign		bus_data_rd_en			=   (dcache_nxstate_wb)?16'b1111_1111_1111_1111:
											(rd_cnt == 5'd00) ? 16'b0000_0000_0000_0001 :
											(rd_cnt == 5'd01) ? 16'b0000_0000_0000_0010 :
											(rd_cnt == 5'd02) ? 16'b0000_0000_0000_0100 :
											(rd_cnt == 5'd03) ? 16'b0000_0000_0000_1000 :
											(rd_cnt == 5'd04) ? 16'b0000_0000_0001_0000 :
											(rd_cnt == 5'd05) ? 16'b0000_0000_0010_0000 :
											(rd_cnt == 5'd06) ? 16'b0000_0000_0100_0000 :
											(rd_cnt == 5'd07) ? 16'b0000_0000_1000_0000 :
											(rd_cnt == 5'd08) ? 16'b0000_0001_0000_0000 :
											(rd_cnt == 5'd09) ? 16'b0000_0010_0000_0000 :
											(rd_cnt == 5'd10) ? 16'b0000_0100_0000_0000 :
											(rd_cnt == 5'd11) ? 16'b0000_1000_0000_0000 :
											(rd_cnt == 5'd12) ? 16'b0001_0000_0000_0000 :
											(rd_cnt == 5'd13) ? 16'b0010_0000_0000_0000 :
											(rd_cnt == 5'd14) ? 16'b0100_0000_0000_0000 :
											(rd_cnt == 5'd15) ? 16'b1000_0000_0000_0000 :
											16'b0000_0000_0000_0000;
	
	
	
	//counter
	always @ (posedge clk) begin
		if(reset == `RESET_ENABLE) begin
			rd_cnt		<=		5'b0;
			wr_cnt		<=		5'b0;
		end
		else if (rd_cnt == 5'd16) begin
			rd_cnt		<=		5'b0;
		end
		else if(wr_cnt == 5'd16) begin
			wr_cnt		<=		5'b0;
		end
		else begin
			rd_cnt		<=		((bus_ready) && (bus_rw == `READ) && (dcache_nxstate_rb) && nxstate_rd_data) ? (rd_cnt + 5'b1) : rd_cnt;//20190729
			//rd_cnt		<=		 (rd_cnt + 5'b1) ;
			//rd_cnt		<=		(bus_ready) ? (rd_cnt + 5'b1) : rd_cnt;
			wr_cnt		<=		((bus_ready)&&(bus_rw == `WRITE)&&(dcache_nxstate_wb) && nxstate_wr_data)? (wr_cnt + 5'b1) : wr_cnt;//20190729
		end
	end
	
	assign	rd_end		=	(rd_cnt == 5'd16);
	assign  wr_end		=	(wr_cnt == 5'd16);
	
	 
	//valid
	always @ (posedge clk) begin
		if(reset == `RESET_ENABLE) begin
			dcache_valid	<=	'b0;
		end
		else begin
			dcache_valid[addr_index]	<=	(dcache_nxstate_wb)?`DISABLE:
			                                 (rd_end)? `ENABLE : dcache_valid[addr_index];
		end
	end
	
	//dirty
	always @ (posedge clk) begin
		if(reset == `RESET_ENABLE) begin
			dcache_dirty	<=	'b0;
			//dcache_dirty	=	'b0;
		end
		//else begin
		else  begin
			/*case (dcache_nxstate)
				`STATE_TAG	:	begin
					dcache_dirty[addr_index_reg]	<=	((dcache_hit)&&(cpu_rw == `WRITE))? `ENABLE :
														
				end
			endcase*/
			//dcache_dirty[addr_index]	<=	(((dcache_hit)&&(cpu_dcache_rw == `WRITE)) | ((cpu_dcache_rw == `WRITE)&&(~dcache_hit)&&(rd_cnt == 4'd15)))? `ENABLE : dcache_dirty[addr_index];
		//dcache_dirty[addr_index]	<=   	(dirty_en)? `ENABLE : 
		dcache_dirty[addr_index]	=	((dcache_hit)&&(cpu_dcache_rw == `WRITE))? `ENABLE : 
											((!dcache_hit)&&(wr_cnt == 4'd14)&&(cpu_dcache_rw == `READ)) ? `DISABLE:
											dcache_dirty[addr_index];
	      end	   
	end	
	assign dirty_en    =   (dcache_hit)&(cpu_dcache_rw == `WRITE);
	
	//tag bram :the A port for cpu read and axi write
	tag_ram tag_way(
	   .addra(addr_index),
	   .clka(clk),
	   .dina(addr_tag),
	   .douta(dcache_tag),
	   .ena(dcache_tag_en),
	   .wea(dcache_tag_we)
	);
	
	//data bram:A port for cpu read and write
	//data bram:B port for axi read and write
	
	genvar		i;
	
	generate
		for(i = 0 ; i < `WORD_NUM ; i = i + 32)begin
		data_bram data_way(
			.clka(clk),
			//.ena(cpu_rd_data_en[i >> 5] & ((cpu_dcache_rw == `READ) | ((cpu_dcache_rw == `WRITE)&(dcache_hit)))),
		//	.ena(cpu_rd_data_en[i >> 5] & ((cpu_dcache_rw == `READ) | ((cpu_dcache_rw == `WRITE)&(dcache_hit)))),
		   .ena(cpu_rd_data_en[i >> 5] & dcache_state_tag &((cpu_dcache_rw_reg == `READ) | ((cpu_dcache_rw_reg == `WRITE)&(dcache_hit)))),
			//.wea(cpu_dcache_rwen & (cpu_dcache_rw==`WRITE)),
		    // .wea(cpu_dcache_rwen_reg & ({4{cpu_dcache_rw_reg  == `WRITE }})),
		    .wea(cpu_dcache_rwen_reg & ({4{((dcache_nxstate_idle)&&(cpu_dcache_rw_reg  == `WRITE ))}})),
			// .wea(cpu_dcache_rwen_reg ),
			.addra(addr_index),
			.dina(cpu_dcache_wr_data),
			.douta(dcache_data_rd_eachword[(i+5'd31):i]),
			.clkb(clk),
		//	.enb((bus_data_wr_en[i >> 5])& bus_rw == `WRITE),
		//	.enb(bus_data_rd_en[i >> 5] & (bus_rw == `READ)),
			.enb(bus_data_rd_en[i >> 5]),
		   // .web({4{dcache_nxstate_rb}}),
		   .web({4{dcache_nxstate_rb  && nxstate_rd_data}}),
			.addrb(addr_index),
			.dinb(bus_rd_data),
			.doutb(bus_wr_data_eachword[(i+5'd31):i])
			);
		end
	endgenerate
	
	
endmodule
	
		
`undef		StateBus				
`undef		STATE_TAG				
`undef		STATE_WB				
`undef		STATE_RB				

`undef		IndexNum				
`undef 	SixtWordDataBus		
`undef		WORD_NUM			
`undef     SixtBlockBus	     

`undef		TagLen				
`undef		IndexLen				
`undef	    BlockLen	   		 	
//`undef		DataGroupLen 			

`undef		TagLoc					
`undef		IndexLoc				
`undef	    BlockLoc	    		
//`undef		DataGroupLoc 			
`undef	    MISS_ZERO_NUM	        	
`undef		CounterBus				
		
	
	
	
	