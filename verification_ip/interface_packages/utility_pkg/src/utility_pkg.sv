package utility_pkg;

//***************************************************************************
//***************************************************************************
//	General Types used Throughout I2C
//***************************************************************************
//***************************************************************************

//***************************************************************************
//	R/W Bit For I2C Transactions
//***************************************************************************
    typedef enum bit {WRITE = 0, READ = 1} i2c_op_t;
		
//***************************************************************************
//	WB Lengths
//***************************************************************************
		parameter int WB_ADDR_WIDTH 	= 2;
		parameter int WB_DATA_WIDTH 	= 8;
		
//***************************************************************************
//	I2C Lengths
//***************************************************************************
		parameter int I2C_ADDR_WIDTH 	= 7;
		parameter int I2C_DATA_WIDTH 	= 8;

//***************************************************************************
//	I2CMB Commands
//***************************************************************************
		parameter bit [WB_DATA_WIDTH - 1:0]
		CSR												= 8'b1100_0000									,
		DPR												= 8'h01													,
		DPR_ADDR_WRITE						= 8'h22													,
		DPR_ADDR_READ							=	8'h23													,
		CMDR_SET_BUS							=	8'b0000_0110									,
		CMDR_START								=	8'b0000_0100									,
		CMDR_WRITE								= 8'b0000_0001									,
		CMDR_READ_NACK						= 8'b0000_0011									,
		CMDR_READ_ACK							= 8'b0000_0010									,
		CMDR_STOP									= 8'b0000_0101									,
		CMDR_WAIT									= 8'b0000_0000									;

//***************************************************************************
//	I2CMB Addresses
//***************************************************************************
		parameter bit [WB_ADDR_WIDTH - 1:0]
		CSR_ADDR									=	2'h0,
		DPR_ADDR									=	2'h1,
		CMDR_ADDR									= 2'h2,
		FSMR_ADDR									= 2'h3;
		
//***************************************************************************
//	I2CMB States for WB Driver
//***************************************************************************
		typedef enum {I2CMB_RESET = 0, 		//For Reset of I2CMB Core
									I2CMB_WRITE = 1, 		//For Writing to the I2CMB Core
									I2CMB_READ 	= 2, 		//For Reading from the I2CMB Core
									I2CMB_NULL 	= 3	} 	//For Testing/Debugging Purposes
									I2CMB_EN_t;
		
//***************************************************************************
//	Slave Address of the i2c_if Virtual Interface
//***************************************************************************
		parameter bit [I2C_ADDR_WIDTH - 1:0]	slave_address						= 7'h11	;

//***************************************************************************
//***************************************************************************
//	Used for Code Coverage
//***************************************************************************
//***************************************************************************

//***************************************************************************
//	I2CMB Addresses for Code Coverage
//***************************************************************************
typedef enum bit [1:0] {	CSR_ADDR_cov 										=	2'h0		, 			//	CSR 	Reg Address 
													DPR_ADDR_cov 										=	2'h1		, 			//	DPR 	Reg Address 
													CMDR_ADDR_cov 									= 2'h2		, 			//	CMDR 	Reg Address
													FSMR_ADDR_cov 									= 2'h3						//	FSMR 	Reg Address
												} reg_addr_cov_t														;

//***************************************************************************
//	I2CMB Command Level Responses for Code Coverage
//***************************************************************************
parameter bit [2:0] 			START_cov 											=	3'b100	, 			//	START 				Response
													STOP_cov 												=	3'b101	, 			//	STOP 					Response
													WRITE_cov 											= 3'b001	, 			//	WRITE 				Response
													READ_ACK_cov										= 3'b010	,				//	READ W/H ACK 	Response
													READ_NACK_cov										= 3'b011	,				// 	READ W/H NACK Response
													INVALID_cov											= 3'b111	,				//	INVALID CMD		Response
													CMDR_SET_BUS_cov								=	3'b110	,				//	CMDR SET BUS	Response
													WAIT_cov												= 3'b000	;				//	Wait					Response
//***************************************************************************
//	I2CMB Byte Level FSM for Code Coverage
//***************************************************************************
parameter bit [3:0] 			BYTE_LVL_FSM_IDLE_cov 					=	4'b0000	, 			//	Byte Level FSM Idle
													BYTE_LVL_FSM_BUS_TAKEN_cov 			=	4'b0001	, 			//	Byte Level FSM Bus Taken
													BYTE_LVL_FSM_START_PENDING_cov 	=	4'b0010	, 			//	Byte Level FSM Start Pending
													BYTE_LVL_FSM_START_cov 					=	4'b0011	, 			//	Byte Level FSM Start
													BYTE_LVL_FSM_STOP_cov 					=	4'b0100	, 			//	Byte Level FSM Stop
													BYTE_LVL_FSM_WRITE_cov 					=	4'b0101	, 			//	Byte Level FSM Write
													BYTE_LVL_FSM_READ_cov 					=	4'b0110	,				//	Byte Level FSM Read
													BYTE_LVL_FSM_WAIT_cov 					=	4'b0111	; 			//	Byte Level FSM Wait


//***************************************************************************
//	I2CMB Default Register Values for Code Coverage
//***************************************************************************
parameter	bit [WB_DATA_WIDTH - 1:0] 			CSR_reg_default_cov 					=	8'b1100_0000	, 			//	Byte Level FSM Idle
																					DPR_reg_default_cov 					=	8'b0000_0000	, 			//	Byte Level FSM Bus Taken
																					CMDR_reg_default_cov 					=	8'b1000_0000	, 			//	Byte Level FSM Start Pending
																					FSMR_reg_default_cov 					=	8'b0000_0000	; 				//	Byte Level FSM Start

//***************************************************************************
//	I2CMB Bit Level FSM Values
//***************************************************************************
parameter bit [3:0] 			BIT_LVL_FSM_IDLE_cov 							=	4'h0	, 			//	Bit Level FSM Idle
													BIT_LVL_FSM_START_A_cov 					=	4'h1	, 			//	Bit Level Start 		A
													BIT_LVL_FSM_START_B_cov 					=	4'h2	, 			//	Bit Level Start 		B
													BIT_LVL_FSM_START_C_cov 					=	4'h3	, 			//	Bit Level Start 		C
													BIT_LVL_FSM_RW_A_cov 							=	4'h4	, 			//	Bit Level R/W				A
													BIT_LVL_FSM_RW_B_cov 							=	4'h5	, 			//	Bit Level R/W				B
													BIT_LVL_FSM_RW_C_cov 							=	4'h6	, 			//	Bit Level R/W				B
													BIT_LVL_FSM_RW_E_cov 							=	4'h7	, 			//	Bit Level R/W				B
													BIT_LVL_FSM_RW_D_cov 							=	4'h8	, 			//	Bit Level R/W				B
													BIT_LVL_FSM_STOP_A_cov						=	4'h9	, 			//	Bit Level STOP			A
													BIT_LVL_FSM_STOP_B_cov						=	4'hA	, 			//	Bit Level STOP			B
													BIT_LVL_FSM_STOP_C_cov						=	4'hB	, 			//	Bit Level STOP			C
													BIT_LVL_FSM_REP_START_A_cov				=	4'hC	, 			//	Bit Level REP_START	A
													BIT_LVL_FSM_REP_START_B_cov				=	4'hD	,				//	Bit Level REP_START	B
													BIT_LVL_FSM_REP_START_C_cov				=	4'hE	; 			//	Bit Level REP_START C
endpackage
