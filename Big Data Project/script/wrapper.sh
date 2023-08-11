#!/bin/bash



# Author: Group 4
# Created: 10th May 2023
# Last Modified: 11th May 2023

# Prerequisit:
# 1) Hadoop services are running
# 2) Your home folder is there on HDFS, Hive ware house is set on hdfs to /user/hive/warehouse
# 3) Hive metastore and Hiveserver2 services are running
# 4) var.properties has been formed

# Description:
#This script calls all the other scripts in the project.

# Usage: 
# ./wrapper.sh [options..]
#options:
# 1 - Runs project upto module 1
# 2 - Runs project upto module 2
# 3 - Runs project upto module 3
# No argument runs the entire project 

source ./var.properties

echo ".....Setting up project environment....."

if [ -f $localPrjPath/tmp/_INPROGRESS ]; then

        echo ".....Application is already running....."

        exit 1
else

	./project_env.sh

fi

echo "Enter the number of the module to be executed:"
echo "1. Module 1"
echo "2. Module 2"
echo "3. Module 3"
echo "Press enter to run all three modules"



read inp



if [ -z "$inp" ]; then
	echo ".....Running all Modules....."
    bash module_1.sh
    bash module_2.sh
    bash module_3.sh
else
    case $inp in
	
        1) echo ".....Running 1st Module....."
 		bash module_1.sh;;
        2) echo ".....Running 2nd  Module....."
		bash module_1.sh
		bash module_2.sh;;
        3) ".....Running 3rd Module....."
		bash module_1.sh
            	bash module_2.sh
            	bash module_3.sh;;
        *) echo "Invalid input, please enter a number between 1 and 3.";;
    esac
fi
