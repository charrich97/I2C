// ****************************************************************************              
// I2C Transaction Class
// ****************************************************************************              
class i2c_transaction extends ncsu_transaction;
  `ncsu_register_object(i2c_transaction)
	
  int I2C_NUM_WRITE_TESTS = 0			    																										;   // Number of Write Tests Conducted
  int I2C_NUM_READ_TESTS	= 0			    																										;   // Number of Read Tests Conducted
  int I2C_NUM_RW_TESTS		= 0			    																										;   // Number of Read/Write Tests Conducted per each Test
	//***************************************************************************
	// I2C Address and Data
	//***************************************************************************
  i2c_op_t																		op																										;
	bit [I2C_ADDR_WIDTH - 1:0]									i2c_addr																							;
	bit [I2C_DATA_WIDTH - 1:0]									i2c_data									[$]									 				;
	bit [I2C_DATA_WIDTH - 1:0]									read_data									[$]									 				;
	bit [I2C_DATA_WIDTH - 1:0]									write_data								[$]									 				;
  bit	[I2C_DATA_WIDTH - 1:0]   								stimuli2  								[$]													;		// Test 2 READ: Read_Data   for I2C Slave
	bit	[I2C_DATA_WIDTH - 1:0]   								stimuli3_read       			[$]													;		// Test 3 R_W: Read_Data   for I2C Slave
	int			    																r_cnstr_int					    															;   // Int for Read Data Constraint Gen
	int				  																r_gen											    												;   // Int for Read Data Stimuli Gen
	int				  																rw_gen										    												;   // Int for Read/Write Read Data Stimuli Gen

  function new(string name="");
    super.new(name);
  endfunction

	//***************************************************************************
	//Prints the Output Format for the Expected and Actual Transactions
	//***************************************************************************
	function string convert2string();  
	        return{$sformatf("TRANSACTION TYPE: %s, ADDRESS: %h, DATA: %p", op, i2c_addr, i2c_data)};
	endfunction	
	
	//***************************************************************************
	//Used for Comparing Predicted and Actual Transactions
	//***************************************************************************
	function bit compare(i2c_transaction rhs);
		return(	
						(this.op										== rhs.op										) &&
						(this.i2c_addr							== rhs.i2c_addr							) && 
						(this.i2c_data							== rhs.i2c_data							)
						);
	endfunction

  constraint read_data_c {
  	// ****************************************************************************              
  	// Read Test Read Data Constraint Gen
  	// ****************************************************************************              
    foreach(stimuli2[r_csntr_int]) 
      stimuli2[r_csntr_int]              inside {[0:255]};
  	// ****************************************************************************              
  	// RW Test Read Data Constraint Gen
  	// ****************************************************************************              
    foreach(stimuli3_read[r_csntr_int]) 
      stimuli3_read[r_csntr_int]        inside {[0:255]};
    
  }

  

endclass

