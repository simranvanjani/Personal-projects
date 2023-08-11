from pyspark.sql import SparkSession
from pyspark.sql import functions as F

if __name__ == "__main__":
    spark = SparkSession.builder.appName("ZomatoSummary").enableHiveSupport().getOrCreate()

    spark.conf.set("spark.sql.crossJoin.enabled", "true")

    # Read data from the "default.dim_country" table
    countries = spark.read.table("default.dim_country").dropna()
    print("Countries Read")

    print(countries.show())

    # Perform transformations on the "default.zomato" table
    df = spark.read.table('default.zomato').withColumn("create_datetime", F.current_timestamp())\
        .withColumnRenamed("filedate", "p_filedate")\
        .withColumn("user_id", F.lit("Module_3"))\
        .withColumn("m_rating_colour", F.when((F.col("aggregate_rating") >= 1.9) & (F.col("aggregate_rating") <= 2.4), "Red")
                    .when((F.col("aggregate_rating") >= 2.5) & (F.col("aggregate_rating") <= 3.4), "Amber")
                    .when((F.col("aggregate_rating") >= 3.5) & (F.col("aggregate_rating") <= 3.9), "Light Green")
                    .when((F.col("aggregate_rating") >= 4.0) & (F.col("aggregate_rating") <= 4.4), "Green")
                    .when((F.col("aggregate_rating") >= 4.5) & (F.col("aggregate_rating") <= 5.0), "Gold")
                    .otherwise("Unknown")
                    )

    print("Pre Join")

    # Perform join and additional transformations
    df = df.join(F.broadcast(countries), df.country_id == countries.country_code)\
        .drop("country_code").withColumnRenamed("country", "p_country_name")\
        .withColumn("m_cuisines", F.when(F.col("p_country_name") == "India", "Indian").otherwise("World Cuisines"))

    print(df.show())

    # Write the DataFrame to a Hive table
    df.write.mode("append").saveAsTable("default.zomato_summary")

    print("Written")
    spark.stop()
