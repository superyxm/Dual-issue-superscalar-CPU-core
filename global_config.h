/*
 -- ============================================================================
 -- FILE NAME	: global_config.h
 -- DESCRIPTION : Global Configuration
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  
 -- 2.0.0	  2017/08/14  
 -- ============================================================================
*/

`ifndef __GLOBAL_CONFIG_HEADER__
	`define __GLOBAL_CONFIG_HEADER__	// Include Guard

//------------------------------------------------------------------------------
// Setting items
//------------------------------------------------------------------------------
	/********** Reset Polarity **********/
//	`define POSITIVE_RESET				// Active High
	`define NEGATIVE_RESET				// Active Low

	/********** Memory Control Signal **********/
	`define POSITIVE_MEMORY				// Active High
//	`define NEGATIVE_MEMORY				// Active Low

	/********** I/O Settings **********/
	`define IMPLEMENT_TIMER				// Timer
	`define IMPLEMENT_UART				// UART
	`define IMPLEMENT_GPIO				// General Purpose I/O

//------------------------------------------------------------------------------
// Setting parameters
//------------------------------------------------------------------------------
	/********** Reset *********/
	// Active Low
	`ifdef POSITIVE_RESET
		`define RESET_EDGE	  posedge	// Reset edge
		`define RESET_ENABLE  1'b1		// Reset enable
		`define RESET_DISABLE 1'b0		// Reset disable
	`endif
	// Active High
	`ifdef NEGATIVE_RESET
		`define RESET_EDGE	  negedge	// Reset edge
		`define RESET_ENABLE  1'b0		// Reset enable
		`define RESET_DISABLE 1'b1		// Reset disable
	`endif

	/********** Mem *********/
	// Active High
	`ifdef POSITIVE_MEMORY
		`define MEM_ENABLE	  1'b1		// Mem enable
		`define MEM_DISABLE	  1'b0		// Mem disable
	`endif
	// Active Low
	`ifdef NEGATIVE_MEMORY
		`define MEM_ENABLE	  1'b0		// Mem enable
		`define MEM_DISABLE	  1'b1		// Mem disable
	`endif

`endif
