-- MAKE SURE YOU REPLACE woven-edge-412500 WITH THE NAME OF YOUR DATASET! 
-- Whenever you run the ALTER TABLE query, only run 5 of the ALTER TABLE statements at one time (by highlighting only 5). 
-- Otherwise BigQuery will say too many alterations to the table are being made.

-- We already have data ingested in gcs from NYC TLC website. We will load data in dwh(Bigquerry) from gcs by creating tables.
-- Note: Ideal way would be to use workflow orchestration with mage + dlt etc. for data load from gcs to dwh(Bigquerry).


-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `woven-edge-412500.ny_taxi.external_fhv_tripdata` 
OPTIONS (
  format = 'CSV',
  uris = ['gs://mage-zoomcamp-ranga-h-1/fhv/fhv_tripdata_2019-*.csv.gz']
);

-- Check fhv trip data
SELECT *
FROM woven-edge-412500.ny_taxi.external_fhv_tripdata
limit 10;

-- Create a non partitioned table from external table into `trips_data_all`
CREATE OR REPLACE TABLE woven-edge-412500.trips_data_all.fhv_tripdata AS
SELECT * FROM woven-edge-412500.ny_taxi.external_fhv_tripdata;

-- Check fhv trip data
SELECT *
FROM woven-edge-412500.trips_data_all.fhv_tripdata
limit 10;
