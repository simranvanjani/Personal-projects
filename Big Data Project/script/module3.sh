#!/bin/bash

# Author:           Group No 2
# Created Date:     08/05/2023
# Modified Date:    09/05/2023

# Usage:            bash script/module_3.sh
# Prerequisites:    HDFS, YARN, HiveMetaStore and HiveServer2 should be running
#                   And already Run the zomato_setup.sh file from home directory

# Dependencies:     1. module.properties
#                   2. conversion.py
#                   3. log_entry.hive
#                   4. zomato_env_setup.sh
#                   5. zomato_summary_log_ddl.hive

# Dependency
bash ./script/module_2.sh

# Required Variables
source ./script/module.properties

declare job_step=module_3
declare job_start_time=$date_part
declare job_id="module_3_$job_start_time"

# Utility Functions
# -------------------------------------------

# Function log_entry is used to make log entry in file and then in hive table
function log_entry(){
    echo "Logging Entry"
    echo $1>$PROJECT_PATH/logs/$log_file_name

    /home/talentum/hive/bin/beeline -u jdbc:hive2://localhost:10000/default -n hiveuser -p Hive@123 \
    -f $PROJECT_PATH/hive/dml/log_entry.hive --hivevar dbname=$dbname \
    --hivevar filepath="$PROJECT_PATH/logs/$log_file_name" \
    --hivevar tablename=$log_tablename

    end_process
}

# Function end_process will end the process by moving json files to archieve
function end_process(){
    rm $PROJECT_PATH/temp/module_3_INPROGRESS
    touch $PROJECT_PATH/temp/module_3_SUCCESS
    
    echo "Module 3 Ended"
}

# This will setup the environment for processing
# bash $PROJECT_PATH/script/zomato_env_setup.sh

# if [ $? -ne 0 ]; then
#     echo "Failed in Seting Up the Environment"
#     log_entry "$job_id,$job_step,$spark_submit_transformation,$job_start_time,$(date +'%F %H:%M:%S'),FAILURE"
#     exit 1
# fi
# echo "Environment Setup Done"

# Checking whether other modules running or not
if [ -f $PROJECT_PATH/temp/module_[0-9]_INPROGRESS ]; then
    log_entry "$job_id,$job_step,$spark_submit_transformation,$job_start_time,$(date +'%F %H:%M:%S'),FAILURE"
    exit 1
fi

# ----------------------------------------------------

# Creating module_3 status INPROGRESS in Temp Folder
touch $PROJECT_PATH/temp/module_3_INPROGRESS
echo "Module 3 INPROGRESS"

# Creating zomato_summary_log and raw_zomato table
/home/talentum/hive/bin/beeline -u jdbc:hive2://localhost:10000/$dbname -n hiveuser -p Hive@123 \
-f $PROJECT_PATH/hive/ddl/createLogTable.hive \
--hivevar dbname=$dbname --hivevar log_tablename=$log_tablename --hivevar hdfs_log_dir="$hdfs_log_dir"

if [ $? -ne 0 ]; then
    echo "Failed in LOG DDL"
    log_entry "$job_id,$job_step,$spark_submit,$job_start_time,$(date +'%F %H:%M:%S'),FAILURE"
    exit 1
fi
echo "LOG DDL Done"

# Unsetting global variables
unset PYSPARK_DRIVER_PYTHON
unset PYSPARK_DRIVER_PYTHON_OPTS

# Executing the spark application
$spark_submit_transformation

# Check for Execution of Whole Module
if [ $? -eq 0 ]; then
    echo "Module 3 Done"
    log_entry "$job_id,$job_step,$spark_submit_transformation,$job_start_time,$(date +'%F %H:%M:%S'),SUCCESS"
    exit 0
else
    echo "Module 3 Failed"
    log_entry "$job_id,$job_step,$spark_submit_transformation,$job_start_time,$(date +'%F %H:%M:%S'),FAILURE"
    exit 1
fi