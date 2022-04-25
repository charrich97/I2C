class wb_sequence extends ncsu_component#(.T(wb_transaction));
  `ncsu_register_object(wb_sequence)
    
  wb_transaction                    wb_trans_seq  											;
  ncsu_component #(wb_transaction) 	agent  															;
  int 															WB_NUM_WRITE_TESTS 									;   // Number of Write Tests Conducted
  int 															WB_NUM_READ_TESTS										;   // Number of Read Tests Conducted
  int 															WB_NUM_RW_TESTS											;   // Number of Read/Write Tests Conducted per each Test
	int																I2CMB_Write_test_int								;		// Int for Incrementing the I2CMB Level Transactions	
	int																I2CMB_Read_test_int;
	int																I2CMB_RW_test_int;

	bit																Write_Test_Start										;		// Indicator for the Start of a Write Test
	bit																Read_Test_Start											;		// Indicator for the Start of a Read Test
	bit																R_W_Test_Start											;		// Indicator for the Start of a R_W Test
	bit																Write_Test_Finished									;		// Indicator for when Write Test is Finished
	bit																Read_Test_Finished									;		// Indicator for when Read Test is Finished
	bit																R_W_Test_Finished										;		// Indicator for when R_W Test is Finished

  bit [I2C_DATA_WIDTH - 1:0]   			stimuli1		        	[$]						;		// Test 1 WRITE: Write_Data  for WB Master
	bit [I2C_DATA_WIDTH - 1:0]   			stimuli3_write      	[$]						;		// Test 3 R_W: Write_Data  for WB Master
	int			    											w_gen											    			;  	// Int for Write Data Gen
	int				  											rw_gen										    			;  	// Int for Read/Write Data Gen

  function new(string name="", ncsu_component_base parent = null); 
    super.new(name, parent);
  endfunction

  function void set_agent(ncsu_component#(wb_transaction) agent);
    this.agent 	= agent;
  endfunction

  // ****************************************************************************              
  // Generate Directed Stimulus Randomly
  // ****************************************************************************              
	function void post_directed();
	// ****************************************************************************              
	// Write Test Directed Write Data Gen
	// ****************************************************************************              
	for (w_gen = 0; w_gen <= WB_NUM_WRITE_TESTS - 1; w_gen = w_gen + 1) begin
		stimuli1[w_gen]								= w_gen;
	end

	// ****************************************************************************              
	// R/W Test Write Data Gen
	// ****************************************************************************              
	for (rw_gen = 0; rw_gen <= WB_NUM_RW_TESTS - 1; rw_gen = rw_gen + 1) begin
		stimuli3_write[rw_gen]				=	rw_gen + 64;
	end

	endfunction
  virtual task run();
   $cast(wb_trans_seq, ncsu_object_factory::create("wb_transaction"));
  	// ****************************************************************************              
  	// Generate Test Stimulus to the I2CMB
  	// ****************************************************************************              
  	post_directed();
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
		run_I2CMB_tests(WB_NUM_WRITE_TESTS, WB_NUM_READ_TESTS, WB_NUM_RW_TESTS, stimuli1, stimuli3_write);
	endtask
	
	virtual task Wait_For_I2CMB_Reset();
		//Wait for Reset of the I2CMB Core
		wb_trans_seq.I2CMB_EN 			= I2CMB_RESET;
		agent.bl_put(wb_trans_seq);
	endtask

	virtual task INIT_CORE();
	 	// Enable Core with Interrupts
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= CSR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= CSR;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
	
	 	// Select I2C Bus
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= DPR;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
	
		Write_CMDR_Set_Bus();
	endtask

	virtual task run_I2CMB_tests( input int                            NUM_WRITE_TESTS                    ,
	                              input int                            NUM_READ_TESTS                     , 
	                              input int                            NUM_RW_TESTS                       , 
	                              input bit [I2C_DATA_WIDTH - 1:0]  write_data    [$] , 
	                              input bit [I2C_DATA_WIDTH - 1:0]  rw_write_data [$]    
	                            );
		I2CMB_Write_Test(NUM_WRITE_TESTS, write_data );
		I2CMB_Read_Test(NUM_READ_TESTS               );
		I2CMB_R_W_Test(NUM_RW_TESTS,rw_write_data   );
	endtask
	
	// ****************************************************************************
	// I2CMB Directed Write Tests
	// ****************************************************************************
	virtual task I2CMB_Write_Test(int NUM_TESTS, bit [I2C_DATA_WIDTH - 1:0] Write_Data_Byte[$]);
		
	  Write_Test_Start 						= 1;
		//Send Start Bit
		send_start();
	
		// Write Slave Address with Write Bit
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.op 						= WRITE;
		wb_trans_seq.addr						= wb_trans_seq.slave_addr;
		wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= 8'h22;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
		
		Write_CMDR();
	
	  for (I2CMB_Write_test_int=0; I2CMB_Write_test_int <= NUM_TESTS - 1; I2CMB_Write_test_int++) begin
		//Write Data Byte to DPR
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= Write_Data_Byte.pop_front();
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);	
		
		Write_CMDR();	
	
		if (I2CMB_Write_test_int == NUM_TESTS - 1) begin 
			Write_Test_Start = 0;
			send_stop();
		end
	end
	endtask


	virtual task I2CMB_Read_Test(int NUM_TESTS);
		Read_Test_Start 						= 1;
	
		send_start();
		// Write Slave Address with Read Bit
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.op 						= READ;
		wb_trans_seq.addr						= wb_trans_seq.slave_addr;
		wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= 8'h23;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
		
		Write_CMDR();
	
	  for (I2CMB_Read_test_int = 0; I2CMB_Read_test_int <= NUM_TESTS - 1; I2CMB_Read_test_int++) begin
		Write_CMDR_Read_With_ACK();	
		//Write CMDR Read
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_READ;
		wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);	
		
		if (I2CMB_Read_test_int == NUM_TESTS - 2) begin 
			Write_CMDR_Read_With_NACK();	
	
			wb_trans_seq.I2CMB_EN 			= I2CMB_READ;
			wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
			wb_trans_seq.i2c_irq				=	0;
			agent.bl_put(wb_trans_seq);	
			Read_Test_Start = 0;
			send_stop();
		end
	end	
	endtask

	virtual task I2CMB_R_W_Test(int NUM_TESTS, bit [I2C_DATA_WIDTH - 1:0] Write_Data_Byte[$]);
		R_W_Test_Start 						= 1;
	  for (I2CMB_RW_test_int = 0; I2CMB_RW_test_int <= NUM_TESTS - 1; I2CMB_RW_test_int++) begin
		// ****************************************************************************
		// Write Tests
		// ****************************************************************************
			//Send Start Bit
			send_start();
			
			// Write Slave Address with Write Bit
			wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
			wb_trans_seq.op 						= WRITE;
			wb_trans_seq.addr						= wb_trans_seq.slave_addr;
			wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
			wb_trans_seq.i2c_cmd_data 	= 8'h22;
			wb_trans_seq.i2c_irq				=	0;
			agent.bl_put(wb_trans_seq);
			
			//CMDR WRITE
			Write_CMDR();
			
			//Write Data Byte to DPR
			wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
			wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
			wb_trans_seq.i2c_cmd_data 	= Write_Data_Byte.pop_front();
			wb_trans_seq.i2c_irq				=	0;
			agent.bl_put(wb_trans_seq);	
			
			//CMDR WRITE
			Write_CMDR();
			
	// ****************************************************************************
	// Read_Tests
	// ****************************************************************************
			//Send Start Bit
			send_start();
			
			// Write Slave Address with Read Bit
			wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
			wb_trans_seq.op 						= READ;
			wb_trans_seq.addr						= wb_trans_seq.slave_addr;
			wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
			wb_trans_seq.i2c_cmd_data 	= 8'h23;
			wb_trans_seq.i2c_irq				=	0;
			agent.bl_put(wb_trans_seq);
	
			//Write CMDR
			Write_CMDR();
	
			//Write CMDR_READ
			Write_CMDR_Read_With_NACK();	
	
			wb_trans_seq.I2CMB_EN 			= I2CMB_READ;
			wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
			wb_trans_seq.i2c_irq				=	0;
			agent.bl_put(wb_trans_seq);	
	
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
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= CMDR_STOP;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
	
		read_FSMR();
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_seq);	
	
	endtask
	
	virtual task send_start();
	
		//Send Start Bit
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= CMDR_START;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
	
		read_FSMR();
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_seq);	
	endtask
	
	virtual task read_FSMR();
		//Send Start Bit
		wb_trans_seq.I2CMB_EN 			= I2CMB_READ;
		wb_trans_seq.i2c_cmd_addr 	= FSMR_ADDR;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
	endtask
	
	virtual task Write_CMDR();
		
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= CMDR_WRITE;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
	
		read_FSMR();
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_seq);	
	endtask
	
	virtual task Write_CMDR_Read_With_ACK();
		//Write CMDR_READ
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= CMDR_READ_ACK;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
	
		read_FSMR();
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_seq);
	endtask
	
	virtual task Write_CMDR_Read_With_NACK();
		//Write CMDR_READ
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= CMDR_READ_NACK;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
	
		read_FSMR();
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_seq);
	endtask
	
	virtual task Write_CMDR_Wait();
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= CMDR_WAIT;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
		
		read_FSMR();
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_seq);
	
	endtask
	
	virtual task Write_CMDR_Set_Bus();
		// Send Set Bus Command to CMDR Register
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= CMDR_SET_BUS;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
	
		read_FSMR();
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_seq);
	endtask
endclass

