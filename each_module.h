/*
 -- ============================================================================
 -- FILE NAME	: each_module.h
 -- DESCRIPTION : each module header
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  
 -- 2.0.0	  2017/08/14
 -- ============================================================================
*/
`ifndef __EACH_HEADER__
	`define __EACH_HEADER__
	/********** cache **********/
	`define	FourWordDataBus	127:0
	
	/********** decoder *********/
	`define	Ptab2addrBus 9:0
	`define Isa2regAddrBus 9:0
	`define	Imme2wayBus 63:0
	`define Type2wayBus 3:0
	`define Insn2wayBus 11:0
	`define Insn2wayOpnEnBus 7:0
	`define TwoWordAddrBus 63:0
	`define	ImmeBus 31:0
	`define InsnTypeBus 1:0
	`define	InsnOpnEnBus 3:0
	`define INSN_OPN_EN_W 4
	`define InsnBus 5:0
	`define IsaSaBus 4:0
	`define IsaSaLoc 10:6
	`define INSN_ALU_TYPE 2'b00
	`define	INSN_MULT_TYPE 2'b01
	`define INSN_DIV_TYPE 2'b10
	`define INSN_NOP_TYPE 2'b11
	`define	DST_VALID_LOC 0
	`define	SRC0_VALID_LOC 1
	`define	SRC1_VALID_LOC 2
	`define	IMME_VALID_LOC 3
	`define	TwoWayBus 1:0
	
	/********* insn_buffer ***********/
	`define InsnValidBus 3:0
	`define	DecodeEnBus	1:0
	`define	DC_READ_DISABLE 2'b00
	`define	DC_READ_0_1 2'b01
	`define	DC_READ_2_3	2'b10
	`define	PtabAddrLoc 69:65
	`define PcLocBus 64:33
	`define InsnLocBus 32:1
	`define ValidLocBus 0:0
	`define	PcWordOffsetLoc 3:2
	`define	PcOtherLoc 31:4
	`define FifoAddrBus 3:0
	`define	FifoDataBus 69:0
	`define	FifoDepthBus 15:0
	`define	FIFO_DATA_W 70
	`define	IfFlushRegBus 1:0
	
	/********** insn_fetch **********/
	`define PcByteOffsetLoc 3:2
	
	/********** branch prediction **********/
	//	Direction Prediction
	`define	PhtDataBus 1:0
	`define	PhtDepthBus 255:0
	`define	PhtAddrBus 7:0
	`define BhrDataBus 7:0
	`define	BHR_DATA_W 8
	`define	OldBhtLoc 6:0
	`define	BankOffsetBus 1:0
	`define	BankOffsetLoc 3:2
	//	Address Prediction
	`define	BtbTypeBus 1:0
	`define BtbIndexBus 7:0
	`define	BtbTagBus 9:0
	`define PcIndexLoc 9:2
	`define	PcTagLoc 19:10
	`define	BtbDataBus 43:0
	`define BtbTagLoc 43:34 
	//`define	BtbValidLoc 44
	`define BtbTypeLoc 33:32
	`define BtbAddrLoc 31:0
	`define	BtbDepthBus 255:0
	`define TYPE_RELATIVE 2'b01
	`define TYPE_CALL 2'b10
	`define	TYPE_RETURN 2'b11
	`define	TYPE_NOP 2'b00
	`define	BtbChoiceBus 1:0
	`define CHOOSE_WAY_0 2'b00
	`define CHOOSE_WAY_1 2'b01
	`define CHOOSE_WAY_2 2'b10
	`define CHOOSE_WAY_3 2'b11
	//	RAS
	`define RasDepthBus 7:0
	`define RasDataBus 31:0
	`define RasAddrBus 2:0
	`define	RepeatCounterBus 7:0
	//	PTAB
	`define	PtabDepthBus 15:0
	`define PtabDataBus 63:0
	`define	Ptab2dataBus 127:0
	`define	PtabPaddrLoc	63:32
	`define	PtabNpcLoc 31:0
	`define	PtabAddrBus 4:0
	`define	PtabIaddrBus 3:0
	
	/********** D-cache Interface **********/
	`define	WordData2wayBus 63:0
	`define	WriteEn2wayBus 7:0
	`define	AddrMask 31:16
	`define	UNCACHE_HEADER 16'hbfaf
	`define MemAddrMask 31:28
	`define MEM_HEADER_8 4'd8
	`define MEM_HEADER_9 4'd9
	`define MEM_HEADER_A 4'ha
	`define MEM_HEADER_B 4'hb
	
	/********** CP0 **********/
	//`define	TwoWayBus 1:0
	`define TwoWordDataBus 63:0
	//`define TwoWordAddrBus 63:0
	`define	Creg_Way0_Loc 31:0
	`define	Creg_Way1_Loc 63:32
	//`define	InsnBus	5:0
	
	/********* ARF **********/
	`define	AregAddrBus	4:0
	
	/********* PRF **********/
	`define PREG_ADDR_W 8
	
	/********* RN **********/
	`define		SrcLBus			15:0
	`define		SrcRBus			15:0
	`define		DestBus			15:0
	`define		Insn2wayTypeBus	3:0
	`define		IdEnBus				1:0
	`define 	RobAgeBit2wayBus    1:0
	`define 	RtrDestAddBus		15:0
	`define 	RtrDestEnBus		1:0
	/********* WB **********/
	`define		LoadBufferDataBus	20:0
	`define		LOAD_BUFFER_DATA_W	21
	`define		LoadDataOpLoc		20:15
	`define		LoadDataOffsetLoc	14:13
	`define		LoadDataDstAddLoc	12:5
	`define		LoadDataRobAddLoc	4:0
	`define 	ReadDataLoc0		7:0
	`define		ReadDataLoc1		15:8
	`define 	ReadDataLoc2		23:16
	`define		ReadDataLoc3		31:24
	`define     HiLoData2wayBus		127:0
	`define     As2wayBus			1:0
	`define     Rw2wayBus			1:0
	`define     As2wayBus			1:0
	`define     Rw2wayBus			1:0
	`define		LoadBufDestBus		7:0
	`define 	WbLoadCmpltAddBus   9:0
	`define		WbLoadCmpltEnBus	1:0
	`define     WordDataLoc0		31:0
	`define     WordDataLoc1		63:32
	
	/********** ROB **********/
	`define		RobCmpltEnBus		1:0
	
`endif