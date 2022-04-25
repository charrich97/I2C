// ****************************************************************************              
// WB Driver Class
// ****************************************************************************              
class wb_driver extends ncsu_component#(.T(wb_transaction));

	virtual wb_if wb_bus;
  wb_configuration configuration;

  function new(string name = "", ncsu_component_base  parent = null);
    super.new(name,parent);
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
		// Wait for the Reset of the I2CMB Core
		if (trans.I2CMB_EN == I2CMB_RESET) begin
			wb_bus.wait_for_reset();
		end

		// Write Data to the I2CMB Core
		if (trans.I2CMB_EN == I2CMB_WRITE) begin
			wb_bus.master_write(trans.i2c_cmd_addr, trans.i2c_cmd_data);
		end
		// Read Data from the I2CMB Core
		if(trans.I2CMB_EN == I2CMB_READ) begin
			wb_bus.master_read(trans.i2c_cmd_addr, trans.i2c_cmd_data);		
		end

		// Wait for Interrupt and Read Data out of the from the I2CMB Core
		if (trans.i2c_irq) begin
			wb_bus.wait_for_interrupt();
			wb_bus.master_read(trans.i2c_cmd_addr, trans.i2c_cmd_data);		
		end
  endtask
endclass

