`define SB_ITEM_NUMBER  16
`define SB_DATA_NOP 32'b0
`define SB_ADDR_NOP 32'b0
`define BUSY_CLEAR  32'b0
`define SB_RWEN_NOP 4'b0
module store_buffer(
	input clk,
	input rst_,
	input flush,
	input [31:0] inst_load_pc,
	input [31:0] in_store_data,
	input [31:0] in_store_addr,
	input [3:0]  in_store_rwen,
	input        in_store_valid,
	input [31:0] in_store_pc,
	//input        in_store_uncache,
	input        cache_is_busy,
	input [31:0] store_buffer_load_addr,
	input store_buffer_search_enanble,

	output reg        store_buffer_hit,
	output reg [31:0] store_buffer_load_data,
    output reg [3:0]  store_buffer_load_data_rwen,

	
	output [31:0] out_store_data,
	output [31:0] out_store_addr,
	output [3:0]  out_store_rwen,
	output  out_store_en,
	output        out_store_uncache,
	output        out_store_rw,
	output   reg     store_buffer_load_data_valid,
	
	output reg store_buffer_is_empty,
	output reg store_buffer_allow_in
);
	reg [31:0] store_buffer_data                  [0:`SB_ITEM_NUMBER-1];
	reg [31:0] store_buffer_addr                  [0:`SB_ITEM_NUMBER-1];
	reg        store_item_busy                    [0:`SB_ITEM_NUMBER-1];
	reg [3:0]  store_buffer_rwen                  [0:`SB_ITEM_NUMBER-1];
	//reg        [0:`SB_ITEM_NUMBER-1]              store_buffer_uncache;               //fresh
	reg        [`SB_ITEM_NUMBER-1:0]              store_buffer_hit_store_buffer_item; //fresh	
	
	reg [4:0] current_item;
	reg store_buffer_is_full;
	
	integer i;
	integer j;
	
reg [31:0] last_store_data;
reg [31:0] last_store_addr;
reg last_store_en;
reg hit_and_cache_is_free;
	
	reg [31:0]last_load_pc;
	reg [31:0]last_store_pc;
	reg [3:0] last_store_rwen;
	
    reg cache_is_busy_i;

always@(posedge clk)begin
    last_load_pc <= inst_load_pc;
    last_store_pc <= in_store_pc;
    cache_is_busy_i <= cache_is_busy;
end

always@(*)begin
    hit_and_cache_is_free = (!cache_is_busy_i)&&(store_buffer_hit);
end

	
	assign out_store_data    = store_buffer_data    [0];
	assign out_store_addr    = store_buffer_addr    [0];
	assign out_store_rwen    = store_buffer_rwen    [0];
	//assign out_store_en      = 1'b1;
	assign out_store_en      = store_item_busy[0];
	//assign out_store_uncache = (store_item_busy      [0])&( store_buffer_uncache [0]);
	assign out_store_rw      = 1'b1;
	
always @(posedge clk)begin

	if(!rst_)begin
	
		for(i=0;i<`SB_ITEM_NUMBER;i=i+1)begin
			store_buffer_data    [i] <= `SB_DATA_NOP;
			store_buffer_addr    [i] <= `SB_ADDR_NOP;
			store_item_busy      [i] <= `BUSY_CLEAR;
			store_buffer_rwen    [i] <= `SB_RWEN_NOP;
