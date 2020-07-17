/* 
 -- ============================================================================
 -- FILE NAME	: isa.h
 -- DESCRIPTION : Instruction Set Architecture
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  
 -- 2.0.0	  2017/08/14  
 -- ============================================================================
*/

`ifndef __ISA_HEADER__
	`define __ISA_HEADER__			 // Include Guard

//------------------------------------------------------------------------------
// Instruction
//------------------------------------------------------------------------------
	/********** Instruction **********/
	`define ISA_NOP			   32'h0 // No Operation
	/********** operation code **********/
	// all insn
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
	// for instruction decoding
	`define ISA_OP_W		   6	 // Opcode width
	`define IsaOpBus		   5:0	 // Opcode bus
	`define IsaOpLoc		   31:26 // Opcode location
	`define IsaFunBus		   5:0	 // Function code bus
	`define IsaFunLoc          5:0   // Function code location
	`define IsaBBus            5:0   // Branch bus
	`define IsaBLoc            20:16 // Branch code location
	`define IsaFiveBus		   4:0
	`define IsaNo1Loc		   10:6
	`define IsaNo2Loc		   15:11
	`define IsaNo3Loc		   20:16
	`define IsaNo4Loc		   25:21
	`define IsaEretLoc         25:6
	`define IsaEretBus         19:0
	`define IsaCp0Loc          10:3
	`define IsaCp0Bus          7:0
	`define ISA_ZERO_ID        5'b00000
	`define ISA_ERET_ID        20'h80000
	`define ISA_CP0_ID         8'b0
	// op code
	`define ISA_OP_NOP_X       6'bxxxxxx
	`define ISA_OP_ADD		   6'h00 // 
	`define ISA_OP_ADDI		   6'h08 // 
	`define ISA_OP_ADDU		   6'h00 // 
	`define ISA_OP_ADDIU	   6'h09 // 
	`define ISA_OP_SUB		   6'h00 // 
	`define ISA_OP_SUBU		   6'h00 // 
	`define ISA_OP_SLT  	   6'h00 // 
	`define ISA_OP_SLTI	       6'h0a // 
	`define ISA_OP_SLTU 	   6'h00 // 
	`define ISA_OP_SLTIU	   6'h0b // 
	`define ISA_OP_DIV  	   6'h00 // 
	`define ISA_OP_DIVU 	   6'h00 // 
	`define ISA_OP_MULT 	   6'h00 // 
	`define ISA_OP_MULTU	   6'h00 // 
	`define ISA_OP_AND  	   6'h00 // 
	`define ISA_OP_ANDI 	   6'h0c // 
	`define ISA_OP_LUI		   6'h0f // 
	`define ISA_OP_NOR		   6'h00 // 
	`define ISA_OP_OR		   6'h00 // 
	`define ISA_OP_ORI		   6'h0d // 
	`define ISA_OP_XOR		   6'h00 // 
	`define ISA_OP_XORI		   6'h0e // 
	`define ISA_OP_SLL		   6'h00 // 
	`define ISA_OP_SLLV		   6'h00 // 
	`define ISA_OP_SRA		   6'h00 // 
	`define ISA_OP_SRAV		   6'h00 // 
	`define ISA_OP_SRL		   6'h00 // 
	`define ISA_OP_SRLV		   6'h00 // 
	`define ISA_OP_BEQ		   6'h04 // 
	`define ISA_OP_BNE		   6'h05 // 
	`define ISA_OP_BGEZ		   6'h01 // 
	`define ISA_OP_BGTZ		   6'h07 // 
	`define ISA_OP_BLEZ		   6'h06 // 
	`define ISA_OP_BLTZ		   6'h01 // 
	`define ISA_OP_BLTZAL	   6'h01 // 
	`define ISA_OP_BGEZAL	   6'h01 // 
	`define ISA_OP_J		   6'h02 // 
	`define ISA_OP_JAL		   6'h03 // 
	`define ISA_OP_JR		   6'h00 // 
	`define ISA_OP_JALR		   6'h00 // 
	`define ISA_OP_MFHI		   6'h00 // 
	`define ISA_OP_MFLO		   6'h00 // 
	`define ISA_OP_MTHI		   6'h00 // 
	`define ISA_OP_MTLO		   6'h00 // 
	`define ISA_OP_BREAK	   6'h00 // 
	`define ISA_OP_SYSCALL	   6'h00 // 
	`define ISA_OP_LB   	   6'h20 // 
	`define ISA_OP_LBU		   6'h24 // 
	`define ISA_OP_LH		   6'h21 // 
	`define ISA_OP_LHU		   6'h25 // 
	`define ISA_OP_LW		   6'h23 // 
	`define ISA_OP_SB		   6'h28 // 
	`define ISA_OP_SH		   6'h29 // 
	`define ISA_OP_SW		   6'h2b // 
	`define ISA_OP_ERET		   6'h10 // 
	`define ISA_OP_MFC0		   6'h10 // 
	`define ISA_OP_MTC0		   6'h10 //	
	// function code
	`define ISA_FUN_ADD		   6'h20 // 
	`define ISA_FUN_ADDU	   6'h21 // 
	`define ISA_FUN_SUB		   6'h22 // 
	`define ISA_FUN_SUBU	   6'h23 // 
	`define ISA_FUN_SLT  	   6'h2a // 
	`define ISA_FUN_SLTU 	   6'h2b // 
	`define ISA_FUN_DIV  	   6'h1a // 
	`define ISA_FUN_DIVU 	   6'h1b // 
	`define ISA_FUN_MULT 	   6'h18 // 
	`define ISA_FUN_MULTU	   6'h19 // 
	`define ISA_FUN_AND  	   6'h24 // 
	`define ISA_FUN_NOR		   6'h27 // 
	`define ISA_FUN_OR		   6'h25 // 
	`define ISA_FUN_XOR		   6'h26 // 
	`define ISA_FUN_SLL		   6'h00 // 
	`define ISA_FUN_SLLV	   6'h04 // 
	`define ISA_FUN_SRA		   6'h03 // 
	`define ISA_FUN_SRAV	   6'h07 // 
	`define ISA_FUN_SRL		   6'h02 // 
	`define ISA_FUN_SRLV	   6'h06 // 
	`define ISA_FUN_JR		   6'h08 // 
	`define ISA_FUN_JALR	   6'h09 // 
	`define ISA_FUN_MFHI	   6'h10 // 
	`define ISA_FUN_MFLO	   6'h12 // 
	`define ISA_FUN_MTHI	   6'h11 // 
	`define ISA_FUN_MTLO	   6'h13 // 
	`define ISA_FUN_BREAK	   6'h0d // 
	`define ISA_FUN_SYSCALL	   6'h0c // 
	`define ISA_FUN_ERET       6'h18 //
	// other code	
	`define ISA_B_BGEZ         5'h01
	`define ISA_B_BLTZ         5'h00
	`define ISA_B_BGEZAL       5'h11
	`define ISA_B_BLTZAL       5'h10
	`define ISA_B_BGTZ         5'h00
	`define ISA_B_BLEZ		   5'h00
	`define ISA_MFC0           5'h00
	`define ISA_MTC0           5'h04

	/********** Register Address **********/
	// bus
	`define ISA_REG_ADDR_W	   5	 // Reg addr width
	`define IsaRegAddrBus	   4:0	 // Reg addr location
	`define IsaRsAddrLoc	   25:21 // Location of Rs
	`define IsaRtAddrLoc	   20:16 // Location of Rd
	`define IsaRdAddrLoc	   15:11 // Location of Rt
	/********** Immediate **********/
	// bus
	`define ISA_IMM_W		   16	 // Immediate width
	`define ISA_EXT_W		   16	 // Immediate extension width
	`define ISA_IMM_MSB		   15	 // MSB of Immediate
	`define IsaImmBus		   15:0	 // Immediate bus
	`define IsaImmLoc		   15:0	 // Immediate location
	`define IsaImmShBus        5:0   // Immediate shift bus
	`define IsaImmShLoc        10:6  // Immediate shift location
	
	`define ISA_EXT_B          14    // Branch signed extension amount
	`define ISA_SLL_B          2     // Branch immediate left shift amount
	`define ISA_SLL_J          2     // Jump immediate left shift amount
	`define ISA_PC_J           31:28 // Location of PC that J-type use
    `define ISA_INSN_J         25:0  // Location of immediate that J-type use
//------------------------------------------------------------------------------
// Exception
//------------------------------------------------------------------------------
	/********** exception code **********/
	// bus
	`define ISA_EXC_W		   5		// exception code width
	`define IsaExcBus		   4:0		// exception code bus
	`define IsaExcLoc          6:2		// exception code location
	// exception
	`define ISA_EXC_NO_EXC	   5'h10	// No exception
	`define ISA_EXC_INT	   	   5'h00	// Interuption
	`define ISA_EXC_RI 		   5'h0a	// Reserve
	`define ISA_EXC_OV         5'h0c	// Arithmetic overflow
	`define ISA_EXC_ADEL       5'h04	// Aligned Data Error of Load
	`define ISA_EXC_ADES	   5'h05	// Aligned Data Error of Read
	`define ISA_EXC_SYS	       5'h08	// System Call
	`define ISA_EXC_BP         5'h09	// Break Point

`endif
