#!/bin/bash
# ----------------------------------------
# A bash script to pre-process SAC files
# Functions: rmean;rtr;taper;trans
# To run this script: bash SACpre-processor.sh
#
# Author: Yi Luo
# Built: 2020-11-20
version="v1.1"

## Settings -------------------------------

# parent folder of SAC files. ["./example_data/SAC_raw/"]
raw_sac_folder="./example_data/SAC_raw/"

# expansion of SAC files. ["",".SAC",".sac"]
# used when SAC folder has non-SAC files, e.g., response files in the same folder. 
# if not, set it empty. 
sac_expansion=""

# output folder. ["./example_data/SAC_processed/"]
# Warning: this folder will be removed if existing! 
out_sac_folder="./example_data/SAC_processed/"

# parent folder of instrument response files. ["./example_data/RESPs/"]
# will not be used if input_type isn't evalresp or polezero
response_folder="./example_data/RESPs/"

# type of input instrument: ["evalresp", "polezero", ...]
# For details see SAC_Docs/transfer
input_type="evalresp"

# type of output instrument: ["none", "vel", "acc", ...]
output_type="none"

# frequency band limits. [(0.005 0.01 15 20)]
frequency_band=(0.005 0.01 15 20)

# log file
log_file="./log_sacpp.txt"

## Main ------------------------------------------------------
##############################################################
echo "Log file for SACpre-processor" $version | tee  $log_file
Date=`date`
echo "Time:" $Date | tee -a $log_file
echo "raw sac folder:" $raw_sac_folder | tee -a $log_file
echo "output folder:" $out_sac_folder | tee -a $log_file
echo "instrument response folder:" $response_folder | tee -a $log_file
echo "input type:" $input_type | tee -a $log_file
echo "output type:" $output_type | tee -a $log_file
echo "frequency band" ${frequency_band[0]} ${frequency_band[1]} ${frequency_band[2]} ${frequency_band[3]} | tee -a $log_file
echo "  " >> $log_file
echo "----Error log------------------------------" >> $log_file

log_file_temp="./log_sacpp.temp.txt"

if [ -d $out_sac_folder ];then
rm -r $out_sac_folder
fi

mkdir $out_sac_folder
cp $raw_sac_folder/*$sac_expansion $out_sac_folder/

export SAC_DISPLAY_COPYRIGHT=0

for file in $out_sac_folder/*;do
    
    echo "   " | tee -a $log_file_temp
    echo "> SAC:" $file | tee -a $log_file_temp

    #echo "   " | tee -a $log_file

    trans_spell=""
    mul_spell=""
    
    net=`saclst knetwk f $file 2>> $log_file| awk '{print $2}'` 
    stnm=`saclst kstnm f $file | awk '{print $2}'`
    khole=`saclst khole f $file | awk '{print $2}'`
    kcmpnm=`saclst kcmpnm f $file | awk '{print $2}'`

    if [ $input_type == "evalresp" ];then
        # RESP.<NET>.<STA>.<LOCID>.<CHN>
        if [ $khole == "-12345" ];then
            khole="" # default ""
        fi
        
        resp_name=$response_folder/RESP.$net.$stnm.$khole.$kcmpnm
        trans_spell="fname "$resp_name

    elif [ $input_type == "polezero" ];then
        # SACPZ.<NET>.<STA>.<LOCID>.<CHN>
        if [ $khole == "-12345" ];then
            khole="--" # default "--"
        fi

        pz_name=$response_folder/SACPZ.$net.$stnm.$khole.$kcmpnm
        trans_spell="subtype "$pz_name
        mul_spell="mul 1.0e9"

    fi

    sac <<EOF 2>> $log_file >> $log_file_temp
r $file
rmean;rtr;taper
trans from $input_type $trans_spell to $output_type freq ${frequency_band[0]} ${frequency_band[1]} ${frequency_band[2]} ${frequency_band[3]}
$mul_spell
w over
q
EOF


done

echo "  " >> $log_file
echo "----Full log-------------------------------" >> $log_file
cat $log_file_temp >> $log_file
rm $log_file_temp

# Main end ---------------------------------------------