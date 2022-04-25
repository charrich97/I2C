class i2cmb_generator extends ncsu_component#(.T(wb_transaction));

  ncsu_component #(wb_transaction)  wb_agent_gen                          ;
  ncsu_component #(i2c_transaction) i2c_agent_gen                         ;
  
  wb_transaction      							wb_trans_gen                          ;
  i2c_transaction     							i2c_trans_gen                         ;		// I2C Transaction
  wb_sequence         							wb_seq_gen     												;		// WB Directed Sequencer
  i2c_sequence        							i2c_seq_gen    												;		// I2C Directed Sequencer


  wb_random_sequence  							wb_rand_seq_gen												;		// WB Random Sequencer
  i2c_random_sequence 							i2c_rand_seq_gen											;		// I2C Random Sequencer 

  wb_coverage_sequence  							wb_cov_seq_gen												;		// WB Coverage Sequencer
  i2c_coverage_sequence 							i2c_cov_seq_gen											;		// I2C Coverage Sequencer 


  int GEN_NUM_WRITE_TESTS = 0			    																		;   //  Number of Write Tests Conducted
  int GEN_NUM_READ_TESTS	= 0			    																		;   //  Number of Read Tests Conducted
  int GEN_NUM_RW_TESTS		=	0			    																		;   //  Number of Read/Write Tests Conducted per each Test
  string        seq_name                                                  ;   //  Transaction Type
	typedef enum bit [1:0] {RANDOM	=	0, DIRECTED =	1, COVERAGE = 2} Test_Select_t							;		// 	Test Select for Directed and Random Tests Based on plusargs val
	Test_Select_t Test_Select;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name,parent);
    if ($test$plusargs("GEN_TRANS_TYPE=directed")) begin
				$display("Test Selected is Directed");
   			$cast(wb_seq_gen, ncsu_object_factory::create("wb_sequence"));
   			$cast(i2c_seq_gen, ncsu_object_factory::create("i2c_sequence"));
				Test_Select 														= DIRECTED;
    end
    else if($test$plusargs("GEN_TRANS_TYPE=random")) begin
				$display("Test Selected is Random");
   			$cast(wb_rand_seq_gen, ncsu_object_factory::create("wb_random_sequence"));
   			$cast(i2c_rand_seq_gen, ncsu_object_factory::create("i2c_random_sequence"));
				Test_Select 														= RANDOM;
    end
    else if($test$plusargs("GEN_TRANS_TYPE=additional_coverage")) begin
				$display("Test Selected is Coverage");
   			$cast(wb_cov_seq_gen, ncsu_object_factory::create("wb_coverage_sequence"));
   			$cast(i2c_cov_seq_gen, ncsu_object_factory::create("i2c_coverage_sequence"));
				Test_Select 														= COVERAGE;
    end
    else if(!$value$plusargs("GEN_TRANS_TYPE=%s", seq_name)) begin
      $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
      $fatal;
    end 
  endfunction

  virtual task run();
		if(Test_Select == DIRECTED) begin	
			wb_seq_gen.set_agent(wb_agent_gen);
			i2c_seq_gen.set_agent(i2c_agent_gen);
  		// ****************************************************************************              
  		// Directed Number of Tests
  		// ****************************************************************************              
			GEN_NUM_WRITE_TESTS										= 32												;
			GEN_NUM_READ_TESTS 										= 32												;
			GEN_NUM_RW_TESTS 	 										= 64												;

  		// ****************************************************************************              
  		// Set Equal to the Transaction Amount for WB & I2C Transactions
  		// ****************************************************************************              
			wb_seq_gen.WB_NUM_WRITE_TESTS 				=	GEN_NUM_WRITE_TESTS 			;
			wb_seq_gen.WB_NUM_READ_TESTS 					=	GEN_NUM_READ_TESTS 				;
			wb_seq_gen.WB_NUM_RW_TESTS 						=	GEN_NUM_RW_TESTS 					;
			
			i2c_seq_gen.I2C_NUM_WRITE_TESTS 			=	GEN_NUM_WRITE_TESTS 			;
			i2c_seq_gen.I2C_NUM_READ_TESTS 				=	GEN_NUM_READ_TESTS 				;
			i2c_seq_gen.I2C_NUM_RW_TESTS 					=	GEN_NUM_RW_TESTS 					;
			fork
				wb_seq_gen.run();
				i2c_seq_gen.run();
			join
		end
		if(Test_Select == RANDOM) begin
			wb_rand_seq_gen.set_agent(wb_agent_gen);
			i2c_rand_seq_gen.set_agent(i2c_agent_gen);
  		// ****************************************************************************              
  		// Random Number of Tests Constrain Between 1 and 100 Don't Want Too
  		// Long
  		// ****************************************************************************              
			GEN_NUM_WRITE_TESTS										= $urandom_range(1,100)			;
			GEN_NUM_READ_TESTS 										= $urandom_range(1,100)			;
			GEN_NUM_RW_TESTS 	 										= $urandom_range(1,100)			;
			
  		// ****************************************************************************              
  		// Set Equal to the Random Transaction Amount for WB & I2C Transactions
  		// ****************************************************************************              
			wb_rand_seq_gen.WB_NUM_WRITE_TESTS 		=	GEN_NUM_WRITE_TESTS 			;
			wb_rand_seq_gen.WB_NUM_READ_TESTS 		=	GEN_NUM_READ_TESTS 				;
			wb_rand_seq_gen.WB_NUM_RW_TESTS 			=	GEN_NUM_RW_TESTS 					;
			
			i2c_rand_seq_gen.I2C_NUM_WRITE_TESTS 	=	GEN_NUM_WRITE_TESTS 			;
			i2c_rand_seq_gen.I2C_NUM_READ_TESTS 	=	GEN_NUM_READ_TESTS 				;
			i2c_rand_seq_gen.I2C_NUM_RW_TESTS 		=	GEN_NUM_RW_TESTS 					;
			fork
				wb_rand_seq_gen.run();
				i2c_rand_seq_gen.run();
			join
		end
		if(Test_Select == COVERAGE) begin
			wb_cov_seq_gen.set_agent(wb_agent_gen);
			i2c_cov_seq_gen.set_agent(i2c_agent_gen);
			//Tests to Clean Up Coverage and Reach Unreached States
			fork
			wb_cov_seq_gen.run();
			i2c_cov_seq_gen.run();
			join_any
		end
		$finish;
  endtask

  // ****************************************************************************              
  // Set the Respective Agents
  // ****************************************************************************              
  function void set_wb_agent(ncsu_component#(wb_transaction) agent);
    this.wb_agent_gen 	= agent;
  endfunction

  function void set_i2c_agent(ncsu_component#(i2c_transaction) agent);
    this.i2c_agent_gen 	= agent;
  endfunction

endclass
