import utility_pkg ::*;
interface wb_if       #(
      int ADDR_WIDTH = 2,                                
      int DATA_WIDTH = 8                                
      )
(
  // System sigals
  input wire clk_i,
  input wire rst_i,
  input wire irq_i,
  // Master signals
  output reg cyc_o,
  output reg stb_o,
  input wire ack_i,
  output reg [ADDR_WIDTH-1:0] adr_o,
  output reg we_o,
  // Slave signals
  input wire cyc_i,
  input wire stb_i,
  output reg ack_o,
  input wire [ADDR_WIDTH-1:0] adr_i,
  input wire we_i,
  // Shred signals
  output reg [DATA_WIDTH-1:0] dat_o,
  input wire [DATA_WIDTH-1:0] dat_i
  );

// ****************************************************************************              
//	Properties for Code Coverage for Byte-Level FSM
//	Test Plan Section 3
// ****************************************************************************              

// ****************************************************************************              
// Property for When CMDR Start is Issued the Byte FSM will Transition to Start
// or Start Pending
// Test Plan Section 3.1
// ****************************************************************************              
property BYTE_FSM_CMDR_Start;
	@(posedge clk_i)	
	($rose(ack_i) && adr_o === CMDR_ADDR && dat_o === CMDR_START && we_o === 1) |->
	##4 (adr_o === FSMR_ADDR && (dat_i[7:4] === BYTE_LVL_FSM_START_cov || dat_i[7:4] === BYTE_LVL_FSM_START_PENDING_cov) && we_o === 0);
endproperty						
assert 	property(BYTE_FSM_CMDR_Start) 			else $error("BYTE_FSM_CMDR_Start Failed, %t"			, $time	)	;
cover 	property(BYTE_FSM_CMDR_Start) 																																	;

// ****************************************************************************              
// Property for When CMDR Set Bus is Issued the Byte FSM will Transition to Idle
// or Bus Taken
// Test Plan Section 3.2
// ****************************************************************************              
property BYTE_FSM_CMDR_Set_Bus;
	@(posedge clk_i)	
	($rose(ack_i) && adr_o === CMDR_ADDR && dat_o === CMDR_SET_BUS && we_o === 1) |->
	##4 (adr_o === FSMR_ADDR && (dat_i[7:4] === BYTE_LVL_FSM_IDLE_cov || dat_i[7:4] === BYTE_LVL_FSM_BUS_TAKEN_cov) && we_o === 0);
endproperty						
assert 	property(BYTE_FSM_CMDR_Set_Bus) 		else $error("BYTE_FSM_CMDR_Set_Bus Failed, %t"		, $time	)	;
cover 	property(BYTE_FSM_CMDR_Set_Bus) 																																;

// ****************************************************************************              
// Property for When CMDR Write is Issued the Byte FSM will Transition to Write
// or Idle
// Test Plan Section 3.3
// ****************************************************************************              
property BYTE_FSM_CMDR_Write;
	@(posedge clk_i)	
	($rose(ack_i) && adr_o === CMDR_ADDR && dat_o === CMDR_WRITE && we_o === 1) |->
	 ##4 (adr_o === FSMR_ADDR && (dat_i[7:4] === BYTE_LVL_FSM_WRITE_cov || dat_i[7:4] === BYTE_LVL_FSM_IDLE_cov) && we_o === 0);
endproperty						
assert 	property(BYTE_FSM_CMDR_Write) 			else $error("BYTE_FSM_CMDR_Write Failed, %t"			, $time	)	;
cover 	property(BYTE_FSM_CMDR_Write) 																																	;

// ****************************************************************************              
// Property for When CMDR Read with ACK is Issued the Byte FSM will Transition to 
// Read or Idle
// Test Plan Section 3.4
// ****************************************************************************              
property BYTE_FSM_CMDR_Read_Ack;
	@(posedge clk_i)	
	($rose(ack_i) && adr_o === CMDR_ADDR && dat_o === CMDR_READ_ACK && we_o === 1) |->
	##4 (adr_o === FSMR_ADDR && (dat_i[7:4] === BYTE_LVL_FSM_READ_cov || dat_i[7:4] === BYTE_LVL_FSM_IDLE_cov) && we_o === 0);
endproperty						
assert 	property(BYTE_FSM_CMDR_Read_Ack) 		else $error("BYTE_FSM_CMDR_Read_Ack Failed, %t"		, $time	)	;
cover 	property(BYTE_FSM_CMDR_Read_Ack) 																															;

// ****************************************************************************              
// Property for When CMDR Read with NACK is Issued the Byte FSM will Transition to 
// Read or Idle
// Test Plan Section 3.5
// ****************************************************************************              
property BYTE_FSM_CMDR_Read_Nack;
	@(posedge clk_i)	
	($rose(ack_i) && adr_o === CMDR_ADDR && dat_o === CMDR_READ_NACK && we_o === 1) |->
	##4 (adr_o === FSMR_ADDR && (dat_i[7:4] === BYTE_LVL_FSM_READ_cov || dat_i[7:4] === BYTE_LVL_FSM_IDLE_cov) && we_o === 0);
