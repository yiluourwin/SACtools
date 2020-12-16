#!/usr/bin/env bash
# ----------------------------------------
# A bash script to archive SAC files by multiple tag
# To run this script: bash SACarchiver_main.sh
#
# Author: Yi Luo
# Built: 2020-12-08
version="v1.0"

## Settings -------------------------------

# parent folders of SAC files. [("./example_data/*"),("./example_data/SAC_1/" "./example_data/SAC_2/")]
# multiple folders are supported. 
sac_folders="./example_data/SAC_raw/*"

# output folder
output_folder="./example_data/SAC_archived"

# tags, separated by space. [knetwk kstnm kcmpnm]
tags="knetwk kstnm kcmpnm"

# delimiter. [".","_"]
delimiter="."

## Main ------------------------------------------------------
##############################################################
echo "--- SACarchiver_main" $version " ---"

if [ ! -d $output_folder ];then
    mkdir $output_folder
fi


for sac_folder in $sac_folders;do
    echo "--from $sac_folder"
    for sac_file in $sac_folder/*;do
        echo Dealing $sac_file
        
        lhinfo=(`saclst $tags f $sac_file`)
        
        destination_folder=${lhinfo[1]}
        
        i_max=${#lhinfo[@]}
        #echo $i_max
        if [ $i_max -gt 2 ];then
            i=2
            #echo i=2
            while [ $i -lt $i_max ]; do
                #echo $i
                destination_folder=$destination_folder$delimiter${lhinfo[i]}
                i=$[i+1]
            done
        fi

        destination_folder=$output_folder/$destination_folder
        echo Copy to $destination_folder


        if [ ! -d $destination_folder ];then
            mkdir $destination_folder
        fi

        cp $sac_file $destination_folder

    done
done
