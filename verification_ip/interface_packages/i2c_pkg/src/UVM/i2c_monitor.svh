// ****************************************************************************              
// I2C Monitor Class
// ****************************************************************************              
class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

  // ****************************************************************************              
  // Instantiate the I2C Virtual Interface
  // ****************************************************************************              
  virtual i2c_if i2c_bus;

  // ****************************************************************************              
  // Extended Classes
  // ****************************************************************************              
  T monitored_trans;
  i2c_configuration  configuration;
  ncsu_component #(T) agent;

  function new(string name = "", ncsu_component_base  parent = null);
    super.new(name,parent);
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
    this.agent = agent;
  endfunction

  virtual task run();
      forever begin
        monitored_trans = new("monitored_trans");
        if ( enable_transaction_viewing) begin
           monitored_trans.start_time = $time;
        end
        i2c_bus.monitor(monitored_trans.i2c_addr,
                        monitored_trans.op,
                        monitored_trans.i2c_data
                       );
        $display("%s i2c_monitor::run() Address: %h, Operation: %0s, I2C_DATA: %p",
                 get_full_name(),
                 monitored_trans.i2c_addr,
                 monitored_trans.op,
                 monitored_trans.i2c_data
                 );
        agent.nb_put(monitored_trans);
        if ( enable_transaction_viewing) begin
           monitored_trans.end_time = $time;
           monitored_trans.add_to_wave(transaction_viewing_stream);
        end
      end
  endtask

endclass

