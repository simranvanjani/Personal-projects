from pyspark.sql.functions import col, explode
import os
import logging
import time
from pyspark.sql import SparkSession


if __name__ == "__main__" :
    spark = SparkSession.builder.appName("Module 1").enableHiveSupport().master("yarn").getOrCreate()
    sc = spark.sparkContext
    
    log4jLogger = sc._jvm.org.apache.log4j
    logger = log4jLogger.LogManager.getLogger("jsontocsv")
    # Set the directory path
    dir_path = "/home/talentum/zomato_etl/source/json"

    try :

    # Get a list of all JSON files in the directory
        files = [file for file in os.listdir(dir_path) if file.endswith('.json')]
        # print(files)

        # Loop through the files
        for file_name in files:
        # Construct the file path
            file_path = f"file://{dir_path}/{file_name}"

            # Read the JSON file
            json_df = spark.read.json(file_path)
            logger.info(json_df.printSchema())
            # Select the required columns, explode, and alias
            explode_df = json_df.select(explode(col("restaurants.restaurant")).alias("clm"))
            logger.info(json_df.select(explode(col("restaurants.restaurant"))).printSchema())

            # Select the required 20 columns with the help of alias clm
            final_df = explode_df.select(
            col("clm.R.res_id"),
            col("clm.name"),
            col("clm.location.country_id"),
            col("clm.location.city"),
            col("clm.location.address"),
            col("clm.location.locality"),
            col("clm.location.locality_verbose"),
            col("clm.location.longitude"),
            col("clm.location.latitude"),
            col("clm.cuisines"),
            col("clm.average_cost_for_two"),
            col("clm.currency"),
            col("clm.has_table_booking"),
            col("clm.has_online_delivery"),
            col("clm.is_delivering_now"),
            col("clm.Switch_to_order_menu"),
            col("clm.price_range"),
            col("clm.user_rating.aggregate_rating"),
            col("clm.user_rating.rating_text"),
            col("clm.user_rating.votes")
            )
            logger.info(final_df.printSchema())
            # Convert to CSV format
            #file_path_parts = file_name.split('.')
            current_time = time.strftime("%Y-%m-%d")
            file_name_csv = f"zomato_{current_time}"
            file_path_csv = f"file:///home/talentum/zomato_etl/source/csv/{file_name_csv}"
            final_df.write.mode("append").option("delimiter","\t").csv(file_path_csv)
    except :
        print("error")

