`timescale 1ns / 1ns
`include "isa.h"
`include "cpu.h"
`include "each_module.h"
`define ITEM_NUMBER 32 

`define IS_QUEUE_ALLOW_IN     2'b00
`define HANDSKE_OK            2'b01
`define IS_QUEUE_NOT_ALLOW_IN 2'b10


module issue_queue(
input clk,
input rst_,
input flush,
//----------- input from Decoder -----------//
input        id_valid_ns,
input [63:0] is_pc,
input [9:0]  is_ptab_addr,
input [54:0] is_decode_info_0,
input [54:0] is_decode_info_1,
input [5:0]  is_decode_valid_0,
input [5:0]  is_decode_valid_1,
input [9:0]  is_exe_code,
input [1:0]  id_is_delot_flag,
input [1:0]  issue_enable,

//----output to Dispatch----//
output [106:0] inst0_to_dispatch,
output [106:0] inst1_to_dispatch,
output        is_allow_in,
output   reg  is_valid
);
reg id_valid_ns_i;
reg push_in_fifo;
wire same;

always @(posedge clk or negedge rst_) begin
	if (!rst_) begin
		is_valid <= 1'b0;
	end
	else if (is_allow_in) begin
		is_valid <= id_valid_ns_i;
	end
end



always@(posedge clk)begin
	id_valid_ns_i <= id_valid_ns;
end


reg [1:0] state;
reg [1:0] nextstate;
/*
always@(posedge clk)begin
    if(!rst_ | flush)begin
        push_in_fifo <= 1'b0;
    end
    else if(nextstate == `HANDSKE_OK)begin
        push_in_fifo <= 1'b1;
    end
    else begin
        push_in_fifo <= 1'b0;
    end
end
*/


always@(*)begin
    if(id_valid_ns && is_allow_in)begin
        push_in_fifo = 1'b1;
    end
    else begin
        push_in_fifo = 1'b0;
    end   
end



always@(posedge clk)begin
    if(!rst_ | flush)begin
        state <= `IS_QUEUE_ALLOW_IN;
    end
    else if(state != nextstate)begin
        state <= nextstate;
    end
end

always@(*)begin
    case (state)
        `IS_QUEUE_ALLOW_IN     : nextstate = (id_valid_ns && is_allow_in)? `HANDSKE_OK : `IS_QUEUE_ALLOW_IN;
        `HANDSKE_OK            : nextstate = (id_valid_ns && is_allow_in)? `HANDSKE_OK : (is_allow_in)? `IS_QUEUE_ALLOW_IN : `IS_QUEUE_NOT_ALLOW_IN;
        `IS_QUEUE_NOT_ALLOW_IN : nextstate = (is_allow_in)? `IS_QUEUE_ALLOW_IN : `IS_QUEUE_NOT_ALLOW_IN;
        default                : nextstate =  `IS_QUEUE_ALLOW_IN;
    endcase
end



//----issue_queque_with 32 items----//
reg [31:0] pc           [0:`ITEM_NUMBER-1];
reg [4:0]  src0         [0:`ITEM_NUMBER-1];
reg [4:0]  src1         [0:`ITEM_NUMBER-1];
reg [31:0] imme         [0:`ITEM_NUMBER-1];
reg [3:0]  inst_type    [0:`ITEM_NUMBER-1];
reg [5:0]  inst_meaning [0:`ITEM_NUMBER-1];
reg [4:0]  dst          [0:`ITEM_NUMBER-1];
reg [5:0]  data_valid   [0:`ITEM_NUMBER-1];
reg [4:0]  ptab_addr    [0:`ITEM_NUMBER-1];
reg [4:0]  exe_code     [0:`ITEM_NUMBER-1];
reg item_busy           [0:`ITEM_NUMBER-1];
reg delot_flag          [0:`ITEM_NUMBER-1];

reg [5:0] current_item;

reg [1:0] issue_queue_is_free;
reg issue_queque_is_full;

wire [31:0] inst0_pc;
wire [31:0] inst0_imme;
wire [4:0]  inst0_dst;
wire [4:0]  inst0_src0;
wire [4:0]  inst0_src1;
wire [3:0]  inst0_inst_type;
wire [5:0]  inst0_meaning;
wire [4:0]  inst0_ptab_addr;
wire [4:0]  inst0_exe_code;
wire        inst0_delot_flag;

wire [31:0] inst1_pc;
wire [31:0] inst1_imme;
wire [4:0]  inst1_dst;
wire [4:0]  inst1_src0;
wire [4:0]  inst1_src1;
wire [3:0]  inst1_inst_type;
wire [5:0]  inst1_meaning;
wire [4:0]  inst1_ptab_addr;
wire [4:0]  inst1_exe_code;
wire        inst1_delot_flag;

