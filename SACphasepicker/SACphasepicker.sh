#!/bin/bash
# ----------------------------------------
# A bash script to pick phases
#
# Author: Yi Luo
# Built: 2021-05-04
# ----------------------------------------

version='v1.0'

## Settings ------------------------------

# parent folder of SAC events. ["./example_data/0.raw_sac"]
source_dir="./example_data/0.raw_sac/"

# output folder. ["./example_data/2.ppk_sac/"]
output_dir="./example_data/2.ppk_sac/"

# process folder. ["./example_data/1.ppk_process/"]
proc_dir="./example_data/1.ppk_process/"

# log file. ["./example_data/sacppk_log.txt"]
log_file="./example_data/sacppk_log.txt"

# pick sac files with all three channels.[1,0]
full_chan_flag=1

# only move sac with $arrival_flag
arrival_flag="t0"

## Main ----------------------------------
echo "--- SAC Phase Picker" $version "---"
echo

export SAC_DISPLAY_COPYRIGHT=0
log_temp='temp_log_for_sac_phase_picker'

if [ ! -d $proc_dir ];then
    echo "Process folder path:" $proc_dir
    echo "Copying sac files from" $source_dir "to" $proc_dir
    cp -r $source_dir $proc_dir
else
    echo "Process folder path exists:" $proc_dir
    echo "Continue recent work..."
fi

if [ -f $log_file ];then
    echo "Log file exists. Arrival info will be added to it."
fi

if [ ! -d $output_dir ];then
    mkdir $output_dir
    echo "Output path:" $output_dir
else
    echo "Output path exists:" $output_dir
fi

echo
echo "SAC ppk hotkeys: "
echo "t(0~9)                mark a phase"
echo "n                     next sac"
echo "b                     last sac"
echo "Hold left mouse       draw a zooming in window"
echo "o                     zoom out"
echo

events=(`ls $proc_dir`)
for event in ${events[@]};do
    echo "* Processing" $event

    if [ $full_chan_flag -eq 1 ];then

# delete sac files without all three channels
        sac_list=(`ls $proc_dir/$event`)
        count_remove=0
        count_left=0
        for sac in $proc_dir/$event/*;do
            lhinfo=(`saclst kstnm f $sac`)
            count=`echo ${sac_list[@]}|grep -o ${lhinfo[1]}|wc -l`
            if [ $count -lt 3 ];then
                rm $sac
                #echo $sac "removed!"
                count_remove=$[count_remove+1]
            else
                count_left=$[count_left+1]
            fi
        done
        echo "  Left:" $count_left "  Removed:" $count_remove
# end

        sac <<EOF 1>$log_temp
r $proc_dir/$event/*
bp c 0.5 5 n 2 p 1
qdp off
ppk p 3 r m
wh
q
EOF

    else
        sac <<EOF 1>$log_temp
r $proc_dir/$event/*
bp c 0.5 5 n 2 p 1
qdp off
ppk
wh
q
EOF

    fi

    rm $log_temp
    echo "ppk done"

#    saclst t0 f $proc_dir/$event/* >> $log_file

#    mv -r $proc_dir/$event $output_dir

# only move sac with $arrival_flag
    count_remove=0
    count_left=0
    for sac in $proc_dir/$event/*;do
        lhinfo=(`saclst $arrival_flag f $sac`)
        if [ ${lhinfo[1]} == "-12345" ];then
            #echo $sac "has no" $arrival_flag "! Skip"
            count_remove=$[count_remove+1]
            continue
        else
            if [ ! -d $output_dir/$event ];then
                mkdir $output_dir/$event
            fi
            cp $sac $output_dir/$event
            count_left=$[count_left+1]
        fi
    done
    echo "  Moved:" $count_left "  Removed:" $count_remove
    rm -r $proc_dir/$event
    saclst t0 f $output_dir/$event/* >> $log_file
# end

    echo "Done!" $output_dir/$event
    echo 

done

