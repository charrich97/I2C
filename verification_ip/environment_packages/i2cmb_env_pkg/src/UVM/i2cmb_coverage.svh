class i2cmb_coverage extends ncsu_component#(.T(wb_transaction));
  i2cmb_env_configuration     configuration;
  
  bit [WB_ADDR_WIDTH - 1:0] Valid_Address     ;

  bit                       Error_Flag        ;
  bit [WB_ADDR_WIDTH - 1:0] Error_Flag_addr   ;

  bit [WB_DATA_WIDTH - 1:0] Default_Registers ;
  bit [WB_ADDR_WIDTH - 1:0] wb_addr_reg       ;
  bit [WB_DATA_WIDTH - 1:0] wb_data_reg       ;
  bit                       wb_we_reg         ;
  bit [WB_ADDR_WIDTH - 1:0] Register_Access   ;
  bit [3:0]                 Byte_FSM          ;
  bit [3:0]                 Bit_FSM           ;

  
  //***************************************************************************
  //  Covergroup for Testing Register Block Functionality 
  //  Test Plan Section 1.
  //***************************************************************************
  covergroup Register_Block_cg();
    option.per_instance = 1;
    option.name         = get_full_name();

    //***************************************************************************
    //  Coverpoint for Testing Address Validity 
    //  Test Plan Section 1.1
    //***************************************************************************
    Valid_Address_cp                                  : coverpoint Valid_Address 
    {
      bins Valid_Address_Vals_bin = {['d0:'d3]};
    }

    //***************************************************************************
    //  Coverpoint for Testing Invalid Response 
    //  Test Plan Section 1.2
    //***************************************************************************
    Error_Flag_cp                                     : coverpoint Error_Flag
    {
      bins Error_Flag_bin           = {'b1}           iff(wb_addr_reg == CMDR_ADDR && wb_we_reg == 'b0);
    }
    
    //***************************************************************************
    //  Coverpoint for Testing Default Register Values 
    //  Test Plan Section 1.3
    //***************************************************************************
    Reset_DUT_cp                                      : coverpoint Default_Registers
    {
      bins CSR_reg_default_bin      = {CSR_reg_default_cov  };
      bins DPR_reg_default_bin      = {DPR_reg_default_cov  };
      bins CMDR_reg_default_bin     = {CMDR_reg_default_cov };
      bins FSMR_reg_default_bin     = {FSMR_reg_default_cov };
    }
    
    //***************************************************************************
    //  Coverpoint for Testing Register Access 
    //  Test Plan Section 1.4
    //***************************************************************************
    Register_Access_cp                                : coverpoint Register_Access 
    {
      bins CSR_Reg_Access_bin       = {CSR_ADDR       };
      bins DPR_Reg_Access_bin       = {DPR_ADDR       };
      bins CMDR_Reg_Access_bin      = {CMDR_ADDR      };
      bins FSMR_Reg_Access_bin      = {FSMR_ADDR      };
    }
    
    Don_Bit_cp                                        : coverpoint wb_data_reg[7]
    {
    bins Don_Bit_Enable_bin       = {'b1}           iff(wb_addr_reg == CMDR_ADDR && wb_we_reg == 'b0);
    }
  
  endgroup :  Register_Block_cg

  //***************************************************************************
  //  Covergroup for Testing I2CMB Core Operations
  //  Test Plan Section 4.
  //***************************************************************************
  covergroup I2CMB_Core_Operation_cg();
    option.per_instance = 1;
    option.name         = get_full_name();
    Write_Op_cp                             : coverpoint wb_data_reg
    {
      bins    Write_bin[32]           = {[0:31]} iff(wb_addr_reg == DPR_ADDR);
    }
    Read_Op_cp                              : coverpoint wb_data_reg
    {
      bins    Read_bin[32]            = {[100:131]} iff(wb_addr_reg == DPR_ADDR);
    }

    RW_Op_cp                                : coverpoint wb_data_reg
    {
      bins    RW_Write_bin[64]        = {[64:127]}  iff (wb_addr_reg == DPR_ADDR);
      bins    RW_Read_bin[64]         = {[63:0]}    iff(wb_addr_reg == DPR_ADDR);
    }
  endgroup : I2CMB_Core_Operation_cg  

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    Register_Block_cg       = new;
    I2CMB_Core_Operation_cg = new;
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void nb_put(T trans);
    //Register Block Signals
    Valid_Address     = trans.i2c_cmd_addr;
    Register_Access   = trans.i2c_cmd_addr;
    Default_Registers = trans.i2c_cmd_data;
    Error_Flag        = trans.i2c_cmd_data[4];
    Error_Flag_addr   = trans.i2c_cmd_addr;
    Register_Access   = trans.i2c_cmd_addr;
    
    //Byte-Level FSM Signals
    Byte_FSM          = trans.i2c_cmd_data[7:4];
  
    //Bit-Level FSM Signals
    Bit_FSM           = trans.i2c_cmd_data[3:0];

    wb_data_reg       = trans.i2c_cmd_data;
    wb_addr_reg       = trans.i2c_cmd_addr;
    wb_we_reg         = trans.we_mon;

    //Sample Cover Groups
    Register_Block_cg.sample();
    I2CMB_Core_Operation_cg.sample();
  endfunction
    
  

endclass



