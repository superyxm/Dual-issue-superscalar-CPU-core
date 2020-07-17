/* 
 -- ============================================================================
 -- FILE NAME	: cpu.h
 -- DESCRIPTION : CPU_header
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  
 -- 2.0.0	  2017/08/14  
 -- ============================================================================
*/

`ifndef __CPU_HEADER__
	`define __CPU_HEADER__				// Include Guard

//------------------------------------------------------------------------------
// Operation
//------------------------------------------------------------------------------
	/********** GPR related **********/
	`define REG_NUM				32		// number of GPR
	`define REG_ADDR_W			7		// reg address width
	`define REG_ADDR_31			5'h1f	// reg address top
	`define REG_ADDR_BASE		5'h0	// reg address base
	`define RegAddrBus			4:0		// reg address bus
	`define REG_HI				2'b01	// HI reg
	`define REG_LO				2'b10	// LO reg
	`define REG_NONE			2'b00	// ZERO reg
	
	/********** Interupt Request Signal **********/
	`define CPU_IRQ_CH			6		// IRQ
	/********** ALU **********/
	// bus
	`define ALU_OP_W			6		// ALU alu_op width
	`define AluOpBus			5:0 	// ALU alu_op bus
	// alu_op
	`define ALU_OP_ADD			6'h00	
	`define ALU_OP_ADDI			6'h01	
	`define ALU_OP_ADDU			6'h02	
	`define ALU_OP_ADDIU		6'h03	
	`define ALU_OP_SUB			6'h04	
	`define ALU_OP_SUBU			6'h05	
	`define ALU_OP_SLT			6'h06	
	`define ALU_OP_SLTI			6'h07	
	`define ALU_OP_SLTU			6'h08	
	`define ALU_OP_SLTIU		6'h09	
	`define ALU_OP_DIV			6'h0a	
	`define ALU_OP_DIVU			6'h0b	
	`define ALU_OP_MULT			6'h0c	
	`define ALU_OP_MULTU		6'h0d	
	`define ALU_OP_AND			6'h0e	
	`define ALU_OP_ANDI			6'h0f	
	`define ALU_OP_LUI			6'h10	
	`define ALU_OP_NOR			6'h11	
	`define ALU_OP_OR			6'h12	
	`define ALU_OP_ORI			6'h13	
	`define ALU_OP_XOR			6'h14	
	`define ALU_OP_XORI			6'h15	
	`define ALU_OP_SLL			6'h16	
	`define ALU_OP_SLLV			6'h17	
	`define ALU_OP_SRA			6'h18	
	`define ALU_OP_SRAV			6'h19	
	`define ALU_OP_SRL			6'h1a	
	`define ALU_OP_SRLV			6'h1b	
	`define ALU_OP_BEQ			6'h1c	
	`define ALU_OP_BNE			6'h1d	
	`define ALU_OP_BGEZ			6'h1e	
	`define ALU_OP_BGTZ			6'h1f	
	`define ALU_OP_BLEZ			6'h20	
	`define ALU_OP_BLTZ			6'h21	
	`define ALU_OP_BLTZAL		6'h22	
	`define ALU_OP_BGEZAL		6'h23	
	`define ALU_OP_J			6'h24	
	`define ALU_OP_JAL			6'h25	
	`define ALU_OP_JR			6'h26	
	`define ALU_OP_JALR			6'h27	
	`define ALU_OP_MFHI			6'h28	
	`define ALU_OP_MFLO			6'h29	
	`define ALU_OP_MTHI			6'h2a	
	`define ALU_OP_MTLO			6'h2b	
	`define ALU_OP_BREAK		6'h2c	
	`define ALU_OP_SYSCALL		6'h2d	
	`define ALU_OP_LB			6'h2e	
	`define ALU_OP_LBU			6'h2f	
	`define ALU_OP_LH			6'h30	
	`define ALU_OP_LHU			6'h31	
	`define ALU_OP_LW			6'h32	
	`define ALU_OP_SB			6'h33	
	`define ALU_OP_SH			6'h34	
	`define ALU_OP_SW			6'h35	
	`define ALU_OP_ERET			6'h36	
	`define ALU_OP_MFC0			6'h37	
	`define ALU_OP_MTC0			6'h38	
	`define ALU_OP_NOP			6'h39	
	
	/********** MEM Stage **********/
	// bus
	`define MEM_OP_W			4	// MEM mem_op width
	`define MemOpBus			3:0 // MEM mem_op bus
	// mem_op
	`define MEM_OP_NOP			4'h0 // No Operation
	`define MEM_OP_LB			4'h1 // Load Byte
	`define MEM_OP_LBU			4'h2 // Load Byte Unsigned
	`define MEM_OP_LH			4'h3 // Load Half
	`define MEM_OP_LHU			4'h4 // Load Half Unsigned
	`define MEM_OP_LW			4'h5 // Load Word
	`define MEM_OP_SB			4'h6 // Store Byte
	`define MEM_OP_SH			4'h7 // Store Half
	`define MEM_OP_SW			4'h8 // Store Word
	`define MEM_OP_MFHI			4'h9 // Move From HI
	`define MEM_OP_MFLO			4'ha // Move From LO
	`define MEM_OP_MTHI			4'hb // Move To HI
	`define MEM_OP_MTLO			4'hc // Move To LO
	`define MEM_OP_MULT			4'hd // mem_op for Multiplication
	`define MEM_OP_DIV			4'he // mem_op for Division
	
	`define MEM_EXT_B			24   // Extension of Byte
	`define MEM_EXT_H			16   // Extension of Half
	`define MEM_MSB_B 			7    // Sign bit of Byte
	`define MEM_MSB_H			15   // Sign bit of Half
	`define MEM_MSB_T           23   // Sign bit of three_byte
    `define MEM_MSB_W           31   // Sign bit of Word
	`define MemNo1BLoc          7:0  // Location of first byte
	`define MemNo2BLoc          15:8 // Location of second byte
	`define MemNo3BLoc          23:16// Location of third byte
	`define MemNo4BLoc          31:24// Location of forth byte
	`define MemNo1HLoc          15:0 // Location of first Half
	`define MemNo2HLoc          31:16// Location of second Half
	
	`define MemOvBus			2:0  // Bus of Overflow Signal
	`define MEM_OV_DISABLE		2'b00// Overflow of 
	`define MEM_OV_LOAD			2'b01// Overflow of Load
	`define MEM_OV_STORE		2'b10// Overflow of Store
	
	/********** Control Code **********/
	// bus
	`define CTRL_OP_W			3	 // control code window
	`define CtrlOpBus			2:0  // control code bus
	// ctrl_op
	`define CTRL_OP_NOP			3'h0 // No Operation
	`define CTRL_OP_BREAK		3'h1 // Break Point
	`define CTRL_OP_SYSCALL		3'h2 // System Call
	`define CTRL_OP_ERET		3'h3 // Exception Return
	`define CTRL_OP_MFC0		3'h4 // Read CP0
	`define CTRL_OP_MTC0		3'h5 // Write CP0

