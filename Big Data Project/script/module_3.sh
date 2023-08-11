#!/bin/bash 


# Author: Group 4
# Created: 08th May 2023
# Last Modified: 11th May 2023

# Prerequisit:
# 1) Hadoop services are running
# 2) Your home folder is there on HDFS, Hive ware house is set on hdfs to /user/hive/warehouse
# 3) Hive metastore and Hiveserver2 services are running
# 4) var.properties has been formed
# 5) A project_env.sh runs successfully

# Description:
# This script is abstractig module 1 functionality of the project
# It is invoked from wrapper.sh

# Reference - Project SRS doc

# Usage: 
# ./module_1.sh 

source ./var.properties


jobstep="Module 3"


# start=`date +"%F %H:%M:%S"`

echo ".....Checking Running Instance of Application....."


if [ -f $localPrjPath/tmp/__INPROGRESS ]; then

	echo ".....Application is already running....."

	exit 1
else
	mkdir -p $localPrjPath/tmp/
	touch $localPrjPath/tmp/_INPROGRESS

fi


unset PYSPARK_DRIVER_PYTHON
unset PYSPARK_DRIVER_PYTHON_OPTS

echo ".....Application Started....."



spark-submit --master yarn --deploy-mode cluster \
--driver-java-options -Dlog4j.configuration=file:///home/talentum/spark/conf/log4j.properties.template \
--conf "spark.executor.extraJavaOptions=-Dlog4j.configuration=file:///home/talentum/spark/conf/log4j.properties.template" \
--driver-memory 2g --num-executors 2 --executor-memory 1g /home/talentum/zomato_etl/spark/py/module_3.py


if [[ $? -eq 0 ]]; then
		status="Successful"
else 
		status="Failed"
fi


echo -en "$jobid,$jobstep,'spark-submit --master yarn --deploy-mode client \
--driver-java-options -Dlog4j.configuration=file:///home/talentum/spark/conf/log4j.properties.template \
--conf "spark.executor.extraJavaOptions=-Dlog4j.configuration=file:///home/talentum/spark/conf/log4j.properties.template" \
--driver-memory 2g --num-executors 2 --executor-memory 1g /home/talentum/zomato_etl/spark/py/module_3.py
',$Start_Time,`date +\"%F %H:%M:%S\"`,$status" > $LogsPath/$logFile.log

echo ".....Uploading Logs....."



beeline -u jdbc:hive2://localhost:10000/default -n hiveuser -p Hive@123 -f $DMLPath/zomato_summary_log_dml.hive \
--hivevar 1=$logFile.log

if [ "$status" ==  "Failed" ]; then

	echo "Failed" | mail -s "Module3 Status Update" akashadusumalli@gmail.com
fi

rm -f $localPrjPath/tmp/*

echo ".....Application stopped....."

exit 0
