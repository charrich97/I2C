// ****************************************************************************              
// I2C Configuration Class
// ****************************************************************************              
class i2c_configuration extends ncsu_configuration;

  covergroup i2c_configuration_cg;
  		option.per_instance = 1;
    	option.name = name;
  endgroup

  function void sample_coverage();
  	i2c_configuration_cg.sample();
  endfunction
  
  function new(string name=""); 
    super.new(name);
    i2c_configuration_cg = new;
  endfunction

  virtual function string convert2string();
     return {super.convert2string};
  endfunction

endclass