endproperty						
assert 	property(BYTE_FSM_CMDR_Read_Nack) 	else $error("BYTE_FSM_CMDR_Read_Nack Failed, %t"	, $time	)	;
cover 	property(BYTE_FSM_CMDR_Read_Nack) 																															;

// ****************************************************************************              
// Property for When CMDR Stop is Issued the Byte FSM will Transition to Stop
// or Idle
// Test Plan Section 3.6
// ****************************************************************************              
property BYTE_FSM_CMDR_Stop;
	@(posedge clk_i)	
	($rose(ack_i) && adr_o === CMDR_ADDR && dat_o === CMDR_STOP && we_o === 1) |->
	##4 (adr_o === FSMR_ADDR && (dat_i[7:4] === BYTE_LVL_FSM_STOP_cov || dat_i[7:4] === BYTE_LVL_FSM_IDLE_cov) && we_o === 0);
endproperty						
assert 	property(BYTE_FSM_CMDR_Stop) 				else $error("BYTE_FSM_CMDR_Stop Failed, %t"				, $time	)	;
cover 	property(BYTE_FSM_CMDR_Stop) 																																		;

// ****************************************************************************              
// Property for When CMDR Wait is Issued the Byte FSM will Transition to Wait
// or Bus Taken
// Test Plan Section 3.7
// ****************************************************************************              
property BYTE_FSM_CMDR_Wait;
	@(posedge clk_i) 	
	($rose(ack_i) && adr_o === CMDR_ADDR && dat_o === CMDR_WAIT && we_o === 1) |->
	##4 (adr_o === FSMR_ADDR && (dat_i[7:4] === BYTE_LVL_FSM_WAIT_cov || dat_i[7:4] === BYTE_LVL_FSM_BUS_TAKEN_cov) && we_o === 0); 
endproperty						
assert 	property(BYTE_FSM_CMDR_Wait) 				else $error("BYTE_FSM_CMDR_Wait Failed, %t"				, $time	)	;
cover 	property(BYTE_FSM_CMDR_Wait) 																																		;

// ****************************************************************************              
//	Properties for Code Coverage for Bit-Level FSM
// 	Test Plan Section 5
// ****************************************************************************              

// ****************************************************************************              
// Property for When CMDR Start is Issued the Bit FSM will Transition to Start_A,
// Rep_Start_A, REP_Start_C, or Idle
// Test Plan Section 5.1
// ****************************************************************************              
property BIT_FSM_CMDR_Start;
	@(posedge clk_i) 	
	($rose(ack_i) && adr_o === CMDR_ADDR && dat_o === CMDR_START && we_o === 1) |->
	##4 (adr_o === FSMR_ADDR && dat_i[3:0] === BIT_LVL_FSM_START_A_cov 			&& we_o === 0)	|| 
			(adr_o === FSMR_ADDR && dat_i[3:0] === BIT_LVL_FSM_REP_START_A_cov 	&& we_o === 0) ||
			(adr_o === FSMR_ADDR && dat_i[3:0] === BIT_LVL_FSM_REP_START_C_cov 	&& we_o === 0) ||
			(adr_o === FSMR_ADDR && dat_i[3:0] === BIT_LVL_FSM_IDLE_cov 				&& we_o === 0) ;
endproperty						
assert 	property(BIT_FSM_CMDR_Start) 			else $error("BIT_FSM_CMDR_Start Failed, %t"				, $time	)	;
cover 	property(BIT_FSM_CMDR_Start) 																																	;

// ****************************************************************************              
// Property for When CMDR Write is Issued the Bit FSM will Transition to RW A
// or Idle
// Test Plan Section 5.2
// ****************************************************************************              
property BIT_FSM_CMDR_Write;
	@(posedge clk_i) 	
	($rose(ack_i) && adr_o === CMDR_ADDR && dat_o === CMDR_WRITE && we_o === 1) |->
	##4 (adr_o === FSMR_ADDR && dat_i[3:0] === BIT_LVL_FSM_RW_A_cov 				&& we_o === 0) ||
			(adr_o === FSMR_ADDR && dat_i[3:0] === BIT_LVL_FSM_IDLE_cov 				&& we_o === 0) ;
endproperty						
assert 	property(BIT_FSM_CMDR_Write) 			else $error("BIT_FSM_CMDR_Write Failed, %t"				, $time	)	;
cover 	property(BIT_FSM_CMDR_Write) 																																	;