//			store_buffer_uncache [i] <= 1'b0;
		end
		
	end
	else if((!store_buffer_is_full)&&(cache_is_busy))begin
	
		store_buffer_data    [current_item] <= (in_store_valid && (last_store_pc != in_store_pc))? in_store_data : `SB_DATA_NOP;
		store_buffer_addr    [current_item] <= (in_store_valid && (last_store_pc != in_store_pc))? in_store_addr : `SB_ADDR_NOP;
		store_item_busy      [current_item] <= (in_store_valid && (last_store_pc != in_store_pc))? 1'b1 : 1'b0;		
		store_buffer_rwen    [current_item] <= (in_store_valid && (last_store_pc != in_store_pc))? in_store_rwen : `SB_RWEN_NOP;
		//store_buffer_uncache [current_item] <= (in_store_valid)? in_store_uncache: 1'b0;
		
		for(i=0;i<`SB_ITEM_NUMBER;i=i+1)begin
			if(i !=current_item)begin
				store_buffer_data    [i] <= store_buffer_data    [i];
				store_buffer_addr    [i] <= store_buffer_addr    [i];
				store_item_busy      [i] <= store_item_busy      [i];
				store_buffer_rwen    [i] <= store_buffer_rwen    [i];
				//store_buffer_uncache [i] <= store_buffer_uncache [i];
			end
		end
		
	end
	else if((!store_buffer_is_full)&&(!cache_is_busy))begin
		
		if(current_item>=5'b1)begin
		
			store_buffer_data    [current_item-1] <= (in_store_valid && (last_store_pc != in_store_pc))? in_store_data : `SB_DATA_NOP;
			store_buffer_addr    [current_item-1] <= (in_store_valid && (last_store_pc != in_store_pc))? in_store_addr : `SB_ADDR_NOP;
			store_item_busy      [current_item-1] <= (in_store_valid && (last_store_pc != in_store_pc))? 1'b1 : 1'b0;		
			store_buffer_rwen    [current_item-1] <= (in_store_valid && (last_store_pc != in_store_pc))? in_store_rwen : `SB_RWEN_NOP;	
			//store_buffer_uncache [current_item-1] <= (in_store_valid)? in_store_uncache: 1'b0;
			
			for(i=0;i<`SB_ITEM_NUMBER;i=i+1)begin
				if((i !=current_item-1)&&(i <= `SB_ITEM_NUMBER-2))begin
					store_buffer_data    [i] <= store_buffer_data    [i+1];
					store_buffer_addr    [i] <= store_buffer_addr    [i+1];
					store_item_busy      [i] <= store_item_busy      [i+1];
					store_buffer_rwen    [i] <= store_buffer_rwen    [i+1];
//store_buffer_uncache [i] <= store_buffer_uncache [i+1];
				end
				else if(i == `SB_ITEM_NUMBER-1)begin
					store_buffer_data    [i] <= `SB_DATA_NOP;
					store_buffer_addr    [i] <= `SB_ADDR_NOP;
					store_item_busy      [i] <= `BUSY_CLEAR;	
					store_buffer_rwen    [i] <= `SB_RWEN_NOP;
//store_buffer_uncache [i] <= 1'b0;
				end
			end
		end
		else begin
			store_buffer_data    [0] <= (in_store_valid && (last_store_pc != in_store_pc))? in_store_data : `SB_DATA_NOP;
			store_buffer_addr    [0] <= (in_store_valid && (last_store_pc != in_store_pc))? in_store_addr : `SB_ADDR_NOP;
			store_item_busy      [0] <= (in_store_valid && (last_store_pc != in_store_pc))? 1'b1 : 1'b0;	
			store_buffer_rwen    [0] <= (in_store_valid && (last_store_pc != in_store_pc))? in_store_rwen : `SB_RWEN_NOP;	
//store_buffer_uncache [0] <= (in_store_valid)? in_store_uncache: 1'b0;
		end
		
	end	
	else if((store_buffer_is_full)&&(!cache_is_busy))begin
	
		store_buffer_data    [current_item-1] <= (in_store_valid && (last_store_pc != in_store_pc))? in_store_data : `SB_DATA_NOP;
		store_buffer_addr    [current_item-1] <= (in_store_valid && (last_store_pc != in_store_pc))? in_store_addr : `SB_ADDR_NOP;
		store_item_busy      [current_item-1] <= (in_store_valid && (last_store_pc != in_store_pc))? 1'b1 : 1'b0;		
		store_buffer_rwen    [current_item-1] <= (in_store_valid && (last_store_pc != in_store_pc))? in_store_rwen : `SB_RWEN_NOP;	
//store_buffer_uncache [current_item-1] <= (in_store_valid)? in_store_uncache: 1'b0;
		
		for(i=0; i<`SB_ITEM_NUMBER; i=i+1)begin
			if((i !=current_item-1)&&(i <= `SB_ITEM_NUMBER-2))begin
				store_buffer_data    [i] <= store_buffer_data    [i+1];
				store_buffer_addr    [i] <= store_buffer_addr    [i+1];
				store_item_busy      [i] <= store_item_busy      [i+1];
				store_buffer_rwen    [i] <= store_buffer_rwen    [i+1];
//store_buffer_uncache [i] <= store_buffer_uncache [i+1];
			end
			if(i == `SB_ITEM_NUMBER-1)begin
				store_buffer_data    [i] <= `SB_DATA_NOP;
				store_buffer_addr    [i] <= `SB_ADDR_NOP;
				store_item_busy      [i] <= `BUSY_CLEAR;	
				store_buffer_rwen    [i] <= `SB_RWEN_NOP;
	//			store_buffer_uncache [i] <= 1'b0;
			end
		end
		
	end
	else if((store_buffer_is_full)&&(cache_is_busy))begin
	
		for(i=0;i<`SB_ITEM_NUMBER;i=i+1)begin
			store_buffer_data    [i] <= store_buffer_data    [i];
			store_buffer_addr    [i] <= store_buffer_addr    [i];
			store_item_busy      [i] <= store_item_busy      [i];
			store_buffer_rwen    [i] <= store_buffer_rwen    [i];
