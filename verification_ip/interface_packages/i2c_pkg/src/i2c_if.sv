`timescale 1ns / 10ps
import utility_pkg::*;
import i2c_pkg::*;
interface i2c_if       #(
      int I2C_ADDR_WIDTH = 7,                                
      int I2C_DATA_WIDTH = 8                                
      )
(
	input wire												scl,
	inout triand											sda
 ); 

parameter bit [6:0]									slave_address						= 7'h11	;

// ****************************************************************************              
// I2C Signals
// ****************************************************************************              
bit																	sda_o										= 1			;
triand															sda_i														;
bit																	SDA_EN									= 0			;

bit 																start_bit								= 0			;
bit 																stop_bit								= 0			;
event																start_trigger										;
event																stop_trigger										;

// ****************************************************************************              
// Tri-State Buffer Logic for I2C Serial Lines
// ****************************************************************************              
assign															sda 	= (SDA_EN == 1'b1) ? sda_o : 1'bz;
assign															sda_i = sda;

// ****************************************************************************              
// PISO/SIPO Shift Registers
// ****************************************************************************              
bit [I2C_ADDR_WIDTH-1:0] 						sr_addr													;
bit [I2C_DATA_WIDTH-1:0] 						sr_write												;
bit [I2C_DATA_WIDTH-1:0]						sr_read													;

// ****************************************************************************              
// ACK Signals
// ****************************************************************************              
bit 																Master_ACK											;
bit																	Master_NACK											;
bit																	Slave_ACK												;
bit																	Slave_NACK											;

// ****************************************************************************              
// Checking Signals
// ****************************************************************************              
bit 																Address_Check										;
bit																	R_W_Bit_Check										;
bit																	Data_Check											;

// ****************************************************************************              
// Monitor Signals
// ****************************************************************************              
bit [I2C_DATA_WIDTH-1:0] 						sr_write_mon										;
bit [I2C_DATA_WIDTH-1:0]						sr_read_mon											;
bit [I2C_DATA_WIDTH-1:0]						local_queue[$]									;
i2c_op_t														op_monitor											;
event																monitor_addr										;
event																monitor_data										;
event																monitor_op											;
event																i2c_done												;
event																monitor_signals									;
bit																	start_transfer									;

bit [I2C_DATA_WIDTH-1:0]            local_write_data[$]             ;
bit [I2C_DATA_WIDTH-1:0]            local_read_data[$]             	;

bit																	Rep_Start_Flag									;
int																	Read_Data_Size									;

// ****************************************************************************              
// Wait for Start Bit             
// ****************************************************************************   
always@(negedge sda) begin
	if (scl) begin
		start_bit 		= 1	;
		stop_bit			= 0	;
		-> start_trigger	;
	end
	else begin
		start_bit			= 0	;
		stop_bit			= 0	;
	end   
end

// ****************************************************************************              
// Wait for Stop Bit             
// ****************************************************************************   
always@(posedge sda) begin
	if (scl) begin
		start_bit 		= 0	;
		stop_bit			= 1	;
		-> stop_trigger		;
	end
	else begin
		start_bit			= 0	;
		stop_bit			= 0	;
	end   
end

// ****************************************************************************              
// Task: Read in Address From Master             
// ****************************************************************************              
task get_address;
repeat(7) begin
@(posedge scl);
start_transfer	= 1;
sr_addr 	= {sr_addr, sda_i};
end
endtask

// ****************************************************************************              
// Task: Write to Slave Device              
// ****************************************************************************              
task write_operation;
@(posedge scl);
sr_write  = {sr_write, sda_i};
@(negedge scl or start_trigger or  stop_trigger)
	if (stop_bit) begin
		start_transfer			=	0;
		-> monitor_signals;
		return; //Stop Transfer
	end
	else if (start_bit) begin
		-> monitor_signals;
		start_transfer			=	0;
		Rep_Start_Flag 			= 1;
		return;
	end
	repeat(7) begin
		@(posedge scl);
		sr_write 	= {sr_write, sda_i};
		end
endtask

// ****************************************************************************              
// Task: Send Data to Master             
// ****************************************************************************              
task read_operation;
	repeat(8) begin
		@(posedge scl);
		sda_o			= sr_read[7];
		sr_read 	= {sr_read[6:0], 1'b0};
	end
	return;
endtask

// ****************************************************************************              
// Wait for I2C Start of Transfer              
// ****************************************************************************              
task wait_for_i2c_transfer (
														output i2c_op_t	op,
														output bit [I2C_DATA_WIDTH-1:0] write_data [$]
														);
// ****************************************************************************              
// Look for 1st Start Bit and Not Reapeated Start
// ****************************************************************************   
SDA_EN = 0;
if (!Rep_Start_Flag) begin
@(start_trigger);

@(negedge scl, stop_trigger);
if(stop_bit) begin
return;
end
end

// ****************************************************************************              
// Intialize Signals for Checking
// ****************************************************************************   
Rep_Start_Flag 			= 0;
Master_ACK					= 0;
Master_NACK					= 0;
Slave_ACK						= 0;
Slave_NACK					= 0;
Address_Check				= 0;
R_W_Bit_Check				= 0;
Data_Check					= 0;

// ****************************************************************************              
// Shift in Address
// ****************************************************************************  
SDA_EN				=	0	;
get_address				;
-> monitor_addr		;

// ****************************************************************************              
// Get R/W Bit
// ****************************************************************************              
SDA_EN					=	0;
R_W_Bit_Check 	= 1;
@(posedge scl);
if (sda_i) begin
	op 					= READ;
	op_monitor 	= READ;
-> monitor_op;
end
else if (!sda_i) begin
	op 					= WRITE;
	op_monitor	= WRITE;
-> monitor_op;
end

// ****************************************************************************              
// Send ACK if Address Match Otherwise Send NACK
// ****************************************************************************              
wait (scl==0);
Address_Check	= 1		;
SDA_EN				=	1		;
if (sr_addr == slave_address) begin
	sda_o				= 1'b0;
	Slave_ACK		= 1'b1;
end
else if (sr_addr !== slave_address) begin
	sda_o				= 1'b1;
	Slave_NACK	= 1'b1;
	$error ("Slave Doesnt Recognize Address Sending NACK");
	return;
end

// ****************************************************************************              
// Release SDA Line After ACK
// ****************************************************************************              
@(negedge scl);
SDA_EN						=	0;

// ****************************************************************************              
// Shift in Data
// ****************************************************************************              
Data_Check				= 1;
Slave_ACK					= 0;
Slave_NACK				= 0;
	if(op == WRITE) begin
		while(1) begin
		write_operation;
		if (!start_transfer) begin
			return; //Stop Transfer
		end
		local_write_data.push_back(sr_write);
		sr_write_mon 		= sr_write;
		write_data			= local_write_data;
		->	monitor_data;
	
		wait(scl == 0);
		SDA_EN						= 1;
		sda_o 						= 1'b0;
		

		@(negedge scl);
		SDA_EN 						= 0;
		Slave_ACK					= 1;
		-> i2c_done;
		end
	end
	else if(op == READ) begin
		return;
	end
endtask

// ****************************************************************************              
// Provide Data for I2C Read Operation              
// ****************************************************************************              
task provide_read_data 	(
											 	 input 	bit [I2C_DATA_WIDTH-1:0] read_data[$]
//												 output bit transfer_complete
												);
bit transfer_complete															;
transfer_complete 				= 0											;
local_read_data						= read_data							;
// ****************************************************************************              
// Pop Off Data From Quene Stack
// ****************************************************************************              
while (1) begin
	Read_Data_Size 						= read_data.size()			;
	sr_read 									= read_data.pop_front()	;
	Read_Data_Size 						= read_data.size()			;
	sr_read_mon								= sr_read								;
	// ****************************************************************************              
	// Shift Out Data to Master Device
	// ****************************************************************************              
	SDA_EN 									= 1											;
	Data_Check 							= 1											;
	read_operation																	;
	-> monitor_data																	;
	
	// ****************************************************************************              
	// Check if Master ACK or NACK
	// ****************************************************************************              
	wait (scl == 0);
		SDA_EN = 0;
	
	@(posedge scl);
		if (sda_i) begin
				Master_ACK 					= 1	;
				Master_NACK 				= 0	;
		    transfer_complete		= 0	;
		    
		end
		else begin
				Master_NACK 				= 1	;
				Master_ACK 					= 0	;
				transfer_complete		= 1 ;
		end
		-> i2c_done;
	if (Read_Data_Size == 0) begin
		break;
	end
end
@(start_trigger or  stop_trigger)
	if (stop_bit) begin
		-> monitor_signals;
		start_transfer 			= 0;
		return; //Stop Transfer
	end
	else if (start_bit) begin
		-> monitor_signals;
		start_transfer 			= 0;
		Rep_Start_Flag			= 1;
		return;
	end
endtask

// ****************************************************************************              
// Return Data Observed by I2C              
// ****************************************************************************              
task monitor (
							output bit [I2C_ADDR_WIDTH-1:0] addr,
							output i2c_op_t 						    op,
							output bit [I2C_DATA_WIDTH-1:0] data[$]
							);
local_queue.delete();
@(monitor_signals);
if (op_monitor == WRITE) begin
	addr	= sr_addr;
	op		=	WRITE;
	local_queue = local_write_data;
	data	=	local_queue;
end
else if (op_monitor == READ) begin
	addr	= sr_addr;
	op		=	READ;
	local_queue = local_read_data;
	data	=	local_queue;
end
local_write_data.delete();
local_read_data.delete();
endtask

endinterface  //i2c_if
