# Data ingestion by running Postgres and pgAdmin together

## Build docker image and verify
```
docker build -t green_taxi_ingest:v001 .
docker images
```

## Docker-Compose
- When running this command, note down network name to be used during 
data ingestion step later

```
docker-compose up -d
```
- Alternativelly, collect network name to be used during data ingestion step later
``` 
docker network ls
```
--------------------

**Note**: Optionally, to make pgAdmin configuration persistent, create a folder `data_pgadmin`. Change its permission via
```
sudo chown 5050:5050 data_pgadmin
```
and mount it to the `/var/lib/pgadmin folder` in `docker-compose.yaml`:
```
services:
  pgadmin:
    image: dpage/pgadmin4
    volumes:
      - ./data_pgadmin:/var/lib/pgadmin
    ...
```
--------------------

## Data ingestion

1. green taxi trips from September 2019:
```
URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz"

docker run -it \
  --network=01-basics_n_setup_default \
  green_taxi_ingest:v001 \
    --user=root \
    --password=root \
    --host=pgdatabase_green \
    --port=5432 \
    --db=ny_taxi \
    --table_name=green_taxi_trips \
    --url=${URL}
```
2. dataset with zones:

- Build separate docker image and verify
```
  cd zones
  docker build -t ingest_data_green_zones:v001 .
  docker images
  cd ..
```
- ingest zones data
```
  URL="https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv"

  docker run -it \
    --network=01-basics_n_setup_default \
    ingest_data_green_zones:v001 \
      --user=root \
      --password=root \
      --host=pgdatabase_green \
      --port=5432 \
      --db=ny_taxi \
      --table_name=green_zones \
      --url=${URL}
```
3. Verify ingested data in PgAdmin via http://localhost:8080

---------------------------------------------------------
---------------------------------------------------------

- optional - in the end, shut down all containers
```
docker-compose down
```