//-----------------------------------------------------------------------------
// Hi/Lo Register Related
//------------------------------------------------------------------------------
	`define HiLoOpBus			1:0
	`define HI_LO_OP_NOP		2'b00
	`define HI_LO_OP_HI			2'b01
	`define HI_LO_OP_LO			2'b10
//-----------------------------------------------------------------------------
// CP0 Register Related
//------------------------------------------------------------------------------
	/********** Address Map **********/
	`define CREG_ADDR_W			5		// CP0 Addr width
	`define CregAddrBus			4:0		// CP0 Addr bus
	`define CREG_ADDR_STATUS	5'h0c	// Reg Status
	`define CREG_ADDR_EPC		5'h0e	// Reg EPC
	`define CREG_ADDR_CAUSE		5'h0d	// Reg Cause
	`define CREG_ADDR_BADVADDR	5'h08	// Reg BadVAddr
	/********** Bit Map **********/
	/* `define CregExeModeLo		0	  // Location of execution mode
	`define CregIntEnableLoc	1	  // Location of interuption enable bit
	`define CregExpCodeLoc		2:0   // Location of exception code
	`define CregDlyFlagLoc		3	  // Location of delay flag */
	
	`define CregStatusImBus		7:0   // Bus of interuption mask 
	`define CregStatusImLoc		15:8  // Location of interuption mask
	`define CregStatusExlLoc	1     // Location of exception bit
	`define CregStatusIeLoc		0     // Location of global interuption bit
	
	`define CregCauseIpsBus		1:0   // Bus of software interuption
	`define CregCauseIpsLoc		9:8   // Location of software interuption
	`define CregCauseIphBus		5:0   // Bus of hardware interuption
	`define CregCauseIphLoc		15:10 // Location of hardware interuption

//------------------------------------------------------------------------------
// SRAM Interface
//------------------------------------------------------------------------------
	/********** State of SRAM Interface **********/
	// bus
	`define SramStateBus		1:0   // state width
	// state
	`define STATE_1				2'h0  
	`define STATE_2				2'h1  
	`define STATE_3				2'h2  
	`define STATE_4				2'h3  

//------------------------------------------------------------------------------
// MISC
//------------------------------------------------------------------------------
	/********** Vector **********/
	`define RESET_VECTOR		32'hbfc00000	// instruction reset vector
	`define RESET_VECTOR_OUT	32'h1fbffffc	// instruction reset vector
	//`define RESET_VECTOR_OUT	32'h1fc00000	// instruction reset vector
	`define EXC_VECTOR			32'hbfc00380	// excption entry vector
	/********** Shift Amount **********/
	`define ShAmountBus			4:0				// shift amount bus
	`define ShAmountLoc			4:0				// shift amount location
	/********** Address Conversion **********/
	`define HeaderLoc			 31:20
	`define MaskLoc				 31:29
	`define MaskNum              3              
	`define AddrKeepLoc          28:0
	`define INST_MASK			 3'b101
	`define DATA_MASK            3'b100
	`define INST_HEADER			 12'h1fc
	`define DATA_HEADER			 12'h000
	`define INST_ID_HEADER       12'hbfc
	`define DATA_ID_HEADER       12'h800

`endif
