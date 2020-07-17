/*
 -- ============================================================================
 -- FILE NAME	: stddef.h
 -- DESCRIPTION : Common Macros
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  
 -- 2.0.0	  2017/08/14  
 -- ============================================================================
*/

`ifndef __STDDEF_HEADER__				 // Include Guard
	`define __STDDEF_HEADER__

// -----------------------------------------------------------------------------
// Signal Value
// -----------------------------------------------------------------------------
	/********** Signal Level *********/
	`define HIGH				1'b1	// High Level
	`define LOW					1'b0	// Low Level
	/********** Effective *********/
	// Positive Logic
	`define DISABLE				1'b0	// non-effective
	`define ENABLE				1'b1	// effective
	// Negative Logic
	`define DISABLE_			1'b1	// non-effective
	`define ENABLE_				1'b0	// effective
	/********** Read / Write *********/
	`define READ				1'b0	// Read
	`define WRITE				1'b1	// Write
	`define WriteEnBus          3:0		// Write Enable Bus
	`define WRITE_4_BYTE        4'b1111	// Write Word = 4 Bytes
	`define READ_WORD           4'b1111	// Read Enable
	`define RW_DISABLE          4'b0000 // Read / Write Disable
	`define WriteSizeBus        2:0 	// Write Size Bus
	`define WRITE_SIZE_BYTE     3'b000	// Write Byte 
	`define WRITE_SIZE_H_WORD   3'b001	// Write Half Word
	`define WRITE_SIZE_WORD     3'b010	// Write Word

// -----------------------------------------------------------------------------
// Data Bus
// -----------------------------------------------------------------------------
	/********** LSB *********/
	`define LSB					0		// Least Significant Bit
	/********** Byte (8 bit) *********/
	`define BYTE_DATA_W			8		// Byte Data width
	`define BYTE_MSB			7		// MSB of Byte
	`define ByteDataBus			7:0		// Data Bus
	/********** Word (32 bit) *********/
	`define WORD_DATA_W			32		// Word Data width
	`define WORD_MSB			31		// MSB of Word
	`define WordDataBus			31:0	// Data Bus
	/********** Double Word (64 bit) *********/
	`define DOUBLE_WORD_DATA_W	64		// Double Word Data width
	`define DOUBLE_WORD_MSB		63		// MSB of Double Word
	`define DoubleWordDataBus	63:0	// Data Bus
	`define HiDataLoc           63:32	// Higher Word of Double
	`define LoDataLoc           31:0	// Lower Word of Double
// -----------------------------------------------------------------------------
// Addr Bus
// -----------------------------------------------------------------------------
	/********** Word Address *********/
	`define WORD_ADDR_W			32		 // Address Width
	`define WORD_ADDR_MSB		31		 // MSB of Address
	`define WordAddrBus			31:0	 // Addr Bus
	/********** Byte Offset *********/
	`define BYTE_OFFSET_W		2		 // Offset width
	`define ByteOffsetBus		1:0		 // Offset bus
	/********** Address Location *********/
	`define WordAddrLoc			31:2	 // Word Address Location
	`define ByteOffsetLoc		1:0		 // Byte Offset Location
	/********** Byte Offset Value *********/
	`define BYTE_OFFSET_WORD	2'b00	 // Word Aligned
	`define BYTE_OFFSET_HWORD   2'b10    // Half Word Aligned
	
	`define EXT_24_BIT          24		// Extension of Bit
	`define EXT_16_BIT          16		// Extension of Half Word
    `define EXT_8_BIT           8		// Extension of Word
	
`endif
