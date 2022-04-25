class wb_random_sequence extends ncsu_component#(.T(wb_transaction));
  `ncsu_register_object(wb_random_sequence)
    
  wb_transaction              					wb_trans_rand_seq  							;
  ncsu_component #(wb_transaction) 			agent    												;

  int 																	WB_NUM_WRITE_TESTS 							;   // Number of Directed Write Tests Conducted
  int 																	WB_NUM_READ_TESTS								;   // Number of Directed Read Tests Conducted
  int 																	WB_NUM_RW_TESTS									;   // Number of Directed Read/Write Tests Conducted per each Test
	int																		I2CMB_Write_test_int						;		// Int for Incrementing the I2CMB Level Write Transactions	
	int																		I2CMB_Read_test_int							;		// Int for Incrementing the I2CMB Level Read Transactions
	int																		I2CMB_RW_test_int								;		// Int for Incrementing the I2CMB Level RW Transactions

	bit																		Write_Test_Start								;		// Indicator for the Start of a Write Test
	bit																		Read_Test_Start									;		// Indicator for the Start of a Read Test
	bit																		R_W_Test_Start									;		// Indicator for the Start of a R_W Test
	bit																		Write_Test_Finished							;		// Indicator for when Write Test is Finished
	bit																		Read_Test_Finished							;		// Indicator for when Read Test is Finished
	bit																		R_W_Test_Finished								;		// Indicator for when R_W Test is Finished


  randc bit 	[I2C_DATA_WIDTH - 1:0]   	stimuli1_rand		        	[$]	  ;		// Test 1 WRITE: Write_Data  for WB Master
	randc bit 	[I2C_DATA_WIDTH - 1:0]   	stimuli3_write_rand      	[$]	  ;		// Test 3 R_W: Write_Data  for WB Master
	int			    													w_cnstr_int					    				;   // Int for Write Data Gen
	int			    													w_gen           					    	;   // Int for Write Data Gen
	int				  													rw_gen										    	;   // Int for Read/Write Data Gen

  function new(string name="", ncsu_component_base parent = null); 
    super.new(name, parent);
  endfunction

  function void set_agent(ncsu_component#(wb_transaction) agent);
    this.agent 	= agent;
  endfunction

  // ****************************************************************************              
  // Constrain the Write Data to be 2^8-1 bits long
  // ****************************************************************************              
  constraint write_data {
    foreach(stimuli1_rand[w_csntr_int])
      stimuli1_rand[w_csntr_int]              inside {[0:255]};
    foreach(stimuli3_write_rand[w_csntr_int])
      stimuli3_write_rand[w_csntr_int]        inside {[0:255]};
  }
	
  // ****************************************************************************              
  // Randomize the Stimulus Randomly
  // ****************************************************************************              
  function void post_randomize();
  	// ****************************************************************************              
  	// Write Test Random Write Data Gen
  	// ****************************************************************************              
    for (w_gen = 0; w_gen <= WB_NUM_WRITE_TESTS - 1; w_gen = w_gen + 1) begin
	  	stimuli1_rand[w_gen]								      = $urandom;
    end 
    
  	// ****************************************************************************              
  	// R/W Test Random Write Data Gen
  	// ****************************************************************************              
	  for (rw_gen = 0; rw_gen <= WB_NUM_RW_TESTS - 1; rw_gen = rw_gen + 1) begin
	  	stimuli3_write_rand[rw_gen]				      	=	$urandom;
	  end
  
  endfunction        

  virtual task run();
    $cast(wb_trans_rand_seq, ncsu_object_factory::create("wb_transaction"));
  	// ****************************************************************************              
  	// Generate Test Stimulus to the I2CMB
  	// ****************************************************************************              
  	post_randomize();
  	// ****************************************************************************              
  	// Wait for I2CMB DUT Reset
  	// ****************************************************************************              
		Wait_For_I2CMB_Reset();
  	// ****************************************************************************              
  	// Intialize I2CMB DUT Core
  	// ****************************************************************************              
		INIT_CORE();
  	// ****************************************************************************              
  	// Run I2CMB Tests
  	// ****************************************************************************              
		run_I2CMB_tests(WB_NUM_WRITE_TESTS, WB_NUM_READ_TESTS, WB_NUM_RW_TESTS, stimuli1_rand, stimuli3_write_rand);
	endtask
	
	virtual task Wait_For_I2CMB_Reset();
		//Wait for Reset of the I2CMB Core
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_RESET;
		agent.bl_put(wb_trans_rand_seq);
	endtask

	virtual task INIT_CORE();
	 	// Enable Core with Interrupts
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_rand_seq.i2c_cmd_addr 	= CSR_ADDR;
		wb_trans_rand_seq.i2c_cmd_data 	= CSR;
		wb_trans_rand_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_rand_seq);
	
	 	// Select I2C Bus
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_rand_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_rand_seq.i2c_cmd_data 	= DPR;
		wb_trans_rand_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_rand_seq);
	
		Write_CMDR_Set_Bus();
	endtask

	virtual task run_I2CMB_tests( input int                         NUM_WRITE_TESTS                    	,
	                              input int                         NUM_READ_TESTS                     	, 
	                              input int                         NUM_RW_TESTS                       	, 
	                              input bit [I2C_DATA_WIDTH - 1:0]  write_data    [$] 									, 
	                              input bit [I2C_DATA_WIDTH - 1:0]  rw_write_data [$]    
	                            );
		I2CMB_Write_Test(NUM_WRITE_TESTS, write_data );
		I2CMB_Read_Test(NUM_READ_TESTS               );
		I2CMB_R_W_Test(NUM_RW_TESTS, rw_write_data   );
		$finish;
	endtask

	// ****************************************************************************
	// I2CMB Random Write Tests
	// ****************************************************************************
	virtual task I2CMB_Write_Test(int NUM_TESTS, bit [I2C_DATA_WIDTH - 1:0] Write_Data_Byte[$]);
		
	  Write_Test_Start 						= 1;
		//Send Start Bit
		send_start();
	
		// Write Slave Address with Write Bit
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_rand_seq.op 						= WRITE;
		wb_trans_rand_seq.addr						= wb_trans_rand_seq.slave_addr;
		wb_trans_rand_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_rand_seq.i2c_cmd_data 	= 8'h22;
		wb_trans_rand_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_rand_seq);
		
		Write_CMDR();
	
	  for (I2CMB_Write_test_int=0; I2CMB_Write_test_int <= NUM_TESTS - 1; I2CMB_Write_test_int++) begin
		//Write Data Byte to DPR
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_rand_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_rand_seq.i2c_cmd_data 	= Write_Data_Byte.pop_front();
		wb_trans_rand_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_rand_seq);	
		
		Write_CMDR();	
	
		if (I2CMB_Write_test_int == NUM_TESTS - 1) begin 
			Write_Test_Start = 0;
			send_stop();
		end
	end
	endtask
	
	
	// ****************************************************************************
	// I2CMB Random Read Tests
	// ****************************************************************************
	virtual task I2CMB_Read_Test(int NUM_TESTS);
		Read_Test_Start 						= 1;
	
		send_start();
		// Write Slave Address with Read Bit
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_rand_seq.op 						= READ;
		wb_trans_rand_seq.addr					= wb_trans_rand_seq.slave_addr;
		wb_trans_rand_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_rand_seq.i2c_cmd_data 	= 8'h23;
		wb_trans_rand_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_rand_seq);
		
		Write_CMDR();
	
	  for (I2CMB_Read_test_int = 0; I2CMB_Read_test_int <= NUM_TESTS - 1; I2CMB_Read_test_int++) begin
		Write_CMDR_Read_With_ACK();	
		//Write CMDR Read
	
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_READ;
		wb_trans_rand_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_rand_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_rand_seq);	
		
		if (I2CMB_Read_test_int == NUM_TESTS - 2) begin 
			Write_CMDR_Read_With_NACK();	
	
			wb_trans_rand_seq.I2CMB_EN 			= I2CMB_READ;
			wb_trans_rand_seq.i2c_cmd_addr 	= DPR_ADDR;
			wb_trans_rand_seq.i2c_irq				=	0;
			agent.bl_put(wb_trans_rand_seq);	
			Read_Test_Start = 0;
			send_stop();
		end
		end	
	endtask
	
	// ****************************************************************************
	// I2CMB RW Tests
	// ****************************************************************************
	virtual task I2CMB_R_W_Test(int NUM_TESTS, bit [I2C_DATA_WIDTH - 1:0] Write_Data_Byte[$]);
		R_W_Test_Start 						= 1;
	  for (I2CMB_RW_test_int = 0; I2CMB_RW_test_int <= NUM_TESTS - 1; I2CMB_RW_test_int++) begin
		
	// ****************************************************************************
	// Write Tests
	// ****************************************************************************
			//Send Start Bit
			send_start();
			
			// Write Slave Address with Write Bit
			wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
			wb_trans_rand_seq.op 						= WRITE;
			wb_trans_rand_seq.addr						= wb_trans_rand_seq.slave_addr;
			wb_trans_rand_seq.i2c_cmd_addr 	= DPR_ADDR;
			wb_trans_rand_seq.i2c_cmd_data 	= 8'h22;
			wb_trans_rand_seq.i2c_irq				=	0;
			agent.bl_put(wb_trans_rand_seq);
			
			//CMDR WRITE
			Write_CMDR();
			
			//Write Data Byte to DPR
			wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
			wb_trans_rand_seq.i2c_cmd_addr 	= DPR_ADDR;
			wb_trans_rand_seq.i2c_cmd_data 	= Write_Data_Byte.pop_front();
			wb_trans_rand_seq.i2c_irq				=	0;
			agent.bl_put(wb_trans_rand_seq);	
			
			//CMDR WRITE
			Write_CMDR();
			
	// ****************************************************************************
	// Read_Tests
	// ****************************************************************************
			//Send Start Bit
			send_start();
			
			// Write Slave Address with Read Bit
			wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
			wb_trans_rand_seq.op 						= READ;
			wb_trans_rand_seq.addr						= wb_trans_rand_seq.slave_addr;
			wb_trans_rand_seq.i2c_cmd_addr 	= DPR_ADDR;
			wb_trans_rand_seq.i2c_cmd_data 	= 8'h23;
			wb_trans_rand_seq.i2c_irq				=	0;
			agent.bl_put(wb_trans_rand_seq);
	
			//Write CMDR
			Write_CMDR();
	
			//Write CMDR_READ
			Write_CMDR_Read_With_NACK();	
	
			wb_trans_rand_seq.I2CMB_EN 			= I2CMB_READ;
			wb_trans_rand_seq.i2c_cmd_addr 	= DPR_ADDR;
			wb_trans_rand_seq.i2c_irq				=	0;
			agent.bl_put(wb_trans_rand_seq);	
	
			if (I2CMB_RW_test_int == NUM_TESTS - 1) begin 
				R_W_Test_Start 						= 0;
				send_stop();
			end
	end
	endtask
	
	
	// ****************************************************************************
	// STOP COMMAND
	// ****************************************************************************
	virtual task send_stop();
	
		//Send Stop Bit
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_rand_seq.i2c_cmd_data 	= CMDR_STOP;
		wb_trans_rand_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_rand_seq);
	
		read_FSMR();
	
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_rand_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_rand_seq);	
	
	endtask
	
	// ****************************************************************************
	// START COMMAND
	// ****************************************************************************
	virtual task send_start();
	
		//Send Start Bit
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_rand_seq.i2c_cmd_data 	= CMDR_START;
		wb_trans_rand_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_rand_seq);
	
		read_FSMR();
	
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_rand_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_rand_seq);	
	endtask
	
	// ****************************************************************************
	// Read From FSMR
	// ****************************************************************************
	virtual task read_FSMR();
		//Send Start Bit
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_READ;
		wb_trans_rand_seq.i2c_cmd_addr 	= FSMR_ADDR;
		wb_trans_rand_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_rand_seq);
	endtask
	
	// ****************************************************************************
	// Write CMDR Write
	// ****************************************************************************
	virtual task Write_CMDR();
		
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_rand_seq.i2c_cmd_data 	= CMDR_WRITE;
		wb_trans_rand_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_rand_seq);
	
		read_FSMR();
	
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_rand_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_rand_seq);	
	endtask
	
	// ****************************************************************************
	// Write CMDR Read with ACK(Acknowledge)
	// ****************************************************************************
	virtual task Write_CMDR_Read_With_ACK();
		//Write CMDR_READ
	
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_rand_seq.i2c_cmd_data 	= CMDR_READ_ACK;
		wb_trans_rand_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_rand_seq);
	
		read_FSMR();
	
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_rand_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_rand_seq);
	endtask
	
	// ****************************************************************************
	// Write CMDR Read with NACK(Acknowledge)
	// ****************************************************************************
	virtual task Write_CMDR_Read_With_NACK();
		//Write CMDR_READ
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_rand_seq.i2c_cmd_data 	= CMDR_READ_NACK;
		wb_trans_rand_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_rand_seq);
	
		read_FSMR();
	
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_rand_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_rand_seq);
	endtask
	
	// ****************************************************************************
	// Write CMDR Wait
	// ****************************************************************************
	virtual task Write_CMDR_Wait();
	
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_rand_seq.i2c_cmd_data 	= CMDR_WAIT;
		wb_trans_rand_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_rand_seq);
		
		read_FSMR();
	
		wb_trans_rand_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_rand_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_rand_seq);
	
	endtask
	
	// ****************************************************************************
	// Write CMDR Set Bus
	// ****************************************************************************
	virtual task Write_CMDR_Set_Bus();
	
		 	// Send Set Bus Command to CMDR Register
			wb_trans_rand_seq.I2CMB_EN 			= I2CMB_WRITE;
			wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
			wb_trans_rand_seq.i2c_cmd_data 	= CMDR_SET_BUS;
			wb_trans_rand_seq.i2c_irq				=	0;
			agent.bl_put(wb_trans_rand_seq);
	
			read_FSMR();
	
			wb_trans_rand_seq.I2CMB_EN 			= I2CMB_NULL;
			wb_trans_rand_seq.i2c_cmd_addr 	= CMDR_ADDR;
			wb_trans_rand_seq.i2c_irq				=	1;
			agent.bl_put(wb_trans_rand_seq);
	endtask
endclass

