`timescale 1ns / 1ns
`include "isa.h"
`include "cpu.h"


module dispatch(
input clk,
input rst_,
input flush,

//----from issue_queue----//
input [106:0] inst0_to_dispatch,
input [106:0] inst1_to_dispatch,

//---- output to issue_queue----//
output reg [1:0]  issue_enable,

input ex_allin,

//----------- output to EX -----------//
output reg        inst0_to_fu_delot_flag,
output reg        inst1_to_fu_delot_flag,
output reg [4:0]  inst0_to_fu_dst,
output reg [4:0]  inst1_to_fu_dst,
output reg [5:0]  inst0_to_fu_meaning,
output reg [5:0]  inst1_to_fu_meaning,
output reg [4:0]  inst0_to_fu_exe_code,
output reg [4:0]  inst1_to_fu_exe_code,
output reg [4:0]  inst0_to_fu_ptab_addr,
output reg [4:0]  inst1_to_fu_ptab_addr,
output reg [31:0] inst0_to_fu_pc,
output reg [31:0] inst1_to_fu_pc,
output reg        inst0_to_fu_valid,
output reg        inst1_to_fu_valid,



output reg [4:0]  inst0_to_fu_src0,
output reg [4:0]  inst0_to_fu_src1,
output reg [4:0]  inst1_to_fu_src0,
output reg [4:0]  inst1_to_fu_src1,
output reg [31:0] inst0_to_fu_imme,
output reg [31:0] inst1_to_fu_imme,
output reg [5:0]  inst0_to_fu_data_valid,
output reg [5:0]  inst1_to_fu_data_valid,

output            is_valid_ns,
input             is_valid
    
);

//----handshake----//



wire is_ready_go;

/*
always @(posedge clk or negedge rst_) begin
	if (!rst_) begin
		is_valid <= 1'b0;
	end
	else if (is_allow_in) begin
		is_valid <= id_valid_ns_i;
	end
end

reg id_valid_ns_i;

always@(posedge clk)begin
	id_valid_ns_i <= id_valid_ns;
end
*/

assign is_ready_go = inst0_ok | inst1_ok;

//assign is_valid_ns = is_valid && is_ready_go; 
assign is_valid_ns = is_ready_go;  //qzy 

//assign is_allin = !is_valid || is_ready_go && ex_allin; 





//----dispatch data from issue_queue----//
wire [31:0] inst0_pc;
wire [31:0] inst0_imme;
wire [4:0]  inst0_dst;
wire [4:0]  inst0_src0;
wire [4:0]  inst0_src1;
wire [3:0]  inst0_type;
wire [5:0]  inst0_meaning;
wire [4:0]  inst0_ptab_addr;
wire [4:0]  inst0_exe_code;

wire        inst0_delot_flag;
wire        inst0_item_busy;
wire [5:0]  inst0_data_valid;
wire [5:0]  inst1_data_valid;

wire [31:0] inst1_pc;
wire [31:0] inst1_imme;
wire [4:0]  inst1_dst;
wire [4:0]  inst1_src0;
wire [4:0]  inst1_src1;
wire [3:0]  inst1_type;
wire [5:0]  inst1_meaning;
wire [4:0]  inst1_ptab_addr;
wire [4:0]  inst1_exe_code;

wire        inst1_delot_flag;
wire        inst1_item_busy;


//----conflict_detect----//
reg inst0_load_store_detect;
reg inst1_load_store_detect;

reg inst0_mul_div_detect;
reg inst1_mul_div_detect;

reg inst0_mf_hilo_detect;
reg inst1_mf_hilo_detect;

reg inst0_mt_hilo_detect;
reg inst1_mt_hilo_detect;

wire inst0_issue_enable;
wire inst1_issue_enable;

wire inst0_ok;
wire inst1_ok;
reg inst0_conflict_with_inst1;




//----input from issue_queue----//
//assign {inst0_pc,inst0_dst,inst0_src0,inst0_src1,inst0_imme,inst0_type,inst0_meaning,inst0_data_valid,inst0_ptab_addr,inst0_exe_code,inst0_delot_flag,inst0_item_busy} = inst0_to_dispatch;
//assign {inst1_pc,inst1_dst,inst1_src0,inst1_src1,inst1_imme,inst1_type,inst1_meaning,inst1_data_valid,inst1_ptab_addr,inst1_exe_code,inst1_delot_flag,inst1_item_busy} = inst1_to_dispatch;

assign inst0_pc         = inst0_to_dispatch [106:75];
assign inst0_dst        = inst0_to_dispatch [74:70];
assign inst0_src0       = inst0_to_dispatch [69:65];
assign inst0_src1       = inst0_to_dispatch [64:60];
assign inst0_imme       = inst0_to_dispatch [59:28];
assign inst0_type       = inst0_to_dispatch [27:24];
assign inst0_meaning    = inst0_to_dispatch [23:18];
assign inst0_data_valid = inst0_to_dispatch [17:12];
assign inst0_ptab_addr  = inst0_to_dispatch [11:7];
assign inst0_exe_code   = inst0_to_dispatch [6:2];
assign inst0_delot_flag = inst0_to_dispatch [1];
assign inst0_item_busy  = inst0_to_dispatch [0];


assign inst1_pc         = inst1_to_dispatch [106:75];
assign inst1_dst        = inst1_to_dispatch [74:70];
assign inst1_src0       = inst1_to_dispatch [69:65];
assign inst1_src1       = inst1_to_dispatch [64:60];
assign inst1_imme       = inst1_to_dispatch [59:28];
assign inst1_type       = inst1_to_dispatch [27:24];
assign inst1_meaning    = inst1_to_dispatch [23:18];
assign inst1_data_valid = inst1_to_dispatch [17:12];
assign inst1_ptab_addr  = inst1_to_dispatch [11:7];
assign inst1_exe_code   = inst1_to_dispatch [6:2];
assign inst1_delot_flag = inst1_to_dispatch [1];
assign inst1_item_busy  = inst1_to_dispatch [0];

reg inst0_branch_detect;
reg inst1_branch_detect;


reg inst0_branch_conflict;
reg inst1_branch_conflict;

assign inst0_ok = inst0_item_busy && (!inst0_branch_conflict);
assign inst1_ok = (inst0_ok & inst1_item_busy &  (!inst0_load_store_detect) & (!inst1_load_store_detect) & (!inst0_conflict_with_inst1) & (!inst1_branch_conflict))? 1'b1 :
                  (inst0_ok & inst1_item_busy &  (!inst0_load_store_detect) & (inst1_load_store_detect)  & (!inst0_conflict_with_inst1) & (!inst1_branch_conflict))? 1'b1 :
                  (inst0_ok & inst1_item_busy &   inst0_load_store_detect &   (!inst1_load_store_detect) & (!inst0_conflict_with_inst1) & (!inst1_branch_conflict))? 1'b1 :
                  (inst0_ok & inst1_item_busy &   inst0_load_store_detect &   inst1_load_store_detect)? 1'b0 : 1'b0;


assign inst0_issue_enable = inst0_ok & ex_allin & is_valid_ns;
assign inst1_issue_enable = inst1_ok & ex_allin & is_valid_ns & inst0_issue_enable;


always@(*)begin
	if(((inst1_src0 == inst0_dst) && (inst1_data_valid [4] ==1'b1) && (inst0_data_valid[5] ) && (inst0_dst != 5'b0))||((inst1_src1 == inst0_dst) && (inst1_data_valid [3]) && (inst0_data_valid[5] )&& (inst0_dst != 5'b0)))begin
		inst0_conflict_with_inst1 = 1'b1;
	end
	else if(inst0_mul_div_detect   &&    inst1_mf_hilo_detect)begin
		inst0_conflict_with_inst1 = 1'b1;	
	end
	else if(inst0_mt_hilo_detect && inst1_mf_hilo_detect)begin
	   inst0_conflict_with_inst1 = 1'b1;
	end
	else if(inst0_mul_div_detect   &&    !inst1_mf_hilo_detect)begin
		inst0_conflict_with_inst1 = 1'b0;
	end
	else begin
	   inst0_conflict_with_inst1 = 1'b0;
	end
end


//----arbitrate----//
always@(*)begin
	if((inst0_issue_enable)&&(inst1_issue_enable))begin
		issue_enable = 2'b10;
	end
	else if((inst0_issue_enable)&&(!inst1_issue_enable))begin
		issue_enable = 2'b01;
	end
	else begin
		issue_enable = 2'b00;
	end
end





always@(*)begin
    if(inst0_branch_detect)begin
        inst0_branch_conflict = (inst1_delot_flag && inst1_item_busy)? 1'b0 : 1'b1;
    end
    else begin
        inst0_branch_conflict = 1'b0;
    end
    
    if(inst1_branch_detect)begin
        inst1_branch_conflict = 1'b1;
    end
    else begin
        inst1_branch_conflict = 1'b0;
    end


end





always@(*)begin
	if(inst0_item_busy)begin
		case(inst0_meaning)
			`INSN_BEQ    : inst0_branch_detect = 1'b1;
			`INSN_BNE    : inst0_branch_detect = 1'b1;
			`INSN_BGEZ   : inst0_branch_detect = 1'b1;
			`INSN_BGTZ   : inst0_branch_detect = 1'b1;
			`INSN_BLEZ   : inst0_branch_detect = 1'b1;
			`INSN_BLTZ   : inst0_branch_detect = 1'b1;
			`INSN_BLTZAL : inst0_branch_detect = 1'b1;
			`INSN_BGEZAL : inst0_branch_detect = 1'b1;
			`INSN_J      : inst0_branch_detect = 1'b1;
			`INSN_JAL    : inst0_branch_detect = 1'b1;
			`INSN_JR     : inst0_branch_detect = 1'b1;
			`INSN_JALR   : inst0_branch_detect = 1'b1;
			default      : inst0_branch_detect = 1'b0;
		endcase
	end
	else begin
		inst0_branch_detect = 1'b0;
	end

	if(inst1_item_busy)begin
		case(inst1_meaning)
			`INSN_BEQ    : inst1_branch_detect = 1'b1;
			`INSN_BNE    : inst1_branch_detect = 1'b1;
			`INSN_BGEZ   : inst1_branch_detect = 1'b1;
			`INSN_BGTZ   : inst1_branch_detect = 1'b1;
			`INSN_BLEZ   : inst1_branch_detect = 1'b1;
			`INSN_BLTZ   : inst1_branch_detect = 1'b1;
			`INSN_BLTZAL : inst1_branch_detect = 1'b1;
			`INSN_BGEZAL : inst1_branch_detect = 1'b1;
			`INSN_J      : inst1_branch_detect = 1'b1;
			`INSN_JAL    : inst1_branch_detect = 1'b1;
			`INSN_JR     : inst1_branch_detect = 1'b1;
			`INSN_JALR   : inst1_branch_detect = 1'b1;
			default      : inst1_branch_detect = 1'b0;
		endcase
	end
	else begin
		inst1_branch_detect = 1'b0;
	end
end


always @ (*)begin
	if(inst0_item_busy)begin
		case(inst0_meaning)
			`INSN_LB : inst0_load_store_detect = 1'b1;
			`INSN_LBU: inst0_load_store_detect = 1'b1;
			`INSN_LH : inst0_load_store_detect = 1'b1;
			`INSN_LHU: inst0_load_store_detect = 1'b1;
			`INSN_LW : inst0_load_store_detect = 1'b1;
			`INSN_SB : inst0_load_store_detect = 1'b1;
			`INSN_SH : inst0_load_store_detect = 1'b1;
			`INSN_SW : inst0_load_store_detect = 1'b1;
			default  : inst0_load_store_detect = 1'b0;
		endcase
	end
	else begin
		inst0_load_store_detect = 1'b0;
	end
	
	if(inst1_item_busy)begin
		case(inst0_meaning)
			`INSN_LB : inst1_load_store_detect = 1'b1;
			`INSN_LBU: inst1_load_store_detect = 1'b1;
			`INSN_LH : inst1_load_store_detect = 1'b1;
			`INSN_LHU: inst1_load_store_detect = 1'b1;
			`INSN_LW : inst1_load_store_detect = 1'b1;
			`INSN_SB : inst1_load_store_detect = 1'b1;
			`INSN_SH : inst1_load_store_detect = 1'b1;
			`INSN_SW : inst1_load_store_detect = 1'b1;
			default  : inst1_load_store_detect = 1'b0;
		endcase
	end
	else begin
		inst1_load_store_detect = 1'b0;
	end

	if(inst0_item_busy)begin
		case(inst0_meaning)
			`INSN_DIV  : inst0_mul_div_detect = 1'b1;
			`INSN_DIVU : inst0_mul_div_detect = 1'b1;
			`INSN_MULT : inst0_mul_div_detect = 1'b1;
			`INSN_MULTU: inst0_mul_div_detect = 1'b1;
			default    : inst0_mul_div_detect = 1'b0;
		endcase
	end
	else begin
		inst0_mul_div_detect = 1'b0;
	end

	if(inst1_item_busy)begin
		case(inst1_meaning)
			`INSN_DIV  : inst1_mul_div_detect = 1'b1;
			`INSN_DIVU : inst1_mul_div_detect = 1'b1;
			`INSN_MULT : inst1_mul_div_detect = 1'b1;
			`INSN_MULTU: inst1_mul_div_detect = 1'b1;
			default    : inst1_mul_div_detect = 1'b0;
		endcase
	end
	else begin
		inst1_mul_div_detect = 1'b0;
	end

	if(inst0_item_busy)begin
		case(inst0_meaning)
			`INSN_MFHI : inst0_mf_hilo_detect = 1'b1;
			`INSN_MFLO : inst0_mf_hilo_detect = 1'b1;
			default    : inst0_mf_hilo_detect = 1'b0;
		endcase
	end
	else begin
		inst0_mf_hilo_detect = 1'b0;
	end

	if(inst1_item_busy)begin
		case(inst1_meaning)
			`INSN_MFHI : inst1_mf_hilo_detect = 1'b1;
			`INSN_MFLO : inst1_mf_hilo_detect = 1'b1;
			default    : inst1_mf_hilo_detect = 1'b0;
		endcase
	end
	else begin
		inst1_mf_hilo_detect = 1'b0;
	end

	if(inst0_item_busy)begin
		case(inst0_meaning)
			`INSN_MTHI : inst0_mt_hilo_detect = 1'b1;
			`INSN_MTLO : inst0_mt_hilo_detect = 1'b1;
			default    : inst0_mt_hilo_detect = 1'b0;
		endcase
	end
	else begin
		inst0_mt_hilo_detect = 1'b0;
	end

	if(inst1_item_busy)begin
		case(inst1_meaning)
			`INSN_MTHI : inst1_mt_hilo_detect = 1'b1;
			`INSN_MTLO : inst1_mt_hilo_detect = 1'b1;
			default    : inst1_mt_hilo_detect = 1'b0;
		endcase
	end
	else begin
		inst1_mt_hilo_detect = 1'b0;
	end


end



always @ (posedge clk )begin
	if(!rst_ | flush)begin
		inst0_to_fu_pc 			  <= 32'b0;
		inst0_to_fu_ptab_addr     <= 5'b0;
		inst0_to_fu_dst		      <= 5'b0;
		inst0_to_fu_exe_code      <= 5'h10;
		inst0_to_fu_imme	      <= 32'b0;
		inst0_to_fu_meaning       <= 6'b0;
		inst0_to_fu_src0		  <= 5'b0;
		inst0_to_fu_src1          <= 5'b0;
		inst0_to_fu_data_valid    <= 6'b0;
		inst0_to_fu_valid         <= 1'b0;
		inst0_to_fu_delot_flag    <= 1'b0;
	end
	else if(inst0_issue_enable)begin			
		inst0_to_fu_pc 				 <= (!flush)? inst0_pc         : 32'b0;
		inst0_to_fu_ptab_addr        <= (!flush)? inst0_ptab_addr  : 5'b0;
		inst0_to_fu_dst				 <= (!flush)? inst0_dst        : 5'b0;
		inst0_to_fu_exe_code         <= (!flush)? inst0_exe_code   : 5'h10;
		inst0_to_fu_imme			 <= (!flush)? inst0_imme       : 32'b0;
		inst0_to_fu_meaning          <= (!flush)? inst0_meaning    : 6'b0;
		inst0_to_fu_src0			 <= (!flush)? inst0_src0       : 5'b0;
		inst0_to_fu_src1             <= (!flush)? inst0_src1       : 5'b0;
		inst0_to_fu_data_valid       <= (!flush)? inst0_data_valid : 6'b0;
		inst0_to_fu_valid            <= (!flush)? inst0_item_busy  : 1'b0;
		inst0_to_fu_delot_flag       <= (!flush)? inst0_delot_flag : 1'b0;
	end
	/*else begin
		inst0_to_fu_pc 			  <= 32'b0;
		inst0_to_fu_ptab_addr     <= 5'b00000;
		inst0_to_fu_dst		      <= 5'b00000;
		inst0_to_fu_exe_code      <= 5'h10;
		inst0_to_fu_imme	      <= 32'b0;
		inst0_to_fu_meaning       <= 6'b00000;
		inst0_to_fu_src0		  <= 5'b00000;
		inst0_to_fu_src1          <= 5'b00000;
		inst0_to_fu_data_valid    <= 6'b00000;
		inst0_to_fu_valid         <= 1'b0;
		inst0_to_fu_delot_flag    <= 1'b0;
	end*/

	
	if(!rst_ | flush)begin
		inst1_to_fu_pc 			  <= 32'b0;
		inst1_to_fu_ptab_addr     <= 5'b0;
		inst1_to_fu_dst           <= 5'b0;
		inst1_to_fu_exe_code      <= 5'h10;
		inst1_to_fu_imme          <= 32'b0;
		inst1_to_fu_meaning       <= 6'b0;
		inst1_to_fu_src0		  <= 5'b0;
		inst1_to_fu_src1          <= 5'b0;
		inst1_to_fu_data_valid    <= 6'b0;
		inst1_to_fu_valid         <= 1'b0;
		inst1_to_fu_delot_flag    <= 1'b0;
	end		
	else if(inst1_issue_enable)begin			
		inst1_to_fu_pc 				 <= (!flush)? inst1_pc         : 32'b0;
		inst1_to_fu_ptab_addr        <= (!flush)? inst1_ptab_addr  : 5'b0;
		inst1_to_fu_dst				 <= (!flush)? inst1_dst        : 5'b0;
		inst1_to_fu_exe_code         <= (!flush)? inst1_exe_code   : 5'h10;
		inst1_to_fu_imme			 <= (!flush)? inst1_imme       : 32'b0;
		inst1_to_fu_meaning          <= (!flush)? inst1_meaning    : 6'b0;
		inst1_to_fu_src0			 <= (!flush)? inst1_src0       : 5'b0;
		inst1_to_fu_src1             <= (!flush)? inst1_src1       : 5'b0;
		inst1_to_fu_data_valid       <= (!flush)? inst1_data_valid : 6'b0;
		inst1_to_fu_valid            <= (!flush)? inst1_item_busy  : 1'b0;
		inst1_to_fu_delot_flag       <= (!flush)? inst1_delot_flag : 1'b0;
	end
	else if(!inst1_ok && inst0_issue_enable)begin
		inst1_to_fu_pc 			  <= 32'b0;
		inst1_to_fu_ptab_addr     <= 5'b0;
		inst1_to_fu_dst           <= 5'b0;
		inst1_to_fu_exe_code      <= 5'h10;
		inst1_to_fu_imme          <= 32'b0;
		inst1_to_fu_meaning       <= 6'b0;
		inst1_to_fu_src0		  <= 5'b0;
		inst1_to_fu_src1          <= 5'b0;
		inst1_to_fu_data_valid    <= 6'b0;
		inst1_to_fu_valid         <= 1'b0;
		inst1_to_fu_delot_flag    <= 1'b0;
	end	

end






endmodule