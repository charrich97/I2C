#!/bin/bash
##########################################################
#Run Random Transaction
##########################################################
make run_init
export GEN_TRANS_TYPE=random
export TEST_SEED=random_seed
make cli
make merge_coverage

##########################################################
#Run Directed Transaction
##########################################################
export GEN_TRANS_TYPE=directed
export TEST_NAME=directed_seed
make cli
make merge_coverage

##########################################################
#Run Additional Coverage Tests
##########################################################
export GEN_TRANS_TYPE=additional_coverage
export TEST_NAME=additional_coverage
make cli
make merge_coverage
make report_coverage
make view_coverage_results
