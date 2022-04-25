onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group top.sv /top/WB_ADDR_WIDTH
add wave -noupdate -group top.sv /top/WB_DATA_WIDTH
add wave -noupdate -group top.sv /top/NUM_I2C_BUSSES
add wave -noupdate -group top.sv /top/clk
add wave -noupdate -group top.sv /top/rst
add wave -noupdate -group top.sv /top/cyc
add wave -noupdate -group top.sv /top/stb
add wave -noupdate -group top.sv /top/we
add wave -noupdate -group top.sv /top/ack
add wave -noupdate -group top.sv /top/adr
add wave -noupdate -group top.sv /top/dat_wr_o
add wave -noupdate -group top.sv /top/dat_rd_i
add wave -noupdate -group top.sv /top/irq
add wave -noupdate -group top.sv /top/scl
add wave -noupdate -group top.sv /top/sda
add wave -noupdate -expand -group wb_bus /top/wb_bus/clk_i
add wave -noupdate -expand -group wb_bus /top/wb_bus/rst_i
add wave -noupdate -expand -group wb_bus /top/wb_bus/irq_i
add wave -noupdate -expand -group wb_bus /top/wb_bus/cyc_o
add wave -noupdate -expand -group wb_bus /top/wb_bus/stb_o
add wave -noupdate -expand -group wb_bus /top/wb_bus/ack_i
add wave -noupdate -expand -group wb_bus /top/wb_bus/adr_o
add wave -noupdate -expand -group wb_bus /top/wb_bus/we_o
add wave -noupdate -expand -group wb_bus /top/wb_bus/cyc_i
add wave -noupdate -expand -group wb_bus /top/wb_bus/stb_i
add wave -noupdate -expand -group wb_bus /top/wb_bus/ack_o
add wave -noupdate -expand -group wb_bus /top/wb_bus/adr_i
add wave -noupdate -expand -group wb_bus /top/wb_bus/we_i
add wave -noupdate -expand -group wb_bus /top/wb_bus/dat_o
add wave -noupdate -expand -group wb_bus /top/wb_bus/dat_i
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/scl
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/sda
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/sda_o
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/sda_i
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/SDA_EN
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/start_bit
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/stop_bit
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/start_trigger
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/stop_trigger
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/sr_addr
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/sr_write
add wave -noupdate -expand -group i2c_bus -radix decimal /top/i2c_bus/sr_read
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/Master_ACK
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/Master_NACK
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/Slave_ACK
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/Slave_NACK
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/Address_Check
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/R_W_Bit_Check
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/Data_Check
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/sr_write_mon
add wave -noupdate -expand -group i2c_bus -radix ufixed /top/i2c_bus/sr_read_mon
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/op_monitor
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/monitor_addr
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/monitor_data
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/monitor_op
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/i2c_done
add wave -noupdate -expand -group i2c_bus /top/i2c_bus/Rep_Start_Flag
add wave -noupdate /top/i2c_bus/wait_for_i2c_transfer/op
add wave -noupdate /top/i2c_bus/wait_for_i2c_transfer/write_data
add wave -noupdate /top/i2c_bus/provide_read_data/read_data
add wave -noupdate /top/i2c_bus/provide_read_data/transfer_complete
add wave -noupdate /top/i2c_bus/monitor/addr
add wave -noupdate /top/i2c_bus/monitor/op
add wave -noupdate -radix decimal /top/i2c_bus/monitor/data
add wave -noupdate -radix decimal /top/i2c_bus/Read_Data_Size
add wave -noupdate /top/i2c_bus/start_transfer
add wave -noupdate /top/i2c_bus/stop_read_transfer
add wave -noupdate /top/i2c_bus/local_write_data
add wave -noupdate /top/i2c_bus/local_read_data
add wave -noupdate /top/i2c_bus/monitor_signals
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19463905080 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 263
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {16763211990 ps} {18794046740 ps}
