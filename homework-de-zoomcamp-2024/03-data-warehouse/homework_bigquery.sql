/*
Create an external table using the Green Taxi Trip Records Data for 2022.
Create a table in BQ using the Green Taxi Trip Records for 2022 (do not partition or cluster this table).
*/
-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `woven-edge-412500.ny_taxi.external_green_tripdata` 
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://mage-zoomcamp-ranga-h-1/green/green_tripdata_2022-*.parquet']
);

-- Check green trip data from external_green_tripdata
SELECT *
FROM woven-edge-412500.ny_taxi.external_green_tripdata
limit 10;

-- Create a non partitioned table from external table
CREATE OR REPLACE TABLE woven-edge-412500.ny_taxi.green_tripdata_non_partitoned AS
SELECT * FROM woven-edge-412500.ny_taxi.external_green_tripdata;

-- Check green trip data green_tripdata_non_partitoned
SELECT *
FROM woven-edge-412500.ny_taxi.green_tripdata_non_partitoned
limit 10;

/*
## Question 1:
Question 1: What is count of records for the 2022 Green Taxi Data??
- 65,623,481
- 840,402
- 1,936,423
- 253,647
*/
SELECT COUNT(*) AS count_records
FROM woven-edge-412500.ny_taxi.external_green_tripdata
;
/*
results:
count_records
840402
*/

/*
## Question 2:
Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables. 
What is the estimated amount of data that will be read when this query is executed on the External Table
and the Table?

- 0 MB for the External Table and 6.41MB for the Materialized Table
- 18.82 MB for the External Table and 47.60 MB for the Materialized Table
- 0 MB for the External Table and 0MB for the Materialized Table
- 2.14 MB for the External Table and 0MB for the Materialized Table
*/
SELECT COUNT(DISTINCT PULocationID) AS distinct_count_PULocationID
FROM woven-edge-412500.ny_taxi.external_green_tripdata
;

SELECT COUNT(DISTINCT PULocationID) AS distinct_count_PULocationID
FROM woven-edge-412500.ny_taxi.green_tripdata_non_partitoned
;
results:
-- 0 MB for the External Table and 6.41MB for the Materialized Table

/*
## Question 3:
How many records have a fare_amount of 0?
- 12,488
- 128,219
- 112
- 1,622
*/
SELECT COUNT(fare_amount) AS n_zero_fair_trips
FROM woven-edge-412500.ny_taxi.green_tripdata_non_partitoned
WHERE fare_amount = 0
;
/*
Result:
n_zero_fair_trips
1622
*/

/*
## Question 4:
What is the best strategy to make an optimized table in Big Query if your query will 
always order the results by PUlocationID and filter based on lpep_pickup_datetime? 
(Create a new table with this strategy)
- Cluster on lpep_pickup_datetime Partition by PUlocationID
- Partition by lpep_pickup_datetime  Cluster on PUlocationID
- Partition by lpep_pickup_datetime and Partition by PUlocationID
- Cluster on by lpep_pickup_datetime and Cluster on PUlocationID
*/
-- Answer: Partition by lpep_pickup_datetime  Cluster on PUlocationID
-- Creating a partition and cluster table
CREATE OR REPLACE TABLE woven-edge-412500.ny_taxi.green_tripdata_partitoned_clustered
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY PUlocationID AS
SELECT * FROM woven-edge-412500.ny_taxi.external_green_tripdata;

/*
## Question 5:
Write a query to retrieve the distinct PULocationID between lpep_pickup_datetime
06/01/2022 and 06/30/2022 (inclusive)

Use the materialized table you created earlier in your from clause and note the 
estimated bytes. Now change the table in the from clause to the partitioned table 
you created for question 4 and note the estimated bytes processed. What are these values?

Choose the answer which most closely matches. 

- 22.82 MB for non-partitioned table and 647.87 MB for the partitioned table
- 12.82 MB for non-partitioned table and 1.12 MB for the partitioned table
- 5.63 MB for non-partitioned table and 0 MB for the partitioned table
- 10.31 MB for non-partitioned table and 10.31 MB for the partitioned table
*/
SELECT DISTINCT PULocationID AS distinct_PULocationID
FROM woven-edge-412500.ny_taxi.green_tripdata_non_partitoned
WHERE DATE(lpep_pickup_datetime) BETWEEN PARSE_DATE('%m/%d/%Y', '06/01/2022') 
  AND PARSE_DATE('%m/%d/%Y', '06/30/2022')
;

SELECT DISTINCT PULocationID AS distinct_PULocationID
FROM woven-edge-412500.ny_taxi.green_tripdata_partitoned_clustered
WHERE DATE(lpep_pickup_datetime) BETWEEN PARSE_DATE('%m/%d/%Y', '06/01/2022') 
  AND PARSE_DATE('%m/%d/%Y', '06/30/2022')
;
-- Answer: 12.82 MB for non-partitioned table and 1.12 MB for the partitioned table

/*
## Question 6: 
Where is the data stored in the External Table you created?

- Big Query
- GCP Bucket
- Big Table
- Container Registry

Answer: GCP Bucket

## Question 7:
It is best practice in Big Query to always cluster your data:
- True
- False

Answer: False
Depends on factors such as the size of your data, the typical query patterns, 
and the trade-offs between performance and cost.
*/

/*
## (Bonus: Not worth points) Question 8:
No Points: Write a `SELECT count(*)` query FROM the materialized table you created. 
How many bytes does it estimate will be read? Why?
*/
SELECT count(*)
FROM woven-edge-412500.ny_taxi.green_tripdata_partitoned_clustered
;

/*
Answer: This query will process 0 B when run.

Explanation:
The reason behind the estimate provided in the comment is related to how BigQuery optimizes 
query execution through its cost-based query optimizer and its storage architecture.

In BigQuery, when you execute a query, the system analyzes the query's structure and the underlying 
data to estimate the amount of data that needs to be processed to produce the result. 
This estimation is crucial for optimizing query performance and minimizing resource consumption.

BigQuery examines the metadata associated with the table woven-edge-412500.ny_taxi.green_tripdata_partitoned_clustered. 
Since you're using COUNT(*), which counts all rows, BigQuery can determine the exact number of rows without needing to 
read the actual data. This is because BigQuery maintains statistics about the table's structure, including the number of rows, 
which enables it to provide an accurate estimate of the query's processing requirements.

Therefore, the estimate "This query will process 0 B when run" indicates that BigQuery anticipates no data to be read 
from storage during the execution of the query because it can derive the count directly from its metadata. This results 
in an efficient query execution, as it avoids unnecessary data scanning and processing.
*/
