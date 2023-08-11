#!/bin/bash


current_date=$(date +%Y-%m-%d)

for file in $(ls $LogsPath | cut -d "-" -f 3); do

    date_diff=$((file - current_date))

    if [ $date_diff -ge 7 ]; then

        rm $dir/log_$file*
done
