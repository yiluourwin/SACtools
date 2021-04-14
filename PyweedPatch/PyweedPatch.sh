#!/usr/bin/env bash
# ----------------------------------------
# Pyweed Patch
# A bash script to archive Pyweed downloaded SAC by events.
# 
# Requirement:
# A event list retrived by Jweed. 
# saclst: normally installed with SAC/IRIS
#
# Author: Yi Luo
# Built: 2021-04-14
# ----------------------------------------
# Warning: 
# The archive process is based on event latitude and longitude (without last number). 
# Events with similar lats & lons may be confused. 
# ----------------------------------------

# Pyweed SAC folder.['example_data/pyweed/']
sac_folder='example_data/pyweed/'

# Output folder.['example_data/event_archived_sac/']
output_folder='example_data/event_archived_sac/'

# Event list by Jweed.['example_data/jweed_complete.events']
ev_list_file='example_data/jweed_incomplete.events'
#ev_list_file='example_data/jweed_complete.events'

# Folder of not archived SAC files.['example_data/not_archived/']
noarch_folder='example_data/not_archived/'


# Main -----------------------------------

if [ ! -d $output_folder ];then
    mkdir $output_folder
fi

if [ -d $noarch_folder ];then
    rm -r $noarch_folder
fi
mkdir $noarch_folder

succ_count=0
fail_count=0

echo Copying SAC files...
cp $sac_folder/* $noarch_folder


echo Dealing SAC files...

for sac_file in $noarch_folder/*;do
    #echo '# ----------------------------' 
    #echo Dealing $sac_file

    lhinfo=(`saclst evla evlo f $sac_file`)

    cmpline=,${lhinfo[1]%?}.*${lhinfo[2]%?}

    matchline=`grep $cmpline $ev_list_file`

    #echo -matchline- $matchline

    flag=${matchline:0:10}
    # whether matched or not
    if [ -z $flag ];then
        echo "! No match ! $sac_file"
        echo ' Event lat & lon : ' ${lhinfo[1]%?} ${lhinfo[2]%?}
        echo ----
        fail_count=$[fail_count+1]
        continue
    fi
    
    # Output folder name for each event
    dest_str=Event_${matchline:6:4}_${matchline:11:2}_${matchline:14:2}_${matchline:17:2}_${matchline:20:2}_${matchline:23:2}
        
    dest_dir=$output_folder/$dest_str/
    if [ ! -d $dest_dir ];then
        mkdir $dest_dir
    fi
    mv $sac_file $dest_dir
    
    #echo ' Match!' $dest_dir
    succ_count=$[succ_count+1]

done

echo 'Done!  Succeed: '$succ_count'  Fail: '$fail_count


