-- SQL Refresher

SELECT 
	*
FROM 
	yellow_taxi_trips 
LIMIT 100
;

-------

SELECT COUNT(1) FROM public.yellow_taxi_trips;

-------

SELECT 
	*
FROM 
	yellow_taxi_trips t,
	zones zpu,
	zones zdo
WHERE 
	t."PULocationID" = zpu."LocationID" AND
	t."DOLocationID" = zdo."LocationID"
LIMIT 100
;

-------

SELECT 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT(zpu."Borough", ' / ', zpu."Zone") AS "pick_up_location",
	CONCAT(zdo."Borough", ' / ', zdo."Zone") AS "drop_off_location"
	
FROM 
	yellow_taxi_trips t,
	zones zpu,
	zones zdo
WHERE 
	t."PULocationID" = zpu."LocationID" AND
	t."DOLocationID" = zdo."LocationID"
LIMIT 100
;

-------

SELECT 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT(zpu."Borough", ' / ', zpu."Zone") AS "pick_up_location",
	CONCAT(zdo."Borough", ' / ', zdo."Zone") AS "drop_off_location"
FROM 
	yellow_taxi_trips t 
	JOIN zones zpu
	ON t."PULocationID" = zpu."LocationID"
	JOIN zones zdo
	ON t."DOLocationID" = zdo."LocationID"
LIMIT 100
;

-------

SELECT 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	"PULocationID",
	"DOLocationID"
FROM 
	yellow_taxi_trips t 
LIMIT 100
;

-------

SELECT 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	"PULocationID",
	"DOLocationID"
FROM 
	yellow_taxi_trips t
WHERE
	"PULocationID" IS NULL OR
	"DOLocationID" IS NULL 
LIMIT 100
;

-------

SELECT 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	"PULocationID",
	"DOLocationID"
FROM 
	yellow_taxi_trips t
WHERE
	"PULocationID" NOT IN (SELECT "LocationID" FROM zones) OR
	"DOLocationID" NOT IN (SELECT "LocationID" FROM zones)
LIMIT 100
;

-------

DELETE FROM zones WHERE "LocationID" = 142;

-------

SELECT 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	"PULocationID",
	"DOLocationID"
FROM 
	yellow_taxi_trips t
WHERE
	"PULocationID" NOT IN (SELECT "LocationID" FROM zones) OR
	"DOLocationID" NOT IN (SELECT "LocationID" FROM zones)
LIMIT 100
;

-------

SELECT 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT(zpu."Borough", ' / ', zpu."Zone") AS "pick_up_location",
	CONCAT(zdo."Borough", ' / ', zdo."Zone") AS "drop_off_location"
FROM 
	yellow_taxi_trips t 
	LEFT JOIN zones zpu
	ON t."PULocationID" = zpu."LocationID"
	LEFT JOIN zones zdo
	ON t."DOLocationID" = zdo."LocationID"
LIMIT 100
;

-------

SELECT 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	-- DATE_TRUNC('DAY', tpep_dropoff_datetime),
	CAST(tpep_dropoff_datetime AS DATE)
	total_amount
FROM 
	yellow_taxi_trips t 
LIMIT 100
;

-------

SELECT 
	CAST(tpep_dropoff_datetime AS DATE) AS "day",
	COUNT(1) AS "count"
FROM 
	yellow_taxi_trips t
GROUP BY 
	CAST(tpep_dropoff_datetime AS DATE)
ORDER BY "count" DESC
;

-------

SELECT 
	CAST(tpep_dropoff_datetime AS DATE) AS "day",
	COUNT(1) AS "count",
	MAX("total_amount") AS max_amount,
	MAX("passenger_count") AS max_passengers
FROM 
	yellow_taxi_trips t
GROUP BY 
	CAST(tpep_dropoff_datetime AS DATE)
ORDER BY "count" DESC
;

-------

SELECT 
	CAST(tpep_dropoff_datetime AS DATE) AS "day",
	"DOLocationID",
	COUNT(1) AS "count",
	MAX("total_amount") AS max_amount,
	MAX("passenger_count") AS max_passengers
FROM 
	yellow_taxi_trips t
GROUP BY 
	1, 2
ORDER BY "count" DESC
;

-------

SELECT 
	CAST(tpep_dropoff_datetime AS DATE) AS "day",
	"DOLocationID",
	COUNT(1) AS "count",
	MAX("total_amount") AS max_amount,
	MAX("passenger_count") AS max_passengers
FROM 
	yellow_taxi_trips t
GROUP BY 
	1, 2
ORDER BY 
	"day" ASC,
	"DOLocationID"  ASC
;

-------