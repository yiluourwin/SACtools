#!/bin/bash
# ----------------------------------------
# An example bash script to pre-process SAC files
# Modify func_sacpp for personal settings
#
# Author: Yi Luo
# Built: 2021-01-07

source ./func_sacpp

# parent folder of SAC files. ["./example_data_2/SAC_raw/"]
raw_sac_folder="./example_data_2/SAC_raw/"

# output folder. ["./example_data_2/SAC_processed/"]
# Warning: this folder will be removed if existing! 
out_sac_folder="./example_data_2/SAC_processed/"

# parent folder of instrument response files. ["./example_data_2/RESPs/"]
response_folder="./example_data_2/RESPs/"

## Main ----------------------

rm ./log_sacpp_*.txt

if [ -d $out_sac_folder ];then
rm -r $out_sac_folder
fi

mkdir $out_sac_folder
cp $raw_sac_folder/* $out_sac_folder/

# ----
func_sacpp $out_sac_folder $response_folder

# ----

# If you do not want a log
# rm ./log_sacpp_*.txt