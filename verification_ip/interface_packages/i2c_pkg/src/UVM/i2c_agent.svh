// ****************************************************************************              
// I2C Agent Class
// ****************************************************************************              
class i2c_agent extends ncsu_component#(.T(i2c_transaction));

  // ****************************************************************************              
  // Extended Classes
  // ****************************************************************************              
  i2c_configuration   configuration;
  i2c_driver          driver;
  i2c_monitor         monitor;
  ncsu_component #(T) subscribers[$];

  // ****************************************************************************              
  // Instantiate the I2C Virtual Interface
  // ****************************************************************************              
  virtual i2c_if i2c_bus;

  function new(string name = "", ncsu_component_base  parent = null);
    super.new(name,parent);
    if ( !(ncsu_config_db#(virtual i2c_if)::get(get_full_name(), this.i2c_bus))) begin;
      $display("i2c_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
      $finish;
    end
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void build();
    driver = new("driver",this);
    driver.set_configuration(configuration);
    driver.build();
    driver.i2c_bus = this.i2c_bus;
    monitor = new("monitor",this);
    monitor.set_configuration(configuration);
    monitor.set_agent(this);
    monitor.enable_transaction_viewing = 1;
    monitor.build();
    monitor.i2c_bus = this.i2c_bus;
  endfunction

  // ****************************************************************************              
  // Used to Put in Subscribers
  // ****************************************************************************              
  virtual function void nb_put(T trans);
    foreach (subscribers[i]) subscribers[i].nb_put(trans);
  endfunction

  // ****************************************************************************              
  // Used to Output Operation and Write Data
  // Used for Read Data Transactions
  // ****************************************************************************              
  virtual task bl_put(T trans);
    driver.bl_put(trans);
  endtask

  // ****************************************************************************              
  // Used to Connect Subscribers
  // ****************************************************************************              
  virtual function void connect_subscriber(ncsu_component#(T) subscriber);
    subscribers.push_back(subscriber);
  endfunction

  // ****************************************************************************              
  // Used to Monitor Signal Transactions
  // ****************************************************************************              
  virtual task run();
     fork monitor.run(); join_none
  endtask

endclass

