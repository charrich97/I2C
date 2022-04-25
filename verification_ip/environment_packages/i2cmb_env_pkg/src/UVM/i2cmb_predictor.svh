class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));

  ncsu_component#(.T(i2c_transaction)) scoreboard;
  i2c_transaction i2c_predict;
  i2cmb_env_configuration configuration;
  i2c_transaction i2c_trans_scbd;

  i2c_op_t                  op_predict                      ;
  bit [6:0]                 addr_predict                    ;
  bit [7:0]                 read_data_predict   [$]         ;
  bit [7:0]                 write_data_predict  [$]         ;
  bit                       Start_Bit                       ;
  bit                       Address_Done                    ;
  bit                       Stop_Bit                        ;
  bit                       Data_Done                       ;
  
  function new(string name = "", ncsu_component_base  parent = null);
    super.new(name,parent);
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void set_scoreboard(ncsu_component #(i2c_transaction) scoreboard);
      this.scoreboard = scoreboard;
  endfunction

  //***************************************************************************
  //  Predicted I2C Transaction
  //***************************************************************************
  virtual function void nb_put(T trans);
    $cast(i2c_predict,ncsu_object_factory::create("i2c_transaction"));
    if(trans.i2c_cmd_addr == CMDR_ADDR && trans.i2c_cmd_data[4] == 1'b1) begin
    Start_Bit     = 0;
    Address_Done  = 0;
    Data_Done     = 0;
    Stop_Bit      = 0;
    write_data_predict.delete();
    read_data_predict.delete();
    return;
    end
    
    if(trans.i2c_cmd_addr == CMDR_ADDR && trans.i2c_cmd_data[5] == 1'b1) begin
    Start_Bit     = 0;
    Address_Done  = 0;
    Data_Done     = 0;
    Stop_Bit      = 0;
    write_data_predict.delete();
    read_data_predict.delete();
    return;
    end
    //***************************************************************************
    //  Predictor State of Stop Bit
    //***************************************************************************
    if (Data_Done == 1) begin
      if (trans.i2c_cmd_addr == CMDR_ADDR  && trans.i2c_cmd_data == CMDR_STOP)  begin
        Start_Bit     = 0;
        Address_Done  = 0;
        Data_Done     = 0;
        Stop_Bit      = 1;
        if (op_predict == WRITE) begin 
          i2c_predict.op        = op_predict;
          i2c_predict.i2c_addr  = addr_predict;
          i2c_predict.i2c_data  = write_data_predict;
          scoreboard.nb_transport(i2c_predict, i2c_trans_scbd);
          write_data_predict.delete();
        end
        else if (op_predict == READ) begin
          i2c_predict.op        = op_predict;
          i2c_predict.i2c_addr  = addr_predict;
          i2c_predict.i2c_data  = read_data_predict;
          scoreboard.nb_transport(i2c_predict, i2c_trans_scbd);
          read_data_predict.delete();
        end
      end
      else if (trans.i2c_cmd_addr == CMDR_ADDR  && trans.i2c_cmd_data == CMDR_START)  begin
        Start_Bit     = 1;
        Address_Done  = 0;
        Data_Done     = 0;
        Stop_Bit      = 0;
        if (op_predict == WRITE) begin 
          i2c_predict.op        = op_predict;
          i2c_predict.i2c_addr  = addr_predict;
          i2c_predict.i2c_data  = write_data_predict;
          scoreboard.nb_transport(i2c_predict, i2c_trans_scbd);
          write_data_predict.delete();
        end
        else if (op_predict == READ) begin
          i2c_predict.op        = op_predict;
          i2c_predict.i2c_addr  = addr_predict;
          i2c_predict.i2c_data  = read_data_predict;
          scoreboard.nb_transport(i2c_predict, i2c_trans_scbd);
          read_data_predict.delete();
        end
      end
    end

    //***************************************************************************
    //  Predictor State of Data Byte
    //***************************************************************************
    if (Address_Done == 1) begin
      if (trans.i2c_cmd_addr == DPR_ADDR) begin
        if (op_predict == WRITE) begin
          Data_Done     = 1;
          write_data_predict.push_back(trans.i2c_cmd_data);
        end
        else if(op_predict == READ) begin
          Data_Done     = 1;
          read_data_predict.push_back(trans.i2c_cmd_data);
        end
      end
    end

    //***************************************************************************
    //  Predictor State of Address and OP Bit(READ/WRITE)
    //***************************************************************************
    if (Start_Bit == 1) begin
      if(trans.i2c_cmd_addr == DPR_ADDR && trans.i2c_cmd_data == 8'h22) begin
        addr_predict            = slave_address;
        op_predict              = WRITE;
        Address_Done            = 1;
        Start_Bit               = 0;
      end
      else if(trans.i2c_cmd_addr == DPR_ADDR && trans.i2c_cmd_data == 8'h23) begin
        addr_predict            = slave_address;
        op_predict              = READ;
        Address_Done            = 1;
        Start_Bit               = 0;
      end
    end

    //***************************************************************************
    //  Predictor State of Start Bit
    //***************************************************************************
    if (!Start_Bit) begin
      if (trans.i2c_cmd_addr == CMDR_ADDR && trans.i2c_cmd_data == CMDR_START ) begin
        Start_Bit = 1;
      end
    end
  endfunction
endclass

