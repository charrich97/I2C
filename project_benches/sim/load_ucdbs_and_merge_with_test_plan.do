

xml2ucdb -format Excel ./I2CMB_Coverage.xml ./I2CMB_Coverage.ucdb
add testbrowser ./*.ucdb
vcover merge -stats=none -strip 0 -totals I2CMB_Coverage_Merged.ucdb ./*.ucdb 
vcover report -details -html -htmldir covhtmlreport -assert -directive -cvg -code bcefst -threshL 50 -threshH 90 ./I2CMB_Coverage_Merged.ucdb
vsim -viewcov I2CMB_Coverage_Merged.ucdb
