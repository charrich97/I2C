# coverage attribute -name TESTNAME -value test_name
# coverage save test_name.$Sv_Seed.ucdb
xml2ucdb -format Excel ./I2CMB_Coverage.xml ./I2CMB_Coverage.ucdb
add testbrowser ./*.ucdb
vcover merge -stats=none -strip 0 -totals I2CMB_Coverage_Merged.ucdb ./*.ucdb 
coverage open ./I2CMB_Coverage_Merged.ucdb
vcover report -detail -html -output covhtmlreport -assert -directive -cvg -code bcefst -threshL 50 -threshH 90 ./I2CMB_Coverage_Merged.ucdb
