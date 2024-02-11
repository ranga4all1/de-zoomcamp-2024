import io
import os
import requests
import pandas as pd
from google.cloud import storage

"""
Pre-reqs: 
1. `pip install pandas pyarrow google-cloud-storage`
2. Set GOOGLE_APPLICATION_CREDENTIALS to your project/service-account key
3. Set GCP_GCS_BUCKET as your bucket or change default value of BUCKET
"""

# services = ['fhv','green','yellow']
init_url = 'https://d37ci6vzurychx.cloudfront.net/trip-data/'
# switch out the bucketname
BUCKET = os.environ.get("GCP_GCS_BUCKET", "mage-zoomcamp-ranga-h-1")


def upload_to_gcs(bucket, object_name, local_file):
    """
    Ref: https://cloud.google.com/storage/docs/uploading-objects#storage-upload-object-python
    """
    # # WORKAROUND to prevent timeout for files > 6 MB on 800 kbps upload speed.
    # # (Ref: https://github.com/googleapis/python-storage/issues/74)
    # storage.blob._MAX_MULTIPART_SIZE = 5 * 1024 * 1024  # 5 MB
    # storage.blob._DEFAULT_CHUNKSIZE = 5 * 1024 * 1024  # 5 MB

    client = storage.Client()
    bucket = client.bucket(bucket)
    blob = bucket.blob(object_name)
    blob.upload_from_filename(local_file)


def web_to_gcs(year, service):
    for i in range(12):
        
        # sets the month part of the file_name string
        month = '0'+str(i+1)
        month = month[-2:]

        # csv file_name
        file_name = f"{service}_tripdata_{year}-{month}.parquet"

        # download it using requests
        request_url = f"{init_url}{service}_tripdata_{year}-{month}.parquet"
        r = requests.get(request_url)
        if r.status_code == 200:
            local_file = f"{service}_{year}-{month}.parquet"
            with open(local_file, 'wb') as f:
                f.write(r.content)
            print(f"Downloaded: {local_file}")

            # upload it to gcs 
            upload_to_gcs(BUCKET, f"{service}/{file_name}", local_file)
            print(f"Uploaded to GCS: {service}/{file_name}")
            os.remove(local_file)  # remove the local file after uploading
        else:
            print(f"Failed to download: {request_url}")


# web_to_gcs('2019', 'green')
# web_to_gcs('2020', 'green')
web_to_gcs('2022', 'green')
# web_to_gcs('2019', 'yellow')
# web_to_gcs('2020', 'yellow')
# web_to_gcs('2019', 'fhv')
# web_to_gcs('2020', 'fhv')
