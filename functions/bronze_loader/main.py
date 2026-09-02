
import json
import os
from datetime import datetime, timezone

import functions_framework
from cloudevents.http import CloudEvent
from google.cloud import bigquery
from google.cloud import storage

import google.auth



# Automatically retrieve the active Project ID from the environment credentials
PROJECT_ID = os.environ["PROJECT_ID"]
BQ_DATASET = os.environ["BQ_DATASET"]
BQ_TABLE = os.environ["BQ_TABLE"]

#_, PROJECT_ID = google.auth.default()
#BQ_DATASET = "fema_bronze"
#BQ_TABLE = "fema_bronze_table"


@functions_framework.cloud_event
def load_to_bigquery(cloud_event: CloudEvent):
    """Load a newly created GCS JSON object into BigQuery Bronze."""

    # Get information about the new GCS object
    data = cloud_event.data

    bucket_name = data["bucket"]
    object_name = data["name"]

    print(
        f"Processing new GCS object: "
        f"gs://{bucket_name}/{object_name}"
    )

    # Connect to Cloud Storage
    storage_client = storage.Client()

    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(object_name)

    # Download JSON from GCS
    json_content = blob.download_as_text()

    source_data = json.loads(json_content)

    # FEMA's response may contain a dictionary containing records.
    # We keep the original JSON structure in Bronze.
    if isinstance(source_data, dict):
        records = [source_data]
    else:
        records = source_data

    # Prepare BigQuery rows
    rows = []

    ingestion_timestamp = datetime.now(timezone.utc).isoformat()

    for record in records:
        rows.append(
            {
                "source_file": object_name,
                "ingestion_timestamp": ingestion_timestamp,
                "payload": json.dumps(record),
            }
        )

    # Connect to BigQuery
    bigquery_client = bigquery.Client()

    table_id = (
        f"{PROJECT_ID}."
        f"{BQ_DATASET}."
        f"{BQ_TABLE}"
    )

    # Insert records
    errors = bigquery_client.insert_rows_json(
        table_id,
        rows,
    )

    if errors:
        print(f"BigQuery errors: {errors}")
        raise RuntimeError(
            f"BigQuery insert failed: {errors}"
        )

    print(
        f"Successfully loaded {len(rows)} records "
        f"into {table_id}"
    )