integer i;
//----dispatch input data from decoder----//
assign inst0_pc         = is_pc            [31:0];
assign inst0_dst        = is_decode_info_0 [54:50];
assign inst0_src0       = is_decode_info_0 [49:45];
assign inst0_src1       = is_decode_info_0 [44:40];
assign inst0_imme       = is_decode_info_0 [39:8];
assign inst0_inst_type  = is_decode_info_0 [7:6];
assign inst0_meaning    = is_decode_info_0 [5:0];

assign inst0_exe_code   = is_exe_code      [4:0];


assign inst1_delot_flag = id_is_delot_flag [1];
assign inst1_ptab_addr  = is_ptab_addr     [9:5];
assign inst0_delot_flag = id_is_delot_flag [0];
assign inst0_ptab_addr  = is_ptab_addr     [4:0];

assign inst1_pc         = is_pc            [63:32];
assign inst1_dst        = is_decode_info_1 [54:50];
assign inst1_src0       = is_decode_info_1 [49:45];
assign inst1_src1       = is_decode_info_1 [44:40];
assign inst1_imme       = is_decode_info_1 [39:8];
assign inst1_inst_type  = is_decode_info_1 [7:6];
assign inst1_meaning    = is_decode_info_1 [5:0];
//assign inst1_ptab_addr  = is_ptab_addr     [4:0];
assign inst1_exe_code   = is_exe_code      [9:5];

/*
wire [106:0] inst0_to_dispatch_from_ID;
wire [106:0] inst1_to_dispatch_from_ID;

assign inst0_to_dispatch_from_ID = {inst0_pc,inst0_dst,inst0_src0,inst0_src1,inst0_imme,inst0_inst_type,inst0_meaning,is_decode_valid_0,inst0_ptab_addr,inst0_exe_code,inst0_delot_flag,id_valid_ns_i};
assign inst1_to_dispatch_from_ID = {inst1_pc,inst1_dst,inst1_src0,inst1_src1,inst1_imme,inst1_inst_type,inst1_meaning,is_decode_valid_1,inst1_ptab_addr,inst1_exe_code,inst1_delot_flag,id_valid_ns_i};
*/


reg [31:0] last_inst0_pc;
reg [31:0] last_inst1_pc;

always@(posedge clk)begin
	if(!rst_ | flush)begin
		last_inst0_pc <= 32'b0;
		last_inst1_pc <= 32'b0;
	
	end
	else if(push_in_fifo)begin
		last_inst0_pc <= inst0_pc;
		last_inst1_pc <= inst1_pc;
	end
end


assign same = (last_inst0_pc == inst0_pc) && (last_inst1_pc == inst1_pc);

//----output to dapatch----//
assign inst0_to_dispatch = {pc[0],dst[0],src0[0],src1[0],imme[0],inst_type[0],inst_meaning[0],data_valid[0],ptab_addr[0],exe_code[0],delot_flag[0],item_busy[0]};
assign inst1_to_dispatch = {pc[1],dst[1],src0[1],src1[1],imme[1],inst_type[1],inst_meaning[1],data_valid[1],ptab_addr[1],exe_code[1],delot_flag[1],item_busy[1]};


