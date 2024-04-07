# Connecting to the Kafka server

import json
import time
import pandas as pd 

from kafka import KafkaProducer
import pyspark
from pyspark.sql import types
from pyspark.sql import functions as F
from pyspark.sql import SparkSession

def json_serializer(data):
    return json.dumps(data).encode('utf-8')

server = 'localhost:9092'

producer = KafkaProducer(
    bootstrap_servers=[server],
    value_serializer=json_serializer
)

producer.bootstrap_connected()


# Sending trip data to the stream

df = pd.read_csv('green_tripdata_2019-10.csv.gz')

columns = ['lpep_pickup_datetime',
'lpep_dropoff_datetime',
'PULocationID',
'DOLocationID',
'passenger_count',
'trip_distance',
'tip_amount']

df_green = df[columns]

t0 = time.time()

topic_name = 'green-trips'

for row in df_green.itertuples(index=False):
    row_dict = {col: getattr(row, col) for col in row._fields}
    # print(row_dict)
    # break

t1 = time.time()
print(f'took {(t1 - t0):.2f} seconds')

producer.flush()

t2 = time.time()
print(f'took {(t2 - t1):.2f} seconds')


# Creating the PySpark consumer

pyspark_version = pyspark.__version__
kafka_jar_package = f"org.apache.spark:spark-sql-kafka-0-10_2.12:{pyspark_version}"

spark = SparkSession \
    .builder \
    .master("local[*]") \
    .appName("GreenTripsConsumer") \
    .config("spark.jars.packages", kafka_jar_package) \
    .getOrCreate()

# connect to the stream
green_stream = spark \
    .readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", "green-trips") \
    .option("startingOffsets", "earliest") \
    .load()

schema = types.StructType() \
    .add("lpep_pickup_datetime", types.StringType()) \
    .add("lpep_dropoff_datetime", types.StringType()) \
    .add("PULocationID", types.IntegerType()) \
    .add("DOLocationID", types.IntegerType()) \
    .add("passenger_count", types.DoubleType()) \
    .add("trip_distance", types.DoubleType()) \
    .add("tip_amount", types.DoubleType())

green_stream = green_stream \
  .select(F.from_json(F.col("value").cast('STRING'), schema).alias("data")) \
  .select("data.*")

def peek(mini_batch, batch_id):
    first_row = mini_batch.take(1)

    if first_row:
        print(first_row[0])

query = green_stream.writeStream.foreachBatch(peek).start()
query.awaitTermination()

"""
TODO:

Most popular destination
Now let's finally do some streaming analytics. We will see what's the most popular destination currently based on our stream of data (which ideally we should have sent with delays like we did in workshop 2)

This is how you can do it:

Add a column "timestamp" using the current_timestamp function
Group by:
5 minutes window based on the timestamp column (F.window(col("timestamp"), "5 minutes"))
"DOLocationID"
Order by count
You can print the output to the console using this code

query = popular_destinations \
    .writeStream \
    .outputMode("complete") \
    .format("console") \
    .option("truncate", "false") \
    .start()

query.awaitTermination()

"""