// ****************************************************************************              
// Property for When CMDR Read w/h Ack is Issued the Bit FSM will Transition 
// to RW A or Idle
// Test Plan Section 5.3
// ****************************************************************************              
property BIT_FSM_CMDR_Read_Ack;
	@(posedge clk_i) 	
	($rose(ack_i) && adr_o === CMDR_ADDR && dat_o === CMDR_READ_ACK && we_o === 1) |->
	##4 (adr_o === FSMR_ADDR && dat_i[3:0] === BIT_LVL_FSM_RW_A_cov 				&& we_o === 0) ||
			(adr_o === FSMR_ADDR && dat_i[3:0] === BIT_LVL_FSM_IDLE_cov 				&& we_o === 0) ;
endproperty						
assert 	property(BIT_FSM_CMDR_Read_Ack) 	else $error("BIT_FSM_CMDR_Read_Ack Failed, %t"		, $time	)	;
cover 	property(BIT_FSM_CMDR_Read_Ack) 																															;

// ****************************************************************************              
// Property for When CMDR Read w/h Nack is Issued the Bit FSM will Transition 
// to RW A or Idle
// Test Plan Section 5.4
// ****************************************************************************              
property BIT_FSM_CMDR_Read_Nack;
	@(posedge clk_i) 	
	($rose(ack_i) && adr_o === CMDR_ADDR && dat_o === CMDR_READ_NACK && we_o === 1) |->
	##4 (adr_o === FSMR_ADDR && dat_i[3:0] === BIT_LVL_FSM_RW_A_cov 				&& we_o === 0) ||
			(adr_o === FSMR_ADDR && dat_i[3:0] === BIT_LVL_FSM_IDLE_cov 				&& we_o === 0) ;
endproperty						
assert 	property(BIT_FSM_CMDR_Read_Nack) 	else $error("BIT_FSM_CMDR_Read_NAck Failed, %t"		, $time	)	;
cover 	property(BIT_FSM_CMDR_Read_Nack) 																															;

// ****************************************************************************              
// Property for When CMDR Stop is Issued the Bit FSM will Transition 
// to Stop_A or Idle
// Test Plan Section 5.5
// ****************************************************************************              
property BIT_FSM_CMDR_Stop;
	@(posedge clk_i) 	
	($rose(ack_i) && adr_o === CMDR_ADDR && dat_o === CMDR_STOP && we_o === 1) |->
	##4 (adr_o === FSMR_ADDR && dat_i[3:0] === BIT_LVL_FSM_STOP_A_cov 			&& we_o === 0) ||
			(adr_o === FSMR_ADDR && dat_i[3:0] === BIT_LVL_FSM_IDLE_cov 				&& we_o === 0) ;
endproperty						
assert 	property(BIT_FSM_CMDR_Stop) 			else $error("BIT_FSM_CMDR_Stop Failed, %t"				, $time	)	;
cover 	property(BIT_FSM_CMDR_Stop) 																																	;


// ****************************************************************************              
// Tasks Used by the WB Interface
// ****************************************************************************              
  initial reset_bus();

// ****************************************************************************              
   task wait_for_reset();
       if (rst_i !== 0) @(negedge rst_i);
   endtask

// ****************************************************************************              
   task wait_for_num_clocks(int num_clocks);
       repeat (num_clocks) @(posedge clk_i);
   endtask

// ****************************************************************************              
   task wait_for_interrupt();
       wait(irq_i == 1);
   endtask

// ****************************************************************************              
   task reset_bus();
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        we_o <= 1'b0;
        adr_o <= 'b0;
        dat_o <= 'b0;
   endtask

// ****************************************************************************              
  task master_write(
                   input bit [ADDR_WIDTH-1:0]  addr,
                   input bit [DATA_WIDTH-1:0]  data
                   );  

        @(posedge clk_i);
        adr_o <= addr;
        dat_o <= data;
        cyc_o <= 1'b1;
        stb_o <= 1'b1;
        we_o <= 1'b1;
        while (!ack_i) @(posedge clk_i);
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        adr_o <= 'bx;
        dat_o <= 'bx;
        we_o <= 1'b0;
        @(posedge clk_i);

endtask        

// ****************************************************************************              
task master_read(
                 input bit [ADDR_WIDTH-1:0]  addr,
                 output bit [DATA_WIDTH-1:0] data
                 );                                                  

        @(posedge clk_i);
        adr_o <= addr;
        dat_o <= 'bx;
        cyc_o <= 1'b1;
        stb_o <= 1'b1;
        we_o <= 1'b0;
        @(posedge clk_i);
        while (!ack_i) @(posedge clk_i);
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        adr_o <= 'bx;
        dat_o <= 'bx;
        we_o <= 1'b0;
        data = dat_i;

endtask        

// ****************************************************************************              
     task master_monitor(
                   output bit [ADDR_WIDTH-1:0] addr,
                   output bit [DATA_WIDTH-1:0] data,
                   output bit we                    
                  );
                         
          while (!cyc_o) @(posedge clk_i);                                                  
          while (!ack_i) @(posedge clk_i);
          addr = adr_o;
          we = we_o;
          if (we_o) begin
            data = dat_o;
          end else begin
            data = dat_i;
          end
          while (cyc_o) @(posedge clk_i);                                                  
     endtask 





endinterface
