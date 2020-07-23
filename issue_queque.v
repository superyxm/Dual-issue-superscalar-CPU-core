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
integer i;
wire issue_queue_fifo_less_2;
wire pointer_left5_equal;
wire pinter_all_equal;
wire pointer_right_most_equal;
wire issue_queue_fifo_full;
wire issue_queue_fifo_empty;
wire [5:0]write_pointer_add_1;
wire [5:0]read_pointer_add_1;

always @(posedge clk or negedge rst_) begin
	if (!rst_) begin
		is_valid <= 1'b0;
	end
	else if (is_allow_in) begin
		is_valid <= id_valid_ns_i;
	end
end




always@(*)begin
    if(id_valid_ns && is_allow_in)begin
        push_in_fifo = 1'b1;
    end
    else begin
        push_in_fifo = 1'b0;
    end   
end



//----issue_queque_with 32 items----//
reg [106:0] issue_queue_fifo  [0:`ITEM_NUMBER-1];
wire [106:0] inst0_to_dispatch_from_ID;
wire [106:0] inst1_to_dispatch_from_ID;

//----dispatch input data from decoder----//
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

assign inst0_pc         = is_pc            [31:0];
assign inst0_dst        = is_decode_info_0 [54:50];
assign inst0_src0       = is_decode_info_0 [49:45];
assign inst0_src1       = is_decode_info_0 [44:40];
assign inst0_imme       = is_decode_info_0 [39:8];
assign inst0_inst_type  = is_decode_info_0 [7:6];
assign inst0_meaning    = is_decode_info_0 [5:0];
assign inst0_exe_code   = is_exe_code      [4:0];
assign inst0_delot_flag = id_is_delot_flag [0];
assign inst0_ptab_addr  = is_ptab_addr     [4:0];

assign inst1_pc         = is_pc            [63:32];
assign inst1_dst        = is_decode_info_1 [54:50];
assign inst1_src0       = is_decode_info_1 [49:45];
assign inst1_src1       = is_decode_info_1 [44:40];
assign inst1_imme       = is_decode_info_1 [39:8];
assign inst1_inst_type  = is_decode_info_1 [7:6];
assign inst1_meaning    = is_decode_info_1 [5:0];
assign inst1_exe_code   = is_exe_code      [9:5];
assign inst1_delot_flag = id_is_delot_flag [1];
assign inst1_ptab_addr  = is_ptab_addr     [9:5];

wire [1:0] item_busy;
wire [106:0] inst0;
wire [106:0] inst1;
reg [5:0] write_pointer;
reg [5:0] read_pointer;

wire pop_out_fifo_2;
wire pop_out_fifo_1;


assign item_busy[0] = ~issue_queue_fifo_empty;
assign item_busy[1] = ~issue_queue_fifo_less_2;

assign inst0_to_dispatch_from_ID = {inst0_pc,inst0_dst,inst0_src0,inst0_src1,inst0_imme,inst0_inst_type,inst0_meaning,is_decode_valid_0,inst0_ptab_addr,inst0_exe_code,inst0_delot_flag,id_valid_ns_i};
assign inst1_to_dispatch_from_ID = {inst1_pc,inst1_dst,inst1_src0,inst1_src1,inst1_imme,inst1_inst_type,inst1_meaning,is_decode_valid_1,inst1_ptab_addr,inst1_exe_code,inst1_delot_flag,id_valid_ns_i};

assign inst0_to_dispatch = {inst0[106:1],item_busy[0]};
assign inst1_to_dispatch = {inst1[106:1],item_busy[1]};

assign inst0 = issue_queue_fifo [read_pointer[4:0]];
assign inst1 = issue_queue_fifo [read_pointer_add_1[4:0]];



assign pop_out_fifo_2 = (issue_enable == 2'b10);
assign pop_out_fifo_1 = (issue_enable == 2'b01);


always@(posedge clk or negedge rst_)begin
    if(~rst_)begin
        for (i=0; i<=`ITEM_NUMBER-1; i=i+1)begin
            issue_queue_fifo [i] <= 107'b0;
        end
        write_pointer            <= 6'b0;
    end
    else if (flush)begin
        if(issue_enable == 2'b0 && inst0[1]==1'b1)begin
	       issue_queue_fifo [read_pointer[4:0]] <= issue_queue_fifo [read_pointer];
	       write_pointer <= read_pointer;
	    end
	    else begin
	       issue_queue_fifo [read_pointer[4:0]] <= 107'b0;
	       write_pointer <= 6'b0;
	    end
        for (i=1; i<=`ITEM_NUMBER-1; i=i+1)begin
            if(i != read_pointer[4:0])issue_queue_fifo [i] <= 107'b0;
        end	    
    end
    else if(push_in_fifo)begin
        issue_queue_fifo[write_pointer[4:0]]     <= inst0_to_dispatch_from_ID;
        issue_queue_fifo[write_pointer_add_1[4:0] ] <= inst1_to_dispatch_from_ID;
        write_pointer                       <= write_pointer + 6'd2;
    end
    else begin
        write_pointer                       <= write_pointer;
    end    
end

always@(posedge clk or negedge rst_)begin
    if(~rst_)begin
        read_pointer <= 6'b0;
    end
    else if (flush)begin
        if(issue_enable == 2'b0 && inst0[1]==1'b1)begin
	       read_pointer <= read_pointer;
	    end
	    else begin
	       read_pointer <= 6'b0;
	    end   
    end
    else if(pop_out_fifo_2)begin
        read_pointer <= read_pointer + 6'd2;
    end
    else if(pop_out_fifo_1)begin
        read_pointer <= read_pointer + 6'd1;
    end
    else begin 
        read_pointer <= read_pointer;
    end

end



assign pointer_left5_equal      = (write_pointer[4:0] == read_pointer[4:0]);
assign pointer_right_most_equal = (write_pointer[5]   == read_pointer[5]  );
assign pinter_all_equal         = pointer_left5_equal && pointer_right_most_equal;
assign issue_queue_fifo_empty = pinter_all_equal;

assign write_pointer_add_1 = write_pointer + 6'b1;
assign read_pointer_add_1  = read_pointer  + 6'b1;

assign issue_queue_fifo_full = (pointer_left5_equal && (~pointer_right_most_equal)) || 
                               ((write_pointer_add_1[4:0] == read_pointer[4:0]) && (write_pointer_add_1[5] != read_pointer[5]));

assign issue_queue_fifo_less_2 = issue_queue_fifo_empty || 
                                 (write_pointer[5:0] == read_pointer_add_1[5:0]);

assign is_allow_in = ~issue_queue_fifo_full;


endmodule
