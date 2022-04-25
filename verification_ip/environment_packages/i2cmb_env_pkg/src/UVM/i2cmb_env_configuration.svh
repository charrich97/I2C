class i2cmb_env_configuration extends ncsu_configuration;
  
  covergroup env_configuration_cg;
  endgroup

  function void sample_coverage();
    env_configuration_cg.sample();
  endfunction
  
  wb_configuration wb_agent_config;
  i2c_configuration i2c_agent_config;

  function new(string name=""); 
    super.new(name);
    env_configuration_cg  = new;
    wb_agent_config       = new("wb_agent_config");
    i2c_agent_config      = new("i2c_agent_config");
  endfunction

endclass
