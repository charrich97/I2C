class wb_coverage_sequence extends ncsu_component#(.T(wb_transaction));
  `ncsu_register_object(wb_coverage_sequence)
    
  wb_transaction                    wb_trans_seq  											;
  ncsu_component #(wb_transaction) 	agent  															;
  int 															WB_NUM_WRITE_TESTS 									;   // Number of WB Write Tests Conducted
  int 															WB_NUM_READ_TESTS										;   // Number of WB Read Tests Conducted
  int 															WB_NUM_RW_TESTS											;   // Number of WB Read/Write Tests Conducted per each Test
	bit 			[WB_DATA_WIDTH - 1:0] 	Write_Error_CMD	= 8'hFF							;
	bit 			[WB_DATA_WIDTH - 1:0] 	Read_Error_CMD	= 8'hFF							;

  function new(string name="", ncsu_component_base parent = null); 
    super.new(name, parent);
  endfunction

  function void set_agent(ncsu_component#(wb_transaction) agent);
    this.agent 	= agent;
  endfunction

  virtual task run();
   $cast(wb_trans_seq, ncsu_object_factory::create("wb_transaction"));
		Wait_For_I2CMB_Reset();
		I2CMB_Reset_Register_Test();
		INIT_CORE();
		Write_CMDR_Wait();
		Write_Test_With_Error();
		$finish;
	endtask
	
	// ****************************************************************************
	// Intialize for I2C Testing
	// ****************************************************************************
	
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

	virtual task I2CMB_Reset_Register_Test();
		wb_trans_seq.I2CMB_EN 			= I2CMB_READ;
		wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);	
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_READ;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);	
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_READ;
		wb_trans_seq.i2c_cmd_addr 	= CSR_ADDR;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);	
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_READ;
		wb_trans_seq.i2c_cmd_addr 	= FSMR_ADDR;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);	
	endtask
	
	
	virtual task Write_Test_With_Error();
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
		
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= 8'hFF;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);	
	
		Write_CMDR_With_Error(Write_Error_CMD);
	endtask
	
	virtual task Write_CMDR_With_Error(bit [WB_DATA_WIDTH - 1: 0] Error_CMD);
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= Error_CMD;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
	
		read_FSMR();
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_seq);
	
	endtask
	
	virtual task Write_Test_With_ARB_Loss();
		//Send Start Bit
		send_start();
		Write_CMDR_Wait();
	
		// Write Slave Address with Write Bit
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.op 						= WRITE;
		wb_trans_seq.addr						= wb_trans_seq.slave_addr;
		wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= 8'h22;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
		
		Write_CMDR();
	
		//Write Data Byte to DPR
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= DPR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= 8'hFF;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);	
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_WRITE;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_cmd_data 	= CMDR_WRITE;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_READ;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_irq				=	0;
		agent.bl_put(wb_trans_seq);
	
		read_FSMR();
	
		wb_trans_seq.I2CMB_EN 			= I2CMB_NULL;
		wb_trans_seq.i2c_cmd_addr 	= CMDR_ADDR;
		wb_trans_seq.i2c_irq				=	1;
		agent.bl_put(wb_trans_seq);	
		
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