//----issue_queue_"FIFO"----//
always @(posedge clk)begin
	if(!rst_)begin
		for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin
			item_busy    [i] <= 1'b0;
			pc           [i] <= 32'b0;
			dst          [i] <= 5'b0;
			src0         [i] <= 5'b0;
			src1         [i] <= 5'b0;
			imme         [i] <= 32'b0;
			inst_type    [i] <= 4'b0;
			inst_meaning [i] <= 6'b0;
			data_valid   [i] <= 6'b0;
			ptab_addr    [i] <= 5'b0;
			exe_code     [i] <= 5'h10;
			delot_flag   [i] <= 1'b0;
		end
	end
	else if(flush)begin
	    if(issue_enable == 2'b0 && delot_flag[0]==1'b1)begin
	       //keep
	    end
	    else begin
	        item_busy    [0] <= 1'b0;
			pc           [0] <= 32'b0;
			dst          [0] <= 5'b0;
			src0         [0] <= 5'b0;
			src1         [0] <= 5'b0;
			imme         [0] <= 32'b0;
			inst_type    [0] <= 4'b0;
			inst_meaning [0] <= 6'b0;
			data_valid   [0] <= 6'b0;
			ptab_addr    [0] <= 5'b0;
			exe_code     [0] <= 5'h10;
			delot_flag   [0] <= 1'b0;
	    end
		for (i=1; i<=`ITEM_NUMBER-1; i=i+1)begin
			item_busy    [i] <= 1'b0;
			pc           [i] <= 32'b0;
			dst          [i] <= 5'b0;
			src0         [i] <= 5'b0;
			src1         [i] <= 5'b0;
			imme         [i] <= 32'b0;
			inst_type    [i] <= 4'b0;
			inst_meaning [i] <= 6'b0;
			data_valid   [i] <= 6'b0;
			ptab_addr    [i] <= 5'b0;
			exe_code     [i] <= 5'h10;
			delot_flag   [i] <= 1'b0;
		end
	end
	else if(issue_enable == 2'b00)begin
		if((issue_queue_is_free == 2'b10)&&(push_in_fifo))begin
			item_busy    [current_item] <= 1'b1;
			pc           [current_item] <= inst0_pc;
			dst          [current_item] <= inst0_dst;
			src0         [current_item] <= inst0_src0;
			src1         [current_item] <= inst0_src1;
			imme         [current_item] <= inst0_imme;
			inst_type    [current_item] <= inst0_inst_type;
			inst_meaning [current_item] <= inst0_meaning;
			data_valid   [current_item] <= is_decode_valid_0;
			ptab_addr    [current_item] <= inst0_ptab_addr;
			exe_code     [current_item] <= inst0_exe_code;
			delot_flag   [current_item] <= inst0_delot_flag;
			
			item_busy    [current_item+1] <= 1'b1;
			pc           [current_item+1] <= inst1_pc;
			dst          [current_item+1] <= inst1_dst;
			src0         [current_item+1] <= inst1_src0;
			src1         [current_item+1] <= inst1_src1;
			imme         [current_item+1] <= inst1_imme;
			inst_type    [current_item+1] <= inst1_inst_type;
			inst_meaning [current_item+1] <= inst1_meaning;	
			data_valid   [current_item+1] <= is_decode_valid_1;
			ptab_addr    [current_item+1] <= inst1_ptab_addr;
			exe_code     [current_item+1] <= inst1_exe_code;
			delot_flag   [current_item+1] <= inst1_delot_flag;
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin
				if((i!=current_item)&&(i!=current_item+1))begin
					item_busy    [i] <= item_busy    [i];
					pc           [i] <= pc           [i];
					dst          [i] <= dst          [i];
					src0         [i] <= src0         [i];
					src1         [i] <= src1         [i];
					imme         [i] <= imme         [i];
					inst_type    [i] <= inst_type    [i];
					inst_meaning [i] <= inst_meaning [i];
					data_valid   [i] <= data_valid   [i];
					ptab_addr    [i] <= ptab_addr    [i];
					exe_code     [i] <= exe_code     [i];
					delot_flag   [i] <= delot_flag   [i];
				end
			end			
		end
		else if((issue_queue_is_free == 2'b01)&&(push_in_fifo))begin
			item_busy    [current_item] <= 1'b1;
			pc           [current_item] <= inst0_pc;
			dst          [current_item] <= inst0_dst;
			src0         [current_item] <= inst0_src0;
			src1         [current_item] <= inst0_src1;
			imme         [current_item] <= inst0_imme;
			inst_type    [current_item] <= inst0_inst_type;
			inst_meaning [current_item] <= inst0_meaning;
			data_valid   [current_item] <= is_decode_valid_0;
			ptab_addr    [current_item] <= inst0_ptab_addr;
			exe_code     [current_item] <= inst0_exe_code;
			delot_flag   [current_item] <= inst0_delot_flag;
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin
				if(i!=current_item)begin
					item_busy    [i] <= item_busy    [i];
					pc           [i] <= pc           [i];
					dst          [i] <= dst          [i];
					src0         [i] <= src0         [i];
					src1         [i] <= src1         [i];
					imme         [i] <= imme         [i];
					inst_type    [i] <= inst_type    [i];
					inst_meaning [i] <= inst_meaning [i];
					data_valid   [i] <= data_valid   [i];
					ptab_addr    [i] <= ptab_addr    [i];
					exe_code     [i] <= exe_code     [i];
					delot_flag   [i] <= delot_flag   [i];
				end
			end					
		end
	end
	else if(issue_enable == 2'b01)begin
		if((issue_queue_is_free == 2'b10)&&(push_in_fifo))begin
			if(current_item >= 6'h01)begin
				item_busy    [current_item-1] <= 1'b1;
				pc           [current_item-1] <= inst0_pc;
				dst          [current_item-1] <= inst0_dst;
				src0         [current_item-1] <= inst0_src0;
				src1         [current_item-1] <= inst0_src1;
				imme         [current_item-1] <= inst0_imme;
				inst_type    [current_item-1] <= inst0_inst_type;
				inst_meaning [current_item-1] <= inst0_meaning;
				data_valid   [current_item-1] <= is_decode_valid_0;
				ptab_addr    [current_item-1] <= inst0_ptab_addr;
				exe_code     [current_item-1] <= inst0_exe_code;
				delot_flag   [current_item-1] <= inst0_delot_flag;
			
				item_busy    [current_item] <= 1'b1;
				pc           [current_item] <= inst1_pc;
				dst          [current_item] <= inst1_dst;
				src0         [current_item] <= inst1_src0;
				src1         [current_item] <= inst1_src1;
				imme         [current_item] <= inst1_imme;
				inst_type    [current_item] <= inst1_inst_type;
				inst_meaning [current_item] <= inst1_meaning;	
				data_valid   [current_item] <= is_decode_valid_1;
				ptab_addr    [current_item] <= inst1_ptab_addr;
				exe_code     [current_item] <= inst1_exe_code;
				delot_flag   [current_item] <= inst1_delot_flag;
			
				for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin
					if((i!=current_item)&&(i!=current_item-1)&&(i<=`ITEM_NUMBER-2))begin
						item_busy    [i] <= item_busy    [i+1];
						pc           [i] <= pc           [i+1];
						dst          [i] <= dst          [i+1];
						src0         [i] <= src0         [i+1];
						src1         [i] <= src1         [i+1];
						imme         [i] <= imme         [i+1];
						inst_type    [i] <= inst_type    [i+1];
						inst_meaning [i] <= inst_meaning [i+1];
						data_valid   [i] <= data_valid   [i+1];
						ptab_addr    [i] <= ptab_addr    [i+1];
						exe_code     [i] <= exe_code     [i+1];			
						delot_flag   [i] <= delot_flag   [i+1];						
					end
					if(i==`ITEM_NUMBER-1)begin
						item_busy    [i] <= 1'b0;
						pc           [i] <= 32'b0;
						dst          [i] <= 5'b0;
						src0         [i] <= 5'b0;
						src1         [i] <= 5'b0;
						imme         [i] <= 32'b0;
						inst_type    [i] <= 4'b0;
						inst_meaning [i] <= 6'b0;	
						data_valid   [i] <= 6'b0;
						ptab_addr    [i] <= 5'b0;
						exe_code     [i] <= 5'h10;		
						delot_flag   [i] <= 1'b0;						
					end
				end
			end
			else begin
				item_busy    [current_item] <= 1'b1;
				pc           [current_item] <= inst0_pc;
				dst          [current_item] <= inst0_dst;
				src0         [current_item] <= inst0_src0;
				src1         [current_item] <= inst0_src1;
				imme         [current_item] <= inst0_imme;
				inst_type    [current_item] <= inst0_inst_type;
				inst_meaning [current_item] <= inst0_meaning;
				data_valid   [current_item] <= is_decode_valid_0;
				ptab_addr    [current_item] <= inst0_ptab_addr;
				exe_code     [current_item] <= inst0_exe_code;	
				delot_flag   [current_item] <= inst0_delot_flag;

				item_busy    [current_item+1] <= 1'b1;
				pc           [current_item+1] <= inst1_pc;
				dst          [current_item+1] <= inst1_dst;
				src0         [current_item+1] <= inst1_src0;
				src1         [current_item+1] <= inst1_src1;
				imme         [current_item+1] <= inst1_imme;
				inst_type    [current_item+1] <= inst1_inst_type;
				inst_meaning [current_item+1] <= inst1_meaning;	
				data_valid   [current_item+1] <= is_decode_valid_1;
				ptab_addr    [current_item+1] <= inst1_ptab_addr;
				exe_code     [current_item+1] <= inst1_exe_code;		
				delot_flag   [current_item+1] <= inst1_delot_flag;
				for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin
					if((i!=current_item)&&(i!=current_item-1)&&(i<=`ITEM_NUMBER-2))begin
						item_busy    [i] <= 1'b0;
						pc           [i] <= 32'b0;
						dst          [i] <= 5'b0;
						src0         [i] <= 5'b0;
						src1         [i] <= 5'b0;
						imme         [i] <= 32'b0;
						inst_type    [i] <= 4'b0;
						inst_meaning [i] <= 6'b0;	
						data_valid   [i] <= 6'b0;
						ptab_addr    [i] <= 5'b0;
						exe_code     [i] <= 5'h10;	
						delot_flag   [i] <= 1'b0;		
					end
				end	
			end
		end
		else if((issue_queue_is_free == 2'b01)&&(push_in_fifo))begin
			item_busy    [current_item-1] <= 1'b1;
			pc           [current_item-1] <= inst0_pc;
			dst          [current_item-1] <= inst0_dst;
			src0         [current_item-1] <= inst0_src0;
			src1         [current_item-1] <= inst0_src1;
			imme         [current_item-1] <= inst0_imme;
			inst_type    [current_item-1] <= inst0_inst_type;
			inst_meaning [current_item-1] <= inst0_meaning;		
			data_valid   [current_item-1] <= is_decode_valid_0;
			ptab_addr    [current_item-1] <= inst0_ptab_addr;
			exe_code     [current_item-1] <= inst0_exe_code;
			delot_flag   [current_item-1] <= inst0_delot_flag;
			
			item_busy    [current_item] <= 1'b1;
			pc           [current_item] <= inst1_pc;
			dst          [current_item] <= inst1_dst;
			src0         [current_item] <= inst1_src0;
			src1         [current_item] <= inst1_src1;
			imme         [current_item] <= inst1_imme;
			inst_type    [current_item] <= inst1_inst_type;
			inst_meaning [current_item] <= inst1_meaning;	
			data_valid   [current_item] <= is_decode_valid_1;
			ptab_addr    [current_item] <= inst1_ptab_addr;
			exe_code     [current_item] <= inst1_exe_code;
			delot_flag   [current_item] <= inst1_delot_flag;
			
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin 
				if((i!=current_item)&&(i!=current_item-1)&&(i<=`ITEM_NUMBER-2))begin
					item_busy    [i] <= item_busy    [i+1];
					pc           [i] <= pc           [i+1];
					dst          [i] <= dst          [i+1];
					src0         [i] <= src0         [i+1];
					src1         [i] <= src1         [i+1];
					imme         [i] <= imme         [i+1];
					inst_type    [i] <= inst_type    [i+1];
					inst_meaning [i] <= inst_meaning [i+1];
					data_valid   [i] <= data_valid   [i+1];
					ptab_addr    [i] <= ptab_addr    [i+1];
					exe_code     [i] <= exe_code     [i+1];	
					delot_flag   [i] <= delot_flag   [i+1];
				end
			end					
		end	
		else if((issue_queue_is_free == 2'b00)&&(push_in_fifo))begin
			item_busy    [current_item-1] <= 1'b1;
			pc           [current_item-1] <= inst0_pc;
			dst          [current_item-1] <= inst0_dst;
			src0         [current_item-1] <= inst0_src0;
			src1         [current_item-1] <= inst0_src1;
			imme         [current_item-1] <= inst0_imme;
			inst_type    [current_item-1] <= inst0_inst_type;
			inst_meaning [current_item-1] <= inst0_meaning;		
			data_valid   [current_item-1] <= is_decode_valid_0;
			ptab_addr    [current_item-1] <= inst0_ptab_addr;
			exe_code     [current_item-1] <= inst0_exe_code;		
			delot_flag   [current_item-1] <= inst0_delot_flag;	
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin 
				if(i<=`ITEM_NUMBER-2)begin
					item_busy    [i] <= item_busy    [i+1];
					pc           [i] <= pc           [i+1];
					dst          [i] <= dst          [i+1];
					src0         [i] <= src0         [i+1];
					src1         [i] <= src1         [i+1];
					imme         [i] <= imme         [i+1];
					inst_type    [i] <= inst_type    [i+1];
					inst_meaning [i] <= inst_meaning [i+1];
					data_valid   [i] <= data_valid   [i+1];
					ptab_addr    [i] <= ptab_addr    [i+1];
					exe_code     [i] <= exe_code     [i+1];
					delot_flag   [i] <= delot_flag   [i+1];
				end
			end				

		end	
		else begin
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin 
				if(i<=`ITEM_NUMBER-2)begin
					item_busy    [i] <= item_busy    [i+1];
					pc           [i] <= pc           [i+1];
					dst          [i] <= dst          [i+1];
					src0         [i] <= src0         [i+1];
					src1         [i] <= src1         [i+1];
					imme         [i] <= imme         [i+1];
					inst_type    [i] <= inst_type    [i+1];
					inst_meaning [i] <= inst_meaning [i+1];
					data_valid   [i] <= data_valid   [i+1];
					ptab_addr    [i] <= ptab_addr    [i+1];
					exe_code     [i] <= exe_code     [i+1];
					delot_flag   [i] <= delot_flag   [i+1];
				end
				else begin
					item_busy    [i] <= 1'b0;
					pc           [i] <= 32'b0;
					dst          [i] <= 5'b0;
					src0         [i] <= 5'b0;
					src1         [i] <= 5'b0;
					imme         [i] <= 32'b0;
					inst_type    [i] <= 4'b0;
					inst_meaning [i] <= 6'b0;
					data_valid   [i] <= 6'b0;
					ptab_addr    [i] <= 5'b0;
					exe_code     [i] <= 5'h10;
					delot_flag   [i] <= 1'b0;
				end
			end			
		end		
	end
	else if(issue_enable == 2'b10)begin
		if((issue_queue_is_free == 2'b10)&&(push_in_fifo))begin
			if(current_item >6'h01)begin
				item_busy    [current_item-2] <= 1'b1;
				pc           [current_item-2] <= inst0_pc;
				dst          [current_item-2] <= inst0_dst;
				src0         [current_item-2] <= inst0_src0;
				src1         [current_item-2] <= inst0_src1;
				imme         [current_item-2] <= inst0_imme;
				inst_type    [current_item-2] <= inst0_inst_type;
				inst_meaning [current_item-2] <= inst0_meaning;
				data_valid   [current_item-2] <= is_decode_valid_0;
				ptab_addr    [current_item-2] <= inst0_ptab_addr;
				exe_code     [current_item-2] <= inst0_exe_code;
				delot_flag   [current_item-2] <= inst0_delot_flag;	
			
				item_busy    [current_item-1] <= 1'b1;
				pc           [current_item-1] <= inst1_pc;
				dst          [current_item-1] <= inst1_dst;
				src0         [current_item-1] <= inst1_src0;
				src1         [current_item-1] <= inst1_src1;
				imme         [current_item-1] <= inst1_imme;
				inst_type    [current_item-1] <= inst1_inst_type;
				inst_meaning [current_item-1] <= inst1_meaning;	
				data_valid   [current_item-1] <= is_decode_valid_1;
				ptab_addr    [current_item-1] <= inst1_ptab_addr;
				exe_code     [current_item-1] <= inst1_exe_code;
				delot_flag   [current_item-1] <= inst1_delot_flag;	

				for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin 
					if((i!=current_item-2)&&(i!=current_item-1)&&(i<=`ITEM_NUMBER-3))begin
					item_busy    [i] <= item_busy    [i+2];
					pc           [i] <= pc           [i+2];
					dst          [i] <= dst          [i+2];
					src0         [i] <= src0         [i+2];
					src1         [i] <= src1         [i+2];
					imme         [i] <= imme         [i+2];
					inst_type    [i] <= inst_type    [i+2];
					inst_meaning [i] <= inst_meaning [i+2];
					data_valid   [i] <= data_valid   [i+2];
					ptab_addr    [i] <= ptab_addr    [i+2];
					exe_code     [i] <= exe_code     [i+2];
					delot_flag   [i] <= delot_flag   [i+2];
				end
				if((i!=current_item-2)&&(i!=current_item-1)&&(i>`ITEM_NUMBER-3))begin
					item_busy    [i] <= 1'b0;
					pc           [i] <= 32'b0;
					dst          [i] <= 5'b0;
					src0         [i] <= 5'b0;
					src1         [i] <= 5'b0;
					imme         [i] <= 32'b0;
					inst_type    [i] <= 4'b0;
					inst_meaning [i] <= 6'b0;
					data_valid   [i] <= 6'b0;
					ptab_addr    [i] <= 5'b0;
					exe_code     [i] <= 5'h10;
					delot_flag   [i] <= 1'b0;
				end
			end	
			end
			else begin
				item_busy    [0] <= 1'b1;
				pc           [0] <= inst0_pc;
				dst          [0] <= inst0_dst;
				src0         [0] <= inst0_src0;
				src1         [0] <= inst0_src1;
				imme         [0] <= inst0_imme;
				inst_type    [0] <= inst0_inst_type;
				inst_meaning [0] <= inst0_meaning;
				data_valid   [0] <= is_decode_valid_0;
				ptab_addr    [0] <= inst0_ptab_addr;
				exe_code     [0] <= inst0_exe_code;
				delot_flag   [0] <= inst0_delot_flag;	
			
				item_busy    [1] <= 1'b1;
				pc           [1] <= inst1_pc;
				dst          [1] <= inst1_dst;
				src0         [1] <= inst1_src0;
				src1         [1] <= inst1_src1;
				imme         [1] <= inst1_imme;
				inst_type    [1] <= inst1_inst_type;
				inst_meaning [1] <= inst1_meaning;	
				data_valid   [1] <= is_decode_valid_1;
				ptab_addr    [1] <= inst1_ptab_addr;
				exe_code     [1] <= inst1_exe_code;
				delot_flag   [1] <= inst1_delot_flag;	
				for (i=2; i<=`ITEM_NUMBER-1; i=i+1)begin
					item_busy    [i] <= 1'b0;
					pc           [i] <= 32'b0;
					dst          [i] <= 5'b0;
					src0         [i] <= 5'b0;
					src1         [i] <= 5'b0;
					imme         [i] <= 32'b0;
					inst_type    [i] <= 4'b0;
					inst_meaning [i] <= 6'b0;	
					data_valid   [i] <= 6'b0;
					ptab_addr    [i] <= 5'b0;
					exe_code     [i] <= 5'h10;	
					delot_flag   [i] <= 1'b0;
				end
			end
			
		end	
		else if((issue_queue_is_free == 2'b01)&&(push_in_fifo))begin
			item_busy    [current_item-2] <= 1'b1;
			pc           [current_item-2] <= inst0_pc;
			dst          [current_item-2] <= inst0_dst;
			src0         [current_item-2] <= inst0_src0;
			src1         [current_item-2] <= inst0_src1;
			imme         [current_item-2] <= inst0_imme;
			inst_type    [current_item-2] <= inst0_inst_type;
			inst_meaning [current_item-2] <= inst0_meaning;
			data_valid   [current_item-2] <= is_decode_valid_0;
			ptab_addr    [current_item-2] <= inst0_ptab_addr;
			exe_code     [current_item-2] <= inst0_exe_code;	
			delot_flag   [current_item-2] <= inst0_delot_flag;	
			
			
			item_busy    [current_item-1] <= 1'b1;
			pc           [current_item-1] <= inst1_pc;
			dst          [current_item-1] <= inst1_dst;
			src0         [current_item-1] <= inst1_src0;
			src1         [current_item-1] <= inst1_src1;
			imme         [current_item-1] <= inst1_imme;
			inst_type    [current_item-1] <= inst1_inst_type;
			inst_meaning [current_item-1] <= inst1_meaning;	
			data_valid   [current_item-1] <= is_decode_valid_1;
			ptab_addr    [current_item-1] <= inst1_ptab_addr;
			exe_code     [current_item-1] <= inst1_exe_code;		
			delot_flag   [current_item-1] <= inst1_delot_flag;				
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin 
				if((i!=current_item-2)&&(i!=current_item-1)&&(i<=`ITEM_NUMBER-3))begin
					item_busy    [i] <= item_busy    [i+2];
					pc           [i] <= pc           [i+2];
					dst          [i] <= dst          [i+2];
					src0         [i] <= src0         [i+2];
					src1         [i] <= src1         [i+2];
					imme         [i] <= imme         [i+2];
					inst_type    [i] <= inst_type    [i+2];
					inst_meaning [i] <= inst_meaning [i+2];
					data_valid   [i] <= data_valid   [i+2];
					ptab_addr    [i] <= ptab_addr    [i+2];
					exe_code     [i] <= exe_code     [i+2];		
					delot_flag   [i] <= delot_flag   [i+2];
				end
				if((i!=current_item-2)&&(i!=current_item-1)&&(i>`ITEM_NUMBER-3))begin
					item_busy    [i] <= 1'b0;
					pc           [i] <= 32'b0;
					dst          [i] <= 5'b0;
					src0         [i] <= 5'b0;
					src1         [i] <= 5'b0;
					imme         [i] <= 32'b0;
					inst_type    [i] <= 4'b0;
					inst_meaning [i] <= 6'b0;
					data_valid   [i] <= 6'b0;
					ptab_addr    [i] <= 5'b0;
					exe_code     [i] <= 5'h10;	
					delot_flag   [i] <= 1'b0;					
				end
			end
		end
		else if((issue_queue_is_free == 2'b00)&&(push_in_fifo))begin
			item_busy    [current_item-2] <= 1'b1;
			pc           [current_item-2] <= inst0_pc;
			dst          [current_item-2] <= inst0_dst;
			src0         [current_item-2] <= inst0_src0;
			src1         [current_item-2] <= inst0_src1;
			imme         [current_item-2] <= inst0_imme;
			inst_type    [current_item-2] <= inst0_inst_type;
			inst_meaning [current_item-2] <= inst0_meaning;
			data_valid   [current_item-2] <= is_decode_valid_0;
			ptab_addr    [current_item-2] <= inst0_ptab_addr;
			exe_code     [current_item-2] <= inst0_exe_code;	
			delot_flag   [current_item-2] <= inst0_delot_flag;	
			
			item_busy    [current_item-1] <= 1'b1;
			pc           [current_item-1] <= inst1_pc;
			dst          [current_item-1] <= inst1_dst;
			src0         [current_item-1] <= inst1_src0;
			src1         [current_item-1] <= inst1_src1;
			imme         [current_item-1] <= inst1_imme;
			inst_type    [current_item-1] <= inst1_inst_type;
			inst_meaning [current_item-1] <= inst1_meaning;		
			data_valid   [current_item-1] <= is_decode_valid_1;
			ptab_addr    [current_item-1] <= inst1_ptab_addr;
			exe_code     [current_item-1] <= inst1_exe_code;	
			delot_flag   [current_item-1] <= inst1_delot_flag;	

			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin 
				if((i!=current_item-2)&&(i!=current_item-1)&&(i<=`ITEM_NUMBER-3))begin
					item_busy    [i] <= item_busy    [i+2];
					pc           [i] <= pc           [i+2];
					dst          [i] <= dst          [i+2];
					src0         [i] <= src0         [i+2];
					src1         [i] <= src1         [i+2];
					imme         [i] <= imme         [i+2];
					inst_type    [i] <= inst_type    [i+2];
					inst_meaning [i] <= inst_meaning [i+2];
					data_valid   [i] <= data_valid   [i+2];
					ptab_addr    [i] <= ptab_addr    [i+2];
					exe_code     [i] <= exe_code     [i+2];		
					delot_flag   [i] <= delot_flag   [i+2];
				end
			end
		end
		else begin
			for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin 
				if(i<=`ITEM_NUMBER-3)begin
					item_busy    [i] <= item_busy    [i+2];
					pc           [i] <= pc           [i+2];
					dst          [i] <= dst          [i+2];
					src0         [i] <= src0         [i+2];
					src1         [i] <= src1         [i+2];
					imme         [i] <= imme         [i+2];
					inst_type    [i] <= inst_type    [i+2];
					inst_meaning [i] <= inst_meaning [i+2];
					data_valid   [i] <= data_valid   [i+2];
					ptab_addr    [i] <= ptab_addr    [i+2];
					exe_code     [i] <= exe_code     [i+2];
					delot_flag   [i] <= delot_flag   [i+2];
				end
				else begin
					item_busy    [i] <= 1'b0;
					pc           [i] <= 32'b0;
					dst          [i] <= 5'b0;
					src0         [i] <= 5'b0;
					src1         [i] <= 5'b0;
					imme         [i] <= 32'b0;
					inst_type    [i] <= 4'b0;
					inst_meaning [i] <= 6'b0;
					data_valid   [i] <= 6'b0;
					ptab_addr    [i] <= 5'b0;
					exe_code     [i] <= 5'h10;
					delot_flag   [i] <= 1'b1;
				end
			end			
		end
				
	end

end


always @ (*)begin
	if(!item_busy[0])begin
		current_item = 6'd00;
	end
	else  if(!item_busy[1])begin
		current_item = 6'd01;
	end
	else  if(!item_busy[2])begin
		current_item = 6'd02;
	end
	else  if(!item_busy[3])begin
		current_item = 6'd03;
	end
	else  if(!item_busy[4])begin
		current_item = 6'd04;
	end
	else  if(!item_busy[5])begin
		current_item = 6'd05;
	end
	else  if(!item_busy[6])begin
		current_item = 6'd06;
	end
	else  if(!item_busy[7])begin
		current_item = 6'd07;
	end
	else  if(!item_busy[8])begin
		current_item = 6'd08;
	end
	else  if(!item_busy[9])begin
		current_item = 6'd09;
	end
	else  if(!item_busy[10])begin
		current_item = 6'd10;
	end
	else  if(!item_busy[11])begin
		current_item = 6'd11;
	end
	else  if(!item_busy[12])begin
		current_item = 6'd12;
	end
	else  if(!item_busy[13])begin
		current_item = 6'd13;
	end
	else  if(!item_busy[14])begin
		current_item = 6'd14;
	end
	else  if(!item_busy[15])begin
		current_item = 6'd15;
	end
	else  if(!item_busy[16])begin
		current_item = 6'd16;
	end
	else  if(!item_busy[17])begin
		current_item = 6'd17;
	end
	else  if(!item_busy[18])begin
		current_item = 6'd18;
	end
	else  if(!item_busy[19])begin
		current_item = 6'd19;
	end
	else  if(!item_busy[20])begin
		current_item = 6'd20;
	end
	else  if(!item_busy[21])begin
		current_item = 6'd21;
	end
	else  if(!item_busy[22])begin
		current_item = 6'd22;
	end
	else  if(!item_busy[23])begin
		current_item = 6'd23;
	end
	else  if(!item_busy[24])begin
		current_item = 6'd24;
	end
	else  if(!item_busy[25])begin
		current_item = 6'd25;
	end
	else  if(!item_busy[26])begin
		current_item = 6'd26;
	end
	else  if(!item_busy[27])begin
		current_item = 6'd27;
	end
	else  if(!item_busy[28])begin
		current_item = 6'd28;
	end
	else  if(!item_busy[29])begin
		current_item = 6'd29;
	end
	else  if(!item_busy[30])begin
		current_item = 6'd30;
	end
	else  if(!item_busy[31])begin
		current_item = 6'd31;
	end
	else  begin
		current_item = 6'd32;
	end
	
	
	if(current_item == 6'd32)begin
		issue_queue_is_free = 2'b00;
		
		if(issue_enable == 2'b10) begin
			issue_queque_is_full = 1'b0;
		end
		else begin
			issue_queque_is_full = 1'b1;
		end
	end
	else if (current_item == 6'd31)begin
		issue_queue_is_free = 2'b01;
		
		if(issue_enable == 2'b00) begin
			issue_queque_is_full = 1'b1;
		end
		else begin
			issue_queque_is_full = 1'b0;
		end
	end
	else begin
		issue_queue_is_free  = 2'b10;
		issue_queque_is_full = 1'b0;
	end
end
	assign is_allow_in = ((issue_queue_is_free == 2'b00) && (issue_enable ==  2'b10))? 1'b1 :
	                     ((issue_queue_is_free == 2'b01) && (issue_enable ==  2'b01))? 1'b1 :
	                     (issue_queue_is_free == 2'b10)?                              1'b1 : 1'b0;

endmodule