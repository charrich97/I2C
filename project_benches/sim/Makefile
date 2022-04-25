export ECE745_PROJECT_HOME ?= $(PWD)/../..
GEN_TRANS_TYPE?=directed
TEST_SEED?=seed
TEST_NAME?=directed
###################################################################################################
# Include the Makefiles for the Verification Interfaces
###################################################################################################
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/utility_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile

###################################################################################################
# Clean Simulation Directory and Remove Work Directory
###################################################################################################
clean: 
	rm -rf work *.wlf transcript covhtmlreport *.ucdb *.log 

###################################################################################################
# Optimize the Testbench for Simulation
###################################################################################################
optimize:
	vopt +acc +cover top -o optimized_debug_top_tb

###################################################################################################
# Compile the I2CMB Core DUT
###################################################################################################
comp_I2C_MB:
	vcom -cover bcesft ../rtl/iicmb_int_pkg.vhd
	vcom -cover bcesft ../rtl/iicmb_pkg.vhd
	vcom -cover bcesft ../rtl/mbyte.vhd
	vcom -cover bcesft ../rtl/mbit.vhd
	vcom -cover bcesft ../rtl/bus_state.vhd
	vcom -cover bcesft ../rtl/filter.vhd
	vcom -cover bcesft ../rtl/conditioner.vhd
	vcom -cover bcesft ../rtl/conditioner_mux.vhd
	vcom -cover bcesft ../rtl/iicmb_m.vhd
	vcom -cover bcesft ../rtl/regblock.vhd
	vcom -cover bcesft ../rtl/wishbone.vhd
	vcom -cover bcesft ../rtl/iicmb_m_wb.vhd
###################################################################################################
# Compile the Testbench
###################################################################################################
comp_bench: comp_ncsu_pkg comp_utility_pkg comp_i2c_pkg comp_wb_pkg comp_i2cmb_env_pkg
						vlog -cover bcesft ../testbench/top.sv
###################################################################################################
# 
###################################################################################################
run_cli:
	vsim  -c -coverage  -sv_seed $(TEST_SEED) -do "set NoQuitOnFinish 1; run -a; coverage attribute -name TESTNAME -value $(GEN_TRANS_TYPE); coverage save $(GEN_TRANS_TYPE).$(TEST_SEED).ucdb; quit -f" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) +TEST_NAME=$(GEN_TRANS_TYPE) optimized_debug_top_tb 

run_gui:
	vsim  -c -coverage -sv_seed $(TEST_SEED) -do "do wave.do;set NoQuitOnFinish 1;run -a; coverage attribute -name TESTNAME -value $(GEN_TRANS_TYPE); coverage save $(GEN_TRANS_TYPE).$(TEST_SEED).ucdb; quit -f" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) +TEST_NAME=$(GEN_TRANS_TYPE) optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize
				 vlog -cover bcesft ../testbench/top.sv

cli: compile optimize run_cli

simulate:
	vsim  -coverage -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

debug: clean compile simulate

###################################################################################################
# Convert Testplan into a .ucdb Format for Reading For Questa Simulation Suite
###################################################################################################
convert_testplan:
	xml2ucdb -format Excel ./I2CMB_Coverage.xml ./I2CMB_Coverage.ucdb
	add testbrowser ./*.ucdb

###################################################################################################
# Merge Coverage into the .ucdb File
###################################################################################################
merge_coverage:
	vcover merge -stats=none -strip 0 -totals I2CMB_Coverage_Merged.ucdb ./*.ucdb 

###################################################################################################
# Make with Code Coverage
###################################################################################################
report_coverage:
	vcover report -details -html -htmldir covhtmlreport -assert -directive -cvg -code bcefst -threshL 50 -threshH 90 ./I2CMB_Coverage_Merged.ucdb

view_coverage_results:
	vsim -viewcov I2CMB_Coverage_Merged.ucdb

merge_coverage_with_test_plan: 
	./testlist.sh  

run_init: clean convert_testplan

run_all: run_init cli merge_coverage report_coverage view_coverage_results

