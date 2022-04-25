class i2c_driver extends ncsu_component#(.T(i2c_transaction));

  function new(string name = "", ncsu_component_base  parent = null);
    super.new(name,parent);
  endfunction

  // ****************************************************************************              
  // Instantiate the I2C Virtual Interface
  // ****************************************************************************              
  virtual i2c_if  i2c_bus;

  // ****************************************************************************              
  // Extended Classes
  // ****************************************************************************              
  i2c_configuration configuration   ;

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
    // Always Start at Wait for I2C Transfer
    i2c_bus.wait_for_i2c_transfer(trans.op, trans.write_data);
    // If Operation is a Read then Provide Read Data for Slave
    if (trans.op == READ) begin 
      i2c_bus.provide_read_data(trans.read_data);
    end
  endtask

endclass
