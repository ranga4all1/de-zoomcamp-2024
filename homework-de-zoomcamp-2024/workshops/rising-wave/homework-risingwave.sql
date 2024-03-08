-- Risingwave homework
-- Stream processing with RisingWave - To process real-time streaming data using SQL in RisingWave.

-------------------------------------

-- SELECT * FROM taxi_zone;

-- SELECT pulocationid, dolocationid, tpep_pickup_datetime, tpep_dropoff_datetime
-- FROM trip_data;

-- SELECT * FROM trip_data LIMIT 10;

-------------------------------------

psql -c "SELECT COUNT(*) FROM trip_data"
/*
Result:  count  
--------
 100000
(1 row)
*/

-------------------------------------

/*
Question 0
This question is just a warm-up to introduce dynamic filter, please attempt it before viewing its solution.
What are the dropoff taxi zones at the latest dropoff times?
*/

CREATE MATERIALIZED VIEW latest_dropoff_time AS
    WITH t AS (
        SELECT MAX(tpep_dropoff_datetime) AS latest_dropoff_time
        FROM trip_data
    )
    SELECT taxi_zone.zone as taxi_zone, latest_dropoff_time
    FROM t,
            trip_data
    JOIN taxi_zone
        ON trip_data.DOLocationID = taxi_zone.location_id
    WHERE trip_data.tpep_dropoff_datetime = t.latest_dropoff_time;


-- Alternate way
CREATE MATERIALIZED VIEW latest_dropoff_time AS
    SELECT 
        -- t.dolocationid,
        z.zone AS taxi_zone,
        t.tpep_dropoff_datetime AS latest_dropoff_time
    FROM trip_data AS t
    LEFT JOIN taxi_zone AS z
        ON t.dolocationid = z.location_id
        -- AND t.pulocationid = z.location_id
    WHERE t.tpep_dropoff_datetime = (
        SELECT 
            MAX(t2.tpep_dropoff_datetime)
        FROM trip_data AS t2
    );


SELECT * FROM latest_dropoff_time;
/*
Result:
   taxi_zone    | latest_dropoff_time 
----------------+---------------------
 Midtown Center | 2022-01-03 17:24:54
(1 row)
*/
-------------------------------------

/*
Question 1
Create a materialized view to compute the average, min and max trip time between each taxi zone.
From this MV, find the pair of taxi zones with the highest average trip time. You may need to use the dynamic filter pattern for this.
Bonus (no marks): Create an MV which can identify anomalies in the data. For example, if the average trip time between two zones is 1 minute, but the max trip time is 10 minutes and 20 minutes respectively.
*/
CREATE MATERIALIZED VIEW trip_time_stats AS
    WITH trip_time_cte AS (
        SELECT
            -- taxi_zone_pu.Zone as pickup_zone,
            -- taxi_zone_do.Zone as dropoff_zone,
            CONCAT(taxi_zone_pu.Zone, '/', taxi_zone_do.Zone) AS zone_pair,
            -- tpep_pickup_datetime,
            -- tpep_dropoff_datetime,
            tpep_dropoff_datetime - tpep_pickup_datetime AS trip_time
        FROM trip_data
        JOIN taxi_zone as taxi_zone_pu
            ON trip_data.PULocationID = taxi_zone_pu.location_id
        JOIN taxi_zone as taxi_zone_do
            ON trip_data.DOLocationID = taxi_zone_do.location_id
        )
    SELECT 
        zone_pair,
        AVG(trip_time) AS avg_trip_time,
        MIN(trip_time) AS min_trip_time,
        MAX(trip_time) AS max_trip_time
    FROM 
        trip_time_cte
    GROUP BY 
        zone_pair
;

-- verify
SELECT * FROM trip_time_stats LIMIT 10;
SELECT COUNT(*) FROM trip_time_stats;

-- find the pair of taxi zones with the highest average trip time
SELECT zone_pair, avg_trip_time
FROM trip_time_stats
WHERE avg_trip_time = (SELECT MAX(avg_trip_time) FROM trip_time_stats);
/*
Result:
        zone_pair        | avg_trip_time    
-------------------------+----------
 Yorkville East/Steinway | 23:59:33
*/

-- Bonus:
-- TO-DO:


-------------------------------------
/*
Question 2
Recreate the MV(s) in question 1, to also find the number of trips for the pair of taxi zones with the highest average trip time.
*/
-- find the number of trips for the pair of taxi zones with the highest average trip time.
WITH pair AS (
    SELECT zone_pair AS pair_htt
    FROM trip_time_stats
    WHERE avg_trip_time = (SELECT MAX(avg_trip_time) FROM trip_time_stats)
)
SELECT COUNT(zone_pair)    
FROM trip_time_stats
WHERE zone_pair = (SELECT pair_htt FROM pair);
/*
Result:
 count 
-------
     1
(1 row)
*/

-------------------------------------
/*
Question 3
From the latest pickup time to 17 hours before, what are the top 3 busiest zones in terms of number of pickups? 
For example if the latest pickup time is 2020-01-01 17:00:00, then the query should return the top 3 busiest zones 
from 2020-01-01 00:00:00 to 2020-01-01 17:00:00.

HINT: You can use dynamic filter pattern to create a filter condition based on the latest pickup time.

NOTE: For this question 17 hours was picked to ensure we have enough data to work with.
*/

SELECT
    taxi_zone.Zone AS pickup_zone,
    count(*) AS last_17_hr_pickup_cnt
FROM
    trip_data
        JOIN taxi_zone
            ON trip_data.PULocationID = taxi_zone.location_id
WHERE trip_data.tpep_pickup_datetime > ((SELECT MAX(tpep_pickup_datetime) FROM trip_data) - INTERVAL '17' HOUR)
GROUP BY
    taxi_zone.Zone
ORDER BY last_17_hr_pickup_cnt DESC
LIMIT 3;

/*
Result:
     pickup_zone     | last_17_hr_pickup_cnt 
---------------------+-----------------------
 LaGuardia Airport   |                    19
 Lincoln Square East |                    17
 JFK Airport         |                    17
(3 rows)
*/
