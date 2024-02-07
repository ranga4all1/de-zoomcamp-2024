import io
import pandas as pd
import requests
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@data_loader
def load_data_from_api(*args, **kwargs):
    """
    Template for loading data from API
    """

    # List to store dataframes for each month
    dfs = []

    # URL for green taxi data
    url_base = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2020-'
    url_suffix = '.csv.gz'

    # Define data types for taxi data
    taxi_dtypes = {
        'VendorID': 'Int64',
        'store_and_fwd_flag': 'str',
        'RatecodeID': 'Int64',
        'PULocationID': 'Int64',
        'DOLocationID': 'Int64',
        'passenger_count': 'Int64',
        'trip_distance': 'float64',
        'fare_amount': 'float64',
        'extra': 'float64',
        'mta_tax': 'float64',
        'tip_amount': 'float64',
        'tolls_amount': 'float64',
        'ehail_fee': 'float64',
        'improvement_surcharge': 'float64',
        'total_amount': 'float64',
        'payment_type': 'float64',
        'trip_type': 'float64',
        'congestion_surcharge': 'float64'
    }

    # Define columns to parse as dates for taxi data
    parse_dates_green_taxi = ['lpep_pickup_datetime', 'lpep_dropoff_datetime']

    # Load data for each month (October, November, December)
    for month in range(10, 13):
        # Construct URL for each month
        url = f"{url_base}{month:02d}{url_suffix}"
        
        # Load data for the month
        df = pd.read_csv(url, sep=',', compression='gzip', dtype=taxi_dtypes, parse_dates=parse_dates_green_taxi)
        
        # Append dataframe to the list
        dfs.append(df)

    # Concatenate dataframes for the final quarter
    final_quarter_data = pd.concat(dfs, ignore_index=True)
    
    return final_quarter_data


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
