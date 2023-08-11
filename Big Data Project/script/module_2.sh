#!/bin/bash

# Author: Group 4
# Created: 10th May 2023
# Last Modified: 11th May 2023

# Prerequisit:
# 1) Hadoop services are running
# 2) Your home folder is there on HDFS, Hive ware house is set on hdfs to /user/hive/warehouse
# 3) Hive metastore and Hiveserver2 services are running
# 4) var.properties has been formed
# 5) A project_env.sh runs successfully
# 6) Module 1 run successfully

# Description:
# This script is abstractig module 2 functionality of the project zomato_etl
# It is invoked from wrapper.sh
# 
# Reference - Project SRS doc

# Usage: 
# ./module_2.sh 

source ./var.properties

# Id=mod_2_$(date +"%Y%m%d%H%M%S")
Step=module_2
SSA="NA"
# Start_Time=$(date +%R)


# 1) Functionality - Checking running instance of the application
# ToDo 1 - Copy this functionality from module_1.sh here
if [ -d $localPrjPath/tmp/* ]; then
	echo ".....Application is running....."

		exit 1
else
		mkdir -p $localPrjPath/tmp/
		touch $localPrjPath/tmp/_INPROGRESS

fi

# 2) Functionality - Ceating an hive external table default.dim_country with location to /user/talentum/zomato_etl/zomato_ext/dim_country 
# ToDo 2 - Refere the shared ddl scripts and use the appropriate one, note you will use beeline command

echo ".....Creating External Table - dim_country....."


beeline -u jdbc:hive2://localhost:10000/default -n hiveuser -p Hive@123 -f $DDLPath/createCountry.hive \
 --hivevar dbname=$dbname

STATUS=$?
if [ $STATUS == "0" ]; then
	# 3) Functionality - 
	#	1) Ceating an hive temporary/managed table default.raw_zomato without location clause
	#	2) Ceating an hive external partition table default.zomato with location to /user/talentum/zomato_etl/zomato_ext/zomato
	# ToDo 3 - Refere the shared ddl scripts and use the appropriate one, note you will use beeline command

	echo ".....Creating Managed Table - raw_zomato....."
	echo ".....Creating External Table - Zomato....."


	beeline -u jdbc:hive2://localhost:10000/default -n hiveuser -p Hive@123 -f $DDLPath/createZomato.hive \
	--hivevar dbname=$dbname
else 
	STATUS="Failed"
	echo ".....Module 2 Failed....."
	echo "Failed in module 2" | mail -s "Module2" akashadusumalli@gmail.com
	exit 1
fi



# 4) Functionality - Loading the data into Hive table default.dim_country table from staging area (/home/talentum/proj_zomato/zomato_raw_files)
# ToDo 4 - Create and invoke a hive script dml/loadIntoCountry.hql, note you will use beeline command
STATUS=$?
if [ $STATUS == "0" ]; then
	echo ".....Loading data into dim_country....."
	beeline -u jdbc:hive2://localhost:10000/default -n hiveuser -p Hive@123 -f $DMLPath/dim_country_dml.hive --hivevar dbname=$dbname
else 
	STATUS="Failed"
	echo ".....Module 2 Failed....."
	echo "Failed in module 2" | mail -s "Module2" akashadusumalli@gmail.com
	exit 1
fi





# 5) Functionality - Loading the data from localPrjCsvPath into Hive table default.raw_zomato 
# ToDo 5 - Create and invoke a hive script dml/loadIntoRaw.hive, note you will use beeline command
STATUS=$?
if [ $STATUS == "0" ]; then
	echo ".....Loading data into raw_zomato....."

	beeline -u jdbc:hive2://localhost:10000/default -n hiveuser -p Hive@123 -f $DMLPath/raw_zomato_dml.hive \
	--hivevar dbname=$dbname
else 
	STATUS="Failed"
	echo ".....Module 2 Failed....."
	echo "Failed in module 2" | mail -s "Module2" akashadusumalli@gmail.com
	exit 1
fi



# 6) Functionality - Inserting records into partition table default.zomato by selecting records from default.raw_zomato 
# ToDo 6- Create and invoke a hive script dml/loadIntoZomato.hive, note you will use beeline command
STATUS=$?
if [ $STATUS == "0" ]; then
	echo ".....Loading data into zomato....."

	beeline -u jdbc:hive2://localhost:10000/default -n hiveuser -p Hive@123 -f $DMLPath/zomato_dml.hive \
	--hivevar dbname=$dbname
else 
	STATUS="Failed"
	echo ".....Module 2 Failed....."
	echo "Failed in module 2" | mail -s "Module2" akashadusumalli@gmail.com
	exit 1
fi



# 7) Functionality - Preparing log message
STATUS=$?
if [ $STATUS == "0" ]; then
	STATUS="Successful"
	echo ".....Module 2 run successfully....."
	# Dropping Hive table default.raw_zomato 
	# ToDo 7- Create and invoke a hive script ddl/dropRaw.hive, note you will use beeline command
	
else
	STATUS="Failed"
	echo ".....Module 2 Failed....."
	echo "Failed in module 2" | mail -s "Module2" akashadusumalli@gmail.com
fi

End_Time=$(date +"%F %H:%M:%S")	

# 8) Functionality - Adding log message into a log file on local file system
echo $jobid","$Step","$SSA","$Start_Time","$End_Time","$STATUS >> $LogsPath/$logFile.log

# 9) Loading the log file from local file system to Hive table
# Create if not exists temporary/managed table default.zomato_summary_log with location clause /user/talentum/zomato_etl/log

echo ".....Uploading Logs....."

beeline -u jdbc:hive2://localhost:10000/default -n hiveuser -p Hive@123 --hivevar dbname=default -f $DDLPath/createLogTable.hive \
 --hivevar dbname=$dbname 


# Load logfile into table default.zomato_summary_log
# ToDo 8- Create and invoke a hive script dml/loadIntoLog.hive, note you will use beeline command
beeline -u jdbc:hive2://localhost:10000/default -n hiveuser -p Hive@123 -f $DMLPath/zomato_summary_log_dml.hive \
 --hivevar dbname=$dbname --hivevar 1=$logFile.log



# 10) Delete the Application running instance
# ToDo 9 - Copy this functionality from module_1.sh here
rm -rf /home/talentum/zomato_etl/tmp
#rmdir /home/talentum/zomato_etl/tmp

echo ".....Application Stopped....."
