`include "config.h"
`include "each_module.h"

/*`define	READ_IDLE             2'b00;
`define	READ_DDR_WAIT         2'b01;
`define	READ_DDR              2'b10;
`define	READ_DDR_END          2'b11;

`define	WRITE_IDLE			  2'b00;
`define	WRITE_DDR_WAIT        2'b01;
`define	WRITE_DDR             2'b10;
`define	WRITE_DDR_END         2'b11;*/

module axi_interface 
/*#(
	parameter	AW_BURST_LEN = 8'd31,
	parameter	AR_BURST_LEN = 8'd31,
	parameter	AW_BURST_STEP = 32'd1,
	parameter	AR_BURST_STEP = 32'd1
	)*/

	(
	/********** global signal **********/
	input 		wire				clk,
	input		wire				reset,
	
	/********** cpu signal **********/
	input   wire                    write_wstrb,//0804
	input	wire					axi_ar_en,
	input	wire					axi_aw_en,
	input	wire		[31:0]		cpu_rd_addr,
	input	wire		[31:0]		cpu_wr_addr,
	input	wire		[31:0]		cpu_wr_data,
	output	reg			[31:0]		cpu_rd_data,
	output	reg						bus_rd_data_ready,
	output	wire					bus_wr_data_ready,
	output	wire					bus_wr_data_finish,
	input	wire		[7:0]		aw_burst_len,
	input	wire		[7:0]		ar_burst_len,
	input	wire		[1:0]		aw_burst_step,
	input	wire		[1:0]		ar_burst_step,
	//output  wire                    axi_idle,//20190728
	/*********** Axi Signal **********/
	output	wire		[3:0]  		awid,
	output	wire		[31:0]  	awaddr,
	output	wire		[3:0]  		awlen,
	output	wire		[2:0]  		awsize,
	output	wire		[1:0]  		awburst,
	output	wire		[1:0]  		awlock,
	output	wire		[3:0]  		awcache,
	output	wire		[2:0]  		awprot,
	output	wire	                awvalid,
	input	wire	                awready,
	
	output	wire		[3:0]  		wid,
	output	wire		[31:0]  	wdata,
	output	wire		[3:0]  		wstrb,
	output	wire	                wlast,
	output	wire	                wvalid,
	input	wire	                wready,
	
	input	wire		[3:0] 		bid,
	input  	wire		[1:0] 	    bresp,
	input	wire	                bvalid,
	output	wire	                bready,
	
	output 	wire		[3:0]  		arid,
	output 	wire		[31:0]   	araddr,
	output 	wire		[3:0] 		arlen,
	output 	wire		[2:0]  		arsize,
	output 	wire		[1:0]  		arburst,
	output 	wire		[1:0]  		arlock,
	output 	wire		[3:0]  		arcache,
	output 	wire		[2:0]   	arprot,
	output	wire	                arvalid,
	input	wire	                arready,
	
    input  	wire		[3:0]  		rid,
	input  	wire		[31:0]		rdata,
	input	wire		[1 :0]  	rresp,
	input	wire	                rlast,
	input	wire	                rvalid,
	output	wire	                rready
	);
	
	/********* Internal parameter *************/
	parameter	READ_IDLE            = 2'h0;
	parameter	READ_DDR_WAIT           = 2'h1;
	parameter	READ_DDR             = 2'h2;
	parameter	READ_DDR_END         = 2'h3;

	parameter	WRITE_IDLE			 = 2'h0;
	parameter	WRITE_DDR_WAIT           = 2'h1;
	parameter	WRITE_DDR            = 2'h2;
	parameter	WRITE_DDR_END        = 2'h3;
	
	/************* Internal Signal **************/
	
	//read state machine
	wire				read_start;
	reg		[1:0]		read_state;
	reg		[1:0]		nx_read_state;
	wire				read_state_change;
	wire				read_ddr_again;
	wire				read_trans_over;
	reg		[1:0]		count_read_step;
	wire				read_idle;
	wire				read_ddr_wait;
	wire				read_ddr;
	wire				read_ddr_end;
	wire				read_step_end;
	
	//ar channel
	reg					arvalid_ddr;
	reg		[31:0]		araddr_ddr;
	reg		[31:0]		read_mem_addr;
	reg					axi_ar_en_reg;
	
	// r channel
	wire				rresp_ok;
	reg					rlast_reg;
	
	//write	state machien
	wire				write_start;
	reg		[1:0]		write_state;
	reg	   [1:0]		nx_write_state;
	wire				write_state_change;
	wire				write_ddr_again;
	wire				write_trans_over;
	reg		[1:0]		count_write_step;
	wire				write_idle;
	wire				write_ddr_wait;
	wire				write_ddr;
	wire				write_ddr_end;
	
	//aw channel
	reg        			awvalid_ddr;
	reg 	[31:0]		awaddr_ddr;
	reg 	[31:0] 		write_mem_addr;
	reg					axi_aw_en_reg;
	
	//w channel
	reg 	[31:0]		wdata_ddr;
	wire 				wlast_ddr;
	reg 				wvalid_ddr;
	reg 	[4:0] 		write_num;
	
	//b
	wire				bresp_ok;
	
	
	/********** read state machine **********/
	assign	read_idle			=	(read_state == READ_IDLE);
	assign 	read_ddr_wait   	= 	(read_state == READ_DDR_WAIT);
	assign 	read_ddr        	= 	(read_state == READ_DDR);
	assign 	read_ddr_end  		= 	(read_state == READ_DDR_END);
	assign	read_state_change	=	(read_state != nx_read_state);
	assign	read_ddr_again		=	(count_read_step != 2'b00);
	assign	read_trans_over		=	(read_ddr_end && (count_read_step == 2'b00))? 1'b1 : 1'b0;
	assign	read_start			=	axi_ar_en & ~axi_ar_en_reg;
	//assign  axi_idle            =   read_idle && write_idle;
	
	always @ (*) begin
		case(read_state) 
			READ_IDLE		:	nx_read_state	=	((read_start )? READ_DDR_WAIT : READ_IDLE);
			READ_DDR_WAIT	: 	nx_read_state	=	((arready)? READ_DDR : READ_DDR_WAIT);
			READ_DDR		:	nx_read_state	=	((rvalid & rready & rlast & rresp_ok )? READ_DDR_END :READ_DDR);
			READ_DDR_END	:	nx_read_state	=	((read_trans_over) ? READ_IDLE : 
													read_ddr_again ? READ_DDR_WAIT : READ_DDR_END);
			default			:	nx_read_state	=	READ_IDLE;
		endcase
	end
	
	always @(posedge clk) begin
		if(reset == `RESET_ENABLE | read_trans_over)begin
			read_state	<=	READ_IDLE;
		end
		else if(read_state_change)begin
			read_state	<=	nx_read_state;
		end
	end
	
	
	//ar
	always	@ (posedge clk)begin
		if(reset == `RESET_ENABLE)begin
			axi_ar_en_reg	<=	1'b0;
		end
		else begin
			axi_ar_en_reg	<=	axi_ar_en;
		end
	end
	
	always @ (posedge clk) begin
		if(reset == `RESET_ENABLE)begin
			arvalid_ddr		<=	1'b0;
		end
		else if(arready & arvalid_ddr)begin
			arvalid_ddr		<=	1'b0;
		end
		else if((read_idle & read_start) | read_ddr_end & read_ddr_again)begin
			arvalid_ddr  	<=	1'b1;
		end
	end
	
	
	always @ (posedge clk) begin
		if(reset == `RESET_ENABLE)begin
			araddr_ddr	<=	'b0;
		end
		else if((read_idle & read_start) | read_ddr_end & read_ddr_again)begin
			araddr_ddr		<=	cpu_rd_addr;
		end
	end
	
	assign	arid	=	4'b1111;
	assign	araddr	=	araddr_ddr;
	assign	arlen	=	ar_burst_len;
	assign	arsize	=	3'b010;
	assign	arburst	=	2'b01;
	assign	arlock	=	2'b00;
	assign	arcache	=	4'b0000;
	assign	arprot	=	3'b000;
	assign	arvalid	=	arvalid_ddr;
	//for read channel
	assign	rready	=	1'b1;
	
	//r
	assign	rresp_ok	=	(rresp == 2'b00);
	always @ (posedge clk) begin
		if(reset == `RESET_ENABLE)begin
			rlast_reg	<=	'b0;
		end
		else begin
			rlast_reg	<=	rlast;
		end
	end
	
	always@(posedge clk)begin
		if(reset == `RESET_ENABLE)begin
			count_read_step <= 2'b0;   
		end
		else if (read_idle) begin
			count_read_step <= ar_burst_step;
		end
		else if(read_ddr & rvalid & rready & rresp_ok & rlast) begin
			count_read_step <= count_read_step - 2'd1;
		end
	end
	
	
	always@(posedge clk)begin
		if(reset == `RESET_ENABLE) begin
			cpu_rd_data <= 32'h0;
			bus_rd_data_ready<= 1'b0;
		end
		else if(read_ddr & rvalid & rready & rresp_ok ) begin
			cpu_rd_data <= rdata;
			bus_rd_data_ready <= 1'b1;
		end
		else begin
			bus_rd_data_ready <= 1'b0;
		end
	end
	
	//write state machine
	assign	write_idle			=	(write_state == WRITE_IDLE);
	assign 	write_ddr_wait   	= 	(write_state == WRITE_DDR_WAIT);
	assign 	write_ddr        	= 	(write_state == WRITE_DDR);
	assign 	write_ddr_end  		= 	(write_state == WRITE_DDR_END);
	assign	write_state_change	=	(write_state != nx_write_state);
	assign	write_ddr_again		=	(count_write_step != 2'b00);
	assign	write_trans_over	=	(write_ddr_end && (count_write_step == 2'b00))? 1'b1 : 1'b0;
	assign	write_start			=	axi_aw_en & ~axi_aw_en_reg;
	
	always @ (*) begin
		case(write_state) 
			WRITE_IDLE		:	nx_write_state	=	((write_start )? WRITE_DDR_WAIT : WRITE_IDLE);
			WRITE_DDR_WAIT	: 	nx_write_state	=	((awready)? WRITE_DDR : WRITE_DDR_WAIT);
			WRITE_DDR		:	nx_write_state	=	((bvalid & bresp_ok & bready )? WRITE_DDR_END :WRITE_DDR);
			WRITE_DDR_END	:	nx_write_state	=	((write_trans_over) ? WRITE_IDLE	 : 
													write_ddr_again ? WRITE_DDR_WAIT : WRITE_DDR_END);
			default			:	nx_write_state	=	WRITE_IDLE;
		endcase
	end
	
	always @(posedge clk) begin
		if(reset == `RESET_ENABLE | write_trans_over)begin
			write_state	<=	WRITE_IDLE;
		end
		else if(write_state_change)begin
			write_state	<=	nx_write_state;
		end
	end
	
	always@(posedge clk)begin
		if(reset == `RESET_ENABLE)begin
			axi_aw_en_reg <= 1'b0;
		end
		else begin
			axi_aw_en_reg <= axi_aw_en;
		end
	end
	
	
	//aw
	always @(posedge clk)begin
		if(reset == `RESET_ENABLE)
			awvalid_ddr <= 1'b0;
		else if(awvalid_ddr & awready)
			awvalid_ddr <= 1'b0;
		else if((write_idle & write_start) | (write_ddr_end & write_ddr_again))
			awvalid_ddr <= 1'b1;
	end
	
	always @(posedge clk)begin
		if(reset == `RESET_ENABLE)begin
			awaddr_ddr <= 'b0;
		end
		else if((write_idle & write_start) | (write_ddr_end & write_ddr_again))begin
			awaddr_ddr <= cpu_wr_addr;
		end
	end
	
	
	assign	awid	=	4'b1111;
	assign	awaddr	=	awaddr_ddr;
	assign	awlen	=	aw_burst_len;
	assign	awsize	=	3'b010;
	assign	awburst	=	2'b01;
	assign	awlock	=	2'b000;
	assign	awcache	=	4'b0000;
	assign	awprot	=	3'b000;
	assign	awvalid	=	awvalid_ddr;
	//for b
	assign	bready	=	1'b1;
	
	
	//b
	assign	bresp_ok	=	(bresp == 2'b00);
	always @(posedge clk)begin
		if(reset == `RESET_ENABLE)begin
			count_write_step <= 2'b00;
		end
		else if (write_idle)begin
			count_write_step <= aw_burst_step;
		end
		else if(write_ddr & bvalid & bresp_ok & bready)begin
			count_write_step <= count_write_step - 2'd1;
		end
	end
	
	//w
	always @(posedge clk)begin
		if(reset == `RESET_ENABLE)begin
			wvalid_ddr <= 1'b0;
		end
		else if (awvalid_ddr & awready)begin
			wvalid_ddr <= 1'b1;
		end    
		else if(write_ddr & wvalid & wready)begin
			wvalid_ddr <= !wlast;
		end
	end
	
	always@(posedge clk)begin
		if(reset==`RESET_ENABLE | write_trans_over)begin
			write_num    <= 'b0;
		end
		else if(write_ddr & wvalid & wready)begin
			write_num  <= write_ddr ? (wlast ? 'b0 : write_num + 1'b1) : write_num;
		end
	end
	assign wlast_ddr = (write_num==awlen); 
	assign wid = 1;
	assign wdata = cpu_wr_data;
	assign wstrb = 8'hff;
	//assign wstrb  = write_wstrb;
	assign wlast = wlast_ddr;
	assign wvalid = wvalid_ddr;
	
	assign	bus_wr_data_finish	=	write_trans_over;
	assign	bus_wr_data_ready	=	(write_ddr & wvalid & wready);


endmodule
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

