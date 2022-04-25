// ****************************************************************************              
// WB Transaction Class
// ****************************************************************************              
class wb_transaction extends ncsu_transaction;
  `ncsu_register_object(wb_transaction)
	
  int WB_NUM_WRITE_TESTS 					= 0						;   // Number of Write Tests Conducted
  int WB_NUM_READ_TESTS						= 0						;   // Number of Read Tests Conducted
  int WB_NUM_RW_TESTS							= 0						;   // Number of Read/Write Tests Conducted per each Test
	parameter [I2C_ADDR_WIDTH-1:0] slave_addr = 7'h11				;


	i2c_op_t 											op												;
	bit [WB_ADDR_WIDTH 	- 1:0] 		addr											;
	
	// Data Inputted/Outputted from WB Tasks
	bit [WB_DATA_WIDTH  - 1:0]		i2c_cmd_data							;
	bit [WB_ADDR_WIDTH	- 1:0]		i2c_cmd_addr							;
	bit														we_mon										;
	bit														i2c_irq										;

	// Enable to Select the Current Operation
	I2CMB_EN_t										I2CMB_EN									;


	function new(string name = "");
		super.new(name);
	endfunction

 virtual function string convert2string();
     return {super.convert2string()}; 
  endfunction

 	 
endclass
