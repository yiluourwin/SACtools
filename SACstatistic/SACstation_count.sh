#!/usr/bin/env bash
# ----------------------------------------
# A bash script to retrive station info from SAC files
# Duplicated stations (also station with multiple locations) will not be recorded twice
# To run this script: bash SACstation_count.sh
#
# Author: Yi Luo
# Built: 2020-12-08
version="v1.0"

## Settings -------------------------------

# parent folders of SAC files. ["./example_data/*",("./example_data/SAC_1/" "./example_data/SAC_2/")]
# multiple folders are supported. 
sac_folders="./example_data/*"

# output station index. ["station_index.txt"]
out_station_index="station_index.txt"

# cover the existing output or not. [1,0]
flag_cover=1

## Main ------------------------------------------------------
##############################################################
echo "--- SACstation_count" $version " ---"

line_pointer=0

# Deal with existing index
if [ -e $out_station_index ]; then
    echo "Warning: Output file $out_station_index exists!"
    if [ $flag_cover -eq 1 ]; then
        echo "Covered!"
        echo "  # longitude latitude station"
        echo "# longitude latitude station" > $out_station_index
    else
        echo "Appended!"
        echo "  # longitude latitude station"

        mapfile -s 1 lines < $out_station_index
        i_max=${#lines[@]}
        i=0
        while (( i < i_max )) ;do
            line_temp=(${lines[i]})
            echo " " $[line_pointer+1] ${line_temp[@]}
            stlos[line_pointer]=${line_temp[0]}
            stlas[line_pointer]=${line_temp[1]}
            stnms[line_pointer]=${line_temp[2]}
            line_pointer=$[line_pointer+1]
            i=$[i+1]
        done
    fi
else
    echo "# longitude latitude station" > $out_station_index
    echo "  # longitude latitude station"
fi


#echo ${stnms[@]}

for sac_folder in $sac_folders;do
    echo "--from $sac_folder"
    for sac_file in $sac_folder/*;do
        lhinfo=(`saclst stlo stla kstnm f $sac_file`)
        stlo_temp=${lhinfo[1]}
        stla_temp=${lhinfo[2]}
        stnm_temp=${lhinfo[3]}

        flag_continue=0
        for stnm_cmp in ${stnms[@]};do
        #echo cmp $stnm_cmp == $stnm_temp
           if [ $stnm_cmp == $stnm_temp ];then
                flag_continue=1
                break
            fi
        done
#echo $flag_continue ${stnms[@]}
        if [ $flag_continue -eq 1 ];then
            continue
        fi
        echo $stlo_temp $stla_temp $stnm_temp >> $out_station_index
        
        echo " " $[line_pointer+1] $stlo_temp $stla_temp $stnm_temp

        stlos[line_pointer]=$stlo_temp
        stlas[line_pointer]=$stla_temp
        stnms[line_pointer]=$stnm_temp
        line_pointer=$[line_pointer+1]
    done
done
