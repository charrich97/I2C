class i2c_random_sequence extends ncsu_component#(.T(i2c_transaction));
    `ncsu_register_object(i2c_random_sequence)
    
  i2c_transaction                       i2c_trans_seq                     ;
  ncsu_component #(i2c_transaction)     i2c_agent_seq                     ;
  int                                   i2c_seq_int                       ;

  int                                   I2C_NUM_WRITE_TESTS               ;
  int                                   I2C_NUM_READ_TESTS                ;
  int                                   I2C_NUM_RW_TESTS                  ;
  
  randc bit   [I2C_DATA_WIDTH - 1:0]    stimuli2_rand             [$]     ;   // Test 2 READ: Read_Data   for I2C Slave
  randc bit   [I2C_DATA_WIDTH - 1:0]    stimuli3_read_rand        [$]     ;   // Test 3 R_W: Read_Data   for I2C Slave
  int                                   r_cnstr_int                       ;   // Int for Read Data Constraint Gen
  int                                   r_gen                             ;   // Int for Read Data Stimuli Gen
  int                                   rw_gen                            ;   // Int for Read/Write Read Data Stimuli Gen

  function new(string name="", ncsu_component_base parent = null); 
    super.new(name, parent);
  endfunction

  function void set_agent(ncsu_component#(i2c_transaction) agent);
    this.i2c_agent_seq  = agent;
  endfunction

  constraint read_data_rand_c {
    // ****************************************************************************              
    // Read Test Read Data Constraint Gen
    // ****************************************************************************              
    foreach(stimuli2_rand[r_csntr_int]) 
      stimuli2_rand[r_csntr_int]              inside {[0:255]};
    
    // ****************************************************************************              
    // RW Test Read Data Constraint Gen
    // ****************************************************************************              
    foreach(stimuli3_read_rand[r_csntr_int]) 
      stimuli3_read_rand[r_csntr_int]         inside {[0:255]};
    
  }

  function void post_randomize();
    // ****************************************************************************              
    // Read Test Read Data Gen
    // ****************************************************************************              
    for (r_gen = 0; r_gen <= I2C_NUM_READ_TESTS - 1; r_gen = r_gen + 1) begin 
      stimuli2_rand[r_gen]                      = $urandom;
    end 
    
    // ****************************************************************************              
    // R/W Test read Data Gen
    // ****************************************************************************              
    for (rw_gen = 0; rw_gen <= I2C_NUM_RW_TESTS - 1; rw_gen = rw_gen + 1) begin
      stimuli3_read_rand[rw_gen]                = $urandom;
    end
  endfunction        

  virtual task run();
  $cast(i2c_trans_seq, ncsu_object_factory::create("i2c_transaction"));
  post_randomize();
  // ****************************************************************************              
  // Generate/Receive DUT Stimulus to the I2C Slave Device
  // ****************************************************************************              
  run_I2C_Tests(I2C_NUM_RW_TESTS, stimuli2_rand, stimuli3_read_rand);
  endtask

  // ****************************************************************************              
  // Run I2C Random Tests
  // ****************************************************************************              
  virtual task run_I2C_Tests( input int                         NUM_TESTS         ,
                              input bit [I2C_DATA_WIDTH - 1:0]  read_data    [$]  , 
                              input bit [I2C_DATA_WIDTH - 1:0]  rw_read_data [$]
                            );
    I2C_Write_Tests();
    I2C_Read_Tests(read_data);
    I2C_RW_Tests(NUM_TESTS, rw_read_data);
  endtask

  // ****************************************************************************              
  // Run I2C Random Write Tests
  // ****************************************************************************              
  virtual task I2C_Write_Tests();
    i2c_agent_seq.bl_put(i2c_trans_seq); 
  endtask

  // ****************************************************************************              
  // Run I2C Random Read Tests
  // ****************************************************************************              
  virtual task I2C_Read_Tests(input bit [I2C_DATA_WIDTH - 1:0] Read_Data_Byte [$]);
    i2c_trans_seq.read_data = Read_Data_Byte;
    i2c_agent_seq.bl_put(i2c_trans_seq); 
    i2c_trans_seq.read_data.delete();
  endtask

  // ****************************************************************************              
  // Run I2C Random RW Tests
  // ****************************************************************************              
  virtual task I2C_RW_Tests(input int                         NUM_TESTS      , 
                            input bit [I2C_DATA_WIDTH - 1:0]  Read_Data_Byte [$]
                            );
    for(i2c_seq_int = 0; i2c_seq_int <= NUM_TESTS - 1; i2c_seq_int ++) begin
      i2c_agent_seq.bl_put(i2c_trans_seq); 
      i2c_trans_seq.read_data.push_front(Read_Data_Byte.pop_front());
      i2c_agent_seq.bl_put(i2c_trans_seq); 
      i2c_trans_seq.read_data.delete();
    end
  endtask
  
endclass