//store_buffer_uncache [i] <= store_buffer_uncache [i];
		end
		
	end	
	else begin
	
		for(i=0;i<`SB_ITEM_NUMBER;i=i+1)begin
			store_buffer_data    [i] <= store_buffer_data    [i];
			store_buffer_addr    [i] <= store_buffer_addr    [i];
			store_item_busy      [i] <= store_item_busy      [i];
			store_buffer_rwen    [i] <= store_buffer_rwen    [i];
	//		store_buffer_uncache [i] <= store_buffer_uncache [i];
		end
		
	end		
end

/*always@(posedge clk)begin
	if(store_buffer_search_enanble)begin
		for(i=`SB_ITEM_NUMBER-1;i>=5'b0;i=i-1)begin
			if(store_buffer_addr [i] == store_buffer_load_addr)begin
				store_buffer_hit_store_buffer_item [i]     <= 1'b1;
			end
			else begin
				store_buffer_hit_store_buffer_item [i]     <= 1'b0;
			end	
		end
	end
end*/// by ysr

always@(posedge clk)begin
    if(!rst_)begin
    last_store_data <= 32'b0;
    last_store_addr <= 32'b0;
    last_store_en   <=  1'b0;
    last_store_rwen <=  4'b0;
    end
    else if(!cache_is_busy)begin
    last_store_data <= out_store_data;
    last_store_addr <= out_store_addr;
    last_store_en   <= out_store_en;
    last_store_rwen <= out_store_rwen;
    end
end

wire [31:0]addr_upper_32bits_select;
assign  addr_upper_32bits_select = 32'hffff_fffc;

always@(posedge clk)begin
	if((store_buffer_search_enanble)&&(inst_load_pc != last_load_pc))begin
		for(i=`SB_ITEM_NUMBER;i>5'b0;i=i-1)begin
			if((((store_buffer_addr [i-1])& addr_upper_32bits_select) == (store_buffer_load_addr & addr_upper_32bits_select)) && (store_item_busy[i-1]))begin//by ysr
	//			store_buffer_hit_store_buffer_item [i-1]     <= (cache_is_busy)?1'b1:1'b0; //0730
				store_buffer_hit_store_buffer_item [i-1]     <= 1'b1;
			end
			else begin
				store_buffer_hit_store_buffer_item [i-1]     <= 1'b0;
			end	
		end	
	end
	else begin
        for(i=`SB_ITEM_NUMBER;i>5'b0;i=i-1)begin
				store_buffer_hit_store_buffer_item [i-1]     <= 1'b0;
		end
	end
end

reg [4:0] store_buffer_hit_num;
always@(*)begin
	store_buffer_hit       = |store_buffer_hit_store_buffer_item;
	casex(store_buffer_hit_store_buffer_item)
	    16'b1xxx_xxxx_xxxx_xxxx: store_buffer_hit_num = 5'd15;
	    16'b01xx_xxxx_xxxx_xxxx: store_buffer_hit_num = 5'd14;
	    16'b001x_xxxx_xxxx_xxxx: store_buffer_hit_num = 5'd13;
	    16'b0001_xxxx_xxxx_xxxx: store_buffer_hit_num = 5'd12;
	    16'b0000_1xxx_xxxx_xxxx: store_buffer_hit_num = 5'd11;
	    16'b0000_01xx_xxxx_xxxx: store_buffer_hit_num = 5'd10;
	    16'b0000_001x_xxxx_xxxx: store_buffer_hit_num = 5'd09;
	    16'b0000_0001_xxxx_xxxx: store_buffer_hit_num = 5'd08;
	    16'b0000_0000_1xxx_xxxx: store_buffer_hit_num = 5'd07;
	    16'b0000_0000_01xx_xxxx: store_buffer_hit_num = 5'd06;
	    16'b0000_0000_001x_xxxx: store_buffer_hit_num = 5'd05;
	    16'b0000_0000_0001_xxxx: store_buffer_hit_num = 5'd04;
	    16'b0000_0000_0000_1xxx: store_buffer_hit_num = 5'd03;
	    16'b0000_0000_0000_01xx: store_buffer_hit_num = 5'd02;
	    16'b0000_0000_0000_001x: store_buffer_hit_num = 5'd01;
	    16'b0000_0000_0000_0001: store_buffer_hit_num = 5'd00;
	    default: store_buffer_hit_num = 5'd16;
	endcase //qzy0730
	/*store_buffer_hit_num   = (store_buffer_hit_store_buffer_item == 16'b1000_0000_0000_0000)? 5'd15 :
				(store_buffer_hit_store_buffer_item == 16'b0100_0000_0000_0000)? 5'd14 :
				(store_buffer_hit_store_buffer_item == 16'b0010_0000_0000_0000)? 5'd13 :
			    (store_buffer_hit_store_buffer_item == 16'b0001_0000_0000_0000)? 5'd12 :
				(store_buffer_hit_store_buffer_item == 16'b0000_1000_0000_0000)? 5'd11 :
				(store_buffer_hit_store_buffer_item == 16'b0000_0100_0000_0000)? 5'd10 :
				(store_buffer_hit_store_buffer_item == 16'b0000_0010_0000_0000)? 5'd09 :
				(store_buffer_hit_store_buffer_item == 16'b0000_0001_0000_0000)? 5'd08 :
				(store_buffer_hit_store_buffer_item == 16'b0000_0000_1000_0000)? 5'd07 :
				(store_buffer_hit_store_buffer_item == 16'b0000_0000_0100_0000)? 5'd06 :
				(store_buffer_hit_store_buffer_item == 16'b0000_0000_0010_0000)? 5'd05 :
				(store_buffer_hit_store_buffer_item == 16'b0000_0000_0001_0000)? 5'd04 :
				(store_buffer_hit_store_buffer_item == 16'b0000_0000_0000_1000)? 5'd03 :
				(store_buffer_hit_store_buffer_item == 16'b0000_0000_0000_0100)? 5'd02 :
				(store_buffer_hit_store_buffer_item == 16'b0000_0000_0000_0010)? 5'd01 :
				(store_buffer_hit_store_buffer_item == 16'b0000_0000_0000_0001)? 5'd00 :5'd16;*/
	
	/*store_buffer_load_data = (store_buffer_hit_num != 5'd16 && hit_and_cache_is_free)? store_buffer_data[store_buffer_hit_num-1] : 
	                         (store_buffer_hit_num != 5'd16 && !hit_and_cache_is_free)? store_buffer_data[store_buffer_hit_num] : 32'b0;*/
	                         
	if((store_buffer_hit_num != 5'd16) && (hit_and_cache_is_free))begin
	   store_buffer_load_data      = (store_buffer_hit_num != 5'b0)? store_buffer_data[store_buffer_hit_num-1] : last_store_data;
	   store_buffer_load_data_rwen = (store_buffer_hit_num != 5'b0)? store_buffer_rwen[store_buffer_hit_num-1] : last_store_rwen;
	end
	else if((store_buffer_hit_num != 5'd16) && (!hit_and_cache_is_free))begin                        
	   store_buffer_load_data      =  store_buffer_data[store_buffer_hit_num];            
	   store_buffer_load_data_rwen =  store_buffer_rwen[store_buffer_hit_num];                         
	end
	else begin
	   store_buffer_load_data      = 32'b0;
	   store_buffer_load_data_rwen = 4'b0;
	end                        
	
	store_buffer_load_data_valid =(store_buffer_hit_num != 5'd16)? 1'b1 : 1'b0;
end




always @ (*)begin
	if(!store_item_busy[0])begin
		current_item = 5'd00;
	end
	else  if(!store_item_busy[1])begin
		current_item = 5'd01;
	end
	else  if(!store_item_busy[2])begin
		current_item = 5'd02;
	end
	else  if(!store_item_busy[3])begin
		current_item = 5'd03;
	end
	else  if(!store_item_busy[4])begin
		current_item = 5'd04;
	end
	else  if(!store_item_busy[5])begin
		current_item = 5'd05;
	end
	else  if(!store_item_busy[6])begin
		current_item = 5'd06;
	end
	else  if(!store_item_busy[7])begin
		current_item = 5'd07;
	end
	else  if(!store_item_busy[8])begin
		current_item = 5'd08;
	end
	else  if(!store_item_busy[9])begin
		current_item = 5'd09;
	end
	else  if(!store_item_busy[10])begin
		current_item = 5'd10;
	end
	else  if(!store_item_busy[11])begin
		current_item = 5'd11;
	end
	else  if(!store_item_busy[12])begin
		current_item = 5'd12;
	end
	else  if(!store_item_busy[13])begin
		current_item = 5'd13;
	end
	else  if(!store_item_busy[14])begin
		current_item = 5'd14;
	end
	else  if(!store_item_busy[15])begin
		current_item = 5'd15;
	end
	else begin
		current_item = 5'd16;
	end
	
	if(current_item == 5'd16)begin
		store_buffer_is_full = 1'b1;
	end
	else begin
		store_buffer_is_full = 1'b0;
	end

	store_buffer_allow_in = (current_item <= 5'd14)? 1'b1 :  
	                       (current_item ==  5'd14 && !in_store_valid)? 1'b1 :
							(!cache_is_busy)? 1'b1 : 1'b0;	
	store_buffer_is_empty = (current_item == 5'd00)? 1'b1 : 1'b0;
end


endmodule