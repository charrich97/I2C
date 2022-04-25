class i2cmb_environment extends ncsu_component;

  i2cmb_env_configuration configuration;
  wb_agent                w_agent;
  i2c_agent               i_agent;
  i2cmb_predictor         pred;
  i2cmb_scoreboard        scbd;
  i2cmb_coverage          coverage;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction 

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void build();
    w_agent   = new("w_agent",this);
    w_agent.set_configuration(configuration.wb_agent_config);
    w_agent.build();

    i_agent   = new("i_agent",this);
    i_agent.set_configuration(configuration.i2c_agent_config);
    i_agent.build();

    pred      = new("pred", this);
    pred.set_configuration(configuration);
    pred.build();

    scbd      = new("scbd", this);
    scbd.build();

    coverage  = new("coverage", this);
    coverage.set_configuration(configuration);
    coverage.build();

    w_agent.connect_subscriber(coverage);
    w_agent.connect_subscriber(pred);

    pred.set_scoreboard(scbd);

    i_agent.connect_subscriber(scbd);
  endfunction

  function ncsu_component#(.T(wb_transaction)) get_wb_agent();
    return w_agent;
  endfunction

  function ncsu_component#(.T(i2c_transaction)) get_i2c_agent();
    return i_agent;
  endfunction

  virtual task run();
     w_agent.run();
     i_agent.run();
  endtask

endclass
