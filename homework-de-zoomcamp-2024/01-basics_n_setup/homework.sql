-- Homework: 01-basics-n-setup : SQL part

/*
## Question 3. Count records 

How many taxi trips were totally made on September 18th 2019?

Tip: started and finished on 2019-09-18. 

Remember that `lpep_pickup_datetime` and `lpep_dropoff_datetime` columns are in the format timestamp (date and hour+min+sec) and not in date.

- 15767
- 15612
- 15859
- 89009
*/

SELECT
	COUNT(*) AS n_trips
FROM 
	green_taxi_trips
WHERE lpep_pickup_datetime::DATE = '2019-09-18'
	AND lpep_dropoff_datetime::DATE = '2019-09-18'
;
/*
Result:
n_trips
15612
*/
----------------------------------------------

/*
## Question 4. Largest trip for each day

Which was the pick up day with the largest trip distance
Use the pick up time for your calculations.

- 2019-09-18
- 2019-09-16
- 2019-09-26
- 2019-09-21
*/

SELECT
	lpep_pickup_datetime::DATE AS date_in_dataset
	, MAX(trip_distance) AS max_trip_distance
FROM 
	green_taxi_trips
GROUP BY lpep_pickup_datetime::DATE
ORDER BY max_trip_distance DESC
LIMIT 1
;
/*
Result:
date_in_dataset 
2019-09-26
max_trip_distance
341.64
*/
----------------------------------------------

/*
## Question 5. Three biggest pick up Boroughs

Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown

Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?
 
- "Brooklyn" "Manhattan" "Queens"
- "Bronx" "Brooklyn" "Manhattan"
- "Bronx" "Manhattan" "Queens" 
- "Brooklyn" "Queens" "Staten Island"
*/
SELECT
	CAST(t.lpep_pickup_datetime AS DATE) AS date_in_dataset
	, ROUND(SUM(t.total_amount)::numeric ,2) AS agg_total_amount
	, zpu."Borough"
FROM 
	green_taxi_trips t
	LEFT JOIN green_zones zpu
	ON t."PULocationID" = zpu."LocationID"
WHERE t.lpep_pickup_datetime::DATE = '2019-09-18'
	AND zpu."Borough" IS NOT NULL
GROUP BY t.lpep_pickup_datetime::DATE, zpu."Borough"
HAVING SUM(t.total_amount) > 50000
ORDER BY agg_total_amount DESC
LIMIT 3
;
/*
Result:
date_in_dataset	agg_total_amount	Borough
2019-09-18	    96333.24	        Brooklyn
2019-09-18	    92271.3	            Manhattan
2019-09-18	    78671.71	        Queens
*/
Alternate way to get Borough only
SELECT
	zpu."Borough"
FROM 
	green_taxi_trips t
	LEFT JOIN green_zones zpu
	ON t."PULocationID" = zpu."LocationID"
WHERE t.lpep_pickup_datetime::DATE = '2019-09-18'
	AND zpu."Borough" IS NOT NULL
GROUP BY t.lpep_pickup_datetime::DATE, zpu."Borough"
HAVING SUM(t.total_amount) > 50000
LIMIT 3
;
/*
Result:
"Brooklyn"
"Manhattan"
"Queens"
*/
----------------------------------------------

/*
## Question 6. Largest tip

For the passengers picked up in September 2019 in the zone name Astoria which was 
the drop off zone that had the largest tip?
We want the name of the zone, not the id.

Note: it's not a typo, it's `tip` , not `trip`

- Central Park
- Jamaica
- JFK Airport
- Long Island City/Queens Plaza
*/
SELECT
	EXTRACT('MONTH' FROM t.lpep_pickup_datetime) AS pickup_month
	, EXTRACT('YEAR' FROM t.lpep_pickup_datetime) AS pickup_year
	, ROUND(MAX(t.tip_amount)::numeric ,2) AS max_tip_amount
	, zpu."Zone" AS pickup_zone
	, zdo."Zone" AS dropoff_zone
FROM 
	green_taxi_trips t
	LEFT JOIN green_zones zpu
	ON t."PULocationID" = zpu."LocationID"
	LEFT JOIN green_zones zdo
	ON t."DOLocationID" = zdo."LocationID"
WHERE EXTRACT('MONTH' FROM t.lpep_pickup_datetime) = 9
	AND EXTRACT('YEAR' FROM t.lpep_pickup_datetime) = 2019
	AND zpu."Zone" = 'Astoria'
GROUP BY EXTRACT('MONTH' FROM t.lpep_pickup_datetime)
	, EXTRACT('YEAR' FROM t.lpep_pickup_datetime)
	, zpu."Zone"
	, zdo."Zone"
ORDER BY max_tip_amount DESC
LIMIT 1
;
/*
Result:
pickup_month	pickup_year	max_tip_amount	pickup_zone	dropoff_zone
9	            2019	    62.31	        Astoria	    JFK Airport
*/

----------------------------------------------
