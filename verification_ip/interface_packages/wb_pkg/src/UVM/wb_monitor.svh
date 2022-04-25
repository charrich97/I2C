class wb_monitor extends ncsu_component#(.T(wb_transaction));
	parameter int WB_ADDR_WIDTH 	= 2;
	parameter int WB_DATA_WIDTH 	= 8;
	
	wb_configuration  configuration;
  virtual wb_if wb_bus;

  T monitored_trans;
  ncsu_component #(T) agent;

  function new(string name = "", ncsu_component_base  parent = null);
    super.new(name,parent);
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
    this.agent = agent;
  endfunction

  virtual task run ();
    wb_bus.wait_for_reset();
      forever begin
        monitored_trans = new("monitored_trans");
        wb_bus.master_monitor(monitored_trans.i2c_cmd_addr,
                    					monitored_trans.i2c_cmd_data,
                    					monitored_trans.we_mon
                    					);
       //$display("%s wb_monitor::run() I2CMB_ADDR: %h, I2CMB_DATA: %b, OP: %b",
       //         get_full_name(),
       //         monitored_trans.i2c_cmd_addr,
       //         monitored_trans.i2c_cmd_data,
       //         monitored_trans.we_mon
       //         );
        agent.nb_put(monitored_trans);
    end
  endtask

endclass

