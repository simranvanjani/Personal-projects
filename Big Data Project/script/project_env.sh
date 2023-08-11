#!/bin/bash


# Author: Group 4
# Created:9th May 2023
# Last Modified: 11th May 2023

# Prerequisit:
# 1) Hadoop services are running
# 2) Your home folder is there on HDFS, Hive ware house is set on hdfs to /user/hive/warehouse
# 3) Hive metastore and Hiveserver2 services are running
# 4) var.properties has been formed

# Description:
# This script is setting up the environment for the project
# this script is invoked in wrapper script

# Usage: 
# ./project_env.sh 

source ./var.properties

echo ".....Dropping all tables....."
 
beeline -u jdbc:hive2://localhost:10000/default -n hiveuser -p Hive@123 -f  $DDLPath/cleanhive.hive --hivevar dbname=$dbname

echo ".....Creating zomato_summary_log table....."

beeline -u jdbc:hive2://localhost:10000/default -n hiveuser -p Hive@123 -f $DDLPath/createLogTable.hive --hivevar dbname=$dbname

echo ".....Setting HDFS directory Structure....."

#SETTING hdfs FILE PATH
hdfs dfs -mkdir -p /user/talentum/zomato_etl_group4/{log,zomato_ext/{zomato,dim_country}}


echo ".....Copying files from zomato_raw_files to json....."

#copying json files from zomato_raw_files to json folder

cp -r /home/talentum/zomato_raw_files/file{1..3}.json $JsonPath

STATUS=$?
if [ $STATUS != "0" ]; then
 
echo ".....project set up Failed....."
exit 1

fi

echo ".....Emptying  Archive Folder....."


#deleting files in archive folder
if [ -d $ArchievePath ]; then
	 rm -f  $ArchievePath/*
fi


echo ".....Deleting Temp Folder....."



#Checking temp folder
if [ -d $localPrjPath/tmp ]; then
	rm -rf $localPrjPath/tmp
fi
