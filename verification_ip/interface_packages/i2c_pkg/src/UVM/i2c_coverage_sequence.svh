class i2c_coverage_sequence extends ncsu_component#(.T(i2c_transaction));
    `ncsu_register_object(i2c_coverage_sequence)
  T i2c_trans_seq;    
  ncsu_component #(i2c_transaction) i2c_agent_seq;
  int I2C_NUM_WRITE_TESTS                                                               ;   // Number of Write Tests Conducted
  int I2C_NUM_READ_TESTS                                                                ;   // Number of Read Tests Conducted
  int I2C_NUM_RW_TESTS                                                                  ;   // Number of Read/Write Tests Conducted per each Test

  function new(string name="", ncsu_component_base parent = null); 
    super.new(name, parent);
  endfunction

  function void set_agent(ncsu_component#(i2c_transaction) agent);
    this.i2c_agent_seq  = agent;
  endfunction

  virtual task run();
  $cast(i2c_trans_seq, ncsu_object_factory::create("i2c_transaction"));
  
  // ****************************************************************************              
  // Generate/Receive DUT Stimulus to the I2C Slave Device
  // ****************************************************************************              
  run_I2C_Tests();
  endtask

  virtual task run_I2C_Tests();
  I2C_Write_Test_With_Error();
  //I2C_Write_Test_With_ARB_Loss();
  endtask

  virtual task I2C_Write_Test_With_Error();
  i2c_agent_seq.bl_put(i2c_trans_seq); 
  endtask
  virtual task I2C_Write_Test_With_ARB_Loss();
  i2c_agent_seq.bl_put(i2c_trans_seq); 
  endtask

  virtual task I2C_Start_Test_With_Error();
  i2c_agent_seq.bl_put(i2c_trans_seq); 
  endtask

  virtual task I2C_Read_Test_With_Error();
  i2c_trans_seq.read_data.push_front(8'hFF);
  i2c_agent_seq.bl_put(i2c_trans_seq); 
  i2c_trans_seq.read_data.delete();
  endtask
endclass

